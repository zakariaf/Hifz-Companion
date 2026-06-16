# E09 — Localization & RTL Foundation

Make fa/ckb/ar and right-to-left a property of the app's *structure*, not a late translation pass: the `gen_l10n` ARB pipeline with Arabic as the base content language, the compile-time-plus-grep locale-completeness CI gate, locale-derived `Directionality`/logical-inset layout, one FSI/PDI bidi-isolation helper for every mixed run, per-locale numerals across two distinct Unicode blocks, the render-only calendar-display layer over E02's conversions, and the swappable sabaq/sabqi/manzil term-sets. Because all three shipping locales are RTL, RTL is the default that must never break — and every religious term and methodology-adjacent string ships flagged for scholarly review until a native speaker and a scholar clear it.

## Why this epic exists

This app is anchored to Iran, Iraqi Kurdistan, and Arabic-speaking communities ([PRD §3](../../docs/PRD.md)), and **all three shipping languages are RTL** ([PRD C4, §13.1](../../docs/PRD.md)). That single fact reframes localization from a feature into a foundation: because there is no LTR locale to hide behind, a physical-side layout slip is a *guaranteed-visible* bug in every locale, not a latent one in an unused one (engineering 12 §intro; design 12 §1). The category's own evidence makes the stakes concrete — "you read best what you read most," so a missing string, an English fallback, the Arabic digit block shown to a Persian reader, or "page 7 of 30" reordering to "30 of 7" each break the everyday-familiar comfort that earns a ḥāfiẓ's trust ([Nedeljković et al., 2020], design 12 §3, §4, §7). Deferring any of this to a "polish phase" is the failure mode this epic forecloses: RTL correctness, locale numerals, and accessibility are always-on gates from the first screen, because the bug surface is *every* screen and the cost of building LTR-first then "mirroring later" is a rewrite (engineering 12 §8; design 12 §1).

Three non-negotiables outrank every mechanism here:

- **The Quran is never localized — only the chrome is.** Whatever the UI language, the muṣḥaf is always the Uthmani QPC glyph page; no mirroring, `NumberFormat`, bidi control, UI font, or term-set ever reaches a glyph of it, and the page's printed ayah numbers are never re-rendered by `intl` ([PRD R1, R2, §11.2, §13.1](../../docs/PRD.md); design 12 §8; engineering 12 §5). The localization toolkit stops at the chrome boundary; the immutable glyph layer is E05's.
- **Copy is *adab* before it is correct.** A string that is clear but harsh fails first. The never-ship list — guilt/fear/loss framing, "You'll lose your hifz," controlling mandates ("you must/should/don't"), "safe to drop"/"mastered"/"done", exclamation marks and emoji, any commercial-transaction word — is release-blocking, and `fa`/`ckb`/`ar` values are *transcreations* against the `ar` base, never literal translations that let register drift ([PRD R3, §7.12](../../docs/PRD.md); design 11 §2, §6, §8, §9).
- **Religious copy ships only behind scholarly review.** The sabaq/sabqi/manzil term-sets and the Kurdish-Sorani defaults are flagged "needs native + scholar review" in the ARB `@description` until cleared; the architecture makes swapping a whole term-set one file so later correction is data, not code ([PRD §13.4, §21.1](../../docs/PRD.md); design 12 §6; engineering 12 §3).

## Scope

### In scope

