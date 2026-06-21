# 12 — Localization, RTL & Accessibility (implementation)

This document specifies how Hifz Companion is internationalized, mirrored, and made accessible — the implementation layer beneath [PRD §13 (Localization & RTL)](../PRD.md) and [PRD §18 (Accessibility)](../PRD.md). It covers the `gen_l10n`/ARB pipeline for the three RTL locales (`ar`, `fa`, `ckb`); how direction is *derived from the locale* rather than hardcoded; the custom `ckb` localizations delegate Flutter does not ship; one bidi-isolation helper for every mixed-script run; per-locale numerals across two distinct Unicode blocks; the display boundary where the calendar conversion owned by [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md) is rendered; and the screen-reader, dynamic-text, contrast, and touch-target implementation that makes the daily recite/grade flow usable for low-vision and motor-impaired huffaz. It applies the *Decision log: Localization, RTL & accessibility impl* entry (README decision 10) and is grounded in the evidence dossier [research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md).

The boundaries are deliberate. This doc owns the **chrome** — the localizable UI strings, layout direction, numerals, and accessibility annotations of every screen. It does **not** own the muṣḥaf: the Quran text is never localized, never re-typeset, and never run through `NumberFormat` or the bidi helper; it is the immutable glyph layer owned by [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md) ([PRD §11.2, §13.1](../PRD.md)). It does not own the calendar *conversion* (that is [07](07-dates-calendars-and-correctness.md)); it owns only the *rendering* of a converted date into locale numerals inside an RTL line. The design-system docs (`docs/design-system/`) own the color tokens, the contrast palette, and the heat-map's non-color encodings; this doc owns the code-level gates that prove those tokens are applied. Where guidance here meets the muṣḥaf, the README's first outranking rule wins: **the sacred text is never put at risk** — the i18n layer touches only chrome.

One framing rule governs everything below: **because all three shipping locales are RTL, RTL is not a mode — it is the default that must never break, and a physical-side layout slip is a guaranteed visible bug in every locale, not a latent one in an unused one.** Direction follows the locale automatically; our job is to never fight it, never hardcode against it, and to test it as an always-on, first-class invariant ([PRD §13.2, §20 gate 5](../PRD.md)).

## At a glance

| Concern | Decision |
|---|---|
| String pipeline | **`flutter_localizations` + `intl` + `gen_l10n`** over ARB; `generate: true`; type-safe `AppLocalizations` — missing key = compile error ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)) |
| Template / base content language | **`ar`** (`app_ar.arb`) — the Arabic-script base; `fa`/`ckb` are translations ([PRD §13.1](../PRD.md)) |
| Direction | **Locale-derived RTL** via `GlobalWidgetsLocalizations`; no app-wide hardcoded `Directionality` ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)) |
| Layout APIs | **Direction-relative only** — `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`; physical sides CI-banned ([Flutter: Directionality class](https://api.flutter.dev/flutter/widgets/Directionality-class.html)) |
| `ckb` (Sorani) | **Custom locale** + vendored Material-localizations delegate; not in Flutter's built-in set ([flutter/flutter #35103](https://github.com/flutter/flutter/issues/35103)) |
| Mixed-script runs | **One bidi-isolation helper** (FSI…PDI / explicit RLI·LRI) for page numbers, names, dates, Latin tokens ([Unicode UAX #9](https://www.unicode.org/reports/tr9/)) |
| Numerals | **Per-locale `NumberFormat`** with explicit `-u-nu-` numbering system; Extended Arabic-Indic for `fa`/`ckb`, Arabic-Indic for `ar` ([Wikipedia: Eastern Arabic numerals](https://en.wikipedia.org/wiki/Eastern_Arabic_numerals)) |
| Regional terminology | sabaq/sabqi/manzil term-sets as a **region-override ARB / ICU `select`**, never edited base strings ([PRD §13.4](../PRD.md)) |
| Plurals | **ICU `plural`** for every count-bearing string; Arabic's six CLDR categories a translation contract ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)) |
| Screen readers | **`Semantics`** labels/hints/roles on every control, localized; tested with TalkBack/VoiceOver ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)) |
| Dynamic text | **`MediaQuery.textScaler`** respected; layouts legible at large scale; never a fixed pixel font ([Flutter: MediaQueryData.textScaler](https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html)) |
| Contrast / color | **≥ 4.5:1** text contrast; **never color alone** on the heat-map ([WCAG 2.2 SC 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html); [SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)) |
| Touch targets | **≥ 48×48 dp** for recite/grade controls ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility); [WCAG 2.2 SC 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)) |
| Gates | Compile-time key coverage + grep against hardcoded strings & physical sides + per-locale RTL/numeral goldens ([PRD §20 gate 5](../PRD.md)) |

---

## 1. The ARB / `gen_l10n` pipeline

### Decision

User-facing strings come **only** from the first-party `flutter_localizations` + `intl` + `gen_l10n` pipeline over ARB files, with code generation enabled (`generate: true`) and an `l10n.yaml` that sets **Arabic (`ar`) as the template/base content language**. The generated `AppLocalizations` class is the single accessor for every chrome string; a referenced-but-undefined key is a **compile error**, and a CI grep bans string literals inside `features/` widgets so no user-facing text can bypass the pipeline (*Decision log: Localization, RTL & accessibility impl*). The pure `engine/` package contains **no** user-facing strings and imports nothing from this layer.

### Rationale

- **The pipeline is prescriptive and code-generated.** Flutter's official path adds `flutter_localizations` and `intl`, enables the `generate` flag under `flutter:` in `pubspec.yaml`, and is configured by a root `l10n.yaml` with documented defaults (`arb-dir`, `template-arb-file`, `output-localization-file: app_localizations.dart`, `output-class: AppLocalizations`) ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)). ARB is JSON: "the key of each entry is used as the method name of the getter, while the value of that entry contains the localized message," and `@`-prefixed metadata carries `description` and `placeholders` for translators ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).
- **Codegen turns the release gate into a compiler invariant.** Generation is automatic on `flutter pub get`/`run` (or `flutter gen-l10n`), and the output is a **type-safe** class where every key becomes a getter/method — a typo or a missing key fails the build rather than missing at runtime ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)). This is exactly the [PRD §20](../PRD.md) gate ("zero missing ARB keys; no hardcoded user-facing strings") made structural rather than a manual review.
- **Arabic is the base content language by design.** Our base script is Arabic and the canonical religious terminology is Arabic ([PRD §13.1, §13.4](../PRD.md)); making `ar` the template keeps the source-of-truth copy in the language a reviewer/scholar reads natively, and `fa`/`ckb` are diffed against it.

