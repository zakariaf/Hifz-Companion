// SCAFFOLD — this file bundles the pieces of a Hifz Companion Settings single-choice
// picker. It is NOT a standalone Dart file: it contains a domain-blind single-select
// widget, the feature-layer wiring that builds the localized options for ONE preference
// and persists the choice, a controller stub, and a widget-test stub. Copy each labelled
// block into the right file under packages/, then fill every // TODO. Opening this file
// on its own shows unresolved symbols — that is expected; the real symbols (the settings
// value types, AppLocalizations, the design-system token layer, the Riverpod providers,
// the injected clock) resolve only inside the pub workspace.
//
// Three pieces, in two layers:
//   1. SettingsSinglePicker<T> — shared ui/ leaf, DOMAIN-BLIND (named options + a selection
//      callback only; it knows NO domain/engine types and computes NOTHING).
//   2. <Preference>SettingsController — features/settings controller: validates the chosen
//      value and persists it through the SINGLE WRITE PATH (persist-before-republish).
//   3. <Preference>SettingsView — features/ leaf: localizes the labels, owns RTL geometry +
//      locale numerals, and hands the picker the current selection + the callback.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / space.* / touch.min).
// The design docs own the concrete values — never inline hex / dp / sp here.
//
// Governing docs:
//   docs/design-system/07-components.md §6 (M3 single-select state layers + visible focus
//     ring (color.outline, WCAG 2.4.7) + Semantics selected; SegmentedButton for a short set;
//     selection is functional, NEVER a reward surface)
//   docs/design-system/12-localization-and-rtl.md §8 (the muṣḥaf is NEVER localized/re-typeset;
//     riwāyah stated, not "the Quran"), §5 (calendars = display transform over a single stored
//     instant — NEVER mutate the instant or due_at), §4 (locale numerals via intl), §6 (term-set
//     = swappable ARB strings; ckb provisional), §1 (RTL by geometry), §3 (FSI/PDI isolation)
//   docs/design-system/05-layout-spacing-touch.md §4 (≥48dp targets, ≥space.2 apart),
//     §5 (Settings template — destructive controls out of easy thumb reach), §3 (EdgeInsetsDirectional)
//   eng-create-riverpod-store (persist-before-republish single write path)
//   eng-define-service-boundary (the injected "today"/clock — never DateTime.now() in a View)
//   eng-rtl-and-bidi-layout (EdgeInsetsDirectional, locale numerals, FSI/PDI isolation)
//   eng-add-localized-string (option + term-set strings, fa/ckb/ar; ckb provisional)
//
// Non-negotiables this scaffold encodes:
//   - A 2+-value preference is a single-select RADIOGROUP. NO slider, NO free text, NO switch.
//   - The choice is a DISPLAY TRANSFORM: re-render dates/digits/labels/palette over UNCHANGED data.
//     A Settings picker NEVER mutates the scheduling engine, a due_at, or the stored instant.
//   - The muṣḥaf/riwāyah picker stores a NAMED edition + states the riwāyah; it NEVER re-typesets,
//     mirrors, translates, or applies UI numerals/fonts to the immutable glyph page.
//   - Selected state is shape (radio glyph) AND text — NEVER color alone; an M3 state layer.
//   - Selection is quiet: NO confetti / streak / badge / score / "recommended" / "optimal!".
//   - RTL by EdgeInsetsDirectional; labels are localized (term-set) strings; numerals are locale.
//   - Offline / no-AI: stores a choice, computes/infers nothing, works in airplane mode.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/settings_single_picker.dart  (shared ui/, DOMAIN-BLIND)
// A generic named single-select list for ONE Settings preference. It takes ONLY
// primitives and a callback: it does NOT import any domain/engine type, does NOT
// know what `T` means, and computes nothing. The feature layer maps T -> persisted
// preference (BLOCK 2/3). (07-components.md §6: M3 single-select state model.)
// ============================================================================

/// One row of display data for a Settings option. The feature layer builds these from
/// AppLocalizations + (for the term-set picker) the active regional term-set; the picker
/// never hardcodes a name. `value` is the typed preference value the callback returns.
class SettingsOption<T> {
  const SettingsOption({
    required this.value,
    required this.label,        // localized string, e.g. "Solar-Hijri (Jalālī)" / "Hijri (Umm al-Qurā)"
    this.subtitle,              // optional localized subtitle, locale-numeral + bidi-isolated
    this.isProvisional = false, // e.g. the ckb term-set default — mark provisional, never "final"
  });
  final T value;
  final String label;
  final String? subtitle;
  final bool isProvisional;
}

