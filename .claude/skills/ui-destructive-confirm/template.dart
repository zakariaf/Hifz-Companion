// SCAFFOLD — this file bundles the pieces of a Hifz Companion irreversible-destructive-
// action confirmation (erase-all-data / wipe-a-profile). It is NOT a standalone Dart
// file: it contains a domain-blind confirmation leaf, an optional second-gate widget, the
// feature-layer controller that performs the wipe through the SINGLE WRITE PATH, and a
// widget/golden + offline-guard test stub. Copy each labelled block into the right file
// under packages/, then fill every // TODO. Opening this file on its own shows unresolved
// symbols — that is expected; the real symbols (AppLocalizations, the design-system token
// layer, the Riverpod providers, the repository) resolve only inside the pub workspace.
//
// Three pieces, in two layers:
//   1. DestructiveConfirmSheet — shared ui/ leaf, DOMAIN-BLIND (consequence text + two
//      callbacks only; safe action is the visually-PRIMARY button, destructive is secondary).
//   2. _TypeToConfirmGate / _HoldToConfirmGate — optional SECOND gate, sized to the blast
//      radius (a whole-device erase warrants it; a single profile may not).
//   3. EraseController — features controller: performs the wipe through the SINGLE WRITE PATH
//      (persist/delete-then-republish), TRULY deleting rows incl. the append-only review_log.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / space.* / touch.min / motion.* /
// haptic.warning). The design docs own the concrete values — never inline hex / dp / sp / ms.
//
// Governing docs:
//   docs/design-system/10-privacy-and-trust-ux.md §8 (erasure is REAL — no soft-delete, nothing
//     recoverable elsewhere; state both halves), §9 (safe choice is the visually-PRIMARY default;
//     the consequential action is one deliberate step away; one decision per screen),
//     §11 (five dark-pattern strategies as a release gate — NO obstruction / interface-interference
//     / sneaking / forced-action / nagging; asymmetry protects the USER's data only)
//   docs/design-system/05-layout-spacing-touch.md §5 (destructive control in the hard-to-reach
//     TOP-START corner; the SAFE action sits LOW in the thumb band; thumb-zone difficulty is the
//     safety margin, never friction-for-friction; logical-direction layout serves fa/ckb/ar)
//   docs/design-system/11-voice-and-tone.md §4 (lead with understanding, end with a real choice;
//     never "you'll lose your hifz"), §6 (invitation/information, never command — no must/should)
//   docs/design-system/06-motion-and-haptics.md §2 (NO celebration on completion — none exists),
//     §4 (haptic.warning is light + single + never escalates; NO success/reward haptic),
//     §5 (reduce-motion: MediaQuery.disableAnimations always wins — cross-fade / instant cut)
//   docs/PRD.md §16 (Erase: one action wipes all local data; right-to-be-forgotten by construction)
//   eng-create-riverpod-store (persist/delete-then-republish single write path)
//   eng-add-persisted-model (the schema/DAO + the append-only review_log truly deleted)
//   eng-rtl-and-bidi-layout (EdgeInsetsDirectional, RTL mirroring)
//   eng-add-localized-string (consequence + button + Semantics copy, fa/ckb/ar; banned-phrase lint)
//   domain-adab-and-religious-integrity (no threat / command / shame / loss-of-hifz leverage)
//
// Non-negotiables this scaffold encodes:
//   - The consequence is CONCRETE and IRREVERSIBLE: what is erased, that it is permanent, that
//     nothing is recoverable elsewhere. NEVER a bare "Are you sure?".
//   - Cancel / "Keep my data" is the PRIMARY FilledButton AND the default focus. The destructive
//     action is a plainer, secondary affordance one deliberate step away — never the bright/default one.
//   - Erasure is REAL: rows are deleted incl. review_log; NO soft-delete flag that secretly retains.
//   - The write goes through ONE transactional store/repository call (persist/delete-then-republish).
//   - No dark patterns: the asymmetry protects the USER's data, never the app's retention.
//   - Completion is QUIET: no confetti/fanfare, no red alarm flourish; at most one haptic.warning.
//   - RTL by EdgeInsetsDirectional; reduce-motion honoured; Semantics name the consequence AND
//     which button is destructive; the focus ring is on the SAFE action.
//   - Offline / no-AI: erase opens NO socket, sends nothing, reads no DateTime.now().

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/destructive_confirm_sheet.dart  (shared ui/, DOMAIN-BLIND)
// A confirmation leaf for ONE irreversible action. Primitives + two callbacks only: it knows
// NO domain/engine type and decides nothing about what gets erased. The SAFE (cancel) action
// is the visually-PRIMARY button; the destructive action is secondary and one deliberate step
// away (10 §9). NEVER a bare "Are you sure?" — the consequence text is required (10 §8).
// ============================================================================

