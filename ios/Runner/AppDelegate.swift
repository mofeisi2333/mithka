import Flutter
import Security
import Sentry
import SwiftUI
import Translation
import UIKit

@main
@MainActor
@objc class AppDelegate: FlutterAppDelegate, @preconcurrency FlutterImplicitEngineDelegate {
  private var nativeTranslationBridge: AnyObject?
  private var pushChannel: FlutterMethodChannel?
  private var apnsDeviceToken: String?
  private var didRegisterFlutterPlugins = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureNativeSentryIfNeeded()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureNativeSentryIfNeeded() {
    guard !SentrySDK.isEnabled else { return }
    let info = Bundle.main.infoDictionary ?? [:]
    let encodedDsn = (info["SentryDSNEncoded"] as? String ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let dsn = (encodedDsn.removingPercentEncoding ?? encodedDsn)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard !dsn.isEmpty, !dsn.contains("$(") else { return }

    let configuredEnvironment = (info["SentryEnvironment"] as? String ?? "production")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let environment = configuredEnvironment.isEmpty || configuredEnvironment.contains("$(")
      ? "production"
      : configuredEnvironment

    SentrySDK.start { options in
      options.dsn = dsn
      options.environment = environment
      options.releaseName = Self.sentryReleaseName(info: info)
      options.sendDefaultPii = false
      options.tracesSampleRate = 0.0
      options.enableWatchdogTerminationTracking = true
    }
  }

  private static func sentryReleaseName(info: [String: Any]) -> String {
    let bundleId = info["CFBundleIdentifier"] as? String ?? "ad.neko.mithka"
    let version = info["CFBundleShortVersionString"] as? String ?? "0"
    let build = info["CFBundleVersion"] as? String ?? "0"
    return "\(bundleId)@\(version)+\(build)"
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Flutter creates the implicit engine before FlutterViewController runs it.
    // Some plugins send an initial platform message during registration, so
    // register after the engine has had a chance to launch on the main loop.
    DispatchQueue.main.async { [weak self] in
      self?.registerFlutterPluginsAndChannels(engineBridge)
    }
  }

  private func registerFlutterPluginsAndChannels(_ engineBridge: FlutterImplicitEngineBridge) {
    guard !didRegisterFlutterPlugins else { return }
    didRegisterFlutterPlugins = true
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let clipboardChannel = FlutterMethodChannel(
      name: "mithka/clipboard",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    clipboardChannel.setMethodCallHandler { call, result in
      guard call.method == "readImage" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let pasteboard = UIPasteboard.general
      if let data = pasteboard.data(forPasteboardType: "com.compuserve.gif") {
        result(["mimeType": "image/gif", "data": FlutterStandardTypedData(bytes: data)])
        return
      }
      if let data = pasteboard.data(forPasteboardType: "public.png") {
        result(["mimeType": "image/png", "data": FlutterStandardTypedData(bytes: data)])
        return
      }
      if let data = pasteboard.data(forPasteboardType: "public.jpeg") {
        result(["mimeType": "image/jpeg", "data": FlutterStandardTypedData(bytes: data)])
        return
      }
      if let image = pasteboard.image, let data = image.pngData() {
        result(["mimeType": "image/png", "data": FlutterStandardTypedData(bytes: data)])
        return
      }
      result(nil)
    }

    let fontsChannel = FlutterMethodChannel(
      name: "mithka/fonts",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    fontsChannel.setMethodCallHandler { call, result in
      if call.method == "normalizeFontFamilies" {
        let values = call.arguments as? [String] ?? []
        result(values.map { value in
          if let font = UIFont(name: value, size: UIFont.systemFontSize) {
            return font.familyName
          }
          return value
        })
        return
      }
      guard call.method == "listFonts" else {
        result(FlutterMethodNotImplemented)
        return
      }
      var names = Set<String>()
      UIFont.familyNames.forEach { family in
        names.insert(family)
      }
      result(Array(names).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
    }

    let accountBackupChannel = FlutterMethodChannel(
      name: "mithka/account_backup",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    let accountBackup = AccountSessionBackupKeychain()
    accountBackupChannel.setMethodCallHandler { call, result in
      accountBackup.handle(call: call, result: result)
    }

    let pushChannel = FlutterMethodChannel(
      name: "mithka/push",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    self.pushChannel = pushChannel
    pushChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "registerForRemoteNotifications" else {
        result(FlutterMethodNotImplemented)
        return
      }
      UIApplication.shared.registerForRemoteNotifications()
      result(self?.apnsDeviceToken)
    }

    let nativeTranslationChannel = FlutterMethodChannel(
      name: "mithka/native_translation",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    if #available(iOS 18.0, *) {
      let bridge = NativeTranslationBridge()
      nativeTranslationBridge = bridge
      bridge.attachHostIfNeeded()
      nativeTranslationChannel.setMethodCallHandler { call, result in
        if call.method == "capabilities" {
          result(["ios_system"])
          return
        }
        bridge.handle(call: call, result: result)
      }
    } else {
      nativeTranslationChannel.setMethodCallHandler { call, result in
        if call.method == "capabilities" {
          result([])
          return
        }
        guard call.method == "translate" else {
          result(FlutterMethodNotImplemented)
          return
        }
        result(
          FlutterError(
            code: "unsupported_platform",
            message: "本机翻译需要 iOS 18 或更高版本",
            details: nil
          )
        )
      }
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    apnsDeviceToken = token
    pushChannel?.invokeMethod("deviceToken", arguments: token)
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    pushChannel?.invokeMethod("registrationError", arguments: error.localizedDescription)
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}

private final class AccountSessionBackupKeychain {
  private let service: String

  init() {
    let bundleId = Bundle.main.bundleIdentifier ?? "ad.neko.mithka"
    self.service = "\(bundleId).sessionsbackup"
  }

  func handle(call: FlutterMethodCall, result: FlutterResult) {
    do {
      switch call.method {
      case "isSupported":
        result(true)
      case "saveSession":
        guard
          let args = call.arguments as? [String: Any],
          let id = args["id"] as? String,
          !id.isEmpty,
          let data = args["data"] as? FlutterStandardTypedData
        else {
          throw AccountSessionBackupError.invalidArguments
        }
        try saveSession(id: id, data: data.data)
        result(nil)
      case "getAllSessions":
        result(try getAllSessions().map { FlutterStandardTypedData(bytes: $0) })
      case "deleteSession":
        guard
          let args = call.arguments as? [String: Any],
          let id = args["id"] as? String,
          !id.isEmpty
        else {
          throw AccountSessionBackupError.invalidArguments
        }
        try deleteSession(id: id)
        result(nil)
      case "deleteAllSessions":
        try deleteAllSessions()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    } catch {
      result(
        FlutterError(
          code: "account_backup_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  private func saveSession(id: String, data: Data) throws {
    do {
      try saveSession(id: id, data: data, synchronizable: true)
    } catch AccountSessionBackupError.keychain(let status)
      where isSynchronizableUnsupported(status) {
      try saveSession(id: id, data: data, synchronizable: false)
    }
  }

  private func saveSession(id: String, data: Data, synchronizable: Bool) throws {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: id,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
    ]
    if synchronizable {
      query[kSecAttrSynchronizable as String] = true
    }

    let status = SecItemAdd(query as CFDictionary, nil)
    if status == errSecDuplicateItem {
      var updateQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: id
      ]
      if synchronizable {
        updateQuery[kSecAttrSynchronizable as String] = true
      }
      let updateStatus = SecItemUpdate(
        updateQuery as CFDictionary,
        [
          kSecValueData as String: data,
          kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ] as CFDictionary
      )
      guard updateStatus == errSecSuccess else {
        throw AccountSessionBackupError.keychain(updateStatus)
      }
    } else if status != errSecSuccess {
      throw AccountSessionBackupError.keychain(status)
    }
  }

  private func getAllSessions() throws -> [Data] {
    do {
      return try getAllSessions(synchronizable: kSecAttrSynchronizableAny)
    } catch AccountSessionBackupError.keychain(let status)
      where isSynchronizableUnsupported(status) {
      return try getAllSessions(synchronizable: nil)
    }
  }

  private func getAllSessions(synchronizable: CFString?) throws -> [Data] {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitAll
    ]
    if let synchronizable {
      query[kSecAttrSynchronizable as String] = synchronizable
    }
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecItemNotFound {
      return []
    }
    guard status == errSecSuccess else {
      throw AccountSessionBackupError.keychain(status)
    }
    return result as? [Data] ?? []
  }

  private func deleteSession(id: String) throws {
    do {
      try deleteSession(id: id, synchronizable: kSecAttrSynchronizableAny)
    } catch AccountSessionBackupError.keychain(let status)
      where isSynchronizableUnsupported(status) {
      try deleteSession(id: id, synchronizable: nil)
    }
  }

  private func deleteSession(id: String, synchronizable: CFString?) throws {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: id
    ]
    if let synchronizable {
      query[kSecAttrSynchronizable as String] = synchronizable
    }
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw AccountSessionBackupError.keychain(status)
    }
  }

  private func deleteAllSessions() throws {
    do {
      try deleteAllSessions(synchronizable: kSecAttrSynchronizableAny)
    } catch AccountSessionBackupError.keychain(let status)
      where isSynchronizableUnsupported(status) {
      try deleteAllSessions(synchronizable: nil)
    }
  }

  private func deleteAllSessions(synchronizable: CFString?) throws {
    var query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service
    ]
    if let synchronizable {
      query[kSecAttrSynchronizable as String] = synchronizable
    }
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw AccountSessionBackupError.keychain(status)
    }
  }

  private func isSynchronizableUnsupported(_ status: OSStatus) -> Bool {
    status == errSecNotAvailable || status == errSecMissingEntitlement || status == errSecParam
  }
}

private enum AccountSessionBackupError: LocalizedError {
  case invalidArguments
  case keychain(OSStatus)

  var errorDescription: String? {
    switch self {
    case .invalidArguments:
      return "Invalid account backup arguments"
    case let .keychain(status):
      return "Keychain error \(status)"
    }
  }
}

@available(iOS 18.0, *)
@MainActor
private final class NativeTranslationBridge {
  private let coordinator = NativeTranslationCoordinator()
  private var hostController: UIHostingController<NativeTranslationHostView>?

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "translate" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let text = args["text"] as? String,
      let targetLanguageCode = args["targetLanguageCode"] as? String,
      !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      !targetLanguageCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "缺少翻译文本或目标语言",
          details: nil
        )
      )
      return
    }

    attachHostIfNeeded()
    guard hostController != nil else {
      result(
        FlutterError(
          code: "translator_unavailable",
          message: "本机翻译暂不可用",
          details: nil
        )
      )
      return
    }

    coordinator.enqueue(
      text: text,
      sourceLanguageCode: args["sourceLanguageCode"] as? String,
      targetLanguageCode: targetLanguageCode,
      result: result
    )
  }