### Specification

`l10n.yaml` at the repo root:

```yaml
# l10n.yaml — Arabic is the template/base content language.
arb-dir: lib/l10n
template-arb-file: app_ar.arb          # ar is the source of truth (PRD §13.1)
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false                 # missing key => compile error, not null
use-escaping: true                     # literal braces/apostrophes in fa/ar copy
synthetic-package: false               # emit into lib/ so it is reviewable in-repo
```

`pubspec.yaml` (relevant fragment):

```yaml
flutter:
  generate: true                       # turns on gen_l10n codegen

dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any
```

ARB entry shape — note the `@description` carries the translator/scholar context the PRD requires:

```json
// lib/l10n/app_ar.arb  (template / base content language)
{
  "@@locale": "ar",
  "todayTitle": "مراجعة اليوم",
  "@todayTitle": {
    "description": "AppBar title of the Today screen — the daily revision session."
  },
  "pagesDue": "{count, plural, zero{لا صفحات} one{صفحة واحدة} two{صفحتان} few{{count} صفحات} many{{count} صفحة} other{{count} صفحة}} مستحقة",
  "@pagesDue": {
    "description": "Count of pages due today. Arabic needs all six CLDR plural categories.",
    "placeholders": { "count": { "type": "int" } }
  }
}
```

`MaterialApp` wiring — the generated lists keep delegates and locales in sync with the ARB set:

```dart
MaterialApp(
  onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates, // includes the three Global* delegates
    CkbMaterialLocalizations.delegate,          // §3 — Flutter ships no ckb
  ],
  supportedLocales: const [
    Locale('ar'),
    Locale('fa'),
    Locale.fromSubtags(languageCode: 'ckb'),    // §3
  ],
  // no `locale:` override — let the device locale resolve; Settings can pin one.
)
```

### Pitfalls / what we refuse

- **We refuse hardcoded user-facing strings.** A CI grep over `features/**` bans string literals passed to `Text(...)`, `tooltip:`, `semanticsLabel:`, and `label:`; every such string must resolve through `AppLocalizations`. This is the enforcement half of [PRD §20 gate 5](../PRD.md).
- **We refuse runtime string lookup that can silently miss.** `nullable-getter: false` means a missing key cannot return `null` and degrade to an empty widget — it fails the build.
- **We refuse strings in the engine.** `/engine` is pure and locale-free ([06-scheduling-engine.md](06-scheduling-engine.md)); it returns structured state (grades, day-counts, track enums), and the presentation layer localizes them. A grep bans `AppLocalizations`/`intl` imports from `/engine`.

---

## 2. Direction is derived from the locale — never hardcoded

### Decision

App-wide RTL is a **consequence of locale selection**, supplied automatically by `GlobalWidgetsLocalizations`; we do **not** wrap the app in a hardcoded `Directionality(TextDirection.rtl)`. Feature code uses **only** direction-relative layout APIs — `EdgeInsetsDirectional`, `AlignmentDirectional`, `Positioned.directional`, `start`/`end` — and a CI grep bans physical-side APIs (`EdgeInsets.only(left:/right:)`, `Alignment.centerLeft/Right`, `Positioned(left:/right:)`) in `features/`. Manual `Directionality` is reserved for two narrow cases: forcing **LTR** around a Latin-only technical island, and an in-Settings language preview (*Decision log: Localization, RTL & accessibility impl*).

### Rationale

