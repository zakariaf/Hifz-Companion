// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:backup/backup.dart' show BackupError, BackupException;
import 'package:composition/composition.dart'
    show
        backupFilePickerProvider,
        backupShareServiceProvider,
        localStoreEraserProvider,
        todayProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import '../../backup/backup_restorer.dart';
import '../../design_system/components/destructive_confirm.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../../backup/backup_providers.dart'
    show backupExporterProvider, backupRestorerProvider;
import 'settings_section.dart';

/// The Backup group of the Settings screen (E17-T08; ui-backup-card): a calm,
/// **no-cloud, no-account, no-sync** surface that exports a `.hifzbackup` file the
/// ḥāfiẓ keeps, imports (replaces or merges) one, and — out of easy thumb reach —
/// erases all local data (E17-T09).
///
/// It frames the backup as *a file you keep that the app moves nowhere*, and
/// states the matching responsibility plainly: because there is no server, the
/// user holds the only copy. A dumb View: it opens no socket, formats no number,
/// and routes every action through the injected export/import/erase boundaries.
class BackupSettingsSection extends ConsumerWidget {
  /// Creates the Backup settings group.
  const BackupSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SettingsSection(
      title: l10n.settingsSectionBackup,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: space.space4,
            end: space.space4,
            bottom: space.space2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Both halves of ownership, plainly — a file you keep; the only copy.
              Text(l10n.backupOwnershipLine, style: text.bodyMedium),
              SizedBox(height: space.space2),
              // A plain status, never a streak. (The persisted last-backup date
              // needs a device-pref write seam — a flagged follow-up; until then
              // this is the neutral "No backup yet".)
              Text(
                l10n.backupNoBackupYet,
                style: text.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.save_alt_outlined),
          title: Text(l10n.backupExportAction),
          onTap: () => _export(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.file_open_outlined),
          title: Text(l10n.backupImportAction),
          onTap: () => _import(context, ref),
        ),
        // Erase sits low/plain and behind a two-step confirmation (T09).
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: space.space4,
            top: space.space2,
            bottom: space.space2,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => _erase(context, ref),
              child: Text(l10n.eraseAllDataAction),
            ),
          ),
        ),
      ],
    );
  }

  // ── EXPORT ──────────────────────────────────────────────────────────────────
  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<_ExportChoice>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ExportSheet(),
    );
    if (choice == null) return; // cancelled

    messenger.showSnackBar(SnackBar(content: Text(l10n.backupPreparing)));
    try {
      final bytes = await ref
          .read(backupExporterProvider)
          .exportAll(passphrase: choice.passphrase);
      final name = 'Hifz-${ref.read(todayProvider)}.hifzbackup';
      await ref.read(backupShareServiceProvider).shareBackup(bytes, name);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupExportFailed)));
    }
  }

  // ── IMPORT ──────────────────────────────────────────────────────────────────
  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final bytes = await ref.read(backupFilePickerProvider).pickBackupBytes();
    if (bytes == null || !context.mounted) return; // cancelled

    final mode = await showModalBottomSheet<RestoreMode>(
      context: context,
      builder: (_) => const _ReplaceMergeSheet(),
    );
    if (mode == null || !context.mounted) return;

    final restorer = ref.read(backupRestorerProvider);
    String? passphrase;
    while (true) {
      try {
        await restorer.restore(bytes, mode: mode, passphrase: passphrase);
        messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
        return;
      } on BackupException catch (e) {
        // A wrong/absent passphrase: prompt once and retry — decode happens
        // before any DB write, so nothing was applied.
        if (e.error == BackupError.wrongPasswordOrDamaged && context.mounted) {
          final entered = await _promptPassphrase(context);
          if (entered == null) return; // user gave up
          passphrase = entered;
          continue;
        }
        messenger
            .showSnackBar(SnackBar(content: Text(_restoreErrorLabel(l10n, e.error))));
        return;
      } on CrossMushafRefused {
        messenger
            .showSnackBar(SnackBar(content: Text(l10n.backupCrossMushaf)));
        return;
      }
    }
  }

  Future<String?> _promptPassphrase(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupPassphrasePromptTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(hintText: l10n.backupPassphraseHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.backupUnlockAction),
          ),
        ],
      ),
    );
  }

  String _restoreErrorLabel(AppLocalizations l10n, BackupError error) =>
      switch (error) {
        BackupError.notAHifzBackup => l10n.backupErrorNotBackup,
        BackupError.newerFormat => l10n.backupErrorNewer,
        BackupError.unknownMode => l10n.backupErrorNotBackup,
        BackupError.integrityFailed => l10n.backupErrorDamaged,
        BackupError.wrongPasswordOrDamaged => l10n.backupErrorWrongPassword,
        BackupError.malformedPayload => l10n.backupErrorUnreadable,
      };

  // ── ERASE (T09) ─────────────────────────────────────────────────────────────
  Future<void> _erase(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => DestructiveConfirmSheet(
        action: DestructiveAction.eraseAll,
        strings: DestructiveConfirmStrings(
          consequence: l10n.eraseConsequence,
          confirmLabel: l10n.eraseConfirmFirst,
          cancelLabel: l10n.eraseKeepData,
          secondConsequence: l10n.eraseConsequenceSecond,
          secondConfirmLabel: l10n.eraseConfirmSecond,
        ),
        onCancelled: () => Navigator.of(sheetContext).pop(),
        onConfirmed: () {
          Navigator.of(sheetContext).pop();
          ref.read(localStoreEraserProvider).eraseEverything();
        },
      ),
    );
  }
}

