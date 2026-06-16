// SCAFFOLD — this file bundles the pieces of a Hifz Companion BACKUP CARD: the calm
// Settings surface that exports a `.hifzbackup` file the user keeps, imports (restores or
// merges) one, shows an honest status line, toggles optional encryption, nudges on a stale
// backup, and erases all local data. It is NOT a standalone Dart file: it contains a
// domain-blind card widget, the feature-layer controller that drives HifzBackup.export/import
// and erase through the SINGLE WRITE PATH, the replace-vs-merge + erase confirmations, and a
// widget-test stub. Copy each labelled block into the right file under packages/, then fill
// every // TODO. Opening this file on its own shows unresolved symbols — that is expected; the
// real symbols (HifzBackup + BackupSnapshot from the backup/ package, AppLocalizations, the
// design-system token layer, the Riverpod providers, the injected share/file/clock boundaries)
// resolve only inside the pub workspace.
//
// Three pieces, in two layers:
//   1. BackupCard — shared ui/ leaf, DOMAIN-BLIND (Export/Import rows + status line + encryption
//      Switch + a calm stale-nudge, taking primitives + callbacks only). NO cloud/account/sync
//      chrome. It knows NO backup-format/engine type and computes/encrypts NOTHING.
//   2. BackupController — features/settings controller: orchestrates /data read -> backup/
//      serialize -> OS share (export), file-pick -> backup/ import -> /data write (restore),
//      and erase — each through the SINGLE WRITE PATH (persist/commit, THEN republish status).
//   3. BackupView — features/ leaf: localizes labels, owns RTL geometry + locale numerals + the
//      bidi-isolated file name + the calendar status date, and wires the card's callbacks.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / space.* / touch.min). The design
// docs own the concrete values — never inline hex / dp / sp here.
//
// Governing docs:
//   docs/design-system/10-privacy-and-trust-ux.md §8 (backup = a file you keep, BOTH halves of
//     ownership; erasure real/immediate/honest, top-corner + confirmation; never imply
//     upload/sync; locale numerals + calendar in the date), §9 (encryption = protective default
//     on, reversible, one honest line), §11 (five dark-pattern gate: export/import/erase/silence
//     are one tap each; nothing pre-checked; honest hierarchy), §2 (NO fake syncing spinner),
//     §3 (specific checkable honesty, never "your data is safe"), §10 (calm peripheral nudge)
//   docs/engineering/10-backup-format.md §9 (export -> OS share, ZERO network; erase wipes
//     local + states irreversible), §7 (replace vs merge — two explicit, separately-confirmed
//     actions; merge = set-union over append-only review_log), §2 (state plainly: an unencrypted
//     backup is readable by anyone), §6 (NO recovery — forgotten passphrase = unrecoverable),
//     §1 (the path opens no socket)
//   docs/design-system/11-voice-and-tone.md §2 (plain & warm + honest voice), §4 (empathy-then-
//     fact for the no-recovery tradeoff), §3 (error copy: cause/consequence/next step), §7 (no
//     transactional framing, status is not a streak), §8/§9 (transcreated strings, bidi isolation)
//   eng-create-riverpod-store (persist/commit-before-republish single write path)
//   eng-define-service-boundary (injected OS share / file picker / backup IO / clock — never a
//     global singleton, never DateTime.now() in a View)
//   eng-rtl-and-bidi-layout (EdgeInsetsDirectional; locale numerals; FSI/PDI-isolate the file name)
//   eng-add-localized-string (the tradeoff/erase/encryption/status strings, transcreated fa/ckb/ar)
//   domain-backup-format (HifzBackup.export/import bytes + replace/merge — driven, NEVER re-derived)
//
// Non-negotiables this scaffold encodes:
//   - NO cloud iconography, NO account, NO "Sign in / Sync / Upload", NO fake "syncing…" spinner.
//     The backup is a LOCAL FILE the app moves nowhere; the OS share sheet moves it.
//   - State BOTH halves of ownership: "a file you keep" AND "you hold the only copy" — and the
//     no-recovery tradeoff as a CHECKABLE FACT, with empathy, never as "your data is safe".
//   - Encryption: protective default ON, reversible, one honest line; a forgotten passphrase is
//     UNRECOVERABLE; an unencrypted backup is plainly flagged readable-by-anyone.
//   - Status line is a plain "Last backup: <localized date>" / "No backup yet" — NEVER a streak.
//   - Restore = two explicit, separately-confirmed actions: Replace (replaces all) / Merge (adds).
//   - Erase sits in the hard-to-reach top corner, behind confirmation, stated irreversible.
//   - Single write path: export/import/erase/toggle commit, THEN republish status. No View write,
//     no global, no DateTime.now(), no socket. Offline / no-AI; works in airplane mode forever.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/backup_card.dart  (shared ui/, DOMAIN-BLIND)
// The calm backup card: Export + Import rows, a plain status line, an encryption Switch,
// and an optional calm stale-nudge. Primitives + callbacks ONLY. It does NOT import any
// backup-format/engine type, does NOT serialize/encrypt, and renders NO cloud/account/sync
// chrome. (10-privacy §8/§9/§11; 11-voice §2.)
// ============================================================================

