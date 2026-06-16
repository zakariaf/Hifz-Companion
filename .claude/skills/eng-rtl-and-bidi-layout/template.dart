// template.dart — eng-rtl-and-bidi-layout
//
// A copy-paste scaffold for a typical RTL *chrome* surface in the Hifz Companion app.
// Fill the // TODO markers. Every rule traces to a governing doc section:
//   - docs/engineering/12-localization-rtl-accessibility-impl.md  (§2 direction, §4 bidi, §5 numerals, §8 gate)
//   - docs/design-system/12-localization-and-rtl.md               (§1 geometry, §2 mirroring, §3 isolation, §4 numerals, §8 sacred/UI split)
//   - docs/engineering/07-dates-calendars-and-correctness.md      (§4 calendar render — numerals downstream of conversion)
//
// HARD BOUNDARY: this toolkit is CHROME-ONLY. No mirroring, NumberFormat, bidi control,
// UI font, or term-set ever reaches the muṣḥaf glyph layer (ds-12 §8). Date *conversion*,
// ARB strings, Semantics, and the CalendarPresenter belong to sibling skills (see header
// of references.md). This file places already-localized values into a correct RTL line.

import 'package:flutter/foundation.dart' show Unicode; // FSI/RLI/LRI/PDI isolate constants
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show Bidi, NumberFormat;

// import 'package:<app>/l10n/app_localizations.dart';      // TODO: generated AppLocalizations
// import 'package:<app>/l10n/ckb_material_localizations.dart'; // TODO: vendored ckb delegate (impl-12 §3)
// import '<feature>/calendar_presenter.dart';              // TODO: sibling-owned conversion (dates-07 §4)

// ─────────────────────────────────────────────────────────────────────────────
// 1. App wiring — RTL is LOCALE-DERIVED, never a hardcoded Directionality.
//    impl-12 §2 (direction derived from the locale) · ds-12 §1 (RTL by geometry)
// ─────────────────────────────────────────────────────────────────────────────

