# E13-T07 — Always-shown riwāyah/edition chrome label + About/Credits attribution entry (never "the Quran" absolutely)

| | |
|---|---|
| **Epic** | [E13 — Muṣḥaf Reader](EPIC.md) |
| **Size** | S (≈0.5-1 day) |
| **Depends on** | E13-T01 |
| **Skills** | domain-adab-and-religious-integrity, domain-mushaf-text-integrity, ui-numerals-calendar-text |

## Goal

The reader always names the muṣḥaf it is showing: a calm, always-visible chrome label rendered from the active `MushafEdition.displayName`/`riwayah` (e.g. "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf") sits around — never on — the glyph page, as ordinary shaped `type.*` UI text with any index in locale numerals, FSI/PDI-isolated. From that label a quiet affordance opens the About/Credits attribution surface (Tanzil text / QUL layout / KFGQPC fonts, each credited, with the byte-for-byte checksum guarantee stated plainly). The page is **never** presented as "the Quran" absolutely, and **zero** tafsīr / translation / commentary is drawn beside it. This task wires only the riwāyah label + the entry to attribution; it re-typesets, re-shapes, and re-derives nothing about the page.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §11.2 | The rendering rules the label sits *around*: the muṣḥaf is glyph-font-only, themed/zoomed by transforming the layer; the riwāyah chrome is UI text, not part of the page — it never touches the glyph layer |
| `docs/PRD.md` §11.1, §11.1.1, §17 | The attribution + integrity facts the About/Credits surface states: Tanzil (text, CC BY 3.0, verbatim, attributed), QUL (layout), KFGQPC (fonts), pinned SHA-256 checksums verified in CI and re-verified at runtime, fully offline after the one-time core-pack download — the "byte-for-byte checksum guarantee" copy traces here |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §1, §8 | `MushafEdition.riwayah`/`displayName` are the fields the chrome names; "State the riwāyah; never present the bundled muṣḥaf as 'the Quran' absolutely" — show `displayName` + Tanzil/QUL/KFGQPC attribution + the checksum guarantee; ship zero tafsīr/translation; the muṣḥaf is identical across fa/ckb/ar (only chrome localizes) |
| `docs/design-system/04-typography.md` §1, §4, §8 | Two pipelines: the muṣḥaf gets **no** `type.*` token and never the OS shaper (§1); the riwāyah/About labels are ordinary shaped UI text on the `type.*` ramp with the 16 sp floor — the riwāyah statement is load-bearing, so `type.body` or above, never below the caption floor (§4); mixed Latin/numeral runs are FSI/PDI-isolated (§8) |
| Skill `domain-adab-and-religious-integrity` (+ `template.md`) | The conscience pass for this surface: R2 — name the riwāyah, never "the Quran" absolutely, attribute Tanzil/QUL/KFGQPC, **zero** tafsīr/translation/commentary; R3 — no badge/ornament/decoration on or beside the sacred page; the voice gate (reverent/calm/plain-warm/honest) on every string; the external-link "needs scholarly review where pending" boundary on any methodology copy |
| Skill `domain-mushaf-text-integrity` (+ `template.dart`) | Step 8 — `displayName` "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf" surfaces at onboarding/settings/About with Tanzil/QUL/KFGQPC attribution + the byte-for-byte checksum guarantee; the label is chrome **around** the immutable glyph layer and never re-typesets, re-shapes, or recolours the page; the muṣḥaf is identical across fa/ckb/ar |
| Skill `ui-numerals-calendar-text` (+ `template.dart`) | Rule 1–2, 6, 9 — any index in the riwāyah/About chrome (a line count, a page count, a font count "604") renders via `numberFormatFor(locale)` (`fa/ckb-u-nu-arabext`, `ar-u-nu-arab`) and is FSI/PDI-isolated as a formatted placeholder; the muṣḥaf's own printed numerals are the immutable glyph layer, never `intl`-reshaped |
| `docs/science/CLAIMS.md` C-048 | "Works fully offline, never records your voice, one-time checksum-verified download, then airplane-mode forever" — the offline/no-mic covenant the About/Credits attribution restates honestly; any "604 pages" / "verified download" copy traces here |
| `docs/science/CLAIMS.md` C-031 | "One card = one muṣḥaf page (604), reviewed whole-page" — the page-as-unit framing behind any "604" figure shown in the attribution; the figure is locale-shaped, not an ASCII splice |
| Sibling E13-T01 | Supplies the `MushafReaderScreen` View, the `MushafReaderViewModel` exposing the active `MushafEdition` (its `displayName`/`riwayah`), and the `widgets/` dir + scoped providers this task adds the label + About entry into; this task fills the riwāyah-chrome seam T01 reserved |
| Sibling E13-T06 | The reader theme/zoom controls; the riwāyah label is part of the same edge-receding chrome the theme toggle lives in — it shares the chrome layout but is independent of the layer transform (the label is never `ColorFilter`ed or scaled with the page) |
| Sibling E13-T08 | Owns the no-dashboard edge-receding/auto-hide treatment of the whole chrome; the riwāyah label is always-present *content* of that chrome — T08 governs *how* it recedes; this task governs *that it is named and never decorated* |
| Sibling E13-T09 | Localizes the riwāyah label wording, the About/Credits strings, and the `Semantics` labels for fa/ckb/ar; this task lands the ARB keys it needs (the riwāyah line, the About-entry label, the attribution body, the checksum-guarantee line) and defers transcreation + Semantics polish to T09 |
| Sibling E13-T16 ↔ E16 (settings) | E16 owns the muṣḥaf/riwāyah swap that re-binds the active `MushafEdition`; this task **displays** whichever edition is active and re-renders the label reactively when it changes — it never picks or swaps the edition |

