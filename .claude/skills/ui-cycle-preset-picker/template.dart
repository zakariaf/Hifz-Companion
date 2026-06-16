// SCAFFOLD — this file bundles the pieces of the Hifz Companion cycle-preset picker.
// It is NOT a standalone Dart file: it contains a domain-blind picker widget, the
// feature-layer wiring that maps the chosen preset -> EngineConfig and persists it,
// plus a controller stub and a widget-test stub. Copy each labelled block into the
// right file under packages/, then fill every // TODO. Opening this file on its own
// shows unresolved symbols — that is expected; the real symbols (EngineConfig and the
// engine value types, AppLocalizations, the design-system token layer, the Riverpod
// providers) resolve only inside the pub workspace.
//
// Three pieces, in two layers:
//   1. CyclePresetPicker — shared ui/ leaf, DOMAIN-BLIND (named options + a selection
//      callback only; it knows NO engine types and computes NOTHING).
//   2. CyclePresetController — features/settings controller: maps the chosen preset to
//      an EngineConfig and persists it through the SINGLE WRITE PATH.
//   3. CycleSettingsView — features/ leaf: localizes the labels, owns RTL geometry,
//      and hands the picker the current selection + the callback.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / space.* / touch.min / motion.*).
// The design docs own the concrete values — never inline hex / dp / sp / ms here.
//
// Governing docs:
//   docs/PRD.md §15.1 (the named preset set; "not sliders"), §7.6 (trust clamp),
//     §7.11 (pure-cycle), §15.2/§15.3 (term-set + per-profile), §17/§18 (offline + a11y)
//   docs/design-system/01-design-principles.md §3 (named cycles, never a target_R dial),
//     §2 (calm — no celebration), §6 (RTL + locale numerals + term-sets), §5 (offline feel)
//   docs/engineering/06-scheduling-engine.md §6 (preset -> EngineConfig.farCycleDays / pureCycleMode;
//     due = min(SR-ideal, ceiling); the picker stores, the engine enforces)
//   docs/design-system/07-components.md §6 (M3 state layers + visible focus ring + Semantics)
//   eng-create-riverpod-store (persist-before-republish single write path)
//   eng-rtl-and-bidi-layout (EdgeInsetsDirectional, locale numerals, FSI/PDI isolation)
//   eng-add-localized-string (preset + manzil/juz term-set strings, fa/ckb/ar)
//
// Non-negotiables this scaffold encodes:
//   - Presets are NAMED single-select choices. NO slider, NO target_R dial, NO FSRS D/S/R shown.
//   - The picker writes ONLY EngineConfig; it NEVER computes due_at, reorders, or reads R.
//   - Pure-cycle is ONE explicit flag, framed as fidelity ("follow my cycle exactly"), not "off".
//   - Selection is quiet: NO confetti / streak / badge / score / "optimal!" / "you're behind".
//   - RTL by EdgeInsetsDirectional; labels are localized term-set strings; numerals are locale.
//   - Offline / no-AI: stores a choice, computes nothing, works in airplane mode.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/cycle_preset_picker.dart  (shared ui/, DOMAIN-BLIND)
// A named single-select list + a Pure-cycle toggle. It takes ONLY primitives and
// callbacks: it does NOT import the engine, does NOT know EngineConfig, and computes
// nothing. The feature layer maps the chosen id -> EngineConfig (BLOCK 2).
// (01-design-principles.md §3: named cycles, never a target_R dial.)
// ============================================================================

/// The named cycle presets the user can choose. These are *identifiers* only —
/// their display names are localized term-set strings supplied by the feature layer,
/// and their engine effect is mapped in BLOCK 2. There is deliberately NO "retention"
/// or "target_R" option here (PRD §15.1; 01-design-principles.md §3).
enum CyclePresetId { sevenManzilWeekly, oneJuzPerDay, halfJuzPerDay, twoJuzPerDay, custom }

/// One row of display data for a preset. The feature layer builds these from
/// AppLocalizations + the active term-set; the picker never hardcodes a name.
class CyclePresetOption {
  const CyclePresetOption({
    required this.id,
    required this.label,       // localized term-set string, e.g. "7-Manzil weekly khatm"
    required this.subtitle,    // localized, e.g. "full Quran every ۷ days" (locale numerals)
  });
  final CyclePresetId id;
  final String label;
  final String subtitle;
}

