# E13-T04 — Jump-to navigator: resolve juz/ḥizb/sūrah/page targets from the fixed bundled structure with locale numerals, seek the controller

| | |
|---|---|
| **Epic** | [E13 — Muṣḥaf Reader](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E13-T03 |
| **Skills** | ui-mushaf-page-view, ui-numerals-calendar-text, eng-rtl-and-bidi-layout, eng-write-dart-test |

## Goal

A calm jump picker lets the reader pick a juz (1–30), ḥizb (1–60), sūrah (1–114), or page (1–604) and seeks the E13-T03 `PageController` to the resolved page. Every target page is **read** from the read-only bundled Quran structure (the `page`/`surah` reference tables, PRD §6.1) — never computed — so a sacred boundary can never land off-by-one; a small pure-Dart resolver maps each `(unit, index)` to a `page_id`, and a frozen golden-vector unit suite pins each unit's boundary pages. Every index and the sūrah list render in the active locale's numeral set, FSI/PDI-isolated, with the muṣḥaf itself untouched.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §6.1 | The fixed hierarchy — **30 juz → 60 ḥizb → 240 rubʿ → 604 pages → 15 lines/page** — is bundled, read-only reference data the app **never recomputes**; the jump-to ranges (1–30 / 1–60 / 1–114 / 1–604) and the resolution-from-data rule come from here |
| `docs/PRD.md` §12.3 | Muṣḥaf reader behaviour: "Swipe pages (RTL), **jump to juz/ḥizb/surah/page**"; the jump-to is one of the reader's two navigation affordances over the immutable page |
| `docs/PRD.md` §11.2 | The page the controller lands on renders glyph-font-only; the jump path selects a `pageNumber` and **re-derives nothing** about the page's text/layout |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 | "**We refuse to recompute the hierarchy.** Juz/ḥizb/rubʿ/page/line/ayah counts are read from data … even when they look trivially derivable" — the resolver reads the `page` reference table, never arithmetic like `(juz-1)*20+1` |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §2, §6 | The reader draws only what E05 verified and refuses unverified Quran assets; the jump path opens no socket and computes no glyphs — it only chooses a `pageNumber` the verified renderer then draws |
| `docs/engineering/05-persistence-and-encryption.md` (reference schema) | The exact read-only columns the resolver queries: `page(page_id, juz, hizb, rub, surah_start, ayah_start, …)` and `surah(surah_id, name_ar, …)`; these are checksum-governed, read-only tables — the jump path issues SELECTs only, never a write |
| `docs/design-system/04-typography.md` §4–§8 | The picker chrome is shaped `type.*` UI text (16 sp floor), locale numerals, FSI/PDI for the "Page ۲۵۳ · Juz ۷" mixed runs and the sūrah-name + index rows — chrome **around**, never on, the page; no `type.*` token or OS text-scale touches the muṣḥaf |
| Skill `ui-mushaf-page-view` (+ `template.dart`) | Step 6 — navigation moves the immutable page by rebuilding with a new `pageNumber` only; the jump seeks the RTL-aware `PageController` (E13-T03) and never mirrors/reorders glyphs; `intl` reshaping never reaches the page's printed ayah/juz/ḥizb markers |
| Skill `ui-numerals-calendar-text` (+ `template.dart`) | Rule 1–2, 6, 9 — every index renders via `numberFormatFor(locale)` (`fa/ckb-u-nu-arabext`, `ar-u-nu-arab`); the "Page N · Juz M" run is a formatted, FSI/PDI-isolated placeholder, never an ASCII splice; the muṣḥaf's own printed numerals are the immutable glyph layer, never `intl`-reshaped |
| Skill `eng-rtl-and-bidi-layout` (+ `template.dart`) | Logical `start`/`end` insets for the picker rows; read `Directionality.of(context)`; isolate every index/sūrah-name run with `isolateLtr` (known-direction digits) / `isolate`; no hardcoded `Directionality`, no `EdgeInsets.only(left:/right:)` |
| Skill `eng-write-dart-test` (+ `template.dart`) | §3 (frozen golden vectors), §4 (resolution lives in a pure unit, not a `pumpWidget`), §7 (RTL goldens per locale), §8 (throwing `HttpOverrides`) — the boundary-page table is the gate that makes "read, never recompute" a passing/failing check |
| `docs/science/CLAIMS.md` C-031 | The "one card = one muṣḥaf page (604)" framing behind the page-count range and the page-as-unit navigation; any "604 pages" copy traces here |
| `docs/science/CLAIMS.md` C-048 | "Works fully offline … one-time checksum-verified download, then airplane-mode forever" — the jump-to covenant: the resolver reads bundled data, opens no socket |
| Sibling E13-T01 | Supplies the `MushafReaderScreen` View + `MushafReaderViewModel` and the typed `go_router` page/juz/ḥizb/sūrah deep-link params; this task wires the **in-app** jump picker into that View and reuses the same resolver the deep-link redirect uses |
| Sibling E13-T02 | The display-only reader-state store holds the current `pageNumber`; the jump **does not** write it directly — it seeks the controller, whose `onPageChanged` (E13-T03) updates the store; no engine state is touched |
| Sibling E13-T03 | Owns the RTL-aware `PageView`/`PageController`; this task calls `controller.jumpToPage(...)` over its page-index mapping (page 1 → first slot), honouring the same RTL direction; glyph content is never mirrored |
| Sibling E13-T09 | Localizes the picker labels, unit names, and `Semantics` strings for fa/ckb/ar; this task lands the ARB keys it needs and defers transcreation/Semantics-label polish to T09 |
| Sibling E13-T10 | Hosts the consolidated jump-to/ViewModel unit suite and the real-font RTL goldens; this task ships its own resolver vectors + picker widget test, which T10 folds into the reader suite |

## Implementation notes

**TEST-FIRST (correctness-critical):** the resolver is a sacred-boundary mapping — a wrong juz/ḥizb/sūrah start page sends the reader to the wrong āyah. Write the frozen boundary-page vector table (below) and the out-of-range cases **first**; they must exist and fail before `resolveJumpTarget` is implemented. The resolver reads data — it never does `(juz - 1) * 20 + 1`-style arithmetic.

1. **Resolver lives in the `data` (or `quran`) package, pure of Flutter.** Add `JumpUnit { juz, hizb, surah, page }` and `JumpTarget({required JumpUnit unit, required int index})` as immutable value types in the `models` package, and a `QuranStructureRepository` in the `data` package exposing `Future<int> firstPageOf(JumpTarget target)` (or `int` over an eagerly-loaded read-only snapshot). It resolves by **reading the bundled reference tables**: page = `MIN(page_id) WHERE juz = :index` for juz, `MIN(page_id) WHERE hizb = :index` for ḥizb, `MIN(page_id) WHERE surah_start = :index` (the page where that sūrah's first āyah falls) for sūrah, and `:index` clamped/validated for page. No Drift symbol crosses the package boundary; the View receives `int pageNumber`, never a row.
2. **Read-only, transaction-free.** The `page`/`surah` tables are checksum-governed read-only reference data (`docs/engineering/05` reference schema). The resolver issues SELECTs only — no `db.transaction`, no write, no `review_log`, no `due_at`. A jump mutates **nothing** engine-side; it is a pure lookup + a controller seek.
3. **Validate the index against the fixed range; never silently clamp a sacred boundary wrong.** juz ∈ [1,30], ḥizb ∈ [1,60], sūrah ∈ [1,114], page ∈ [1,604]. An out-of-range index returns a sealed error (or is unreachable because the picker only offers valid indices) — it never falls back to page 1 silently and never computes a page the data does not assert.
4. **Wire the picker into E13-T01's View, expose `jumpTo` on the ViewModel.** `MushafReaderViewModel.jumpTo(JumpTarget)` calls `firstPageOf`, then asks the E13-T03 navigator to `jumpToPage(pageIndexFor(pageNumber))` over its RTL page-index mapping. The same resolver backs the `go_router` deep-link redirect (E13-T01) so an in-app jump and a deep-link land identically. The jump picker is a calm modal/sheet built from the E10 jump-picker pattern (token names only); a tab/segmented control selects the unit, a list/wheel selects the index.
5. **Every index renders via `numberFormatFor(locale)`; the sūrah row pairs `name_ar` + isolated index.** The juz/ḥizb/page index lists and the resolved-target confirmation ("Page ۲۵۳ · Juz ۷") format through `numberFormatFor(locale)` (`fa/ckb-u-nu-arabext`, `ar-u-nu-arab`) and FSI/PDI-isolate each token as a formatted ARB placeholder (`isolateLtr` for the digit run) — never `"Page " + n.toString()`. The sūrah list shows `surah.name_ar` (a single `Text`/`TextSpan`, isolated) beside its isolated locale-numeral index. **The muṣḥaf's own printed juz/ḥizb/ayah markers are never `intl`-reshaped** — only the picker chrome is.
6. **RTL + logical layout.** Picker rows use `EdgeInsetsDirectional`/`AlignmentDirectional`; direction-needing logic reads `Directionality.of(context)`; the unit selector advances in RTL reading order. No hardcoded `Directionality`, no `EdgeInsets.only(left:/right:)`, no `Alignment.centerLeft/Right` (the `features/**` grep bans them).
7. **Offline / no engine mutation / no gamification.** The resolver reads bundled data only — it opens no socket and infers nothing. The jump writes no card, appends no `review_log`, re-derives no `due_at`, and surfaces no "you haven't read juz N", no progress badge, and no streak — it is a quiet navigation control over a sacred reference surface.
8. **Pitfalls to avoid:** computing a juz/ḥizb/sūrah start page by arithmetic instead of reading the table (the §3 "refuse to recompute" violation — and an off-by-one on a sacred boundary); resolving a sūrah jump to where the sūrah *name banner* sits vs. where its **first āyah** falls — pin the chosen rule in a vector and a doc comment; mapping page→page-index in the wrong RTL direction so the controller lands mirrored (defer the index mapping to E13-T03, do not re-derive it here); letting a Drift row or a calendar/`intl` digit reach the page; splicing an ASCII index into a localized label; writing the reader-state store directly instead of letting the controller's `onPageChanged` update it.

## Acceptance criteria

- [ ] `JumpUnit`/`JumpTarget` are immutable value types in `models`; `QuranStructureRepository.firstPageOf` lives in `data` and returns an `int pageNumber` — no Drift symbol crosses the boundary (verifiable by grep over the feature/View files).
- [ ] `firstPageOf` resolves juz/ḥizb/sūrah/page **by reading** the `page`/`surah` reference tables (`MIN(page_id)` over the matching column); no arithmetic derivation of any boundary appears in the source.
- [ ] The resolution is read-only: no `db.transaction`, no write to any user table, no `review_log` append, no `due_at` re-derivation on the jump path.
- [ ] An out-of-range or unknown index yields a sealed error (or is unreachable by construction); it never silently falls back to page 1 and never returns a page the data does not assert.
- [ ] Selecting a target seeks the E13-T03 `PageController` to the resolved page via its RTL page-index mapping; the in-app jump and the E13-T01 deep-link share the resolver and land identically.
- [ ] Every index and the resolved-target confirmation render via `numberFormatFor(locale)` (fa/ckb Extended Arabic-Indic ۰۱۲, ar Arabic-Indic ٠١٢); every mixed run is FSI/PDI-isolated as a formatted placeholder; no ASCII digit reaches a localized string.
- [ ] The picker uses logical `start`/`end` layout, reads `Directionality.of(context)`, and advances in RTL order; no `EdgeInsets.only(left:/right:)`/`Alignment.centerLeft/Right`/hardcoded `Directionality` survives the `features/**` grep.
- [ ] The muṣḥaf is untouched: the page's printed juz/ḥizb/ayah markers are never `intl`-reshaped; the jump only chooses a `pageNumber` the verified E05 renderer draws glyph-only.
- [ ] No gamification on the jump path: no "unread juz" nudge, progress badge, streak, or score; the picker is a calm navigation control.

## Tests

**Resolver golden-vector suite — `packages/data/test/quran_structure_repository_test.dart`** (`package:test` if the resolver is pure-Dart over a snapshot; `flutter_test` with an in-memory Drift fixture seeded from the bundled reference rows otherwise), REUSE SPDX header, throwing `HttpOverrides` installed via the shared bootstrap. Written FIRST:

- **Frozen boundary-page vectors** — a committed `(JumpUnit, index) → page_id` table asserting the **first** page of every juz (1–30), every ḥizb (1–60), and a representative spread of sūrahs (al-Fātiḥa→1, al-Baqarah→2, an-Nās, and a few mid-muṣḥaf sūrahs), plus `page → page` identity for endpoints (1, 604). The table is the executable form of "read, never recompute"; it is regenerated only by an explicit, human-reviewed `--update-vectors` run, never blessed in CI.
- **Read-only proof** — a recording/fake repository (or a read-only-opened fixture) asserts the resolution path issues no write and opens no transaction; a jump leaves every user table byte-identical.
- **Range guard** — juz 0, juz 31, ḥizb 61, sūrah 0, sūrah 115, page 0, page 605 each yield the sealed error (or are rejected), never page 1 and never an out-of-data page.
- **Resolver-is-pure** — the resolution is asserted as a unit, not driven through `pumpWidget`.

**Picker widget test — `packages/features/test/mushaf/jump_picker_test.dart`** (`flutter_test`, in-memory Riverpod overrides for the repository and a spy navigator):

- Choosing juz 7 / ḥizb 14 / sūrah 36 / page 253 calls the resolver and then `jumpToPage` with the **page-index** the E13-T03 mapping yields for that page (RTL direction preserved); the reader-state store is updated only via the controller's `onPageChanged`, not written directly by the picker.
- A per-locale numeral golden (`@Tags(['golden'])`, real bundled UI fonts via `FontLoader`, never Ahem) under `Directionality.rtl` for fa/ckb/ar confirms indices render in the locale block (U+06F0-range for fa/ckb, U+0660-range for ar) and the "Page N · Juz M" run is bidi-correct.

**Offline guard:** the throwing `HttpOverrides` stays installed across both suites; a jump/resolve makes no network call (CLAIMS C-048).

## Definition of Done

- [ ] All acceptance criteria met; resolver vectors + picker tests green locally and in CI (the fast job for units, the pinned golden job for the numeral golden).
- [ ] **Offline / no-network (non-negotiable):** the jump path opens no socket and fetches nothing; it reads only the bundled, verified reference tables; the throwing-`HttpOverrides` guard proves the radio stays off while resolving and seeking (CLAIMS C-048); E01's no-network/banned-import gates stay green.
- [ ] **No AI / no microphone:** nothing in the resolver or picker uses AI, ASR, audio, or inference; targets are read from fixed data, not predicted.
- [ ] **Quran text fidelity (existential):** the jump **re-derives and re-typesets nothing** — it reads `page_id` from data (never recomputes the hierarchy, `docs/engineering/08` §3), and only chooses a `pageNumber` the E05 renderer draws glyph-only; no `intl` numeral, bidi control, or UI font reaches the page's printed markers; the muṣḥaf is identical before and after a jump.
- [ ] **RTL + fa/ckb/ar strings:** every picker label, unit name, index, and the resolved-target confirmation ship via `gen_l10n` for fa/ckb/ar (T09), with `type.*` tokens, locale numerals, and FSI/PDI isolation; the picker advances right-to-left in all three locales.
- [ ] **Accessibility:** the unit selector, each index option, and the confirm/seek action carry localized `Semantics` labels, meet the 48dp/contrast floors, and respect RTL focus order; indices are reachable by screen reader in correct logical order.
- [ ] **Sect-neutral adab:** the picker names units neutrally (juz/ḥizb/sūrah/page), introduces no madhhab-specific framing, no tafsīr/translation, and never presents the destination as "the Quran" absolutely; no gamification, badge, or "unread" guilt on the jump.
- [ ] **Nothing safe to drop / single write path:** the jump marks no page droppable, optional, or done, surfaces no D/S/R or percentage, writes no card/`review_log`, and re-derives no `due_at`; reader state updates only through the controller's `onPageChanged` (E13-T02/T03), never by the picker writing it.
- [ ] **Deterministic tests:** the boundary-page vectors are frozen and human-reviewed (no auto-bless), the resolver is a pure unit, and the numeral golden uses real fonts under `Directionality.rtl` — all running in CI on every PR.