## Implementation notes

TEST-FIRST (correctness-critical for adab): the two release-blocking facts here are *the riwāyah is always named* and *the page is never called "the Quran" absolutely with zero tafsīr beside it*. Write the widget test that asserts the `displayName` is present on the reader chrome, and the banned-content guard test (no "the Quran"-absolute string key, no tafsīr/translation widget in the page subtree), **before** the label/About bodies — they must exist and fail first.

1. **Riwāyah label widget** — `packages/features/lib/src/mushaf/widgets/riwayah_chrome_label.dart`, one primary type `RiwayahChromeLabel extends ConsumerWidget` (or a dumb `StatelessWidget` fed the edition). It reads the active `MushafEdition` from the `MushafReaderViewModel`'s state (the seam T01 exposed) — it issues **no** DAO call, reaches **no** engine, and contains **no** `DateTime.now()`. It renders `edition.displayName` (the human "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf") as a single `Text` in `type.body`/`type.label` with `color.text.secondary`, in the bundled `type.family.ui` — **never** the QPC page font, never a `type.*`-less raw style. The label is content of the reader chrome that recedes to the edge (layout owned by T08); it is **always present** while the page is shown — never gated, dismissed permanently, or hidden behind a tap.

2. **The label is chrome, not the page — keep the pipelines apart (existential).** The `RiwayahChromeLabel` lives in the chrome layer of the reader `Stack`/`Scaffold`, *outside* the `MushafPageView`'s `ColorFiltered`/`Transform.scale` frame, so theme and zoom never recolour or scale it with the glyph layer. It never imports or applies `qpcFontFamily(...)`; it never draws `glyphCodes`; it never re-typesets any verse. A grep over the widget shows no QPC font family, no `glyphCodes`, no `fontFamilyFallback`.

3. **Any number in the chrome goes through `numberFormatFor(locale)`, FSI/PDI-isolated.** If the riwāyah line or the About body shows an index (a line count "15", a page/font count "604"), it is formatted via `numberFormatFor(locale)` (`fa/ckb-u-nu-arabext`, `ar-u-nu-arab`) and isolated as a formatted ARB placeholder (`isolateLtr` for the digit run) — never `edition.pageCount.toString()` spliced into a sentence. The `displayName` itself is a localized chrome string (T09), not a hardcoded literal; the transliterated riwāyah term (*Ḥafṣ ʿan ʿĀṣim*) is preserved with correct transliteration per adab.