/// Named-cycle selector + Pure-cycle toggle. DOMAIN-BLIND: primitives and callbacks only.
///
/// - [options]            : the named presets to show (already localized, in display order).
/// - [selectedId]         : the currently-selected preset.
/// - [pureCycleEnabled]   : whether Pure-cycle mode (fixed rotation) is on.
/// - [pureCycleLabel]     : localized toggle label, framed as fidelity, NOT "turn off smart…".
/// - [onPresetSelected]   : invoked on selection; the feature layer routes it through the
///                          controller's single write path (it must NOT mutate config here).
/// - [onPureCycleToggled] : invoked on toggle; same single-write-path rule.
/// - [customEditor]       : the slot for the Custom editor (BLOCK 3), shown only when
///                          [selectedId] == custom. Four bounded fields, no retention target.
class CyclePresetPicker extends StatelessWidget {
  const CyclePresetPicker({
    super.key,
    required this.options,
    required this.selectedId,
    required this.pureCycleEnabled,
    required this.pureCycleLabel,
    required this.onPresetSelected,
    required this.onPureCycleToggled,
    this.customEditor,
  });

  final List<CyclePresetOption> options;
  final CyclePresetId selectedId;
  final bool pureCycleEnabled;
  final String pureCycleLabel;
  final ValueChanged<CyclePresetId> onPresetSelected;
  final ValueChanged<bool> onPureCycleToggled;
  final Widget? customEditor;

  @override
  Widget build(BuildContext context) {
    // A radiogroup of named options — NEVER a Slider. Selection is signalled by an M3
    // state layer + the radio glyph (shape AND state), never color alone (07 §6).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in options)
          // TODO: use RadioListTile<CyclePresetId> (or a selectable Card) on the M3
          // TODO: single-select pattern. contentPadding = EdgeInsetsDirectional (RTL).
          // TODO: title = option.label in type.body; subtitle = option.subtitle in
          // TODO:   type.caption / color.text.secondary; row height >= touch.min (>=48dp).
          // TODO: wrap each row in Semantics(label: option.label, selected: ...,
          // TODO:   inMutuallyExclusiveGroup: true) so it announces as a radiogroup item.
          // TODO: a visible focus ring (color.outline) for keyboard/switch-control (WCAG 2.4.7).
          _PresetRowPlaceholder(
            option: option,
            isSelected: option.id == selectedId,
            onSelected: () => onPresetSelected(option.id),
          ),

        // The Custom editor is revealed inline ONLY when Custom is selected.
        if (selectedId == CyclePresetId.custom && customEditor != null)
          Padding(
            // TODO: EdgeInsetsDirectional.only(start: space.4) — logical inset, RTL-safe.
            padding: EdgeInsetsDirectional.zero, // TODO: space.4
            child: customEditor,
          ),

        // TODO: a quiet section divider (space.6) — no celebratory chrome.

        // Pure-cycle mode: ONE explicit flag, framed as fidelity (PRD §7.11; engine §6).
        // TODO: SwitchListTile.adaptive(
        // TODO:   value: pureCycleEnabled, onChanged: onPureCycleToggled,
        // TODO:   title: Text(pureCycleLabel, style: /* type.body */),
        // TODO:   contentPadding: EdgeInsetsDirectional...,
        // TODO: ) wrapped in Semantics(label: pureCycleLabel, toggled: pureCycleEnabled).
        // The label is fidelity copy ("follow my cycle exactly"), NEVER "disable smart scheduling".
      ],
    );
  }
}

// Placeholder so the scaffold parses; replace with a real RadioListTile/Card in BLOCK 1.
class _PresetRowPlaceholder extends StatelessWidget {
  const _PresetRowPlaceholder({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });
  final CyclePresetOption option;
  final bool isSelected;
  final VoidCallback onSelected;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // TODO: real row
}