/// Display data for an irreversible-action confirmation. The feature layer builds these from
/// AppLocalizations (empathy-then-consequence copy, 11 §4/§6) — the leaf hardcodes no English.
class DestructiveConfirmContent {
  const DestructiveConfirmContent({
    required this.title,            // calm, non-blaming, e.g. "Erase all data on this device?"
    required this.consequence,      // CONCRETE + IRREVERSIBLE: what is erased, that it is permanent,
                                    //   that nothing is recoverable elsewhere (10 §8). NEVER empty.
    required this.cancelLabel,      // the SAFE choice, e.g. "Keep my data" — primary button label
    required this.destructiveLabel, // the destructive choice, e.g. "Erase everything" — secondary
    this.exportFirstLabel,          // optional: "Export a backup first" (offer the recoverable copy,
                                    //   domain-backup-format) — NEVER force it (no forced action, 10 §11)
  });
  final String title;
  final String consequence;
  final String cancelLabel;
  final String destructiveLabel;
  final String? exportFirstLabel;
}

/// A confirmation sheet/dialog for an irreversible action. DOMAIN-BLIND — primitives + callbacks.
///
/// - [content]        : the localized, concrete consequence text + button labels.
/// - [onCancel]       : the SAFE path (primary, default focus).
/// - [onConfirm]      : the destructive path (secondary, one deliberate step away). The feature
///                      layer routes it through EraseController's single write path (BLOCK 3).
/// - [onExportFirst]  : optional — open the export flow (domain-backup-format) before erasing.
class DestructiveConfirmSheet extends StatelessWidget {
  const DestructiveConfirmSheet({
    super.key,
    required this.content,
    required this.onCancel,
    required this.onConfirm,
    this.onExportFirst,
  });

  final DestructiveConfirmContent content;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback? onExportFirst;