- **The framework already does the mirroring.** Flutter's docs draw the division of labor explicitly: "`GlobalWidgetsLocalizations.delegate` defines the default text direction, either left-to-right or right-to-left, for the widgets library" ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)). When the active locale is `ar`/`fa`/`ckb`, the ambient direction becomes RTL with no per-widget code. `Directionality` "determines the ambient directionality of text and text-direction-sensitive render objects," and `MaterialApp` installs it from the resolved locale ([Flutter: Directionality class](https://api.flutter.dev/flutter/widgets/Directionality-class.html)).
- **Direction-relative APIs resolve per the ambient direction.** `Padding` "depend[s] on `Directionality` to resolve `EdgeInsetsDirectional` objects into absolute `EdgeInsets` objects" ([Flutter: Directionality class](https://api.flutter.dev/flutter/widgets/Directionality-class.html)). Any hardcoded `EdgeInsets.only(left:)`, `Alignment.centerLeft`, or fixed positive `x`-offset bypasses mirroring and becomes an RTL bug. Because the app is RTL in **every** locale, that slip is guaranteed-visible, not latent ([research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md)).
- **Base direction reorders the whole UI, not just paragraphs.** The W3C i18n guidance frames why this is a layout-wide property: setting base direction reorders the entire interface, so direction-correctness is structural ([W3C i18n: Structural markup and right-to-left text](https://www.w3.org/International/questions/qa-html-dir)).

### Specification

The bottom nav, chevrons, and progress direction mirror automatically once start/end are used. The RTL nav order from [PRD §12](../PRD.md) (Today rightmost) is the *visual* result of laying children out in logical order under RTL — not a manual reversal:

```dart
// features/shell — logical order; RTL renders "Today" at the right edge automatically.
NavigationBar(
  destinations: [
    NavigationDestination(icon: const Icon(Icons.today),    label: l10n.navToday),
    NavigationDestination(icon: const Icon(Icons.menu_book), label: l10n.navMushaf),
    NavigationDestination(icon: const Icon(Icons.compare),   label: l10n.navMutashabihat),
    NavigationDestination(icon: const Icon(Icons.grid_on),   label: l10n.navProgress),
    NavigationDestination(icon: const Icon(Icons.settings),  label: l10n.navSettings),
  ],
)

// Correct: logical insets resolve to the right edge under RTL.
Padding(padding: const EdgeInsetsDirectional.only(start: 16), child: child)

// REFUSED — grep-banned: physical side ignores direction.
// Padding(padding: const EdgeInsets.only(left: 16), child: child)
```

The two permitted manual-`Directionality` islands:

```dart
// (a) A Latin-only technical token (e.g. a version string, a hex checksum in an
// auditor screen) forced LTR so it doesn't visually scramble inside RTL chrome.
Directionality(textDirection: TextDirection.ltr, child: Text(buildSha));

// (b) Settings language preview: render a sample in the candidate locale's direction.
Directionality(textDirection: previewDir, child: Text(sample));
```

### Pitfalls / what we refuse

- **We refuse a hardcoded app-wide `Directionality`.** Wrapping the root in `TextDirection.rtl` works today but hides physical-side bugs (they happen to look right) and breaks the moment a Latin island needs LTR. Direction must flow from the locale ([research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md)).
- **We refuse physical-side layout APIs in feature code.** The grep gate forbids `EdgeInsets.only(left:/right:)`, `Alignment.centerLeft/centerRight/topLeft/...`, and `Positioned(left:/right:)`; only `*Directional` and `start`/`end` pass. Icons that imply direction (back/next) use the auto-mirroring `Icons.arrow_back`/`Icons.arrow_forward` family, which respects ambient direction.
- **We refuse to assume RTL in logic.** Code never reads `TextDirection.rtl` as a constant; if direction is needed it reads `Directionality.of(context)`, so the rare LTR island and the language preview behave correctly.

---

## 3. `ckb` (Kurdish Sorani) is a custom locale with a vendored delegate

### Decision

`ckb` is declared as a custom locale via `Locale.fromSubtags(languageCode: 'ckb')`, and we supply a **custom `GlobalMaterialLocalizations` subclass + `LocalizationsDelegate`** (vendored or adapted from a community package such as `ckb_localizations`) for the built-in widget chrome Flutter does not ship for Central Kurdish. Our own strings already come from the ARB set; the delegate covers only framework chrome ("OK"/"Cancel", date-picker labels, tooltips). Direction is **not** part of this work — once `ckb` resolves, the Arabic-script locale yields RTL automatically (§2) (*Decision log: Localization, RTL & accessibility impl*).

### Rationale

- **Flutter's Material localizations do not include `ckb`.** `GlobalMaterialLocalizations` ships a fixed locale list and Central Kurdish is not among it — a long-standing tracked gap ([flutter/flutter #35103](https://github.com/flutter/flutter/issues/35103)). Without a delegate, built-in widget chrome falls back to a default language while our ARB strings still render in Sorani — a visibly mixed UI.
- **The documented remedy is a custom delegate.** Flutter's i18n guide walks through providing a custom `GlobalMaterialLocalizations` subclass and `LocalizationsDelegate` for an unsupported language and registering it in `localizationsDelegates` ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)). Community packages implement exactly this delegate for `ckb` and can be vendored ([pub.dev: ckb_localizations](https://pub.dev/packages/ckb_localizations)).
- **`Locale.fromSubtags` is the prescribed constructor** for a locale that may carry a script subtag (`ckb_Arab` if ever needed) ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).

### Specification

```dart
// l10n/ckb_material_localizations.dart — covers framework chrome only.
class CkbMaterialLocalizations extends GlobalMaterialLocalizations {
  const CkbMaterialLocalizations({
    super.localeName = 'ckb',
    required super.fullYearFormat,
    required super.compactDateFormat,
    // ...required intl formatters, supplied by the delegate below
  });

  @override TextDirection get textDirection => TextDirection.rtl; // Sorani is RTL
  @override String get okButtonLabel => 'باشە';
  @override String get cancelButtonLabel => 'هەڵوەشاندنەوە';
  // ...override the required getters; vendor the full set from ckb_localizations.

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _CkbMaterialLocalizationsDelegate();
}

class _CkbMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _CkbMaterialLocalizationsDelegate();
  @override bool isSupported(Locale locale) => locale.languageCode == 'ckb';
  @override Future<MaterialLocalizations> load(Locale locale) { /* build formatters */ }
  @override bool shouldReload(_) => false;
}
```

Sorani requires glyph coverage for its extra letters — پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە — so the bundled UI font must be **verified to render all of them** before `ckb` is locked ([PRD §13.5, §21](../PRD.md)); that font verification is a release-gate item shared with the design-system typography doc.

### Pitfalls / what we refuse

- **We refuse to ship `ckb` with default-language framework chrome.** A widget test asserts a Material dialog under `ckb` renders Sorani button labels, catching a missing delegate registration.
- **We refuse to treat the delegate as a direction source.** The delegate fills chrome strings only; direction comes from the locale resolving to RTL (§2). Conflating the two re-introduces a hardcoded direction.
- **We refuse to lock `ckb` copy as final.** Per [PRD §21](../PRD.md), Sorani terminology is flagged "needs native + scholar review" in the ARB `@description` metadata until confirmed; the architecture makes swapping a term-set one file (§5).

---

## 4. One bidi-isolation helper for every mixed-script run

### Decision

Every string that mixes scripts or directions inside one line — a page number, "Juz N", a surah name beside RTL copy, a date, a percentage, a user-typed profile name — is routed through **one bidi-isolation helper** before display. The helper wraps an embedded run in Unicode **isolates** (FSI…PDI for unknown direction; explicit RLI/LRI when the run's direction is known), using `intl`'s `Bidi`/`BidiFormatter`. Raw concatenation of opposite-direction runs is banned in feature code (*Decision log: Localization, RTL & accessibility impl*).

### Rationale

- **Isolates are the standard's recommended primitive.** Unicode UAX #9 explicitly encourages directional **isolates** over the older embedding/override codes: "the use of the directional isolates instead of embeddings is encouraged in new documents," because an isolate "functions like a neutral character on the ordering of the surrounding characters" ([Unicode UAX #9](https://www.unicode.org/reports/tr9/)). Without isolation, the Bidirectional Algorithm can reorder neighbouring runs — the classic "the number jumps to the wrong end" bug. (UAX #9 rules W4–W5 keep the digits *within* a single number in logical order regardless — a specific number is never internally reversed.)
- **Flutter/`intl` expose both the raw controls and a higher-level wrapper.** The `Unicode` class in `foundation` provides `FSI` (U+2068), `RLI` (U+2067), `LRI` (U+2066), `PDI` (U+2069) ([Flutter: Unicode class](https://api.flutter.dev/flutter/foundation/Unicode-class.html)); `intl` provides `BidiFormatter` for "formatting display text in a potentially opposite-directionality context without garbling layout issues," whose `wrapWithUnicode(text)` emits plain-text controls suitable for a Flutter `Text` (not HTML) ([Dart intl: BidiFormatter class](https://pub.dev/documentation/intl/latest/intl/BidiFormatter-class.html)).
- **Prefer explicit direction over first-strong when known.** Flutter's own constant doc warns that FSI's first-strong detection mis-guesses when the leading character is the "wrong" script (an Arabic string opening with an ASCII quote can detect as LTR), so for a run whose direction we know we use `RLI`/`LRI` (or `BidiFormatter.RTL`/`.LTR`) rather than `FSI` ([Flutter: Unicode.FSI constant](https://api.flutter.dev/flutter/foundation/Unicode/FSI-constant.html)).

### Specification

```dart
// l10n/bidi.dart — the single isolation helper. Routes every mixed-script run.
import 'package:flutter/foundation.dart' show Unicode;
import 'package:intl/intl.dart' show Bidi;

/// Isolate a run of *unknown* direction (user-typed names, arbitrary tokens).
String isolate(String run) => '${Unicode.FSI}$run${Unicode.PDI}';

/// Isolate a run whose direction we KNOW (prefer over FSI — no first-strong guess).
String isolateLtr(String run) => '${Unicode.LRI}$run${Unicode.PDI}';
String isolateRtl(String run) => '${Unicode.RLI}$run${Unicode.PDI}';

/// True iff a string has RTL content — to choose the right isolate.
bool _isRtl(String s) => Bidi.hasAnyRtl(s);
```

Usage — a Latin technical token and a localized number are isolated *before* injection into the ICU placeholder, so the localized sentence and its embedded run agree:

```dart
// A profile name of unknown script inside RTL copy:
Text(l10n.welcomeBack(isolate(profile.displayName)));

// A page label "Juz N" where N is locale numerals (§5): the number is known-direction.
final juz = isolateLtr(fmt.format(juzNumber)); // digits run as one isolated token
Text(l10n.juzLabel(juz));
```

### Pitfalls / what we refuse

- **We refuse raw concatenation of opposite-direction runs.** A code-review checklist item and a grep for `'$' …` interpolation of names/numbers into `Text` without `isolate*` flag the unguarded case. Every mixed run goes through the helper.
- **We refuse FSI where direction is known.** Because first-strong mis-detects on leading punctuation, known-direction runs use `isolateLtr`/`isolateRtl` ([Flutter: Unicode.FSI constant](https://api.flutter.dev/flutter/foundation/Unicode/FSI-constant.html)).
- **We refuse to isolate muṣḥaf glyphs.** The helper is chrome-only. Quran glyph runs come pre-shaped from the immutable layer ([08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md)) and are never passed through bidi controls or `Text` shaping.

---

## 5. Locale numerals and regional terminology

### Decision

Numbers in chrome render in the locale's digit set via **per-locale `NumberFormat`**, with the numbering system pinned by an explicit Unicode **`-u-nu-` extension** to avoid `intl`'s inconsistent Arabic-digit defaults: Persian and Kurdish render **Extended Arabic-Indic** (U+06F0–U+06F9, `۰۱۲۳۴۵۶۷۸۹`), Arabic renders **Arabic-Indic** (U+0660–U+0669, `٠١٢٣٤٥٦٧٨٩`). ASCII digits are **never** concatenated into a localized string — a number is formatted, then injected into an ICU placeholder. The regional sabaq/sabqi/manzil **term-sets** are modeled as a region-override ARB / ICU `select`, never by editing base strings (*Decision log: Localization, RTL & accessibility impl*).

### Rationale

- **Persian/Kurdish and Arabic use two different, non-interchangeable Unicode blocks.** Extended Arabic-Indic (U+06F0–U+06F9) and Arabic-Indic (U+0660–U+0669) are separate codepoints even where glyphs look alike: "Each numeral in the Persian variant has a different Unicode point even if it looks identical," with visually distinct glyphs for 4, 5, and 6 ([Wikipedia: Eastern Arabic numerals](https://en.wikipedia.org/wiki/Eastern_Arabic_numerals)). A `fa` UI must show `۴۵۶`, not `٤٥٦` — using the Arabic block for Persian is a defect a Persian reader notices.
- **`intl`'s `NumberFormat` is the supported path, but its Arabic-digit handling is inconsistent.** `NumberFormat` takes a locale and applies its digits, exposing `localeZero` ([Dart intl: NumberFormat class](https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html)); but Eastern-digit emission "is implemented in dates, but not in NumberFormat," and bare `ar` vs country sublocales disagree ([dart-lang/i18n #197](https://github.com/dart-lang/i18n/issues/197)). The fix is to pin the numbering system on the locale tag (`-u-nu-arab`, `-u-nu-latn`) so digit choice is explicit, not a sublocale default.
- **The regional vocabulary is data, not code.** The track labels, grade verbs, and cycle names differ by region ([PRD §13.4](../PRD.md)); modeling the choice as an ICU `select` over a region key (or a per-region override file the build merges) makes swapping a vocabulary set one file, never a code change — and `select` is a first-class ARB construct ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).

### Specification

A single numeral formatter, chosen per locale with an explicit numbering system:

```dart
// l10n/numerals.dart — pin the numbering system; never rely on sublocale defaults.
import 'package:intl/intl.dart';

NumberFormat numberFormatFor(Locale locale) {
  final tag = switch (locale.languageCode) {
    'fa'  => 'fa-u-nu-arabext', // Extended Arabic-Indic ۰۱۲۳۴۵۶۷۸۹ (U+06F0..)
    'ckb' => 'ckb-u-nu-arabext',// Sorani uses the same Extended set
    'ar'  => 'ar-u-nu-arab',    // Arabic-Indic ٠١٢٣٤٥٦٧٨٩ (U+0660..) — pinned, not default
    _     => 'en',
  };
  return NumberFormat.decimal(tag);
}
```

ICU placeholders receive the *formatted* number — never raw ASCII:

```json
// app_fa.arb
{
  "pagesDue": "{count} صفحه برای مرور",
  "@pagesDue": { "placeholders": { "count": { "type": "int" } } }
}
```

```dart
final fmt = numberFormatFor(locale);
Text(l10n.pagesDue(int.parse(fmt.format(dueCount)))); // count rendered as locale digits
```

Regional term-set selection via `select` over a region key — one ARB entry switches the whole vocabulary ([PRD §13.4](../PRD.md)):

```json
// app_ar.arb — the manzil/far-revision label, switched by region preset.
{
  "trackFar": "{region, select, levant{المراجعة البعيدة} subcontinent{المنزل} other{المراجعة البعيدة}}",
  "@trackFar": {
    "description": "Far-revision (manzil/dhor) track label; varies by region. NEEDS scholar review.",
    "placeholders": { "region": { "type": "String" } }
  }
}
```

Calendar dates render through this same numeral path: the conversion (Hijri Umm al-Qurā / Jalālī / Gregorian) is owned by [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md), which emits a `(y,m,d)` whose numeric fields are **re-mapped to locale digits here, downstream of the conversion** — calendar packages emit Latin digits, so the numeral transform sits after them, and a Hijri date carries the standing honesty caveat from [07](07-dates-calendars-and-correctness.md) ([research/calendars-i18n-hijri-jalali.md](research/calendars-i18n-hijri-jalali.md)).

### Pitfalls / what we refuse

- **We refuse ASCII digits in localized copy.** A grep flags `'$count '`-style interpolation of a raw int into a `Text`/ARB value; counts must pass through `numberFormatFor(locale)` first ([PRD §13.3](../PRD.md)).
- **We refuse the Arabic block for Persian/Kurdish (or vice-versa).** A per-locale numeral golden asserts `fa`/`ckb` render U+06F0-range glyphs and `ar` renders U+0660-range glyphs ([research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md)).
- **We refuse to re-typeset muṣḥaf numerals.** Ayah numbers, juz/ḥizb markers, and sajda marks *on the page* come from the immutable glyph layer ([PRD §11.2](../PRD.md)); `NumberFormat` applies only to chrome (Today, Progress, Settings, dates), preserving the sacred-text boundary.
- **We refuse to edit base strings to localize a region's vocabulary.** Term-sets are a `select`/override file so a regional swap is data, and the Kurdish defaults stay flagged for review ([PRD §21](../PRD.md)).

---

## 6. Plurals: ICU `plural` and Arabic's six categories

### Decision

Every count-bearing chrome string ("N pages due", "N days in your catch-up plan", "N sign-offs") uses an **ICU `plural`** message, and the ARB review checklist treats Arabic's full CLDR category set (`zero`, `one`, `two`, `few`, `many`, `other`) as a **translation contract** — a missing category is a release blocker, not a cosmetic gap (*Decision log: Localization, RTL & accessibility impl*).

### Rationale

- **ARB carries ICU plural natively and the languages need it.** A pluralized message "must include a `num` parameter," and `intl` applies the correct CLDR plural category per target language ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)). Arabic is the canonical hard case: CLDR defines **six** plural categories for Arabic, so "3 pages" vs "11 pages" vs "100 pages" inflect differently — correct only if the translator supplies every needed category ([Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization), [research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md)).

### Specification

The `pagesDue` template in §1 already shows all six Arabic categories. The non-negotiable companion rule is that the count is formatted to locale numerals (§5) and the result placed in the plural form, so number agreement and digit shaping are both correct. The ARB-completeness CI step asserts that for `app_ar.arb`, every `plural` message defines `zero/one/two/few/many/other`.

### Pitfalls / what we refuse

- **We refuse a count string without a `plural` message.** A naive `"$count pages"` is grammatically wrong in Arabic and Persian; the grep that bans ASCII-digit concatenation (§5) also surfaces these.
- **We refuse an incomplete Arabic plural.** A missing `few`/`many` is a silent grammatical error a native reader catches; the ARB review gate fails the build on it.

---

## 7. Accessibility implementation

### Decision

Accessibility is implemented as four concrete, gated obligations, applying [PRD §18](../PRD.md): (1) **semantic labels** in the active locale on every control, so TalkBack/VoiceOver can describe the recite/grade flow; (2) **dynamic text** — layouts respect `MediaQuery.textScaler` and stay legible at large scale, never a fixed-pixel font; (3) **contrast ≥ 4.5:1** for text and **never color alone** to convey state, especially on the retention heat-map; (4) **touch targets ≥ 48×48 dp** for the daily, fast-tapped recite/grade controls (*Decision log: Localization, RTL & accessibility impl*).

### Rationale

- **Screen-reader support is a first-class Flutter feature, tested with the platform tools.** Flutter's accessibility guide directs: "Test your app with TalkBack (Android) and VoiceOver (iOS)," and the screen reader "should be able to describe all controls on the page when you tap on them, and the descriptions should be intelligible" ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)). The mechanism is the `Semantics` widget — "a widget that annotates the widget tree with a description of the meaning of the widgets," exposing `label`, `hint`, `button`, `header`, and `excludeSemantics`/`MergeSemantics` for screen readers and assistive tech ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)).
- **Dynamic text scaling is a platform preference we must honor.** `MediaQueryData.textScaler` is "the font scaling strategy to use for laying out textual contents" and "may change as the user changes the scaling factor in the operating system's accessibility settings" ([Flutter: MediaQueryData.textScaler](https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html)); `TextScaler` is the replacement for the now-deprecated `textScaleFactor` scalar, introduced "in preparation for the upcoming Android 14 nonlinear font scaling feature" ([Flutter: Deprecate textScaleFactor in favor of TextScaler](https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor)). Flutter's checklist requires the UI to "remain legible and usable at very large scale factors for text size and display scaling" ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)). For low-vision reciters this is core, not cosmetic ([PRD §18](../PRD.md)).
- **Contrast and non-color encoding are WCAG requirements the heat-map must meet.** Flutter recommends "a contrast ratio of at least 4.5:1 between controls or text and the background" ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)), matching WCAG 2.2 SC 1.4.3: "text and images of text [have] a contrast ratio of at least 4.5:1" ([WCAG 2.2 SC 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)). WCAG 2.2 SC 1.4.1 requires that "color is not used as the only visual means of conveying information" ([WCAG 2.2 SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)) — directly the PRD's rule that the retention heat-map "never rely on color alone (use labels/patterns)" for color-blind users ([PRD §18](../PRD.md)).
- **Touch targets must clear the platform minimum.** Flutter's checklist sets "Tappable targets ... 48x48 pixels minimum" ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)); WCAG 2.2 SC 2.5.8 requires targets "at least 24 by 24 CSS pixels" with spacing exceptions ([WCAG 2.2 SC 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)) — we adopt the stricter 48 dp because the recite/grade flow is used daily and quickly ([PRD §18](../PRD.md)).

### Specification

Localized semantics on a grade button — `label` and `hint` come from the ARB set, so the screen reader speaks the active locale:

```dart
// features/today — a grade control, fully described for TalkBack/VoiceOver.
Semantics(
  button: true,
  label: l10n.gradeGoodLabel,   // e.g. "خوب" / "Good" verb, localized (PRD §6.3)
  hint: l10n.gradeGoodHint,     // "recited clean" — the traditional verb
  child: SizedBox(
    width: 48, height: 48,      // ≥ 48×48 dp tappable target
    child: InkWell(onTap: () => vm.grade(Grade.good), child: const Icon(Icons.check)),
  ),
)
```

Respect the user's text scale rather than overriding it; size containers in scalable units and let text grow:

```dart
// Honor the OS text-scale; never clamp to a fixed pixel font.
final scaler = MediaQuery.textScalerOf(context); // current TextScaler
// Lay out so the recite/grade row reflows (Wrap/Flexible) at large scale,
// instead of truncating or overflowing. No `textScaleFactor: 1.0` override.
```

Heat-map state carries a non-color encoding (label + pattern) so it reads without color, satisfying SC 1.4.1 and [PRD §18](../PRD.md):

```dart
// features/progress — each cell announces its state in words, not just hue.
Semantics(
  label: l10n.pageHealth(pageNumberLocalized, l10n.healthState(cell.tier)),
  child: HeatCell(
    color: tierColor(cell.tier),     // design-system token, ≥4.5:1 vs background
    pattern: tierPattern(cell.tier), // hatch/dot pattern — not color alone
  ),
)
```

Accessibility is verified against the [PRD §20 gate 5](../PRD.md) and Flutter's release checklist: per-locale RTL golden screenshots; a TalkBack/VoiceOver pass over the cold-start → recite → grade journey; a contrast check on the heat-map palette and chrome; a large-text-scale pass; and a tappable-target audit of the grade controls ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)).

### Pitfalls / what we refuse

- **We refuse unlabeled controls.** Every interactive widget has a localized `Semantics` `label`; a missing label is caught by Flutter's `SemanticsTester`/accessibility-guideline tests in the widget suite ([11-testing-strategy.md](11-testing-strategy.md)).
- **We refuse fixed-pixel typography and text-scale overrides.** No `textScaler: TextScaler.noScaling` clamp on user-facing text; layouts reflow at large scale ([Flutter: MediaQueryData.textScaler](https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html)).
- **We refuse color as the only signal.** The heat-map (and any due/overdue/weak indicator) pairs color with a label and pattern; color-only state fails SC 1.4.1 ([WCAG 2.2 SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)) and the PRD's color-blind requirement ([PRD §18](../PRD.md)).
- **We refuse sub-48 dp tappable targets in the daily flow.** Grade/recite controls are ≥ 48×48 dp; an audit and a widget test on hit-test sizes enforce it.
- **We refuse to make the muṣḥaf an accessibility afterthought.** The reader honors zoom and high-contrast/sepia/dark themes by transforming the rendered glyph layer, never by re-shaping text ([08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md), [PRD §11.2, §18](../PRD.md)).

---

## 8. The localization & accessibility gate

### Decision

The [PRD §20 gate 5](../PRD.md) is implemented as a layered, mostly-compile-time gate that fails the build on any regression (*Decision log: Localization, RTL & accessibility impl*). The layers:

| Layer | Mechanism | Catches |
|---|---|---|
| Key coverage | `gen_l10n` codegen + `nullable-getter: false` | Missing/typo ARB key (compile error) ([Flutter: i18n](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)) |
| Hardcoded strings | Grep over `features/**` | String literals bypassing `AppLocalizations` ([PRD §20](../PRD.md)) |
| Physical sides | Grep for `EdgeInsets.only(left:/right:`, `Alignment.center{Left,Right}`, `Positioned(left:/right:` | RTL-breaking layout ([Flutter: Directionality](https://api.flutter.dev/flutter/widgets/Directionality-class.html)) |
| ASCII digits | Grep for raw int interpolation into `Text`/ARB | Wrong/un-localized numerals ([PRD §13.3](../PRD.md)) |
| Arabic plurals | ARB completeness check | Missing CLDR plural category ([Flutter: i18n](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)) |
| RTL + numerals | Per-locale golden screenshots | Mirroring + digit-block regressions ([PRD §20](../PRD.md)) |
| Accessibility | Widget `SemanticsTester` + [manual TalkBack/VoiceOver pass](manual-a9-screenreader-procedure.md) (A9; recorded by E08-T09, executed by E20) | Unlabeled controls, small targets, scale break ([Flutter: Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)) |

### Rationale

RTL correctness is a *layout* property that can regress on any screen, and it can be tested without a finished translation — direction follows the locale, so a golden under each `Directionality`/locale exercises mirroring on draft copy ([research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md)). Making most checks compile-time or grep-based means the gate is cheap and structural, matching how the rest of the engineering set turns invariants into build failures (Decision log: *testing strategy & CI* — [11-testing-strategy.md](11-testing-strategy.md)).

### Pitfalls / what we refuse

- **We refuse to defer RTL/accessibility to a "polish" phase.** Both are always-on gates from the first screen, not a late locale; the cost is low and the bug surface is every screen ([PRD §20](../PRD.md)).
- **We refuse goldens rendered with a placeholder font.** Per-locale goldens load the **real** bundled UI fonts (so Sorani extra letters and Persian digits are actually exercised), consistent with the muṣḥaf golden rule of never using `Ahem` ([11-testing-strategy.md](11-testing-strategy.md)).

---

## References

All URLs verified to resolve on 2026-06-16.

- Flutter (Google). *Internationalizing Flutter apps* (the `flutter_localizations` + `intl` + `gen_l10n` pipeline; `l10n.yaml` options; ARB key→getter rule; `GlobalWidgetsLocalizations` sets default text direction; ICU plural/select; `use-escaping`; custom-delegate recipe for an unsupported locale). https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Flutter (Google). *Accessibility* (test with TalkBack/VoiceOver; legible at very large scale factors; ≥ 4.5:1 contrast; 48×48 tappable targets; release checklist). https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
- Flutter API. *Directionality class* ("determines the ambient directionality of text and text-direction-sensitive render objects"; `Padding` resolves `EdgeInsetsDirectional` → `EdgeInsets`). https://api.flutter.dev/flutter/widgets/Directionality-class.html
- Flutter API. *Semantics class* ("a widget that annotates the widget tree with a description of the meaning of the widgets"; `label`/`hint`/`button`/`header`/`excludeSemantics`). https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Flutter API. *MediaQueryData.textScaler* ("the font scaling strategy to use for laying out textual contents"; reflects OS accessibility text scaling). https://api.flutter.dev/flutter/widgets/MediaQueryData/textScaler.html
- Flutter (Google). *Deprecate textScaleFactor in favor of TextScaler* (breaking-changes migration; `TextScaler` replaces the deprecated `textScaleFactor` scalar ahead of Android 14 nonlinear font scaling). https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor
- Flutter API. *Unicode class (foundation)* (isolate constants `FSI` U+2068, `RLI` U+2067, `LRI` U+2066, `PDI` U+2069, direction marks). https://api.flutter.dev/flutter/foundation/Unicode-class.html
- Flutter API. *Unicode.FSI constant* (first-strong isolate definition; first-strong mis-detection caveat). https://api.flutter.dev/flutter/foundation/Unicode/FSI-constant.html
- flutter/flutter. *Issue #35103 — Localization support for Central Kurdish, locale 'ckb'* (`ckb` not in built-in `GlobalMaterialLocalizations`; custom delegate required). https://github.com/flutter/flutter/issues/35103
- Dart `intl`. *BidiFormatter class* ("formatting display text in a potentially opposite-directionality context without garbling layout issues"; `wrapWithUnicode`). https://pub.dev/documentation/intl/latest/intl/BidiFormatter-class.html
- Dart `intl`. *Bidi class* (`hasAnyRtl`, `estimateDirectionOfText`, `isRtlLanguage`, isolate/mark constants). https://pub.dev/documentation/intl/latest/intl/Bidi-class.html
- Dart `intl`. *NumberFormat class* (locale-specific digits; `localeZero`; `format()`). https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html
- dart-lang/i18n. *Issue #197 — odd handling of Arabic locales and their digits (ar_DZ vs ar_EG vs ar)* (Eastern-digit handling "is implemented in dates, but not in NumberFormat"; basis for pinning the numbering system). https://github.com/dart-lang/i18n/issues/197
- pub.dev. *ckb_localizations* (community Material/Cupertino localization delegate for Central Kurdish; vendorable for `ckb` chrome). https://pub.dev/packages/ckb_localizations
- Unicode Consortium. *UAX #9 — Unicode Bidirectional Algorithm* (isolates "encouraged in new documents" over embeddings; isolate "functions like a neutral character"; W4–W5 keep digits in logical order). https://www.unicode.org/reports/tr9/
- Wikipedia. *Eastern Arabic numerals* (Arabic-Indic U+0660–U+0669 vs Extended Arabic-Indic/Persian U+06F0–U+06F9; "different Unicode point even if it looks identical"; distinct 4/5/6 glyphs). https://en.wikipedia.org/wiki/Eastern_Arabic_numerals
- W3C WAI. *WCAG 2.2 — Understanding SC 1.4.3 Contrast (Minimum)* (text contrast ratio at least 4.5:1; 3:1 for large text). https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html
- W3C WAI. *WCAG 2.2 — Understanding SC 1.4.1 Use of Color* ("color is not used as the only visual means of conveying information"). https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html
- W3C WAI. *WCAG 2.2 — Understanding SC 2.5.8 Target Size (Minimum)* (targets "at least 24 by 24 CSS pixels"; spacing exception). https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
- W3C i18n. *Structural markup and right-to-left text in HTML* (base direction reorders whole layout, not just paragraphs). https://www.w3.org/International/questions/qa-html-dir
- Hifz Companion. *Product Requirements Document* (§11 immutable rendering, §13 localization & RTL, §18 accessibility, §20 release gates, §21 open decisions). [PRD.md](../PRD.md)
- Hifz Companion. *Engineering README & tech-decision log* (Decision 10: localization, RTL & accessibility impl). [README.md](README.md)
- Hifz Companion. *Flutter i18n & RTL research note.* [research/flutter-rtl-i18n.md](research/flutter-rtl-i18n.md)
- Hifz Companion. *Calendars & i18n research note.* [research/calendars-i18n-hijri-jalali.md](research/calendars-i18n-hijri-jalali.md)