// ============================================================================
// BLOCK 2 — packages/features/lib/src/settings/cycle_preset_controller.dart
// Maps the chosen preset -> EngineConfig and persists it through the SINGLE WRITE PATH:
// persist transactionally FIRST, then republish in-memory state (eng-create-riverpod-store).
// The engine then rebuilds the day deterministically (engine §6–§7) — this controller
// computes NO due_at and reorders NOTHING.
// ============================================================================

/// The preset -> cycle-ceiling mapping. This is the picker's ENTIRE engine effect:
/// it sets EngineConfig.farCycleDays (the trust-clamp ceiling), never a target_R.
/// (PRD §15.1; engine §6 cycleCeilingDays.)  EngineConfig itself is owned by the
/// engine package — see domain-scheduling-engine-rules.
int farCycleDaysFor(CyclePresetId id) {
  switch (id) {
    case CyclePresetId.sevenManzilWeekly:
      return 7; // weekly khatm — full Quran every 7 days
    case CyclePresetId.oneJuzPerDay:
      return 30;
    case CyclePresetId.halfJuzPerDay:
      return 60;
    case CyclePresetId.twoJuzPerDay:
      return 15;
    case CyclePresetId.custom:
      // TODO: read far-cycle length from the Custom editor's value (bounded field).
      throw UnimplementedError('custom far-cycle length comes from the Custom editor');
  }
}

// TODO: declare a Riverpod Notifier/AsyncNotifier (see eng-create-riverpod-store), e.g.:
// final cyclePresetControllerProvider = NotifierProvider<CyclePresetController, EngineConfig>(...);
class CyclePresetController /* extends Notifier<EngineConfig> */ {
  // TODO: inject the repository that owns the transactional EngineConfig write
  //       (eng-define-service-boundary — never a global singleton, never DateTime.now()).

  /// Select a named preset. Single write path: build the new EngineConfig, PERSIST it
  /// transactionally, THEN republish state and let the engine rebuild the day.
  Future<void> selectPreset(CyclePresetId id) async {
    // TODO: final next = state.copyWith(
    // TODO:   farCycleDays: farCycleDaysFor(id),
    // TODO:   selectedPreset: id,           // remember the named choice for the UI
    // TODO:   pureCycleMode: state.pureCycleMode, // unchanged here
    // TODO: );
    // TODO: await _repository.saveEngineConfig(next);  // PERSIST FIRST (transactional)
    // TODO: state = next;                              // THEN republish
    // TODO: // the engine's buildToday() reruns off the new config — we do NOT call it by hand
    //       NEVER: compute due_at, reorder pages, or touch FSRS D/S/R here.
  }

  /// Toggle Pure-cycle mode — exactly ONE flag (PRD §7.11; engine §6 one-flag change).
  Future<void> setPureCycle(bool enabled) async {
    // TODO: final next = state.copyWith(pureCycleMode: enabled);
    // TODO: await _repository.saveEngineConfig(next); // persist-before-republish
    // TODO: state = next;
  }

  /// Apply a Custom config — four bounded fields, each 1:1 with an EngineConfig field.
  /// NO raw retention target is accepted (PRD §15.1).
  Future<void> applyCustom({
    required int farCycleDays,      // bounded
    required int nearWindowJuz,     // bounded
    required int newLinesPerDay,    // bounded
    required int dailyBudgetMinutes,// bounded
  }) async {
    // TODO: build EngineConfig from these four fields + persist-before-republish.
    //       There is NO target_R / D / S parameter — those are internal to the engine.
  }
}

// ============================================================================
// BLOCK 3 — packages/features/lib/src/settings/cycle_settings_view.dart
// Dumb View: localizes labels (term-set), owns RTL geometry + locale numerals, and
// hands BLOCK 1 the current selection + callbacks that call BLOCK 2. Reads the
// controller; never mutates config itself.
// ============================================================================

class CycleSettingsView extends ConsumerWidget {
  const CycleSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final config = ref.watch(cyclePresetControllerProvider); // EngineConfig
    // final l10n   = AppLocalizations.of(context)!;            // term-set strings (fa/ckb/ar)

