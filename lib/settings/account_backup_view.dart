import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/account_backup_service.dart';
import '../auth/account_store.dart';
import '../auth/auth_manager.dart';
import '../components/app_icons.dart';
import '../components/confirm_dialog.dart';
import '../components/toast.dart';
import '../components/ui_components.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class AccountBackupView extends StatefulWidget {
  const AccountBackupView({
    super.key,
    this.showCreateAction = true,
    this.closeAfterRestore = false,
  });

  final bool showCreateAction;
  final bool closeAfterRestore;

  @override
  State<AccountBackupView> createState() => _AccountBackupViewState();
}

class _AccountBackupViewState extends State<AccountBackupView> {
  final _service = AccountBackupService.shared;
  final _dateFormat = DateFormat.yMMMd().add_jm();
  var _loading = true;
  var _working = false;
  var _enabled = true;
  List<AccountSessionBackup> _backups = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final enabled = await _service.isEnabled;
      final backups = await _service.listBackups();
      if (mounted) {
        setState(() {
          _enabled = enabled;
          _backups = backups;
        });
      }
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setEnabled(bool value) async {
    if (_working) return;
    setState(() {
      _enabled = value;
      _working = true;
      if (!value) _backups = const [];
    });
    try {
      await _service.setEnabled(value);
      if (value && widget.showCreateAction && Platform.isIOS) {
        await _service.backupActiveAccountIfEnabled();
      }
      await _load();
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _backupActive() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final backup = await _service.backupActiveAccount();
      await _load();
      if (mounted) {
        showToast(
          context,
          AppStrings.t(AppStringKeys.accountBackupSaved, {
            'value1': _formatBytes(backup.sizeBytes),
          }),
        );
      }
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _restore(AccountSessionBackup backup) async {
    final ok = await confirmDialog(
      context,
      title: AppStringKeys.accountBackupRestoreTitle,
      message: AppStringKeys.accountBackupRestoreMessage,
      confirmText: AppStringKeys.accountBackupRestore,
    );
    if (!ok || !mounted || _working) return;
    final auth = context.read<AuthManager>();
    final accounts = context.read<AccountStore>();
    setState(() => _working = true);
    try {
      final slot = await _service.restore(backup);
      auth.reloadAuthState();
      await accounts.refresh();
      if (mounted) {
        showToast(
          context,
          AppStrings.t(AppStringKeys.accountBackupRestored, {
            'value1': '$slot',
          }),
        );
        if (widget.closeAfterRestore) {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _delete(AccountSessionBackup backup) async {
    final ok = await confirmDialog(
      context,
      title: AppStringKeys.accountBackupDeleteTitle,
      message: AppStringKeys.accountBackupDeleteMessage,
      confirmText: AppStringKeys.chatDelete,
      destructive: true,
    );
    if (!ok || !mounted || _working) return;
    setState(() => _working = true);
    try {
      await _service.delete(backup);
      await _load();
    } catch (error) {
      if (mounted) showToast(context, error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.groupedBackground,
      body: Column(
        children: [
          NavHeader(
            title: AppStrings.t(AppStringKeys.accountBackupTitle),
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
              children: [
                _enabledSwitch(),
                if (widget.showCreateAction) ...[
                  const SizedBox(height: 12),
                  _actionButton(),
                ],
                const SizedBox(height: 12),
                _notice(),
                const SizedBox(height: 18),
                _sectionTitle(AppStringKeys.accountBackupSessions),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!Platform.isIOS)
                  _empty(AppStringKeys.accountBackupIOSOnly)
                else if (_backups.isEmpty)
                  _empty(AppStringKeys.accountBackupEmpty)
                else
                  _backupList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _working || !_enabled || !Platform.isIOS ? null : _backupActive,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(HeroAppIcons.key.data, size: 20, color: AppTheme.brand),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.t(AppStringKeys.accountBackupCreate),
                style: TextStyle(fontSize: 16, color: c.textPrimary),
              ),
            ),
            if (_working)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              AppIcon(
                HeroAppIcons.chevronRight,
                size: 14,
                color: c.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _enabledSwitch() {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SettingsSwitchRow(
        title: AppStringKeys.accountBackupEnabled,
        value: _enabled,
        onChanged: Platform.isIOS && !_working ? _setEnabled : (_) {},
        leading: Icon(HeroAppIcons.key.data, size: 20, color: AppTheme.brand),
        leadingInset: 16,
      ),
    );
  }

  Widget _notice() {
    final c = context.colors;
    return Text(
      AppStrings.t(AppStringKeys.accountBackupNotice),
      style: TextStyle(fontSize: 13, height: 1.35, color: c.textTertiary),
    );
  }

  Widget _sectionTitle(String title) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        title.l10n(context),
        style: TextStyle(fontSize: 13, color: c.textTertiary),
      ),
    );
  }

  Widget _empty(String message) {
    final c = context.colors;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message.l10n(context),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: c.textSecondary),
      ),
    );
  }

  Widget _backupList() {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final backup in _backups) ...[
            _BackupRow(
              backup: backup,
              subtitle:
                  '${_dateFormat.format(backup.createdAt.toLocal())} · ${_formatBytes(backup.sizeBytes)}',
              onRestore: () => _restore(backup),
              onDelete: () => _delete(backup),
            ),
            if (backup != _backups.last) const InsetDivider(leadingInset: 56),
          ],
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.backup,
    required this.subtitle,
    required this.onRestore,
    required this.onDelete,
  });

  final AccountSessionBackup backup;
  final String subtitle;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(HeroAppIcons.circleUser.data, size: 24, color: AppTheme.brand),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    backup.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: c.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: AppStrings.t(AppStringKeys.accountBackupRestore),
              onPressed: onRestore,
              icon: AppIcon(HeroAppIcons.arrowUp, color: AppTheme.brand),
            ),
            IconButton(
              tooltip: AppStrings.t(AppStringKeys.chatDelete),
              onPressed: onDelete,
              icon: const AppIcon(HeroAppIcons.trash, color: Color(0xFFFF3B30)),
            ),
          ],
        ),
      ),
    );
  }
}
