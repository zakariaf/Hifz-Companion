# template — add/change a localized string

Fill-in procedure. Copy the block that matches your case, replace the `// TODO`/placeholder text, transcreate the `fa`/`ckb`/`ar` values against the `ar` base, and run the local gate at the end before pushing. All snippets obey: author in `app_ar.arb` (the `ar` template/base) first; read only through `AppLocalizations` (`l10n.*`); ICU `plural` with all six Arabic categories for any count; numerals/dates via `numberFormatFor(locale)`; mixed runs FSI/PDI-isolated; sabaq/sabqi/manzil terms as a `select`/region-override; canonical `ckb`; the four voice attributes and the never-ship list; and no string in `/engine`.

---

## 0. Where things live

| Concern | File |
|---|---|
| The base/template ARB (`ar`, source of truth) | `lib/l10n/app_ar.arb` |
| The Persian transcreation | `lib/l10n/app_fa.arb` |
| The Kurdish-Sorani transcreation (provisional) | `lib/l10n/app_ckb.arb` |
| The bidi-isolation helper | `lib/l10n/bidi.dart` |
| The locale-numeral formatter | `lib/l10n/numerals.dart` |
| The vendored Sorani chrome delegate | `lib/l10n/ckb_material_localizations.dart` |
| Generated accessor (do not hand-edit) | `lib/l10n/app_localizations.dart` |

`l10n.yaml` already sets `template-arb-file: app_ar.arb`, `nullable-getter: false`, `use-escaping: true`. Codegen runs on `flutter pub get`/`run` (or `flutter gen-l10n`). Read in a widget via `final l10n = AppLocalizations.of(context)!;`.

---

## 1. A plain visible / notification / `Semantics` string

`app_ar.arb` — the key is authored here first, with an `@description` carrying translator/scholar context:

```json
// lib/l10n/app_ar.arb  (template / base content language)
{
  "todayTitle": "مراجعة اليوم",
  "@todayTitle": {
    "description": "AppBar title of the Today screen — the daily revision session."  // TODO: real context
  }
}
```

`app_fa.arb` / `app_ckb.arb` — **transcreations**, not literal translations (set the register per §8 below):

```json
// lib/l10n/app_fa.arb
{ "todayTitle": "مرور امروز" }            // TODO: Persian, respectful-warm register
// lib/l10n/app_ckb.arb  (PROVISIONAL — see §8 ckb flag)
{ "todayTitle": "پێداچوونەوەی ئەمڕۆ" }    // TODO: Sorani, canonical encoding, native+scholar review pending
```

In a widget / view model — read through `AppLocalizations`, never a literal:

```dart
final l10n = AppLocalizations.of(context)!;

Text(l10n.todayTitle);                                    // visible text
Semantics(button: true, label: l10n.gradeGoodLabel, hint: l10n.gradeGoodHint, child: /* … */);
// Notification body/title also resolve through l10n.* — same pipeline as visible text.
```

> A referenced-but-undefined key is a **compile error** (`nullable-getter: false`) — not a silent empty widget. A string literal in `features/**` (`Text(...)`, `tooltip:`, `semanticsLabel:`, `label:`) fails the CI grep.

---

## 2. An interpolated string — ICU placeholders in one full message

NEVER concatenate localized fragments — RTL word order will not survive it, and Arabic/Persian grammar differs. One ICU message, named placeholders. Keep any opposite-direction value a **placeholder** so it can be isolated (§4):

```json
// app_ar.arb
{
  "welcomeBack": "أهلاً بعودتك، {name}",
  "@welcomeBack": {
    "description": "Greeting with the user's profile name. {name} may be any script — isolate before passing.",
    "placeholders": { "name": { "type": "String" } }
  }
}
```

```dart
// The name is unknown-direction → isolate it BEFORE injecting (see §4):
Text(l10n.welcomeBack(isolate(profile.displayName)));
```

> Do not greet a returning user in a way that implies they lapsed — no "Welcome back! You haven't opened the app in N days." Resume silently into the normal Today screen (voice §3). This example is illustrative of the *mechanics* only.

---

## 3. A count-bearing string — ICU `plural`, ALL SIX Arabic categories (REQUIRED)

Arabic needs `zero`/`one`/`two`/`few`/`many`/`other` — a missing category is a **release blocker**. The count is locale-numeral-formatted (§3b) before placement.

```json
// app_ar.arb — the count-of-pages-due template. All six categories are a translation contract.
{
  "pagesDue": "{count, plural, zero{لا صفحات} one{صفحة واحدة} two{صفحتان} few{{count} صفحات} many{{count} صفحة} other{{count} صفحة}} مستحقة",
  "@pagesDue": {
    "description": "Count of pages due today. Arabic needs all six CLDR plural categories.",
    "placeholders": { "count": { "type": "int" } }
  }
}
```