- **The ARB / `gen_l10n` pipeline as the single string accessor.** `l10n.yaml` with `template-arb-file: app_ar.arb` (Arabic the base content language), `nullable-getter: false` (a missing/typo key is a compile error), `use-escaping: true`, `synthetic-package: false`; the generated `AppLocalizations` as the only path to a chrome string, with `@description` metadata carrying translator/scholar context (engineering 12 §1; design 12 §7).
- **The `ckb` (Kurdish Sorani) custom locale + vendored chrome delegate.** `Locale.fromSubtags(languageCode: 'ckb')`, a `CkbMaterialLocalizations` subclass + `LocalizationsDelegate` for the framework chrome Flutter does not ship (OK/Cancel, date-picker labels), and canonical Sorani encoding (U+06D5 ە for AE, U+06A9 ک for kaf; reject stray U+200C and Teh-Marbuta-for-AE) (engineering 12 §3; design 12 §7).
- **Locale-derived RTL + logical layout rules.** App-wide RTL as a consequence of `supportedLocales: [ar, fa, ckb]` + `GlobalWidgetsLocalizations` (no hardcoded app-wide `Directionality`); direction-relative APIs only (`EdgeInsetsDirectional`/`AlignmentDirectional`/`Positioned.directional`, `start`/`end`); the directional-icon mirror policy (mirror back/next/chevron/progress, never media/clock/numerals/the muṣḥaf); the two permitted manual-`Directionality` islands (forced-LTR Latin token, Settings language preview) (engineering 12 §2; design 12 §1, §2).
- **One bidi-isolation helper** (`l10n/bidi.dart`) routing every mixed-script run — page number, "Juz N", surah name beside RTL copy, date, percentage, user-typed name — through Unicode isolates: `isolate` (FSI…PDI) for unknown direction, `isolateLtr`/`isolateRtl` (LRI/RLI…PDI) when direction is known (preferred over FSI's first-strong guess); legacy LRE/RLE embeddings banned (engineering 12 §4; design 12 §3).
- **Per-locale numerals** via `numberFormatFor(locale)` with a pinned `-u-nu-` numbering system — Extended Arabic-Indic (`-u-nu-arabext`, U+06F0..) for fa/ckb, Arabic-Indic (`-u-nu-arab`, U+0660..) for ar — never ASCII concatenation, never the wrong block (engineering 12 §5; design 12 §4).
- **ICU `plural` for every count-bearing string**, with Arabic's six CLDR categories (`zero`/`one`/`two`/`few`/`many`/`other`) treated as a translation contract (engineering 12 §6; design 12 §7).
- **The render-only calendar-display layer**: take E02's converted `(y,m,d)` and re-map its Latin digits to the locale set, then isolate the run; the Settings calendar picker selecting an explicit `CalendarSystem` (default Jalālī for `fa`); CLDR-driven week-start (Saturday for fa/ar) — **conversion is not in this epic** (engineering 12 §5; design 12 §5).
- **The swappable sabaq/sabqi/manzil term-sets** as an ICU `select` over a region key / region-override file (one-file vocabulary swap), with the four traditional grade verbs and cycle names drawn from the active set; the `ckb` defaults flagged provisional (engineering 12 §5; design 12 §6).
- **The localization-completeness CI gate** (PRD §20 gate 5): compile-time key coverage, the `features/**` hardcoded-string grep, the physical-side grep, the ASCII-digit grep, the Arabic-plural completeness check, the canonical-`ckb` lint, the banned-phrase (adab) lint, and the per-locale RTL + numeral golden suite rendered on the **real** bundled UI fonts (engineering 12 §8; design 12 §7).

### Out of scope

- **The `CalendarDate` value type, integer day math, and the Hijri/Jalālī/Gregorian *conversion*** (this epic only renders an already-converted date) → **E02 calendar-and-date-core** (engineering 07; domain-calendars-and-hifzdate).
- **Screen-reader `Semantics`, dynamic-text `textScaler`, contrast ≥ 4.5:1, the heat-map non-color encoding, ≥ 48 dp touch targets** — the accessibility obligations on the same widgets → **E08 accessibility-foundation** (engineering 12 §7).
- **The `MaterialApp.router` shell, `supportedLocales` wiring, and the bottom-nav composition** the RTL order *results* from → **E07 app-shell-walking-skeleton** (this epic supplies the localization/RTL rules that shell obeys).
- **The design tokens, calm palette, typography `type.numeral` token, and the bundled-font Sorani-coverage selection** → **E06 mihrab-foundation / E10 mihrab-component-library** (design 04; design 12 §4 constrains them, does not own them).
- **The empty ARB scaffolding, `l10n.yaml`, and `check_l10n_complete.sh` skeleton** already stood up → **E01 repo-scaffold-and-ci** (this epic fills them with real keys, transcreations, and the full gate).
- **The actual screen copy of Today/Onboarding/Settings/Progress** (its keys are added by those feature epics *using* this pipeline) → **E11–E19** (this epic owns the pipeline, helpers, term-sets, and gate; not every feature's strings).
- **Any muṣḥaf glyph, ayah number, juz/sajda marker, or page text** → **E05 quran-data-and-rendering** (domain-mushaf-text-integrity); the localization toolkit never crosses the sacred-text boundary.

## Dependencies

### Depends on

- **E01 repo-scaffold-and-ci** — the `l10n` Flutter package (`flutter`, `intl`), the `app_ar.arb` template + empty `app_fa.arb`/`app_ckb.arb`, the generated `AppLocalizations` committed (`synthetic-package: false`), `l10n.yaml` with the `ar` template, and the dormant `check_l10n_complete.sh` this epic turns into the full layered gate.
- **E06 mihrab-foundation** — the calm-palette color tokens, the UI typography and `type.numeral` digit-set token, and the bundled Perso-Arabic / Sorani-covering UI fonts the per-locale RTL/numeral goldens render with (never `Ahem`).
- **E07 app-shell-walking-skeleton** — the `MaterialApp.router` composition root, `localizationsDelegates`/`supportedLocales: [ar, fa, ckb]`, and the bottom-nav whose RTL order this epic's logical-layout rules make correct by construction.

### Enables

- **E08 accessibility-foundation** — shares the per-locale RTL focus/reading-order invariant and the golden harness; the localized `Semantics` labels E08 audits are stored through this epic's ARB pipeline.
- **E10 mihrab-component-library** — every component (page card, grade band, heat cell, banner) lays out with the logical-inset, mirror-policy, bidi-isolation, and locale-numeral rules established here.
- **E11–E19** — onboarding/cold-start, Today + recite/grade, muṣḥaf reader chrome, mutashābihāt trainer, progress/heat-map, settings/profiles/teacher, backup, reminders, and the science screen all add their strings through this pipeline and render numerals/dates/term-sets through these helpers.
- **E16 settings-profiles-teacher** — the UI-language, calendar-system, numeral, and term-set pickers ride this epic's `numberFormatFor`, `CalendarSystem`-display, and region-override term-set machinery.
- **E20 release-readiness** — gate 5 (localization completeness: zero missing keys, no hardcoded strings, per-locale RTL/numeral goldens) is a release-blocker this epic makes machine-checkable.

## Foundation inputs

| Input | Where (doc / skill) | What this epic takes from it |
|---|---|---|
| The ARB / `gen_l10n` pipeline | docs/engineering/12-localization-rtl-accessibility-impl.md §1 | `l10n.yaml` with `ar` template, `nullable-getter: false`/`use-escaping`/`synthetic-package: false`; the key→getter rule; `AppLocalizations` as the single accessor; the `@description` metadata contract; "no strings in `/engine`" |
| Locale-derived direction & logical layout | docs/engineering/12-localization-rtl-accessibility-impl.md §2 | RTL from the locale (no hardcoded app-wide `Directionality`); direction-relative-only APIs and the physical-side grep ban; the two permitted manual-`Directionality` islands; read `Directionality.of(context)`, never assume RTL |
| `ckb` custom locale + vendored delegate | docs/engineering/12-localization-rtl-accessibility-impl.md §3 | `Locale.fromSubtags(languageCode: 'ckb')`; the `CkbMaterialLocalizations` subclass + delegate for framework chrome; the Sorani glyph-coverage release-gate item; ckb copy stays provisional |
| One bidi-isolation helper | docs/engineering/12-localization-rtl-accessibility-impl.md §4 | The single `bidi.dart`; FSI…PDI for unknown direction, `isolateLtr`/`isolateRtl` for known; isolate the embedded token (not the word); refuse FSI where direction is known; refuse to isolate muṣḥaf glyphs |
| Locale numerals & regional terminology | docs/engineering/12-localization-rtl-accessibility-impl.md §5 | `numberFormatFor(locale)` with pinned `-u-nu-arabext`/`-u-nu-arab`; ASCII-digit refusal; the calendar-display boundary (digits remapped downstream of conversion); the region-override `select` for term-sets |
| ICU plurals & Arabic's six categories | docs/engineering/12-localization-rtl-accessibility-impl.md §6 | Every count-bearing string is an ICU `plural`; the six-category `pagesDue` template; the ARB-completeness assertion of `zero/one/two/few/many/other` for `app_ar.arb` |
| The localization & accessibility gate | docs/engineering/12-localization-rtl-accessibility-impl.md §8 | The layered, mostly compile-time/grep gate table (key coverage, hardcoded-string grep, physical-side grep, ASCII-digit grep, Arabic-plural check, RTL+numeral goldens on real fonts); RTL is a tested, always-on invariant |
| RTL by geometry & icon-mirroring table | docs/design-system/12-localization-and-rtl.md §1, §2 | Logical `start`/`end` everywhere; the RTL nav order is a *visual result*, not a manual reversal; the curated mirror/never-mirror table; the muṣḥaf page/ayah marker/sajda sign are never mirrored |
| FSI/PDI isolation & locale digit sets | docs/design-system/12-localization-and-rtl.md §3, §4 | The "page 7 of 30 → 30 of 7" failure the helper prevents; placeholder-not-splice; the two distinct Unicode digit blocks via `intl`; only chrome numbers are `intl`-shaped, never the page's ayah numbers |
| Calendars, week-start, term-sets, Sorani encoding | docs/design-system/12-localization-and-rtl.md §5, §6, §7 | Three user-selectable calendars rendered (not converted) here; CLDR week-start (Saturday for fa/ar); term-sets as swappable string data with a regional override; 100% ARB coverage + canonical Sorani encoding |
| The Quran is never localized | docs/design-system/12-localization-and-rtl.md §8 | The sacred/chrome boundary every localization mechanism stops at; the riwāyah named, the page content immutable |
| Voice, transcreation & the never-ship list | docs/design-system/11-voice-and-tone.md §2, §6, §8, §9 | The four fixed voice attributes; controlling-language ban; transcreation + per-locale register (Persian *šomā*/honorific, softened Arabic imperatives, provisional Sorani); the banned-phrase lint + native + scholar review per locale |
| Skill: ARB string pipeline | .claude/skills/eng-add-localized-string/SKILL.md | The canonical add-a-string procedure: key in `app_ar.arb` first, `l10n.*`-only reads, one full ICU message, six-category plural, `numberFormatFor` numerals, FSI/PDI isolation, `select`/region-override term-sets, canonical-ckb + provisional flag, transcreate to the voice charter, run the gate |
| Skill: RTL & bidi layout | .claude/skills/eng-rtl-and-bidi-layout/SKILL.md | The widget-layer contract: locale-derived direction, logical insets, the mirror policy, the bidi helper, pinned per-locale `NumberFormat`, render-downstream dates, the sacred-text chrome boundary, the per-locale golden gate |

## Deliverables

- [ ] `l10n.yaml` finalized (Arabic template, `nullable-getter: false`, `use-escaping: true`, `synthetic-package: false`) and `AppLocalizations` generated into source and committed; every chrome string read only through `l10n.*`.
- [ ] `lib/l10n/app_ar.arb` (base content language) populated with the foundation key set; `app_fa.arb` and `app_ckb.arb` transcreated against it, each `@description` carrying translator/scholar context; ckb values canonically encoded and flagged "needs native + scholar review".
- [ ] `CkbMaterialLocalizations` subclass + `LocalizationsDelegate` vendored and registered; a widget test asserts a Material dialog under `ckb` renders Sorani button labels (not a default-language fallback).
- [ ] Locale-derived RTL confirmed (no hardcoded app-wide `Directionality`); the physical-side grep gate (`EdgeInsets.only(left:/right:)`, `Alignment.center{Left,Right}`, `Positioned(left:/right:)`) active over `features/**`; the curated icon-mirroring table documented.
- [ ] `l10n/bidi.dart` — the one isolation helper (`isolate`, `isolateLtr`, `isolateRtl`) — and its use at every mixed-run call site; raw opposite-direction concatenation grep-banned.
- [ ] `l10n/numerals.dart` — `numberFormatFor(locale)` pinning `-u-nu-arabext` (fa/ckb) / `-u-nu-arab` (ar); the ASCII-digit-interpolation grep active.
- [ ] Every count-bearing chrome string is an ICU `plural`; the ARB-completeness check asserts all six Arabic CLDR categories for each `plural` in `app_ar.arb`.
- [ ] The calendar-display layer renders E02's converted `(y,m,d)` into locale numerals inside an isolated RTL run; week-start read from CLDR (Saturday for fa/ar); no conversion logic in this epic.
- [ ] The sabaq/sabqi/manzil term-sets modeled as an ICU `select`/region-override (one-file swap), the four traditional grade verbs and cycle names drawn from the active set; ckb term-set flagged provisional.
- [ ] The layered localization-completeness CI gate green: key coverage (compile), `features/**` hardcoded-string grep, physical-side grep, ASCII-digit grep, Arabic-plural completeness, canonical-`ckb` lint, banned-phrase (adab) lint, and per-locale RTL + numeral golden screenshots on the real bundled fonts.

## Definition of Done

- [ ] **Offline / no-network preserved:** nothing in this epic opens a socket or fetches a font/locale at runtime — all direction, numeral, bidi, plural, term-set, and date-display logic is local; bundled UI fonts only, no `google_fonts` ([PRD C1, §13.5, §19.3](../../docs/PRD.md)).
- [ ] **No AI:** no ML/translation-service/ASR dependency is introduced; transcreations are authored and reviewed by humans, not machine-translated ([PRD C2](../../docs/PRD.md); design 11 §8).
- [ ] **Text fidelity / sacred boundary held:** no mirroring, `NumberFormat`, bidi control, UI font, or term-set reaches a muṣḥaf glyph; the page's printed ayah numbers are never re-rendered by `intl`; the muṣḥaf page is never mirrored/flipped/re-typeset; the riwāyah is named in chrome, never the Quran "in the absolute" ([PRD R1, R2, §11.2, §13.1](../../docs/PRD.md); design 12 §8).
- [ ] **RTL + fa/ckb/ar localization is structural, not a phase:** RTL comes from the locale (no hardcoded app-wide `Directionality`); all positioning is logical (`start`/`end`); the physical-side and ASCII-digit greps are green; `fa`/`ckb` render Extended Arabic-Indic (U+06F0..) and `ar` renders Arabic-Indic (U+0660..), proven by per-locale numeral goldens; zero missing ARB keys and zero hardcoded user-facing strings ([PRD C4, §13, §20 gate 5](../../docs/PRD.md)).
- [ ] **Bidi correctness proven:** every mixed-script run is isolated (FSI/LRI/RLI…PDI) via the one helper, known-direction runs use `isolateLtr`/`isolateRtl`, no legacy LRE/RLE; per-locale RTL goldens confirm "page N of M" reads in the correct order and the RTL reading/focus order is the tested visual result.
- [ ] **Calendar layer is render-only:** the conversion (Hijri Umm al-Qurā / Jalālī / Gregorian) stays in E02; this epic only remaps the converted date's digits and isolates the run; the calendar is an explicit `CalendarSystem` setting (default Jalālī for `fa`); week-start is CLDR data, never hardcoded Monday/Sunday.
- [ ] **Accessibility seam respected:** the localized `Semantics` labels this pipeline stores are exercised by E08's TalkBack/VoiceOver pass; goldens render on the real bundled UI fonts (Sorani extra letters پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە and Persian digits actually exercised), never `Ahem`; this epic introduces no streak/score/shame surface.
- [ ] **Sect-neutral adab:** every string passes the adab gate first and the four voice attributes (reverent/calm/plain-and-warm/honest); no never-ship phrase (guilt/fear/loss, "safe to drop"/"mastered", "you must/should/don't", exclamation marks, emoji, "upgrade/premium"); Arabic imperatives are softened to statements of readiness; hard-news strings follow empathy → fact → path → choice; no string issues a fiqh ruling or speaks for the Quran ([PRD R3, R6, §7.12](../../docs/PRD.md); design 11 §3–§6).
- [ ] **Scholarly review flagged where pending:** the sabaq/sabqi/manzil term-sets and all `ckb` values carry "needs native + scholar review" in their `@description` and ship clearly provisional until a native speaker (register) and a scholar (terminology) clear them; the architecture lets a cleared term-set replace them as a one-file data change ([PRD §13.4, §21.1](../../docs/PRD.md); design 12 §6).
- [ ] **Tests:** the localization-completeness gate (key coverage, the four greps, the Arabic-plural check, the canonical-ckb lint, the banned-phrase lint) and the per-locale RTL + numeral golden suite are green in CI; the `ckb`-dialog widget test passes; correctness-sensitive helpers (`numberFormatFor`, `bidi.dart`) carry unit tests written test-first ([PRD §20 gate 5](../../docs/PRD.md); engineering 12 §8).
- [ ] **No CLAIMS attach by construction:** this epic is pure chrome — it stores, isolates, and digit-shapes wording but originates no user-facing factual number, scheduling rule, or methodology claim; any such claim is registered by the feature epic that authors it (domain-claims-register-and-science-screen), and this epic only renders its already-cleared wording.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E09-T01 | [Finalize the gen_l10n/ARB pipeline: l10n.yaml (ar base), nullable-getter false, committed AppLocalizations, app_ar.arb foundation keys](E09-T01-arb-pipeline-ar-base.md) | M | E01, E07 |
| E09-T02 | [Locale-completeness CI gate: key coverage + features/** hardcoded-string grep + physical-side grep + ASCII-digit grep + banned-phrase (adab) lint](E09-T02-localization-completeness-gate.md) | M | E09-T01 |
| E09-T03 | [ckb custom locale + vendored CkbMaterialLocalizations delegate + canonical-Sorani encoding lint + ckb-dialog widget test](E09-T03-ckb-locale-and-delegate.md) | M | E09-T01 |
| E09-T04 | [Locale-derived RTL + logical-inset rules + the directional-icon mirror table + the two permitted manual-Directionality islands](E09-T04-rtl-logical-layout-mirror-policy.md) | M | E09-T01, E07 |
| E09-T05 | [bidi.dart: the one FSI/PDI isolation helper (isolate / isolateLtr / isolateRtl) + raw-concat grep ban (test-first)](E09-T05-bidi-isolation-helper.md) | S | E09-T01 |
| E09-T06 | [numerals.dart: numberFormatFor(locale) with pinned -u-nu-arabext/-u-nu-arab + ASCII-digit grep + per-locale numeral goldens (test-first)](E09-T06-locale-numerals.md) | M | E09-T01, E06 |
| E09-T07 | [ICU plural pipeline: every count-bearing string a plural; Arabic six-category ARB-completeness check (test-first)](E09-T07-icu-plural-arabic-categories.md) | S | E09-T01, E09-T02 |
| E09-T08 | [Calendar-display layer: render E02's converted (y,m,d) into locale numerals, isolate the run, CLDR week-start; no conversion here](E09-T08-calendar-display-layer.md) | M | E09-T05, E09-T06, E02 |
| E09-T09 | [Swappable sabaq/sabqi/manzil term-sets: ICU select/region-override + grade verbs/cycle names + provisional ckb flagging](E09-T09-term-sets-region-override.md) | M | E09-T01, E09-T03 |
| E09-T10 | [Per-locale RTL + numeral golden suite on the real bundled fonts; wire the full gate into CI green](E09-T10-rtl-numeral-golden-suite.md) | M | E09-T04, E09-T06, E09-T08, E09-T09 |

## Risks

- **RTL/localization deferred to a "polish phase."** Treating fa/ckb/ar as a late translation pass produces an LTR-first app "mirrored later" — a rewrite, since the bug surface is every screen. *Mitigation:* the physical-side and ASCII-digit greps and the per-locale RTL/numeral goldens are always-on gates from this epic forward, and direction follows the locale so they run on draft copy before any final translation lands (engineering 12 §8; design 12 §1).
- **A gate that passes because it checks nothing.** A grep with a bad path glob, or a golden rendered with `Ahem`, exits green while Sorani letters and Persian digits go unexercised. *Mitigation:* goldens load the *real* bundled UI fonts; the ckb-dialog widget test catches a missing delegate; each grep is proven against a deliberate violation per eng-add-ci-check (engineering 12 §8; design 12 §7).
- **The Arabic-digit `intl` inconsistency.** `intl` shapes Eastern digits in dates but not reliably in `NumberFormat`, and bare-locale defaults disagree, so a Persian reader could see `٤٥٦` (the Arabic block) instead of `۴۵۶`. *Mitigation:* `numberFormatFor` pins the numbering system explicitly (`-u-nu-arabext`/`-u-nu-arab`), and a per-locale numeral golden asserts the exact Unicode block on both numbers and dates (engineering 12 §5; design 12 §4).
- **A mixed run reorders the line or scrambles the screen-reader order.** "Page 7 of 30" rendering "30 of 7" is a visual *and* an accessibility bug. *Mitigation:* one mandatory `bidi.dart` helper, known-direction runs use `isolateLtr`/`isolateRtl` (not FSI's mis-guessing first-strong), raw concatenation grep-banned, isolation verified in the RTL goldens and an E08 TalkBack/VoiceOver pass (engineering 12 §4; design 12 §3).
- **The localization toolkit reaching the muṣḥaf.** A well-meant "make the ayah numbers match the UI numeral set" or a mirrored page would alter scripture and end the project. *Mitigation:* the sacred/chrome boundary is explicit — no mirroring/`NumberFormat`/bidi/font ever touches the immutable glyph layer; the page's ayah numbers come from E05, never `intl` ([PRD R1](../../docs/PRD.md); design 12 §8).
- **Provisional Sorani / term-set copy shipped as final.** Locking ckb terminology or a regional vocabulary before native + scholar review risks a wrong or non-neutral religious term. *Mitigation:* ckb values and term-sets carry "needs native + scholar review" in the `@description`, ship clearly provisional, state no ruling, and are replaceable as a one-file data change; the banned-phrase lint plus per-locale human review gate them ([PRD §13.4, §21.1](../../docs/PRD.md); design 11 §9; design 12 §6).
- **A literal translation silently changes the tone.** Pronoun, register, and the imperative do not map across fa/ar/ckb, so word-for-word translation can turn a calm line curt or cold. *Mitigation:* `fa`/`ckb`/`ar` values are transcreations against the four-attribute voice charter with deliberate per-locale register; the banned-phrase lint and native-register review run per locale (design 11 §8, §9).

## References

- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/PRD.md — C1, C2, C4, C6, R1, R2, R3, R6, §3, §11.2, §13 (§13.1–§13.6), §17, §18, §19.1, §19.3, §20 (gate 5), §21.1
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/12-localization-rtl-accessibility-impl.md — §1, §2, §3, §4, §5, §6, §8 (§7 accessibility consumed at the E08 boundary)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/engineering/07-dates-calendars-and-correctness.md — §4 (the converted date this epic renders; conversion owned by E02)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/12-localization-and-rtl.md — §1, §2, §3, §4, §5, §6, §7, §8
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/11-voice-and-tone.md — §2, §3, §4, §6, §8, §9
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-add-localized-string/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-rtl-and-bidi-layout/SKILL.md

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
