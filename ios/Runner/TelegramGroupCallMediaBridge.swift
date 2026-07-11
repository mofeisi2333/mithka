import AVFoundation
import Flutter
import UIKit

#if canImport(TgVoipWebrtc)
import TgVoipWebrtc

private final class TelegramGroupCallQueue: NSObject, OngoingCallThreadLocalContextQueueWebrtc {
  private let queue = DispatchQueue(label: "ad.neko.mithka.group-call", qos: .userInitiated)
  private let key = DispatchSpecificKey<Void>()

  override init() {
    super.init()
    queue.setSpecific(key: key, value: ())
  }

  func dispatch(_ block: @escaping () -> Void) {
    queue.async(execute: block)
  }

  func dispatch(after seconds: Double, block: @escaping () -> Void) {
    queue.asyncAfter(deadline: .now() + seconds, execute: block)
  }

  func isCurrent() -> Bool {
    DispatchQueue.getSpecific(key: key) != nil
  }

  func scheduleBlock(_ block: @escaping () -> Void, after timeout: Double) -> GroupCallDisposable {
    let work = DispatchWorkItem(block: block)
    queue.asyncAfter(deadline: .now() + timeout, execute: work)
    return GroupCallDisposable { work.cancel() }
  }
}

private final class EmptyBroadcastTask: NSObject, OngoingGroupCallBroadcastPartTask {
  func cancel() {}
}

private final class EmptyMediaDescriptionTask: NSObject, OngoingGroupCallMediaChannelDescriptionTask {
  func cancel() {}
}
#endif

@MainActor
final class TelegramGroupCallMediaBridge: NSObject {
  private let channel: FlutterMethodChannel
  private var audioSessionIsActive: Bool

#if canImport(TgVoipWebrtc)
  private let contextQueue = TelegramGroupCallQueue()
  private var context: GroupCallThreadLocalContext?
  private var videoCapturer: OngoingCallThreadLocalContextVideoCapturer?
  private var audioDevice: SharedCallAudioDevice?
  private let mediaDescriptionsLock = NSLock()
  private var mediaDescriptionsBySsrc: [UInt32: OngoingGroupCallMediaChannelDescription] = [:]
#endif