```json
// app_fa.arb — Persian uses one/other; author the natural Persian form, not a literal map.
{
  "pagesDue": "{count, plural, one{{count} صفحه برای مرور} other{{count} صفحه برای مرور}}"  // TODO: Persian
}
```

```dart
// Format the count to locale digits FIRST, then pass it (see §3b). The plural category is selected from the int.
final fmt = numberFormatFor(locale);
Text(l10n.pagesDue(dueCount));                 // ICU selects the category; digits shaped per §3b path
```

> **Why a ternary is banned, not just discouraged:** `count == 1 ? … : …` hard-codes a two-category assumption and structurally cannot represent Arabic's six categories — "3 pages" (`few`) vs "11 pages" (`many`) vs "100 pages" (`other`) all inflect differently. A `"$count pages"` splice is wrong in Arabic *and* Persian and is also caught by the ASCII-digit grep (§3b). The ARB-completeness CI step asserts every `plural` in `app_ar.arb` defines all six slots.

---

## 3b. A numeral or date — `numberFormatFor(locale)`, never hand-formatted ASCII

`lib/l10n/numerals.dart` — pin the numbering system explicitly; never rely on sublocale defaults:

```dart
// lib/l10n/numerals.dart
import 'package:intl/intl.dart';

NumberFormat numberFormatFor(Locale locale) {
  final tag = switch (locale.languageCode) {
    'fa'  => 'fa-u-nu-arabext',  // Extended Arabic-Indic ۰۱۲۳۴۵۶۷۸۹ (U+06F0..)
    'ckb' => 'ckb-u-nu-arabext', // Sorani uses the same Extended set
    'ar'  => 'ar-u-nu-arab',     // Arabic-Indic ٠١٢٣٤٥٦٧٨٩ (U+0660..) — pinned, not default
    _     => 'en',               // TODO: only a fallback; never a shipped UI locale
  };
  return NumberFormat.decimal(tag);
}
```

```dart
// ✅ Format at the boundary, inject the result. fa/ckb → ۴۵۶ ; ar → ٤٥٦
final fmt = numberFormatFor(locale);
Text(l10n.pagesDue(int.parse(fmt.format(dueCount))));

// A calendar (y,m,d) comes Latin-digited from domain-calendars-and-hifzdate;
// re-map it to locale digits HERE, downstream of the conversion:
final dateText = DateFormat.yMMMMd(locale.toString()).format(displayDate); // intl, locale digits

// ❌ NEVER — bypasses the numbering system, the bidi path, and the ASCII-digit grep:
final bad = 'Page ' + n.toString();          // and never the wrong block (Arabic digits for fa/ckb)
```

> Because of the documented `intl` date-vs-number digit inconsistency, the per-locale numeral golden asserts **both dates and numbers** show the locale's digits in fa/ckb/ar. Ayah numbers *on the muṣḥaf page* are the immutable glyph layer — never re-rendered here (`domain-mushaf-text-integrity`).

---

## 4. Bidi safety — isolate every mixed-script run (FSI/PDI)

`lib/l10n/bidi.dart` — the single isolation helper. Route every page number, "Juz N", surah name beside RTL copy, date, percentage, or user-typed name through it:

```dart
// lib/l10n/bidi.dart
import 'package:flutter/foundation.dart' show Unicode;
import 'package:intl/intl.dart' show Bidi;

/// Isolate a run of *unknown* direction (user-typed names, arbitrary tokens).
String isolate(String run) => '${Unicode.FSI}$run${Unicode.PDI}';

/// Isolate a run whose direction we KNOW (prefer over FSI — no first-strong guess).
String isolateLtr(String run) => '${Unicode.LRI}$run${Unicode.PDI}';
String isolateRtl(String run) => '${Unicode.RLI}$run${Unicode.PDI}';

bool _isRtl(String s) => Bidi.hasAnyRtl(s);   // to choose the right isolate when needed
```

```dart
// A "Juz N" label where N is locale numerals — direction is KNOWN, so prefer isolateLtr over FSI:
final juz = isolateLtr(numberFormatFor(locale).format(juzNumber));
Text(l10n.juzLabel(juz));

// A profile name of unknown script inside RTL copy:
Text(l10n.welcomeBack(isolate(profile.displayName)));
```

> Use `isolateLtr`/`isolateRtl` (not `isolate`/FSI) whenever the run's direction is known — FSI's first-strong detection mis-guesses on leading punctuation. Never raw-concatenate opposite-direction runs; never the legacy LRE/RLE/LRO/RLO embeddings. The helper is **chrome-only** — never pass a muṣḥaf glyph run through it.