/// A single-choice Settings picker: a RADIOGROUP of named options. DOMAIN-BLIND —
/// primitives and one callback only. NO Slider, NO free text, NO Switch (a 2+-value
/// preference is mutually exclusive, not on/off).
///
/// - [options]    : the named options to show (already localized, in display order).
/// - [selected]   : the currently-selected value.
/// - [onSelected] : invoked on selection; the feature layer routes it through the
///                  controller's single write path (it must NOT persist here).
class SettingsSinglePicker<T> extends StatelessWidget {
  const SettingsSinglePicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<SettingsOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    // A radiogroup of named options — NEVER a Slider. Selection is signalled by an M3
    // state layer + the radio glyph (shape AND state), never color alone (07 §6).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final option in options)
          // TODO: use RadioListTile<T> (or a selectable Card, or SegmentedButton<T> when
          // TODO:   the set is short and short-labelled — 07 §6). The leading radio sits at
          // TODO:   the START (right) in RTL; contentPadding = EdgeInsetsDirectional (05 §3).
          // TODO: title = option.label in type.body; subtitle = option.subtitle in
          // TODO:   type.caption / color.text.secondary; row height >= touch.min (>=48dp, 05 §4).
          // TODO: if option.isProvisional, append a quiet localized "(provisional)" note —
          // TODO:   the ckb term-set default ships marked provisional (12 §6), never as final.
          // TODO: wrap each row in Semantics(label: option.label, selected: ...,
          // TODO:   inMutuallyExclusiveGroup: true) so it announces as a radiogroup item (07 §6).
          // TODO: ensure a visible focus ring (color.outline) for keyboard/switch-control (WCAG 2.4.7).
          _OptionRowPlaceholder<T>(
            option: option,
            isSelected: option.value == selected,
            onSelected: () => onSelected(option.value),
          ),
        // NO celebratory chrome, NO "recommended" badge, NO score. A quiet list and nothing more (07 §6).
      ],
    );
  }
}

// Placeholder so the scaffold parses; replace with a real RadioListTile/Card in BLOCK 1.
class _OptionRowPlaceholder<T> extends StatelessWidget {
  const _OptionRowPlaceholder({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });
  final SettingsOption<T> option;
  final bool isSelected;
  final VoidCallback onSelected;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // TODO: real row
}

// ============================================================================
// BLOCK 2 — packages/features/lib/src/settings/calendar_settings_controller.dart
// The calendar picker is the CANONICAL "display transform, never mutate" case: it
// persists the chosen calendar system through the SINGLE WRITE PATH and changes how
// dates are RENDERED — it NEVER mutates the stored instant or any due_at (12 §5).
// (Swap CalendarSystem for ThemeMode / NumeralSystem / TermSetId / MushafEditionId /
//  AppLocale to make the language/numerals/term-set/muṣḥaf/theme pickers — same shape.)
// ============================================================================

/// The user-selectable calendar systems (a DISPLAY choice, 12 §5). The chosen value is
/// a pure render transform over the single stored instant — it carries NO scheduling effect.
enum CalendarSystem { solarHijriJalali, hijriUmmAlQura, gregorian }

// TODO: declare a Riverpod Notifier (see eng-create-riverpod-store), e.g.:
// final calendarSettingsControllerProvider =
//     NotifierProvider<CalendarSettingsController, CalendarSystem>(...);
class CalendarSettingsController /* extends Notifier<CalendarSystem> */ {
  // TODO: inject the repository that owns the transactional preference write
  //       (eng-define-service-boundary — never a global singleton, never DateTime.now()).

  /// Select a calendar system. Single write path: PERSIST transactionally, THEN republish.
  /// This is presentation only — the engine, the due_at values, and the stored instant are
  /// UNTOUCHED; only the date RENDERING changes downstream (12 §5).
  Future<void> selectCalendar(CalendarSystem system) async {
    // TODO: await _repository.saveCalendarSystem(system); // PERSIST FIRST (transactional)
    // TODO: state = system;                               // THEN republish
    //       NEVER: convert/mutate stored timestamps, recompute due_at, or touch the engine.
    //       Dates are RE-RENDERED via intl DateFormat for the active locale + this calendar.
  }
}

// ============================================================================
// BLOCK 3 — packages/features/lib/src/settings/calendar_settings_view.dart
// Dumb View: localizes labels, owns RTL geometry + locale numerals, and hands BLOCK 1
// the current selection + a callback that calls BLOCK 2. Reads the controller; never
// persists itself, never reads DateTime.now() (the clock is injected — service boundary).
// ============================================================================