  func attachHostIfNeeded() {
    guard hostController == nil else { return }
    guard let root = Self.rootViewController() else { return }
    let host = UIHostingController(
      rootView: NativeTranslationHostView(coordinator: coordinator)
    )
    host.view.isHidden = true
    host.view.backgroundColor = .clear
    host.view.isUserInteractionEnabled = false
    root.addChild(host)
    root.view.addSubview(host.view)
    host.view.frame = .zero
    host.didMove(toParent: root)
    hostController = host
  }

  private static func rootViewController() -> UIViewController? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }?
      .rootViewController
  }
}

@available(iOS 18.0, *)
private struct NativeTranslationHostView: View {
  @ObservedObject var coordinator: NativeTranslationCoordinator

  var body: some View {
    Color.clear
      .frame(width: 0, height: 0)
      .translationTask(coordinator.configuration) { session in
        await coordinator.perform(session: session)
      }
  }
}

@available(iOS 18.0, *)
@MainActor
private final class NativeTranslationCoordinator: ObservableObject {
  @Published var configuration: TranslationSession.Configuration?

  private var queue: [NativeTranslationRequest] = []
  private var activeRequestId: UUID?
  private var configurationSourceKey: String?
  private var configurationTargetKey: String?
  private var timeoutTask: Task<Void, Never>?