---

## 5. A regional sabaq/sabqi/manzil term-set — ICU `select` / region-override (NEVER an edited base string)

The track labels, the four grade verbs, and cycle names are *data*, switched by a region key. One ARB entry swaps the whole vocabulary:

```json
// app_ar.arb — the far-revision (manzil/dhor) track label, switched by region preset.
{
  "trackFar": "{region, select, levant{المراجعة البعيدة} subcontinent{المنزل} other{المراجعة البعيدة}}",
  "@trackFar": {
    "description": "Far-revision (manzil/dhor) track label; varies by region. NEEDS scholar review.",  // TODO
    "placeholders": { "region": { "type": "String" } }
  }
}
```

```dart
// The region preset comes from cycle_config (term_label_set / region_preset), NOT a code constant.
Text(l10n.trackFar(cycleConfig.regionPreset));

// The four-grade scale shows the active term-set's traditional verb; the engine signal is unchanged:
// grade.again / grade.hard / grade.good / grade.easy  →  "needed help" / "minor mistakes" /
//   "recited clean" / "effortless" (localized, per active term-set; PRD §6.3).
```

> Never hard-code "Manzil"/"Sabqi"/"Dhor" in a widget, and never edit a base string to localize a region's vocabulary — it is always a `select`/override so a regional swap is a one-file, data-only change. The `ckb` term-set stays flagged provisional (§8).

---

## 6. The `ckb` (Kurdish Sorani) value — canonical encoding + provisional flag

Author Sorani with **U+06D5 (ە)** for AE and **U+06A9 (ک)** for kaf; the lint rejects stray U+200C (ZWNJ) and any Teh-Marbuta (ة) substituted where ە belongs:

```json
// app_ckb.arb — PROVISIONAL until native + scholar review (PRD §21).
{
  "trackFar": "{region, select, kurdistan{پێداچوونەوەی دوور} other{مەنزڵ}}",  // TODO: native review
  "@trackFar": {
    "description": "ckb far-revision label. NEEDS native + scholar review; encoding: U+06D5 ە, U+06A9 ک."
  }
}
```

`lib/l10n/ckb_material_localizations.dart` — the vendored framework-chrome delegate (Flutter ships no `ckb`):

```dart
class CkbMaterialLocalizations extends GlobalMaterialLocalizations {
  const CkbMaterialLocalizations({ super.localeName = 'ckb', /* …required intl formatters… */ });
  @override TextDirection get textDirection => TextDirection.rtl; // Sorani is RTL
  @override String get okButtonLabel => 'باشە';
  @override String get cancelButtonLabel => 'هەڵوەشاندنەوە';
  // TODO: override the remaining required getters; vendor the full set from ckb_localizations.
  static const LocalizationsDelegate<MaterialLocalizations> delegate = _CkbMaterialLocalizationsDelegate();
}
```

Register it (Flutter wiring) alongside the generated delegates:

```dart
MaterialApp(
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    CkbMaterialLocalizations.delegate,                 // Flutter ships no ckb
  ],
  supportedLocales: const [
    Locale('ar'), Locale('fa'), Locale.fromSubtags(languageCode: 'ckb'),
  ],
  // no `locale:` override — let the device locale resolve; Settings can pin one.
);
```

> Direction is automatic once `ckb` resolves to RTL — the delegate fills *chrome strings only*, never direction. Verify the bundled UI font renders پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە before locking `ckb`.

---

## 7. Voice / adab — the four attributes and the never-ship list (the FIRST gate)

Every string passes the **adab gate first**, then the four attributes (reverent, calm, plain-and-warm, honest). Sentence case; second-person singular warm; verbs in the locale's idiom. The never-ship list is release-blocking in **every** locale:

```
✅ "Your revision for today is ready."        (calm statement of readiness)
✅ "This juz is weakening. Today's plan brings it back."   (honest + empathetic; describe then act)
✅ "Recorded with your teacher's sign-off."   (defer to the teacher; the app records)

❌ "12 pages OVERDUE!"           — alarm, exclamation
❌ "You'll lose your hifz."       — guilt/fear/loss; weaponizes a real spiritual fear
❌ "You're behind." / "N days lost"  — blame; lead with empathy + a path instead
❌ "You've mastered this juz." / "safe to drop"  — contradicts an engine invariant + the honesty pillar
❌ "You must / should revise now." — controlling mandate; provokes reactance
❌ "Great job! 🎉"                 — praise theatre, emoji; the system confirms, it does not react
❌ "Upgrade" / "premium" / "unlock"  — commercial framing; the app is free as ṣadaqah jāriyah
```