4. **About/Credits entry.** Add a quiet affordance on/near the label (an "ⓘ" / "About this muṣḥaf" text button — a calm chrome control, not a badge) that opens an About/Credits surface (a modal sheet or a `GoRoute('/mushaf/about')` — match whatever the app's About pattern is; defer to the E16 settings About surface if one exists and link into it rather than duplicating). The surface states, from the active `MushafEdition` and pinned manifest facts, three credited rows: **Tanzil** (Uthmani text, CC BY 3.0, verbatim, attributed, with the tanzil.net link), **QUL/Tarteel** (page layout geometry), **KFGQPC** (the 604 per-page glyph fonts, redistributed unmodified) — plus a plain-language **byte-for-byte checksum guarantee** line ("the text and every page font are verified against a pinned SHA-256 before they are ever shown; an unverified asset is refused") and the offline covenant (C-048). It draws **no** tafsīr, **no** translation, **no** commentary.

5. **External links clearly leave the app, fully offline-safe.** The Tanzil attribution link (and any source link) is rendered so it visibly leaves the app and opens in the browser (`url_launcher`-style external open) — the app itself opens no socket; tapping a link hands off to the OS browser. The About surface and the label render with **no** network call (CLAIMS C-048); a throwing `HttpOverrides` guard proves it.

6. **The adab conscience pass (release-blocking).** Run every string through the voice gate: reverent, calm, plain-and-warm, honest; no exclamation, no emoji, no "the Quran" absolute, no marketing/upgrade copy. Name the riwāyah; never imply this is *the* canonical Quran to the exclusion of other authentic riwāyāt; keep the wording madhhab/sect-neutral. Any methodology sentence stays attributed/optional and flagged "needs scholarly review" where pending — but this surface should contain **no fiqh ruling** at all; it is attribution, not guidance.

7. **RTL + logical layout.** The label and About rows use `EdgeInsetsDirectional`/`AlignmentDirectional`; direction-needing logic reads `Directionality.of(context)`; no `EdgeInsets.only(left:/right:)`, no `Alignment.centerLeft/Right`, no hardcoded `Directionality` (the `features/**` grep bans them). The label aligns to the logical start of the chrome and reads right-to-left in all three locales.

8. **Pitfalls to avoid:** rendering `displayName` in the QPC page font or pulling the riwāyah into a shared muṣḥaf `TextStyle` (it is chrome, not scripture — keep the §1 two-pipeline line); placing the label *inside* the `ColorFiltered`/`Transform.scale` frame so it dims/scales with the page; letting the label be hidden permanently or gated behind a tap (it must be always-present while the page shows); splicing `pageCount.toString()`/an ASCII digit into a localized line; drawing **any** tafsīr/translation/commentary on the About surface or beside the page ("just a quick translation toggle" is forbidden, not discouraged — R2); calling the page "the Quran" absolutely in any string key; adding a badge/ornament/decorative frame to the label (it is a calm credit, not a stamp); opening a socket to fetch attribution text (it is bundled/from the manifest); hardcoding the riwāyah literal instead of an ARB key; an external link that opens in-app without signalling it leaves the app.

## Acceptance criteria

- [ ] `riwayah_chrome_label.dart` exists in `packages/features/lib/src/mushaf/widgets/` with one primary type; it reads the active `MushafEdition` from the reader ViewModel state, reaches no DAO/engine, and contains no `DateTime.now()`.
- [ ] While a page is shown, the active `MushafEdition.displayName` (e.g. "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf") is **always visible** in the reader chrome; it is never permanently hidden, dismissed, or gated behind a tap.
- [ ] The label renders in the bundled UI font (`type.family.ui`) on the `type.*` ramp (at `type.body`/`type.label`, never below the caption floor), with `color.*`/`type.*` referenced by name — never the QPC page font, never a glyph-code string, never a `fontFamilyFallback` (verifiable by grep over the widget).
- [ ] The label sits **outside** the `MushafPageView`'s `ColorFiltered`/`Transform.scale` frame, so theme/zoom never recolour or scale it with the glyph layer.
- [ ] Any number in the riwāyah/About chrome renders via `numberFormatFor(locale)` (fa/ckb Extended Arabic-Indic ۰۱۲, ar Arabic-Indic ٠١٢) and is FSI/PDI-isolated as a formatted placeholder; no ASCII digit is spliced into a localized string.
- [ ] An "About this muṣḥaf" affordance opens an About/Credits surface that credits **Tanzil** (text, CC BY 3.0, tanzil.net link), **QUL/Tarteel** (layout), and **KFGQPC** (fonts), and states the **byte-for-byte SHA-256 checksum guarantee** + the fully-offline covenant in plain language.
- [ ] **Zero** tafsīr / translation / commentary is drawn on the About surface or beside the page; the page is **never** called "the Quran" absolutely in any string key.
- [ ] Source links visibly leave the app (open in the OS browser); the label and About surface make no network call at runtime.
- [ ] The label and About rows use logical `start`/`end` layout, read `Directionality.of(context)`, and read right-to-left; no `EdgeInsets.only(left:/right:)`/`Alignment.centerLeft/Right`/hardcoded `Directionality` survives the `features/**` grep.
- [ ] Every user-facing string comes from `AppLocalizations` (ARB keys; `ar` template + `fa`/`ckb` completed in T09); no hardcoded UI literal, no inline hex/pt.

## Tests

Mirror the source under `packages/features/test/mushaf/`; `flutter_test` + Riverpod `ProviderContainer.test()`; goldens load the **real bundled UI fonts** (and, where the page is in frame, the **real KFGQPC fonts**) via `FontLoader` (never Ahem) under an RTL `Directionality` and a pinned runner; REUSE SPDX header; throwing `HttpOverrides` installed via the shared bootstrap. Written FIRST for the riwāyah-present and banned-content cases.

**`riwayah_chrome_label_test.dart`** (widget):
- **Riwāyah always named** — with a fake active `MushafEdition` whose `displayName` is "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf", `RiwayahChromeLabel` renders that text; with a *different* fake edition, the label re-renders to its `displayName` (proves it reads the active edition, not a hardcode).
- **Chrome, not scripture** — the label's resolved `TextStyle.fontFamily` is the UI family, **not** any `QPC_P###` family; no `glyphCodes` string and no `fontFamilyFallback` appears in the widget subtree.
- **Outside the transform frame** — applying a sepia/dark `ColorFilter` and a zoom step to the page does **not** recolour or scale the label (asserted by the label living outside the `ColorFiltered`/`Transform.scale` subtree).
- **Locale numerals** — a per-locale check (fa/ckb U+06F0-range, ar U+0660-range) on any index shown in the label/About; the "604"/"15" figures are locale-shaped and isolated, never ASCII.

**`mushaf_about_credits_test.dart`** (widget):
- **Three attributions present** — the About surface shows the Tanzil, QUL/Tarteel, and KFGQPC credits and the plain-language checksum-guarantee + offline-covenant lines.
- **No tafsīr/translation** — a guard asserts the About subtree (and the reader page subtree) contains **no** translation/tafsīr/commentary widget or string key; a banned-key lint asserts no string key presents the page as "the Quran" absolutely.
- **External link leaves the app** — the Tanzil link triggers an external open (a spy on the launcher), not an in-app navigation; no socket is opened.

**Adab conscience snapshot** — a `flutter_test` over the ARB keys this task introduces asserts each passes the banned-phrase lint (no "the Quran"-absolute, no guilt/fear/loss, no "upgrade/premium", no exclamation/emoji) in the `ar` template (fa/ckb folded into T09's per-locale lint).

**Offline guard** — the throwing `HttpOverrides` stays installed across the suite; rendering the label and opening the About surface make no network call (CLAIMS C-048). No `DateTime.now()` is reachable from the widgets (grep + injected-clock assertion).

The consolidated reader real-font RTL goldens (light/sepia/dark + zoom + overlays on/off, with the riwāyah label in frame) live in **E13-T10**; this task ships its own label/About widget tests, which T10 folds into the reader suite.

## Definition of Done

- [ ] All acceptance criteria met; the label/About widget tests, the adab snapshot, and the `HttpOverrides` offline guard run green locally and in CI on every PR; E01's no-network + banned-import + banned-phrase gates stay green with the new strings/widgets included.
- [ ] **Offline / no-network (non-negotiable):** the label and About surface open no socket and fetch nothing at runtime; attribution text is bundled/from the pinned manifest; an external source link hands off to the OS browser; the throwing-`HttpOverrides` guard proves the radio stays off (CLAIMS C-048).
- [ ] **No AI / no microphone:** nothing in the label or About path uses AI, ASR, or audio; the surface couples to no microphone and no audio-recognition.
- [ ] **Quran text fidelity (existential):** the riwāyah label is chrome in the bundled UI font, kept architecturally apart from the muṣḥaf — it re-shapes, re-typesets, and recolours nothing on the page; it applies no QPC font, draws no `glyphCodes`, adds no `fontFamilyFallback`, and sits outside the page's `ColorFilter`/scale frame; the muṣḥaf is identical before and after the label/About render.
- [ ] **Sect-neutral adab (release-blocking):** the active riwāyah/`displayName` is **always named** while the page is shown; the page is **never** called "the Quran" absolutely; **zero** tafsīr/translation/commentary is drawn on the About surface or beside the page; Tanzil/QUL/KFGQPC are credited with the byte-for-byte checksum guarantee stated plainly; the wording is madhhab/sect-neutral and issues no fiqh ruling.
- [ ] **RTL + fa/ckb/ar strings:** the riwāyah line, the About-entry label, the attribution body, and the checksum-guarantee line ship via `gen_l10n` for fa/ckb/ar (T09), with `type.*` tokens, locale numerals, and FSI/PDI isolation; the muṣḥaf itself is identical across all three locales (only this chrome localizes).
- [ ] **Accessibility:** the always-shown riwāyah label and the About affordance carry localized `Semantics` labels, meet the 48dp/contrast floors, and respect RTL focus order; the riwāyah statement is load-bearing and never truncated/auto-shrunk below the caption floor; external links announce that they leave the app.
- [ ] **No gamification / nothing safe to drop:** the label and About surface add no badge/counter/streak/score/ornament/decorative frame over or beside the page, mark no page droppable or done, and surface no D/S/R or percentage — they are a calm, reverent credit.
- [ ] **Single write path / no engine mutation:** the label and About path are display-only — they mutate no card, append no `review_log`, re-derive no `due_at`, and do not swap the edition (E16 owns the swap; this surface only reads the active edition).
- [ ] **Deterministic tests:** the riwāyah-present, chrome-not-scripture, banned-content, and locale-numeral cases are pure widget tests with no hidden clock and no network; goldens (in T10) load real fonts via `FontLoader` (never Ahem) under `Directionality.rtl`; this task adds no re-rendered muṣḥaf reference of its own.