MaterialApp buildApp(Widget home) {
  return MaterialApp(
    // No `locale:` override and NO root Directionality(TextDirection.rtl):
    // GlobalWidgetsLocalizations sets the default direction from the resolved locale,
    // and all three shipping locales are RTL, so the whole app is RTL by construction.
    localizationsDelegates: const [
      // ...AppLocalizations.localizationsDelegates, // TODO: includes the three Global* delegates
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate, // <-- this is what makes direction RTL
      GlobalCupertinoLocalizations.delegate,
      // CkbMaterialLocalizations.delegate, // TODO: Flutter ships no ckb chrome (impl-12 §3)
    ],
    supportedLocales: const [
      Locale('ar'),
      Locale('fa'),
      Locale.fromSubtags(languageCode: 'ckb'), // custom locale (impl-12 §3)
    ],
    home: home,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. The single bidi-isolation helper — route EVERY mixed-script run through it.
//    impl-12 §4 (one helper; prefer known-direction over FSI) · ds-12 §3 (FSI/PDI)
//    Prefer LRI/RLI isolating controls over legacy LRE/RLE/LRO/RLO (UAX #9).
// ─────────────────────────────────────────────────────────────────────────────

/// Isolate a run of *unknown* direction (user-typed names, arbitrary tokens).
String isolate(String run) => '${Unicode.FSI}$run${Unicode.PDI}';

/// Isolate a run whose direction we KNOW — prefer over FSI (no first-strong mis-guess).
String isolateLtr(String run) => '${Unicode.LRI}$run${Unicode.PDI}';
String isolateRtl(String run) => '${Unicode.RLI}$run${Unicode.PDI}';

/// True iff a string has RTL content — to pick the right isolate when needed.
bool _isRtl(String s) => Bidi.hasAnyRtl(s);

// ─────────────────────────────────────────────────────────────────────────────
// 3. Per-locale numerals — pin the numbering system; ASCII digits never reach copy.
//    impl-12 §5 (per-locale NumberFormat, pinned -u-nu-) · ds-12 §4 (type.numeral)
//    fa/ckb → Extended Arabic-Indic (۰۱۲۳۴۵۶۷۸۹), ar → Arabic-Indic (٠١٢٣٤٥٦٧٨٩).
// ─────────────────────────────────────────────────────────────────────────────

NumberFormat numberFormatFor(Locale locale) {
  final tag = switch (locale.languageCode) {
    'fa' => 'fa-u-nu-arabext', // Extended Arabic-Indic (U+06F0..)
    'ckb' => 'ckb-u-nu-arabext', // Sorani uses the same Extended set
    'ar' => 'ar-u-nu-arab', // Arabic-Indic (U+0660..) — pinned, not a bare-locale default
    _ => 'en',
  };
  return NumberFormat.decimal(tag);
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. A logical-inset Riverpod widget rendering an isolated, locale-numeralled line.
//    impl-12 §2 (EdgeInsetsDirectional / start-end) · ds-12 §1 (logical everywhere)
//    impl-12 §4 (isolate the embedded run) · §5 (format the number first)
// ─────────────────────────────────────────────────────────────────────────────

class TodayPageLabel extends ConsumerWidget {
  const TodayPageLabel({super.key, required this.pageNumber, required this.totalPages});

  final int pageNumber;
  final int totalPages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final fmt = numberFormatFor(locale);
    // final l10n = AppLocalizations.of(context)!; // TODO: ARB strings (eng-localization-arb-pipeline)

    // Format the numbers to locale digits, then isolate each as a known-direction run.
    // The localized sentence is an ARB placeholder string like "{page} از {total}" —
    // NEVER "Page " + n. Isolation wraps the embedded TOKEN, not the surrounding word.
    final page = isolateLtr(fmt.format(pageNumber));
    final total = isolateLtr(fmt.format(totalPages));

    return Padding(
      // Correct: logical inset resolves to the right edge under RTL.
      // REFUSED (grep-banned): EdgeInsets.only(left: 16) — bypasses mirroring (impl-12 §2).
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16), // space.* scale
      child: Align(
        alignment: AlignmentDirectional.centerStart, // not Alignment.centerLeft
        // The whole label stays in ONE Text/TextSpan (ds-12 §3 — never fragment an
        // Arabic-script word). The isolated tokens are interpolated into the ARB value.
        child: Text('TODO l10n.todayLabel(page, total)'), // e.g. "{page} از {total}"
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. A directional icon — mirror sequence/nav glyphs ONLY; the muṣḥaf is never mirrored.
//    ds-12 §2 (the mirroring table is authoritative)
// ─────────────────────────────────────────────────────────────────────────────

class NextPageButton extends StatelessWidget {
  const NextPageButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Auto-mirroring family: arrow_forward flips under ambient RTL (ds-12 §2).
      // DO mirror: back/next/chevron/progress/sign-off.
      // DON'T mirror: media-play/clock/phone/numerals — and NEVER the muṣḥaf glyph
      // page, ayah-end marker, or sajda sign (ds-12 §2, §8 — sacred glyph layer).
      icon: const Icon(Icons.arrow_forward),
      onPressed: onTap,
      // tooltip: l10n.nextPage, // TODO: localized Semantics label (eng-accessibility-implementation)
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Rendering a CONVERTED date — conversion is sibling-owned; we render in RTL.
//    dates-07 §4 (numerals remapped downstream of conversion) · ds-12 §5 (calendars)
// ─────────────────────────────────────────────────────────────────────────────

class DueDateLabel extends ConsumerWidget {
  const DueDateLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);

    // The CalendarPresenter (domain-calendars-and-hifzdate) already converted the
    // CalendarDate to the user's chosen CalendarSystem and produced a label whose
    // month-name/era come from the calendar package. We ONLY:
    //   (a) remap its Latin digits to the locale set (numberFormatFor), DOWNSTREAM, and
    //   (b) isolate the run so it reads correctly inside RTL copy.
    // We do NOT convert here, infer the calendar from Locale.current, or hardcode week-start
    // (Saturday for fa/ar comes from CLDR — ds-12 §5).
    // final presented = ref.watch(calendarPresenterProvider).format(dueDate); // TODO
    const presentedLatin = 'TODO converted-date-with-latin-digits';
    final localized = isolateRtl(_toLocaleNumerals(presentedLatin, locale));

    return Text(localized); // single Text/TextSpan
  }

  // Downstream numeral remap (dates-07 §4): convert first, then digits — never inside conversion.
  String _toLocaleNumerals(String s, Locale locale) {
    final zero = numberFormatFor(locale).format(0); // the locale's '0' glyph
    final base = zero.codeUnitAt(0) - 0x30; // offset from ASCII '0' to the locale block
    return String.fromCharCodes(
      s.runes.map((r) => (r >= 0x30 && r <= 0x39) ? r + base : r),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. The TWO permitted manual-Directionality islands. impl-12 §2.
// ─────────────────────────────────────────────────────────────────────────────

/// (a) A Latin-only technical token forced LTR so it doesn't scramble inside RTL chrome
/// (e.g. a version string or a hex checksum on an auditor/Settings screen).
Widget latinIsland(String buildSha) =>
    Directionality(textDirection: TextDirection.ltr, child: Text(buildSha));

/// (b) Settings language preview: render a sample in the CANDIDATE locale's direction.
Widget languagePreview(String sample, TextDirection previewDir) =>
    Directionality(textDirection: previewDir, child: Text(sample));

// Everywhere else, logic that needs direction reads it from context — never a constant:
//   final dir = Directionality.of(context); // NOT `TextDirection.rtl`

// ─────────────────────────────────────────────────────────────────────────────
// 8. The release gate — per-locale RTL + numeral goldens on the REAL bundled fonts.
//    impl-12 §8 (gate layers) · ds-12 §1 (RTL focus/reading order is tested)
//    Harness: eng-write-dart-test. Goldens NEVER use Ahem/a placeholder font.
// ─────────────────────────────────────────────────────────────────────────────

// testWidgets('TodayPageLabel — per-locale RTL + numeral golden', (tester) async {
//   for (final locale in const [Locale('fa'), Locale.fromSubtags(languageCode: 'ckb'), Locale('ar')]) {
//     await tester.pumpWidget(/* TODO wrap in buildApp + ProviderScope, force `locale` */);
//     // Assert: layout mirrors RTL; numbers show the locale block
//     //   fa/ckb → Extended Arabic-Indic (U+06F0..), ar → Arabic-Indic (U+0660..); no ASCII digits.
//     // await expectLater(find.byType(TodayPageLabel), matchesGoldenFile('today_label_$locale.png'));
//   }
// });