/// The card's display state, built by the feature layer from the persisted backup metadata.
/// `lastBackupLabel` is ALREADY a localized calendar+numeral string (e.g. the Jalālī date in
/// Extended Arabic-Indic digits) — the card never formats a date itself (eng-rtl-and-bidi-layout).
class BackupCardState {
  const BackupCardState({
    required this.lastBackupLabel, // localized "Last backup: <date>" OR the "No backup yet" string
    required this.hasBackup,
    required this.encryptionEnabled,
    this.isStale = false, // feature layer decides staleness against the INJECTED clock, not now()
  });
  final String lastBackupLabel;
  final bool hasBackup;
  final bool encryptionEnabled;
  final bool isStale;
}

/// Localized copy for the card. Every field is a transcreated ARB string (fa/ckb/ar), reviewed
/// per locale — NEVER hardcoded English, NEVER concatenated with a number (11-voice §8/§9).
class BackupCardStrings {
  const BackupCardStrings({
    required this.cardTitle, // e.g. "Backup"
    required this.ownershipLine, // BOTH halves: "A file you keep. We move it nowhere — and you
    //                              hold the only copy." (10-privacy §8; 11-voice §2)
    required this.exportLabel, // verb: "Save backup"
    required this.importLabel, // verb: "Restore from a file"
    required this.encryptionToggleLabel, // "Encrypt the backup file"
    required this.encryptionOneLiner, // "Locks your backup file with a password only you hold."
    required this.unencryptedReadableNote, // "An unencrypted backup is readable by anyone who opens
    //                                         it." — shown when encryption is OFF (10-backup §2)
    required this.staleNudge, // calm fact + offer, NEVER a scold (10-privacy §10; 11-voice §3/§4)
    required this.eraseLabel, // "Erase all data"
  });
  final String cardTitle;
  final String ownershipLine;
  final String exportLabel;
  final String importLabel;
  final String encryptionToggleLabel;
  final String encryptionOneLiner;
  final String unencryptedReadableNote;
  final String staleNudge;
  final String eraseLabel;
}

/// The backup card. DOMAIN-BLIND: primitives + callbacks only. NO cloud glyph, NO account row,
/// NO "Sign in / Sync / Upload", NO "syncing…" spinner (there is no server — 10-privacy §2/§8).
class BackupCard extends StatelessWidget {
  const BackupCard({
    super.key,
    required this.state,
    required this.strings,
    required this.onExport,
    required this.onImport,
    required this.onToggleEncryption,
    required this.onDismissStaleNudge,
    required this.onErase,
  });