  func enqueue(
    text: String,
    sourceLanguageCode: String?,
    targetLanguageCode: String,
    result: @escaping FlutterResult
  ) {
    queue.append(
      NativeTranslationRequest(
        text: text,
        sourceLanguageCode: sourceLanguageCode,
        targetLanguageCode: targetLanguageCode,
        result: result
      )
    )
    startNextIfNeeded()
  }

  func perform(session: TranslationSession) async {
    guard
      let activeRequestId,
      let request = queue.first(where: { $0.id == activeRequestId })
    else { return }

    do {
      let response = try await session.translate(request.text)
      guard self.activeRequestId == activeRequestId else { return }
      request.result(response.targetText)
    } catch {
      guard self.activeRequestId == activeRequestId else { return }
      request.result(
        FlutterError(
          code: "translation_failed",
          message: error.localizedDescription,
          details: nil
        )
      )
    }

    finishActiveRequest(activeRequestId)
  }

  private func startNextIfNeeded() {
    guard activeRequestId == nil, let request = queue.first else { return }
    let sourceKey = Self.normalizedLanguageKey(for: request.sourceLanguageCode)
    guard
      let targetKey = Self.normalizedLanguageKey(for: request.targetLanguageCode),
      let target = Self.localeLanguage(for: targetKey)
    else {
      request.result(
        FlutterError(
          code: "unsupported_language",
          message: "不支持目标语言 \(request.targetLanguageCode)",
          details: nil
        )
      )
      queue.removeFirst()
      startNextIfNeeded()
      return
    }

    activeRequestId = request.id
    startTimeout(for: request.id)

    if configuration == nil ||
      configurationSourceKey != sourceKey ||
      configurationTargetKey != targetKey
    {
      configuration = TranslationSession.Configuration(
        source: Self.localeLanguage(for: sourceKey),
        target: target
      )
      configurationSourceKey = sourceKey
      configurationTargetKey = targetKey
    } else {
      configuration?.invalidate()
    }
  }