/// The user's confirmed export choice — whether to encrypt, and the passphrase.
class _ExportChoice {
  const _ExportChoice(this.passphrase);

  /// The passphrase for an encrypted export, or null for a plaintext export.
  final String? passphrase;
}

/// The export confirmation sheet: the no-recovery tradeoff stated as a checkable
/// fact, an optional-encryption switch (protective default ON), and — when off —
/// the plain readable-by-anyone honesty note.
class _ExportSheet extends StatefulWidget {
  const _ExportSheet();

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _encrypt = true; // protective default on
  final TextEditingController _passphrase = TextEditingController();

  @override
  void dispose() {
    _passphrase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: space.space4,
        end: space.space4,
        top: space.space4,
        bottom: space.space4 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.backupExportAction, style: text.titleMedium),
          SizedBox(height: space.space2),
          // Empathy-then-fact: the honest tradeoff, never "your data is safe".
          Text(l10n.backupNoRecoveryTradeoff, style: text.bodyMedium),
          SizedBox(height: space.space3),
          SwitchListTile(
            contentPadding: EdgeInsetsDirectional.zero,
            value: _encrypt,
            onChanged: (v) => setState(() => _encrypt = v),
            title: Text(l10n.backupEncryptToggle),
            subtitle: Text(l10n.backupEncryptOneLiner),
          ),
          if (_encrypt) ...[
            TextField(
              controller: _passphrase,
              autofocus: true,
              obscureText: true,
              decoration: InputDecoration(hintText: l10n.backupPassphraseHint),
            ),
            SizedBox(height: space.space1),
            Text(
              l10n.backupPassphraseUnrecoverable,
              style:
                  text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ] else
            Text(
              l10n.backupUnencryptedReadable,
              style:
                  text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          SizedBox(height: space.space4),
          FilledButton(
            onPressed: () {
              final pass =
                  _encrypt && _passphrase.text.isNotEmpty ? _passphrase.text : null;
              // An encrypt switch with no passphrase falls back to plaintext
              // rather than silently producing an unopenable file.
              Navigator.of(context).pop(_ExportChoice(pass));
            },
            child: Text(l10n.backupSaveAction),
          ),
        ],
      ),
    );
  }
}

/// The restore confirmation: two DISTINCT, separately-confirmed modes — Replace
/// (wipes and rebuilds) vs Merge (adds the imported reviews) — neither preselected.
class _ReplaceMergeSheet extends StatelessWidget {
  const _ReplaceMergeSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsetsDirectional.all(space.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.backupImportAction, style: text.titleMedium),
          SizedBox(height: space.space3),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(RestoreMode.merge),
            child: Text(l10n.backupMergeOption),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: space.space2,
              top: space.space1,
              bottom: space.space3,
            ),
            child: Text(l10n.backupMergeConsequence, style: text.bodySmall),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(RestoreMode.replace),
            child: Text(l10n.backupReplaceOption),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: space.space2,
              top: space.space1,
            ),
            child: Text(l10n.backupReplaceConsequence, style: text.bodySmall),
          ),
        ],
      ),
    );
  }
}