  init(
    messenger: FlutterBinaryMessenger,
    registrar: FlutterApplicationRegistrar,
    audioSessionManagedBySystem: Bool
  ) {
    channel = FlutterMethodChannel(name: "mithka/call_media", binaryMessenger: messenger)
    audioSessionIsActive = !audioSessionManagedBySystem
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      Task { @MainActor in
        self?.handle(call: call, result: result)
      }
    }
    registrar.register(
      TelegramGroupVideoViewFactory(bridge: self),
      withId: "mithka/group_video_view"
    )
  }

  func setAudioSessionActive(_ active: Bool) {
    audioSessionIsActive = active
#if canImport(TgVoipWebrtc)
    context?.setManualAudioSessionIsActive(active)
    audioDevice?.setManualAudioSessionIsActive(active)
#endif
  }

  fileprivate func attachVideo(role: String, to container: UIView) {
#if canImport(TgVoipWebrtc)
    let completion: (UIView?) -> Void = { view in
      DispatchQueue.main.async {
        container.subviews.forEach { $0.removeFromSuperview() }
        guard let view else { return }
        view.frame = container.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(view)
      }
    }
    if role == "group:local" {
      videoCapturer?.makeOutgoingVideoView(false) { view, _ in completion(view) }
    } else if role.hasPrefix("group:") {
      let endpointId = String(role.dropFirst("group:".count))
      context?.makeIncomingVideoView(
        withEndpointId: endpointId,
        requestClone: false
      ) { view, _ in completion(view) }
    }
#endif
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
#if canImport(TgVoipWebrtc)
      result(true)
#else
      result(false)
#endif
    case "createGroup":
      createGroup(call: call, result: result)
    case "connectGroup":
      connectGroup(call: call, result: result)
    case "stop":
      stop()
      result(nil)
    case "setMuted":
#if canImport(TgVoipWebrtc)
      context?.setIsMuted(call.arguments as? Bool ?? false)
#endif
      result(nil)
    case "setSpeaker":
      setSpeaker(call.arguments as? Bool ?? true, result: result)
    case "setVideoEnabled":
      setVideoEnabled(call: call, result: result)
    case "switchCamera":
#if canImport(TgVoipWebrtc)
      let useFront = !(videoCapturer.map { _ in currentCameraIsFront } ?? true)
      currentCameraIsFront = useFront
      videoCapturer?.switchVideoInput(useFront ? "" : "back")
#endif
      result(nil)
    case "setRequestedVideoChannels":
      setRequestedVideoChannels(call.arguments)
      result(nil)
    case "setMediaChannelDescriptions":
      setMediaChannelDescriptions(call.arguments)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

#if canImport(TgVoipWebrtc)
  private var currentCameraIsFront = true
#endif

  private func createGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
#if canImport(TgVoipWebrtc)
    stop()
    let arguments = call.arguments as? [String: Any]
    let isVideo = arguments?["isVideo"] as? Bool ?? false
    currentCameraIsFront = true
    videoCapturer = isVideo
      ? OngoingCallThreadLocalContextVideoCapturer(deviceId: "", keepLandscape: false)
      : nil
    let device = SharedCallAudioDevice(disableRecording: false, enableSystemMute: false)
    audioDevice = device
    let logBase = (NSTemporaryDirectory() as NSString).appendingPathComponent("mithka-group-call")
    let context = GroupCallThreadLocalContext(
      queue: contextQueue,
      networkStateUpdated: { _ in },
      audioLevelsUpdated: { _ in },
      activityUpdated: { _ in },
      inputDeviceId: "",
      outputDeviceId: "",
      videoCapturer: videoCapturer,
      requestMediaChannelDescriptions: { [weak self] ssrcs, completion in
        guard let self else {
          completion([])
          return EmptyMediaDescriptionTask()
        }
        self.mediaDescriptionsLock.lock()
        let descriptions = ssrcs.compactMap {
          self.mediaDescriptionsBySsrc[$0.uint32Value]
        }
        self.mediaDescriptionsLock.unlock()
        completion(descriptions)
        return EmptyMediaDescriptionTask()
      },
      requestCurrentTime: { completion in
        completion(0)
        return EmptyBroadcastTask()
      },
      requestAudioBroadcastPart: { _, _, _ in EmptyBroadcastTask() },
      requestVideoBroadcastPart: { _, _, _, _, _ in EmptyBroadcastTask() },
      outgoingAudioBitrateKbit: 32,
      videoContentType: isVideo ? .generic : .none,
      enableNoiseSuppression: true,
      disableAudioInput: false,
      enableSystemMute: false,
      prioritizeVP8: false,
      logPath: "\(logBase).log",
      statsLogPath: "\(logBase)-stats.json",
      onMutedSpeechActivityDetected: nil,
      audioDevice: device,
      isConference: false,
      isActiveByDefault: audioSessionIsActive,
      encryptDecrypt: nil,
      useReferenceImpl: false
    )
    self.context = context
    context.setManualAudioSessionIsActive(audioSessionIsActive)
    device.setManualAudioSessionIsActive(audioSessionIsActive)
    context.emitJoinPayload { payload, ssrc in
      DispatchQueue.main.async {
        result(["audioSourceId": Int64(ssrc), "payload": payload])
      }
    }
#else
    result(
      FlutterError(
        code: "tgvoip_webrtc_missing",
        message: "This build does not contain Telegram's TgVoipWebrtc framework",
        details: nil
      )
    )
#endif
  }

  private func connectGroup(call: FlutterMethodCall, result: @escaping FlutterResult) {
#if canImport(TgVoipWebrtc)
    guard
      let arguments = call.arguments as? [String: Any],
      let payload = arguments["responsePayload"] as? String,
      let context
    else {
      result(FlutterError(code: "group_call_not_created", message: nil, details: nil))
      return
    }
    context.setConnectionMode(
      .rtc,
      keepBroadcastConnectedIfWasEnabled: false,
      isUnifiedBroadcast: false
    )
    context.setJoinResponsePayload(payload)
    result(nil)
#else
    result(FlutterError(code: "tgvoip_webrtc_missing", message: nil, details: nil))
#endif
  }

  private func setVideoEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
#if canImport(TgVoipWebrtc)
    guard let context else {
      result(FlutterError(code: "group_call_not_created", message: nil, details: nil))
      return
    }
    let arguments = call.arguments as? [String: Any]
    let enabled = arguments?["enabled"] as? Bool ?? false
    currentCameraIsFront = arguments?["front"] as? Bool ?? true
    let completion: (String, UInt32) -> Void = { payload, ssrc in
      DispatchQueue.main.async {
        result(["audioSourceId": Int64(ssrc), "payload": payload])
      }
    }
    if enabled {
      let capturer = videoCapturer
        ?? OngoingCallThreadLocalContextVideoCapturer(deviceId: "", keepLandscape: false)
      capturer.switchVideoInput(currentCameraIsFront ? "" : "back")
      videoCapturer = capturer
      context.requestVideo(capturer, completion: completion)
    } else {
      context.disableVideo { [weak self] payload, ssrc in
        DispatchQueue.main.async {
          self?.videoCapturer = nil
          result(["audioSourceId": Int64(ssrc), "payload": payload])
        }
      }
    }