class CalendarSettingsView extends ConsumerWidget {
  const CalendarSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final selected = ref.watch(calendarSettingsControllerProvider);  // CalendarSystem
    // final l10n     = AppLocalizations.of(context)!;                  // localized labels (fa/ckb/ar)

    // Build localized options. Any numbered label (e.g. a Hijri year preview) renders numerals
    // in the locale set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) via intl
    // NumberFormat/DateFormat, with mixed Latin/number runs FSI/PDI-isolated — eng-rtl-and-bidi-layout.
    final options = <SettingsOption<CalendarSystem>>[
      // TODO: SettingsOption(value: solarHijriJalali, label: l10n.calendarJalali,
      // TODO:   subtitle: l10n.calendarJalaliPreview(localizedToday)),  // default for fa
      // TODO: SettingsOption(value: hijriUmmAlQura, label: l10n.calendarUmmAlQura, ...), // lead for ar
      // TODO: SettingsOption(value: gregorian, label: l10n.calendarGregorian, ...),
      //       Labels are ARB strings, NEVER hardcoded English (12 §4/§6).
    ];

    return Directionality(
      // TODO: textDirection from the active locale (fa/ckb/ar => RTL). The app is RTL by
      //       construction; rely on EdgeInsetsDirectional, not hardcoded left/right (12 §1, 05 §3).
      textDirection: TextDirection.rtl,
      child: SettingsSinglePicker<CalendarSystem>(
        options: options,
        selected: CalendarSystem.solarHijriJalali, // TODO: ref.watch(...) current value
        onSelected: (system) {
          // TODO: ref.read(calendarSettingsControllerProvider.notifier).selectCalendar(system);
          // Quiet, factual change — NO snackbar fanfare, NO "recommended", NO exclamation (07 §6).
          // The stored instant does NOT change; downstream date surfaces simply re-render (12 §5).
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// MUṢḤAF / RIWĀYAH PICKER — the special case (12 §8). Same SettingsSinglePicker<T>,
// but T is a NAMED edition id, and the label MUST state the riwāyah explicitly
// ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), never "the Quran" in the absolute. Selecting it
// stores the named edition (+ its pinned glyph-font/layout asset set); it NEVER
// re-typesets, mirrors, translates, or applies UI numerals/fonts to the glyph page.
// Rendering the chosen edition is ui-mushaf-page-view / domain-mushaf-text-integrity.
// ----------------------------------------------------------------------------

/// A named muṣḥaf edition id. The label states the riwāyah; this picker only persists
/// the choice. Applying it (font registration, layout, page assembly) is owned elsewhere.
enum MushafEditionId { hafsMadani /* TODO: add other reviewed editions/riwāyāt as packs land */ }

// TODO: a MushafSettingsController mirrors BLOCK 2: persist the named edition through the
// TODO:   single write path; do NOT touch the glyph layer here. ui-mushaf-page-view reads the
// TODO:   stored edition and renders the immutable page (domain-mushaf-text-integrity).

// ============================================================================
// BLOCK 4 — test/features/settings/settings_single_picker_test.dart  (widget + invariant)
// Verifies: (a) selecting an option routes through the controller (single write path),
// (b) NO Slider exists anywhere in the tree (a preference is a radiogroup, not a dial),
// (c) for the calendar picker, the stored instant is UNCHANGED after a calendar switch,
// (d) RTL goldens per locale (fa/ckb/ar), (e) the ckb term-set option is marked provisional.
// (eng-write-dart-test.)
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('a preference is a radiogroup — there is NO slider', (tester) async {
//     // TODO: pump CalendarSettingsView with an overridden controller provider.
//     // TODO: expect(find.byType(Slider), findsNothing);          // 2+-value pref != a dial
//     // TODO: expect(find.byType(RadioListTile<CalendarSystem>), findsWidgets);
//   });
//
//   testWidgets('selecting an option persists via the single write path', (tester) async {
//     // TODO: tap "Hijri (Umm al-Qurā)"; verify the fake repository saved the new value
//     // TODO:   BEFORE in-memory state republished; nothing else mutated.
//   });
//
//   test('switching calendar does NOT mutate the stored instant or any due_at', () {
//     // TODO: with a fixed injected "today" and a seeded card, switch calendar systems and
//     // TODO:   assert the stored instant + card.due_at are byte-identical before/after (12 §5).
//   });
//
//   testWidgets('the ckb term-set default is marked provisional', (tester) async {
//     // TODO: in the term-set picker, assert the ckb default row carries the provisional note (12 §6).
//   });
//
//   // TODO: RTL golden per locale — matchesGoldenFile for fa, ckb, ar (labels + locale numerals,
//   // TODO:   leading radio at the START/right, mixed runs FSI/PDI-isolated).
// }
