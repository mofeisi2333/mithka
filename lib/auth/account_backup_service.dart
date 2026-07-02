import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tdlib/json_helpers.dart';
import '../tdlib/td_client.dart';
import '../tdlib/td_models.dart';

class AccountSessionBackup {
  const AccountSessionBackup({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
    required this.tdBinlog,
    this.phone,
    this.userId,
  });

  final String id;
  final String name;
  final String? phone;
  final int? userId;
  final DateTime createdAt;
  final int sizeBytes;
  final Uint8List tdBinlog;

  String get displayName => name.trim().isEmpty ? id : name;
}

class AccountBackupService {
  AccountBackupService._();
  static final AccountBackupService shared = AccountBackupService._();

  static const _channel = MethodChannel('mithka/account_backup');
  static const _format = 'mithka.tdlib.session.v1';
  static const _binaryFormat = 'mithka.tdlib.session.v2';
  static const _enabledKey = 'mithka.accountBackup.enabled';
  static final List<int> _binaryMagic = ascii.encode('MITHKA_TDSESSION2\n');
  static const _fileName = 'td.binlog';
  final Set<int> _inFlightAutoBackups = {};

  Future<bool> get isSupported async {
    if (!Platform.isIOS) return false;
    return await _channel.invokeMethod<bool>('isSupported') ?? false;
  }

  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (!value) {
      await deleteAll();
    }
  }

  Future<void> backupActiveAccountIfEnabled() async {
    if (!await isEnabled) return;
    if (!await isSupported) return;

    final slot = TdClient.shared.activeSlot;
    if (!_inFlightAutoBackups.add(slot)) return;
    try {
      await backupActiveAccount();
    } catch (error) {
      stderr.writeln('☁️ [Mithka] account backup skipped: $error');
    } finally {
      _inFlightAutoBackups.remove(slot);
    }
  }

  Future<List<AccountSessionBackup>> listBackups() async {
    if (!await isSupported) return const [];
    final rawItems = await _channel.invokeListMethod<Object?>('getAllSessions');
    final backups = <AccountSessionBackup>[];
    for (final raw in rawItems ?? const []) {
      final data = raw is Uint8List ? raw : null;
      if (data == null) continue;
      final backup = _decode(data);
      if (backup != null) backups.add(backup);
    }
    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  Future<AccountSessionBackup> backupActiveAccount() async {
    if (!await isSupported) {
      throw UnsupportedError('Account session backup is only available on iOS');
    }
    final slot = TdClient.shared.activeSlot;
    final sessionExport = await TdClient.shared.exportSessionBackupForSlot(
      slot,
    );
    final tdBinlog = sessionExport.bytes;
    if (tdBinlog.isEmpty) {
      throw StateError('TDLib session file is empty');
    }

    final me = await TdClient.shared.query({'@type': 'getMe'});
    final userId = me.int64('id');
    final name = TDParse.userName(me);
    final phone = TDParse.formatPhone(me.str('phone_number'));
    final id = userId?.toString() ?? 'slot-$slot';
    final createdAt = DateTime.now().toUtc();
    final header = <String, Object?>{
      'format': _binaryFormat,
      'id': id,
      'slot': slot,
      'userId': userId,
      'name': name,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'fileName': _fileName,
      'compact': sessionExport.isCompact,
    };
    final data = _encodeBinaryBackup(header, tdBinlog);
    await _channel.invokeMethod<void>('saveSession', {'id': id, 'data': data});
    return AccountSessionBackup(
      id: id,
      name: name,
      phone: phone,
      userId: userId,
      createdAt: createdAt,
      sizeBytes: tdBinlog.length,
      tdBinlog: tdBinlog,
    );
  }

  Future<int> restore(AccountSessionBackup backup) async {
    final slot = await TdClient.shared.restoreSessionSlot(backup.tdBinlog);
    return slot;
  }

  Future<void> delete(AccountSessionBackup backup) async {
    if (!await isSupported) return;
    await _channel.invokeMethod<void>('deleteSession', {'id': backup.id});
  }

  Future<void> deleteAll() async {
    if (!await isSupported) return;
    await _channel.invokeMethod<void>('deleteAllSessions');
  }

  AccountSessionBackup? _decode(Uint8List data) {
    try {
      final binary = _decodeBinaryBackup(data);
      if (binary != null) return binary;
      final decoded = jsonDecode(utf8.decode(data));
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['format'] != _format) return null;
      final files = decoded['files'];
      if (files is! Map<String, dynamic>) return null;
      final encodedSession = files[_fileName];
      if (encodedSession is! String || encodedSession.isEmpty) return null;
      final tdBinlog = base64Decode(encodedSession);
      if (tdBinlog.isEmpty) return null;
      final createdAtText = decoded['createdAt'];
      final createdAt = createdAtText is String
          ? DateTime.tryParse(createdAtText)
          : null;
      final id = decoded['id']?.toString();
      if (id == null || id.isEmpty) return null;
      final userIdValue = decoded['userId'];
      return AccountSessionBackup(
        id: id,
        name: decoded['name']?.toString() ?? id,
        phone: decoded['phone']?.toString(),
        userId: userIdValue is int ? userIdValue : int.tryParse('$userIdValue'),
        createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        sizeBytes: tdBinlog.length,
        tdBinlog: Uint8List.fromList(tdBinlog),
      );
    } catch (_) {
      return null;
    }
  }

  Uint8List _encodeBinaryBackup(
    Map<String, Object?> header,
    List<int> tdBinlog,
  ) {
    final headerBytes = utf8.encode(jsonEncode(header));
    final lengthBytes = ascii.encode(
      headerBytes.length.toRadixString(16).padLeft(8, '0'),
    );
    return Uint8List.fromList([
      ..._binaryMagic,
      ...lengthBytes,
      ...headerBytes,
      ...tdBinlog,
    ]);
  }

  AccountSessionBackup? _decodeBinaryBackup(Uint8List data) {
    if (data.length < _binaryMagic.length + 8) return null;
    for (var i = 0; i < _binaryMagic.length; i++) {
      if (data[i] != _binaryMagic[i]) return null;
    }
    final lengthStart = _binaryMagic.length;
    final lengthEnd = lengthStart + 8;
    final headerLength = int.tryParse(
      ascii.decode(data.sublist(lengthStart, lengthEnd)),
      radix: 16,
    );
    if (headerLength == null || headerLength <= 0) return null;
    final headerEnd = lengthEnd + headerLength;
    if (headerEnd >= data.length) return null;

    final decoded = jsonDecode(utf8.decode(data.sublist(lengthEnd, headerEnd)));
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['format'] != _binaryFormat) return null;
    if (decoded['fileName'] != _fileName) return null;
    final id = decoded['id']?.toString();
    if (id == null || id.isEmpty) return null;
    final tdBinlog = data.sublist(headerEnd);
    if (tdBinlog.isEmpty) return null;
    final createdAtText = decoded['createdAt'];
    final createdAt = createdAtText is String
        ? DateTime.tryParse(createdAtText)
        : null;
    final userIdValue = decoded['userId'];
    return AccountSessionBackup(
      id: id,
      name: decoded['name']?.toString() ?? id,
      phone: decoded['phone']?.toString(),
      userId: userIdValue is int ? userIdValue : int.tryParse('$userIdValue'),
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      sizeBytes: tdBinlog.length,
      tdBinlog: Uint8List.fromList(tdBinlog),
    );
  }
}
