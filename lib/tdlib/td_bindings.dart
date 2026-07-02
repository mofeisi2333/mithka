//
//  td_bindings.dart
//
//  Dart FFI bindings to TDLib's `tdjson` JSON client — the four stable C entry
//  points (the Flutter equivalent of the Swift bridging header). No generated
//  headers are required; the symbols are resolved from the platform library:
//
//   • Android  → libtdjson.so   (bundled in jniLibs, opened by name)
//   • iOS      → tdjson.framework (embedded in Runner.app/Frameworks)
//
//  The returned `char*` from td_receive / td_execute is owned by tdjson's
//  thread-local storage and must NOT be freed; we copy it to a Dart string
//  immediately. Because the receive loop runs on its own isolate, each isolate
//  opens its own handle to the (process-global) library.
//

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// C signatures
typedef _CreateClientIdC = Int32 Function();
typedef _CreateClientIdDart = int Function();

typedef _SendC = Void Function(Int32 clientId, Pointer<Utf8> request);
typedef _SendDart = void Function(int clientId, Pointer<Utf8> request);

typedef _ReceiveC = Pointer<Utf8> Function(Double timeout);
typedef _ReceiveDart = Pointer<Utf8> Function(double timeout);

typedef _ExecuteC = Pointer<Utf8> Function(Pointer<Utf8> request);
typedef _ExecuteDart = Pointer<Utf8> Function(Pointer<Utf8> request);

typedef _CompactSessionC =
    Int32 Function(Pointer<Utf8> sourcePath, Pointer<Utf8> destinationPath);
typedef _CompactSessionDart =
    int Function(Pointer<Utf8> sourcePath, Pointer<Utf8> destinationPath);

typedef _LastErrorC = Pointer<Utf8> Function();
typedef _LastErrorDart = Pointer<Utf8> Function();

/// Opens the tdjson library and binds its four entry points. Safe to construct
/// in any isolate — `dlopen` reference-counts, so every isolate shares the same
/// underlying (process-global) tdjson state.
class TdBindings {
  TdBindings._(DynamicLibrary lib)
    : _createClientId = lib
          .lookupFunction<_CreateClientIdC, _CreateClientIdDart>(
            'td_create_client_id',
          ),
      _send = lib.lookupFunction<_SendC, _SendDart>('td_send'),
      _receive = lib.lookupFunction<_ReceiveC, _ReceiveDart>('td_receive'),
      _execute = lib.lookupFunction<_ExecuteC, _ExecuteDart>('td_execute'),
      _compactSession = _lookupCompactSession(lib),
      _lastError = _lookupLastError(lib);

  factory TdBindings.open() => TdBindings._(_openLibrary());

  final _CreateClientIdDart _createClientId;
  final _SendDart _send;
  final _ReceiveDart _receive;
  final _ExecuteDart _execute;
  final _CompactSessionDart? _compactSession;
  final _LastErrorDart? _lastError;

  /// Creates a fresh per-process client id.
  int createClientId() => _createClientId();

  bool get supportsCompactSessionBackup =>
      _compactSession != null && _lastError != null;

  static _CompactSessionDart? _lookupCompactSession(DynamicLibrary lib) {
    try {
      return lib.lookupFunction<_CompactSessionC, _CompactSessionDart>(
        'td_mithka_write_compact_session_binlog',
      );
    } on ArgumentError {
      return null;
    }
  }

  static _LastErrorDart? _lookupLastError(DynamicLibrary lib) {
    try {
      return lib.lookupFunction<_LastErrorC, _LastErrorDart>(
        'td_mithka_last_error',
      );
    } on ArgumentError {
      return null;
    }
  }

  static DynamicLibrary _openLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libtdjson.so');
    }
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        return DynamicLibrary.open('tdjson.framework/tdjson');
      } on ArgumentError {
        return DynamicLibrary.process();
      }
    }
    if (Platform.isWindows) return DynamicLibrary.open('tdjson.dll');
    return DynamicLibrary.open('libtdjson.so');
  }

  /// Sends a UTF-8 JSON request to a specific client (fire-and-forget).
  void send(int clientId, String request) {
    final ptr = request.toNativeUtf8();
    try {
      _send(clientId, ptr);
    } finally {
      malloc.free(ptr);
    }
  }

  /// Blocks up to [timeout] seconds for the next incoming event (any client).
  /// Returns the raw JSON string, or null on timeout. Must be called on the
  /// owning isolate's thread only.
  String? receive(double timeout) {
    final ptr = _receive(timeout);
    if (ptr == nullptr) return null;
    return ptr.toDartString();
  }

  /// Synchronous, network-free request (e.g. log level). Returns the JSON.
  String? execute(String request) {
    final reqPtr = request.toNativeUtf8();
    try {
      final out = _execute(reqPtr);
      if (out == nullptr) return null;
      return out.toDartString();
    } finally {
      malloc.free(reqPtr);
    }
  }

  void writeCompactSessionBinlog(String sourcePath, String destinationPath) {
    final compactSession = _compactSession;
    if (compactSession == null) {
      throw UnsupportedError('Compact TDLib session backup is unavailable');
    }

    final sourcePtr = sourcePath.toNativeUtf8();
    final destinationPtr = destinationPath.toNativeUtf8();
    try {
      final code = compactSession(sourcePtr, destinationPtr);
      if (code != 0) {
        final errorPtr = _lastError?.call();
        final message = errorPtr == null || errorPtr == nullptr
            ? 'Unknown compact TDLib session backup error'
            : errorPtr.toDartString();
        throw StateError(message);
      }
    } finally {
      malloc.free(sourcePtr);
      malloc.free(destinationPtr);
    }
  }
}