  final BackupCardState state;
  final BackupCardStrings strings;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final ValueChanged<bool> onToggleEncryption;
  final VoidCallback onDismissStaleNudge;
  final VoidCallback onErase; // routes to the top-corner confirmation (BLOCK 3 / ui-destructive-confirm)

  @override
  Widget build(BuildContext context) {
    // RTL by construction for fa/ckb/ar — rely on EdgeInsetsDirectional, never named left/right.
    // A Card/Column of plain Settings rows. NO cloud iconography anywhere (10-privacy §8).
    return Card(
      child: Padding(
        // TODO: padding = EdgeInsetsDirectional(...) using space.* (eng-rtl-and-bidi-layout).
        padding: EdgeInsetsDirectional.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: title in type.title; ownership line in type.body/color.text.secondary —
            // TODO:   BOTH halves of ownership, plainly (10-privacy §8; 11-voice §2).

            // --- STATUS LINE: plain "Last backup: <date>" / "No backup yet" — NOT a streak ---
            // TODO: Text(state.lastBackupLabel, style: type.body). The label is ALREADY a
            // TODO:   localized calendar+numeral string (locale numerals via intl); the card
            // TODO:   does not format it (10-privacy §8; 11-voice §7 — a status, never a score).

            // --- STALE NUDGE (optional): a calm fact + an offer, NEVER a red/danger fill ---
            if (state.isStale)
              // TODO: a quiet inline note (type.caption / color.text.secondary) = strings.staleNudge,
              // TODO:   with a "Save backup now" action (onExport) and a dismiss (onDismissStaleNudge).
              // TODO:   NO red fill, NO escalation, NO guilt (10-privacy §10; 11-voice §3/§4).
              const SizedBox.shrink(),

            // --- EXPORT ROW: one un-obstructed tap; verb label ---
            // TODO: a FilledButton/ListTile = strings.exportLabel -> onExport. >=touch.min (>=48dp).
            // TODO:   NO cloud/upload glyph; the icon (if any) is a neutral file/save mark.

            // --- IMPORT ROW: one un-obstructed tap; leads into replace-vs-merge (BLOCK 3) ---
            // TODO: a ListTile = strings.importLabel -> onImport. The two restore modes are chosen
            // TODO:   in the confirmation, NOT pre-selected here (10-backup §7; 10-privacy §11).

            // --- ENCRYPTION TOGGLE: protective default ON, reversible, one honest line ---
            // TODO: SwitchListTile(value: state.encryptionEnabled, onChanged: onToggleEncryption,
            // TODO:   title: strings.encryptionToggleLabel, subtitle: strings.encryptionOneLiner).
            // TODO:   When OFF, show strings.unencryptedReadableNote plainly (10-backup §2; privacy §9).
            // TODO:   NOT pre-checked as a trap; the SAFE option is the default (10-privacy §9).

            // --- ERASE: out of easy thumb reach, behind confirmation (top corner / end of card) ---
            // TODO: a plain, de-emphasised TextButton = strings.eraseLabel -> onErase. The actual
            // TODO:   irreversible confirmation is BLOCK 3 (10-privacy §8; ui-destructive-confirm).

            // NO cloud, NO account, NO "Sign in / Sync / Upload", NO "syncing…" spinner (10-privacy §2/§8).
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BLOCK 2 — packages/features/lib/src/settings/backup_controller.dart
// Orchestrates the backup actions through the SINGLE WRITE PATH. Drives the backup/ package
// (HifzBackup.export/import) and the /data layer; opens NO socket. Republishes the card's
// status only AFTER the write/commit. (10-backup §1/§7/§9; eng-create-riverpod-store.)
// ============================================================================

/// The card's persisted/derived status (last-backup metadata + the encryption preference).
/// Derived fields (e.g. staleness) are computed against the INJECTED clock, never DateTime.now().
class BackupStatus {
  const BackupStatus({required this.encryptionEnabled /* TODO: + lastBackupAt (CalendarDate), hasBackup */});
  final bool encryptionEnabled;
}

/// Which restore mode the user explicitly confirmed (10-backup §7). NEVER auto-resolved.
enum RestoreMode { replace, merge }

// TODO: declare a Riverpod Notifier/AsyncNotifier (see eng-create-riverpod-store), e.g.:
// final backupControllerProvider =
//     AsyncNotifierProvider<BackupController, BackupStatus>(...);
class BackupController /* extends AsyncNotifier<BackupStatus> */ {
  // TODO: inject the boundaries (eng-define-service-boundary) — NEVER globals, NEVER DateTime.now():
  //   - the /data layer (readSnapshot(scope) -> BackupSnapshot; writeSnapshot in one transaction)
  //   - the OS share sheet wrapper (moves the exported file; the app sends nothing)
  //   - the OS file picker wrapper (picks a .hifzbackup to restore)
  //   - the clock (the injected "today" / CalendarDate) for the status date + staleness
  //   - the secure-storage / erase wrapper

  /// EXPORT — build snapshot in /data, serialize/encrypt in backup/ (off the UI isolate), write an
  /// atomic temp file, hand it to the OS SHARE SHEET. ZERO network I/O (10-backup §1/§9).
  Future<void> exportBackup({String? passphrase}) async {
    // TODO: final snapshot = await _data.readSnapshot(scope);           // /data -> value types
    // TODO: final bytes = await _runOffIsolate(() =>                    // backup/ — off UI isolate
    // TODO:     HifzBackup.export(snapshot, passphrase: passphrase));   // (domain-backup-format)
    // TODO: final file = await _writeAtomicTempFile(bytes, _defaultName()); // e.g. Hifz-2026-06-16.hifzbackup
    // TODO: await _share.shareFile(file);                              // OS share sheet — app sends NOTHING
    // TODO: await _refreshStatus();                                    // republish status AFTER the action
    //       Show real progress only — NEVER a fake "syncing…" animation (10-privacy §2).
    //       If encryption is on, plaintext is NEVER written to disk; only ciphertext (10-backup §9).
  }

  /// RESTORE — pick a file, validate it ENTIRELY in memory, then apply the user's confirmed mode in
  /// ONE transaction. Replace wipes-and-rebuilds; Merge is a set-union over the append-only
  /// review_log (10-backup §7). The card calls this only after the explicit confirmation (BLOCK 3).
  Future<void> restoreFromFile(RestoreMode mode, {String? passphrase}) async {
    // TODO: final bytes = await _picker.pickHifzbackup();              // OS file picker
    // TODO: final snapshot = await _runOffIsolate(() =>
    // TODO:     HifzBackup.import(bytes, passphrase: passphrase));     // throws a typed BackupError
    //       On BackupError surface the §3 error copy (cause/consequence/next step; data unchanged).
    // TODO: await _data.applyRestore(snapshot, mode);                  // ONE transaction (replace|merge)
    //       After merge/restore the ENGINE recomputes D/S/due_at + re-applies the trust clamp
    //       (domain-backup-format §7 / domain-scheduling-engine-rules) — the card just refreshes.
    // TODO: await _refreshStatus();
  }

  /// Toggle the encryption PREFERENCE (protective default on). Single write path: PERSIST first,
  /// THEN republish (10-privacy §9; eng-create-riverpod-store).
  Future<void> setEncryptionEnabled(bool enabled) async {
    // TODO: await _data.saveEncryptionPreference(enabled); // PERSIST FIRST (transactional)
    // TODO: _refreshStatus();                              // THEN republish
  }

  /// ERASE — one irreversible action: wipe all local user data (DB + WAL siblings + the DB key if
  /// encryption was on). Right-to-be-forgotten by construction (10-backup §9; 10-privacy §8).
  /// Called only after the top-corner irreversible confirmation (BLOCK 3 / ui-destructive-confirm).
  Future<void> eraseAllLocalData() async {
    // TODO: await _data.eraseAllLocalData(); // deletes .sqlite + -wal + -shm + secure-storage key
    // TODO: await _refreshStatus();          // status now reflects "No backup record on this device"
  }

  // TODO: String _defaultName() => 'Hifz-<injected-today>.hifzbackup'; // date from the injected clock
}

// ============================================================================
// BLOCK 3 — packages/features/lib/src/settings/backup_view.dart
// Dumb View: localizes labels, owns RTL geometry + locale numerals + the bidi-isolated file name,
// builds the status string from the INJECTED clock + chosen calendar, and wires the card's
// callbacks (export, import->confirm, toggle, erase->confirm). Reads the controller; never
// persists itself, never reads DateTime.now().
// ============================================================================

class BackupView extends ConsumerWidget {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final status = ref.watch(backupControllerProvider);   // BackupStatus (async)
    // final l10n   = AppLocalizations.of(context)!;          // transcreated labels (fa/ckb/ar)

    // Build the status label: "Last backup: <date>" in the user's CALENDAR + LOCALE NUMERALS via
    // intl (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), date from the INJECTED clock —
    // NEVER DateTime.now(), NEVER ASCII digits, NEVER concatenate a number into a sentence
    // (eng-rtl-and-bidi-layout; domain-calendars-and-hifzdate). A backup FILE NAME shown anywhere
    // (a mixed Latin/number run) is FSI/PDI-isolated so it never flips the RTL line (11-voice §8).

    final strings = BackupCardStrings(
      // TODO: cardTitle: l10n.backupTitle,
      // TODO: ownershipLine: l10n.backupOwnershipLine,        // BOTH halves (10-privacy §8)
      // TODO: exportLabel: l10n.backupSave,
      // TODO: importLabel: l10n.backupRestore,
      // TODO: encryptionToggleLabel: l10n.backupEncryptToggle,
      // TODO: encryptionOneLiner: l10n.backupEncryptOneLiner, // (10-privacy §9)
      // TODO: unencryptedReadableNote: l10n.backupUnencryptedReadable, // (10-backup §2)
      // TODO: staleNudge: l10n.backupStaleNudge,              // calm fact + offer (10-privacy §10)
      // TODO: eraseLabel: l10n.eraseAllData,
      cardTitle: '',
      ownershipLine: '',
      exportLabel: '',
      importLabel: '',
      encryptionToggleLabel: '',
      encryptionOneLiner: '',
      unencryptedReadableNote: '',
      staleNudge: '',
      eraseLabel: '',
    );

    return Directionality(
      // TODO: textDirection from the active locale (fa/ckb/ar => RTL). Rely on EdgeInsetsDirectional,
      //       not hardcoded left/right (eng-rtl-and-bidi-layout).
      textDirection: TextDirection.rtl,
      child: BackupCard(
        state: const BackupCardState(
          lastBackupLabel: '', // TODO: localized "Last backup: <date>" / "No backup yet"
          hasBackup: false,
          encryptionEnabled: true, // protective DEFAULT on (10-privacy §9)
          isStale: false, // TODO: computed against the INJECTED clock, never now()
        ),
        strings: strings,
        onExport: () async {
          // EXPORT: confirm with the NO-RECOVERY tradeoff stated as a CHECKABLE FACT, with empathy
          // (10-privacy §8/§3; 11-voice §4): "Lose this phone and this file and your record is gone —
          // there is no cloud to recover it." If encryption is on, prompt for a passphrase and warn
          // a forgotten passphrase is unrecoverable (10-backup §6). Then:
          // TODO: ref.read(backupControllerProvider.notifier).exportBackup(passphrase: ...);
          // Quiet, factual result — NO fanfare, NO "synced", NO exclamation (11-voice §2/§7).
        },
        onImport: () async {
          // RESTORE: show TWO explicit, separately-confirmed choices — never one button, never a
          // pre-selected trap (10-backup §7; 10-privacy §11):
          //   Replace -> "This will replace all data currently in Hifz Companion."
          //   Merge   -> "This will add the imported reviews to your existing history."
          // TODO: final mode = await _showReplaceVsMergeSheet(context);   // returns RestoreMode?
          // TODO: if (mode != null) ref.read(backupControllerProvider.notifier)
          // TODO:     .restoreFromFile(mode, passphrase: ...);
        },
        onToggleEncryption: (enabled) {
          // TODO: ref.read(backupControllerProvider.notifier).setEncryptionEnabled(enabled);
          // The SAFE (on) option is the default; toggling is quiet (10-privacy §9).
        },
        onDismissStaleNudge: () {
          // TODO: persist "nudge dismissed" via the controller — no nagging re-show (10-privacy §10/§11).
        },
        onErase: () async {
          // ERASE: top-corner, irreversible, behind confirmation. State plainly it cannot be undone
          // and that any existing backup file is then the only remaining copy — no soft-delete
          // (10-privacy §8; ui-destructive-confirm). The CANCEL (safe) choice is visually primary.
          // TODO: final confirmed = await _showEraseConfirm(context);   // double-confirm
          // TODO: if (confirmed) ref.read(backupControllerProvider.notifier).eraseAllLocalData();
        },
      ),
    );
  }
}

// ============================================================================
// BLOCK 4 — test/features/settings/backup_card_test.dart  (widget + invariant)
// Verifies: (a) NO cloud / sync / account / "Sign in" / "Upload" glyph or string anywhere in the
// tree (the file is local; the app moves nothing), (b) export/import/erase/toggle route through
// the controller (single write path — persist/commit before republish), (c) restore shows TWO
// distinct confirmations (replace vs merge), (d) the encryption toggle defaults ON, (e) an
// unencrypted state shows the readable-by-anyone note, (f) RTL goldens per locale (fa/ckb/ar)
// with a bidi-isolated file name + a locale-numeral/calendar date. (eng-write-dart-test.)
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('the backup card shows NO cloud / sync / account chrome', (tester) async {
//     // TODO: pump BackupView with an overridden controller provider.
//     // TODO: expect(find.byIcon(Icons.cloud), findsNothing);
//     // TODO: expect(find.byIcon(Icons.cloud_upload), findsNothing);
//     // TODO: expect(find.byIcon(Icons.sync), findsNothing);
//     // TODO: expect(find.textContaining('Sign in'), findsNothing);
//     // TODO: expect(find.textContaining('Upload'), findsNothing);   // localized variants too
//   });
//
//   testWidgets('export / import / erase route through the controller (single write path)', (tester) async {
//     // TODO: tap Save backup -> verify the fake controller.exportBackup ran and committed BEFORE
//     // TODO:   the status republished; assert the fake share wrapper was handed the file (no socket).
//   });
//
//   testWidgets('restore offers TWO distinct, separately-confirmed modes', (tester) async {
//     // TODO: tap Restore -> assert both "replace all" and "add to your history" confirmations exist,
//     // TODO:   neither pre-selected; choosing Merge calls restoreFromFile(RestoreMode.merge) (10-backup §7).
//   });
//
//   testWidgets('encryption defaults ON; an unencrypted backup is flagged readable-by-anyone', (tester) async {
//     // TODO: assert the encryption SwitchListTile value is true by default (10-privacy §9);
//     // TODO:   toggling it OFF reveals the "readable by anyone" note (10-backup §2).
//   });
//
//   testWidgets('the status line is a plain date, not a streak/score', (tester) async {
//     // TODO: assert "Last backup: <localized date>" renders with LOCALE numerals (no ASCII digits)
//     // TODO:   and no streak/score widget; "No backup yet" is neutral, not a scold (11-voice §2/§7).
//   });
//
//   // TODO: RTL golden per locale — matchesGoldenFile for fa, ckb, ar (actions/status on logical
//   // TODO:   start/end, the backup file name FSI/PDI-isolated, the date in locale numerals/calendar).
// }