  @override
  Widget build(BuildContext context) {
    // RTL by construction: rely on EdgeInsetsDirectional, never hardcoded left/right (05 §5).
    return Padding(
      // TODO: padding = EdgeInsetsDirectional symmetric on space.4 (05 §1); content scrolls, the
      // TODO:   action row sits at the BOTTOM (thumb band) — the SAFE action is reachable low (05 §5).
      padding: const EdgeInsetsDirectional.all(0), // TODO: space.4
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: title in type.title, color.text.primary — calm, non-blaming (11 §4).
          Text(content.title),

          // TODO: space.3 gap.

          // The CONCRETE consequence. Required, never empty, never "Are you sure?" (10 §8).
          // type.body, color.text.secondary; wraps (never truncates) for longer ckb strings.
          // Wrap in Semantics so a screen-reader hears the FULL consequence before the buttons.
          Semantics(
            // TODO: label: content.consequence,  // announce the irreversible consequence first
            child: Text(content.consequence),
          ),

          // TODO: space.4 gap.

          // Optional, NEVER forced: offer to export a recoverable backup first (domain-backup-format).
          // A plain secondary affordance — offering it is help, requiring it would be FORCED ACTION (10 §11).
          if (content.exportFirstLabel != null && onExportFirst != null)
            // TODO: TextButton(onPressed: onExportFirst, child: Text(content.exportFirstLabel!)),
            const SizedBox.shrink(),

          // ----- ACTION ROW (bottom thumb band) -----
          // SAFE choice = visually-PRIMARY FilledButton AND the default-focused control (10 §9).
          // The destructive choice = a plainer, secondary affordance one deliberate step away — never
          // the bright/default button, never disguised as the safe one (10 §9/§11 interface-interference).
          // NO confetti/fanfare on either path; completion is a quiet state change (06 §2).
          Row(
            children: [
              // SECONDARY: the destructive action. Plainer (text/outlined), error-toned label only.
              // It must NOT be the FilledButton and must NOT hold default focus.
              Expanded(
                child: Semantics(
                  // TODO: label: content.destructiveLabel, hint: "irreversible" — name it as destructive
                  button: true,
                  child: OutlinedButton(
                    // TODO: style with color.error label; onPressed: onConfirm
                    // TODO:   (the feature layer may interpose the BLOCK 2 second gate here first).
                    onPressed: onConfirm,
                    child: Text(content.destructiveLabel),
                  ),
                ),
              ),

              // TODO: space.3 gap between the two actions (>= space.2, 05 §4).

              // PRIMARY + DEFAULT FOCUS: the SAFE choice. Visually dominant; autofocus here, not on
              // the destructive button. A visible focus ring (color.outline, WCAG 2.4.7) sits on THIS.
              Expanded(
                child: FilledButton(
                  // TODO: autofocus: true,  // default focus is the SAFE path (10 §9)
                  onPressed: onCancel,
                  child: Text(content.cancelLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BLOCK 2 — packages/ui/lib/src/_type_to_confirm_gate.dart  (OPTIONAL second gate)
// For a high-blast-radius erase (whole device), require a SECOND deliberate gesture so it can't
// fire on one stray tap (10 §9 — one deliberate step away). Use the MINIMUM step that defeats an
// accidental tap; do NOT escalate beyond it (10 §11 — never obstruction-for-its-own-sake).
// Choose ONE: type-the-word, or hold-to-confirm. A single profile wipe may skip this entirely.
// ============================================================================

/// Type-the-word gate: the destructive button stays disabled until the user types the confirm
/// word (e.g. localized "ERASE"). A deliberate, reversible-until-final step — not friction-for-friction.
class TypeToConfirmGate extends StatefulWidget {
  const TypeToConfirmGate({
    super.key,
    required this.confirmWord,   // localized (NOT necessarily English); shown verbatim to type
    required this.fieldLabel,    // localized Semantics/label, e.g. "Type {word} to confirm"
    required this.onArmed,       // called with true/false as the typed text matches
  });
  final String confirmWord;
  final String fieldLabel;
  final ValueChanged<bool> onArmed;

  @override
  State<TypeToConfirmGate> createState() => _TypeToConfirmGateState();
}

class _TypeToConfirmGateState extends State<TypeToConfirmGate> {
  @override
  Widget build(BuildContext context) {
    // TODO: a TextField whose Semantics label = widget.fieldLabel; onChanged compares the typed
    // TODO:   text to widget.confirmWord (trim/normalize) and calls widget.onArmed(matched).
    // TODO: at most ONE haptic.warning when the field first arms — light, single, NEVER repeating (06 §4).
    // TODO: EdgeInsetsDirectional; the typed word is bidi-isolated (FSI/PDI) in mixed scripts.
    return const SizedBox.shrink(); // TODO: real field
  }
}

// ============================================================================
// BLOCK 3 — packages/features/lib/src/settings/erase_controller.dart
// Performs the wipe through the SINGLE WRITE PATH. Erasure is REAL: rows are deleted, INCLUDING
// the append-only review_log — NO soft-delete flag (10 §8). One transactional repository call,
// persist/delete-THEN-republish; the View never deletes persisted state itself.
// ============================================================================

/// What the user chose to erase. The View builds the consequence copy from this scope.
enum EraseScope {
  /// Everything on this device — every profile, card, review_log, config. The high-blast-radius
  /// case that warrants the BLOCK 2 second gate.
  allDataOnDevice,

  /// One profile's records (its cards + append-only review_log). Sits beside ui-profile-switcher.
  singleProfile,
}

// TODO: declare a Riverpod Notifier (see eng-create-riverpod-store), e.g.:
// final eraseControllerProvider =
//     AsyncNotifierProvider<EraseController, void>(EraseController.new);
class EraseController /* extends AsyncNotifier<void> */ {
  // TODO: inject the repository that owns the transactional delete (eng-define-service-boundary —
  //       never a global singleton; the erase opens NO socket and reads NO DateTime.now()).

  /// Perform the confirmed wipe. SINGLE WRITE PATH: DELETE transactionally, THEN republish.
  /// Erasure is REAL — the rows (incl. the append-only review_log) are deleted, never soft-deleted.
  /// After this, nothing about the user persists on-device (PRD §16; right-to-be-forgotten).
  Future<void> erase(EraseScope scope, {String? profileId}) async {
    // TODO: await _repository.transaction(() async {            // ONE transaction (eng-add-persisted-model)
    // TODO:   switch (scope) {
    // TODO:     case EraseScope.allDataOnDevice:
    // TODO:       await _repository.deleteAllProfilesCardsLogsConfigs();  // truly delete every table's rows
    // TODO:     case EraseScope.singleProfile:
    // TODO:       await _repository.deleteProfile(profileId!);            // its cards + review_log rows
    // TODO:   }
    // TODO: });                                                  // PERSIST/DELETE FIRST (transactional)
    // TODO: state = const AsyncData(null);                       // THEN republish (read models re-scope)
    //       NEVER: set a "deleted" flag and keep the rows (that is a soft-delete, 10 §8).
    //       NO success haptic, NO celebratory motion on completion — a quiet state change only (06 §2).
  }
}

// ============================================================================
// BLOCK 4 — packages/features/lib/src/settings/erase_view.dart
// Dumb View: localizes the empathy-then-consequence copy, owns RTL geometry, presents BLOCK 1
// (+ BLOCK 2 for a whole-device erase), and on confirm calls BLOCK 3. Reads the controller;
// never deletes persisted state itself, never reads DateTime.now().
// ============================================================================

class EraseView extends ConsumerWidget {
  const EraseView({super.key, required this.scope, this.profileId});

  final EraseScope scope;
  final String? profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context)!;  // empathy-then-consequence copy, fa/ckb/ar (11 §4/§6)

    // Build the CONCRETE, IRREVERSIBLE consequence text from the scope. Lead with understanding,
    // state the permanent fact, end with the user's real choice — NEVER "you'll lose your hifz",
    // NEVER "you must" (11 §4/§6; domain-adab-and-religious-integrity). Labels are ARB strings.
    final content = DestructiveConfirmContent(
      title: '',            // TODO: l10n.eraseTitle(scope)  — calm, non-blaming
      consequence: '',      // TODO: l10n.eraseConsequence(scope) — what / permanent / nothing recoverable
      cancelLabel: '',      // TODO: l10n.keepMyData         — the SAFE, primary label
      destructiveLabel: '', // TODO: l10n.eraseEverything    — the destructive, secondary label
      exportFirstLabel: '', // TODO: l10n.exportBackupFirst  — optional, NEVER forced (10 §11)
    );

    // Whole-device erase ⇒ require the BLOCK 2 second gate; a single profile may skip it (10 §9).
    // final needsSecondGate = scope == EraseScope.allDataOnDevice;

    return Directionality(
      // TODO: textDirection from the active locale (fa/ckb/ar => RTL). Rely on EdgeInsetsDirectional,
      //       not hardcoded left/right (05 §5). Any transition into this surface obeys
      //       MediaQuery.of(context).disableAnimations — cross-fade / instant cut (06 §5).
      textDirection: TextDirection.rtl,
      child: DestructiveConfirmSheet(
        content: content,
        onCancel: () {
          // TODO: Navigator.pop(context);  // the SAFE, primary, default-focused path (10 §9)
        },
        onConfirm: () async {
          // TODO: if needsSecondGate and the BLOCK 2 gate is not armed, present/await it first.
          // TODO: await ref.read(eraseControllerProvider.notifier).erase(scope, profileId: profileId);
          // Quiet, factual outcome — NO confetti, NO red alarm flourish, NO success haptic (06 §2/§4).
          // After erase, nothing about the user persists on-device (PRD §16).
        },
        onExportFirst: () {
          // TODO: open the export flow (domain-backup-format) — offered, never required (10 §11).
        },
      ),
    );
  }
}

// ============================================================================
// BLOCK 5 — test/features/settings/erase_view_test.dart  (widget + golden + offline guard)
// Verifies: (a) the CONCRETE consequence text is shown (never a bare "Are you sure?"),
// (b) Cancel is the primary + default-focused control and the destructive button is secondary,
// (c) confirming routes through the single write path and the rows — incl. review_log — are gone,
// (d) NO Slider/celebration; at most one haptic.warning, (e) RTL goldens per locale (fa/ckb/ar),
// (f) an HttpOverrides offline guard proves NO socket opens on erase. (eng-write-dart-test.)
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('the confirmation states a concrete, irreversible consequence', (tester) async {
//     // TODO: pump EraseView(scope: allDataOnDevice); assert the consequence text names WHAT is
//     // TODO:   erased + that it is permanent + that nothing is recoverable; NOT a bare "Are you sure?".
//   });
//
//   testWidgets('Cancel is the primary + default-focused control; destructive is secondary', (tester) async {
//     // TODO: expect the SAFE action is a FilledButton with autofocus; the destructive action is NOT.
//   });
//
//   testWidgets('confirming routes through the single write path and truly deletes rows', (tester) async {
//     // TODO: confirm erase; verify the fake repository ran ONE transaction that DELETED the rows
//     // TODO:   (incl. review_log) BEFORE state republished — and set NO "deleted" soft-delete flag.
//   });
//
//   testWidgets('erase is quiet — no celebration, at most one warning haptic', (tester) async {
//     // TODO: assert no confetti/celebration widget; at most a single haptic.warning at the gate.
//   });
//
//   testWidgets('no socket opens on erase (offline guard)', (tester) async {
//     // TODO: wrap in HttpOverrides that throws on any connection; run erase; expect no socket attempt.
//   });
//
//   // TODO: RTL golden per locale — matchesGoldenFile for fa, ckb, ar (consequence wraps not truncates;
//   // TODO:   safe action low/primary; destructive in the top-start corner of its entry point; mirrored).
// }