  private func startTimeout(for requestId: UUID) {
    timeoutTask?.cancel()
    timeoutTask = Task { @MainActor in
      try? await Task.sleep(nanoseconds: 55_000_000_000)
      guard self.activeRequestId == requestId,
        let request = self.queue.first(where: { $0.id == requestId })
      else { return }
      request.result(
        FlutterError(
          code: "translation_timeout",
          message: "本机翻译已取消或超时",
          details: nil
        )
      )
      self.finishActiveRequest(requestId)
    }
  }

  private func finishActiveRequest(_ requestId: UUID) {
    timeoutTask?.cancel()
    timeoutTask = nil
    queue.removeAll { $0.id == requestId }
    if activeRequestId == requestId {
      activeRequestId = nil
    }
    if !queue.isEmpty {
      Task { @MainActor in
        self.startNextIfNeeded()
      }
    }
  }

  private static func localeLanguage(for code: String?) -> Locale.Language? {
    guard let normalized = normalizedLanguageKey(for: code) else { return nil }
    return Locale.Language(identifier: normalized)
  }

  private static func normalizedLanguageKey(for code: String?) -> String? {
    guard
      let code,
      !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else { return nil }
    let normalized = code
      .replacingOccurrences(of: "_", with: "-")
      .lowercased()
    if normalized == "auto" || normalized == "autodetect" {
      return nil
    }
    if normalized == "zh" || normalized == "zh-hans" || normalized == "zh-cn" {
      return "zh-Hans"
    }
    if normalized == "zh-hant" || normalized == "zh-tw" || normalized == "zh-hk" {
      return "zh-Hant"
    }
    return normalized.components(separatedBy: "-").first ?? normalized
  }
}

private struct NativeTranslationRequest {
  let id = UUID()
  let text: String
  let sourceLanguageCode: String?
  let targetLanguageCode: String
  let result: FlutterResult
}