    // Build localized options. Subtitles render numerals in the locale set (Extended
    // Arabic-Indic for fa/ckb, Arabic-Indic for ar) via intl NumberFormat, with mixed
    // Latin/number runs bidi-isolated (FSI/PDI) — see eng-rtl-and-bidi-layout.
    final options = <CyclePresetOption>[
      // TODO: CyclePresetOption(id: sevenManzilWeekly, label: l10n.cycleSevenManzil,
      // TODO:   subtitle: l10n.cycleSevenManzilSub(localeNumber(7))),
      // TODO: ... oneJuzPerDay / halfJuzPerDay / twoJuzPerDay / custom ...
      //       Labels are TERM-SET strings (regional manzil/juz vocabulary), NEVER hardcoded English.
    ];

    return Directionality(
      // TODO: textDirection from the active locale (fa/ckb/ar => RTL). The app is RTL by
      //       construction; rely on EdgeInsetsDirectional, not hardcoded left/right (01 §6).
      textDirection: TextDirection.rtl,
      child: CyclePresetPicker(
        options: options,
        selectedId: CyclePresetId.oneJuzPerDay, // TODO: config.selectedPreset
        pureCycleEnabled: false,                // TODO: config.pureCycleMode
        pureCycleLabel: 'TODO: l10n.pureCycleFidelity', // fidelity copy, NOT "turn off smart…"
        onPresetSelected: (id) {
          // TODO: ref.read(cyclePresetControllerProvider.notifier).selectPreset(id);
          // Quiet, factual change — NO snackbar fanfare, NO "optimal!", NO exclamation (01 §2).
        },
        onPureCycleToggled: (on) {
          // TODO: ref.read(cyclePresetControllerProvider.notifier).setPureCycle(on);
        },
        customEditor: const _CustomCycleEditorPlaceholder(),
      ),
    );
  }
}

/// The Custom editor: exactly four bounded, labelled fields, each 1:1 with an EngineConfig
/// field (PRD §15.1). NO retention target, NO "advanced math" pane, NO D/S/R.
class _CustomCycleEditorPlaceholder extends StatelessWidget {
  const _CustomCycleEditorPlaceholder();
  @override
  Widget build(BuildContext context) {
    // TODO: four steppers/selects, labelled in term-set strings, locale numerals, RTL:
    // TODO:   far-cycle length (days) · near-window size (juz) · new-lines/day · daily budget (min)
    // TODO: on commit -> controller.applyCustom(...). Each field bounded; no free target_R.
    return const SizedBox.shrink();
  }
}

// ============================================================================
// BLOCK 4 — test/features/settings/cycle_preset_picker_test.dart  (widget + mapping)
// Verifies: (a) selecting a named preset routes through the controller (single write path),
// (b) the preset -> farCycleDays mapping is correct, (c) Pure-cycle flips exactly one flag,
// (d) NO Slider exists anywhere in the tree, (e) RTL goldens per locale (fa/ckb/ar).
// (eng-write-dart-test; the clamp invariant itself is golden-tested in domain-scheduling-engine-rules.)
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   test('preset -> farCycleDays mapping is exact', () {
//     // TODO: expect(farCycleDaysFor(CyclePresetId.sevenManzilWeekly), 7);
//     // TODO: expect(farCycleDaysFor(CyclePresetId.oneJuzPerDay), 30);
//     // TODO: expect(farCycleDaysFor(CyclePresetId.halfJuzPerDay), 60);
//     // TODO: expect(farCycleDaysFor(CyclePresetId.twoJuzPerDay), 15);
//   });
//
//   testWidgets('there is NO slider — presets are named choices only', (tester) async {
//     // TODO: pump CycleSettingsView with an overridden controller provider.
//     // TODO: expect(find.byType(Slider), findsNothing);   // PRD §15.1: not sliders
//   });
//
//   testWidgets('selecting a preset persists via the single write path', (tester) async {
//     // TODO: tap "1 juz / day"; verify the fake repository saved EngineConfig with
//     // TODO:   farCycleDays == 30 BEFORE in-memory state republished; no due_at computed.
//   });
//
//   testWidgets('pure-cycle toggle flips exactly one flag', (tester) async {
//     // TODO: toggle on; verify only pureCycleMode changed; farCycleDays unchanged.
//   });
//
//   // TODO: RTL golden per locale — matchesGoldenFile for fa, ckb, ar (term-set + locale numerals).
// }