#else
    result(FlutterError(code: "tgvoip_webrtc_missing", message: nil, details: nil))
#endif
  }

  private func setRequestedVideoChannels(_ rawArguments: Any?) {
#if canImport(TgVoipWebrtc)
    let rawChannels = rawArguments as? [[String: Any]] ?? []
    let channels = rawChannels.compactMap { raw -> OngoingGroupCallRequestedVideoChannel? in
      guard
        let audioSource = raw["audioSourceId"] as? NSNumber,
        let userId = raw["userId"] as? NSNumber,
        let endpointId = raw["endpointId"] as? String
      else { return nil }
      let groups: [OngoingGroupCallSsrcGroup] = (
        raw["sourceGroups"] as? [[String: Any]] ?? []
      ).compactMap { group -> OngoingGroupCallSsrcGroup? in
        guard
          let semantics = group["semantics"] as? String,
          let sourceIds = group["sourceIds"] as? [NSNumber]
        else { return nil }
        return OngoingGroupCallSsrcGroup(semantics: semantics, ssrcs: sourceIds)
      }
      return OngoingGroupCallRequestedVideoChannel(
        audioSsrc: audioSource.uint32Value,
        userId: userId.int64Value,
        endpointId: endpointId,
        ssrcGroups: groups,
        minQuality: quality(raw["minQuality"] as? String),
        maxQuality: quality(raw["maxQuality"] as? String)
      )
    }
    context?.setRequestedVideoChannels(channels)
#endif
  }

  private func setMediaChannelDescriptions(_ rawArguments: Any?) {
#if canImport(TgVoipWebrtc)
    let rawDescriptions = rawArguments as? [[String: Any]] ?? []
    var descriptions: [UInt32: OngoingGroupCallMediaChannelDescription] = [:]
    for raw in rawDescriptions {
      guard
        let audioSource = raw["audioSourceId"] as? NSNumber,
        let userId = raw["userId"] as? NSNumber
      else { continue }
      let ssrc = audioSource.uint32Value
      descriptions[ssrc] = OngoingGroupCallMediaChannelDescription(
        type: .audio,
        peerId: userId.int64Value,
        audioSsrc: ssrc,
        videoDescription: nil
      )
    }
    mediaDescriptionsLock.lock()
    mediaDescriptionsBySsrc = descriptions
    mediaDescriptionsLock.unlock()
#endif
  }

#if canImport(TgVoipWebrtc)
  private func quality(_ value: String?) -> OngoingGroupCallRequestedVideoQuality {
    switch value {
    case "medium": return .medium
    case "full": return .full
    default: return .thumbnail
    }
  }
#endif

  private func setSpeaker(_ enabled: Bool, result: @escaping FlutterResult) {
    do {
      try AVAudioSession.sharedInstance().overrideOutputAudioPort(enabled ? .speaker : .none)
      result(nil)
    } catch {
      result(FlutterError(code: "audio_route_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func stop() {
#if canImport(TgVoipWebrtc)
    context?.stop(nil)
    context = nil
    videoCapturer = nil
    audioDevice = nil
    mediaDescriptionsLock.lock()
    mediaDescriptionsBySsrc.removeAll()
    mediaDescriptionsLock.unlock()
#endif
  }
}

@MainActor
private final class TelegramGroupVideoViewFactory: NSObject, FlutterPlatformViewFactory {
  private weak var bridge: TelegramGroupCallMediaBridge?

  init(bridge: TelegramGroupCallMediaBridge) {
    self.bridge = bridge
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    let role = (args as? [String: Any])?["role"] as? String ?? ""
    return TelegramGroupVideoPlatformView(frame: frame, role: role, bridge: bridge)
  }
}

@MainActor
private final class TelegramGroupVideoPlatformView: NSObject, FlutterPlatformView {
  private let container: UIView

  init(frame: CGRect, role: String, bridge: TelegramGroupCallMediaBridge?) {
    container = UIView(frame: frame)
    container.backgroundColor = .black
    super.init()
    bridge?.attachVideo(role: role, to: container)
  }

  func view() -> UIView {
    container
  }
}