Hard news (decay, missed days, budget overflow, lapse) follows **empathy → honest fact → concrete path → the user's choice**:

```
"You missed 3 days. Here is a 5-day catch-up that still completes your cycle."   (re-spread, never a dump)
"Today's scope doesn't fit your time. You can raise the budget, lengthen the cycle, or pause new sabaq."
```

Per-locale register (§8): **Persian** respectful-warm (*šomā*/honorific, *taʿārof*-aware); **Arabic** gender/number forms with **imperatives softened to statements of readiness**; **Sorani** register + vocabulary by native reviewers, provisional.

---

## 8. Run the localization & accessibility gate locally (before pushing)

```bash
# 1. Key coverage + codegen: a missing/typo key is a COMPILE error (nullable-getter: false).
flutter gen-l10n && flutter analyze

# 2. No hardcoded user-facing literals in features/** (Text / tooltip / semanticsLabel / label).
! grep -rEn "(Text|tooltip:|semanticsLabel:|label:)\s*\(?\s*['\"]" lib/src/  # TODO: tune to repo layout

# 3. No physical-side layout APIs in features/** (RTL-breaking).
! grep -rEn "EdgeInsets\.only\((left|right):|Alignment\.center(Left|Right)|Positioned\((left|right):" lib/src/

# 4. No ASCII-digit interpolation into a Text/ARB value (un-localized numerals).
! grep -rEn "Text\([^)]*\\\$[A-Za-z_].*\.toString\(\)" lib/src/   # counts must pass through numberFormatFor

# 5. No AppLocalizations / intl imports inside the pure engine.
! grep -rEn "package:.*l10n|app_localizations|package:intl" packages/engine/lib/

# 6. Arabic plural completeness: every `plural` in app_ar.arb defines all six CLDR categories.
#    (zero/one/two/few/many/other) — TODO: wire the ARB-completeness check as a test or script.

# 7. Per-locale RTL + numeral goldens, with the REAL bundled fonts (never Ahem), and the offline guard.
flutter test --tags golden    # see eng-write-dart-test
```

Then: a TalkBack/VoiceOver pass over the cold-start → recite → grade journey in fa/ckb/ar (labels speak the active locale; mixed runs read in order). For any **term-set, methodology-adjacent, or religious** wording, confirm the per-locale **native + scholar review** has cleared it — or it ships clearly marked provisional and states no ruling.

---

## Final checklist (mirror of SKILL.md)

- [ ] Key authored in `app_ar.arb` (the `ar` template/base) with an `@description`; `fa`/`ckb`/`ar` are transcreations, not literal translations.
- [ ] Read only through `AppLocalizations` (`l10n.*`); no literal in `features/**`; missing key is a compile error.
- [ ] No user-facing string in `/engine`.
- [ ] Interpolation = one full ICU message with `{placeholder}` slots; no concatenation, no hard-spliced substring.
- [ ] Count-bearing → ICU `plural` with all six Arabic categories; count locale-numeral-formatted first; no ternary, no `"$count"` splice.
- [ ] Numerals/dates via `numberFormatFor(locale)` / `intl` (`fa`/`ckb` arabext, `ar` arab), injected as a placeholder; calendar `(y,m,d)` re-mapped to locale digits downstream of `domain-calendars-and-hifzdate`.
- [ ] Mixed-script runs go through `bidi.dart` — `isolate` (FSI) for unknown, `isolateLtr`/`isolateRtl` for known direction; no raw concatenation, no legacy embeddings.
- [ ] Sabaq/sabqi/manzil terms are an ICU `select`/region-override (one-file swap); active term-set's traditional grade verb shows; never a hard-coded label.
- [ ] `ckb` canonical-encoded (U+06D5 ە, U+06A9 ک; no ZWNJ/Teh-Marbuta hack), flagged provisional, vendored chrome delegate registered, font coverage verified.
- [ ] Passes the **adab gate first** + the four voice attributes; no never-ship phrase; Arabic imperatives softened; hard news follows empathy → fact → path → choice.
- [ ] Direction stays locale-derived; the ARB value carries no physical-side/hardcoded-RTL assumption.
- [ ] The gate is green (key coverage, hardcoded-string grep, physical-side grep, ASCII-digit grep, Arabic-plural completeness, canonical-`ckb` lint, per-locale RTL/numeral goldens with real fonts, TalkBack/VoiceOver pass).
- [ ] Term-set / methodology / religious wording cleared by per-locale native + scholar review (or shipped clearly provisional, stating no ruling).
