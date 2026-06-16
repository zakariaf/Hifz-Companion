# E09-T04 — Locale-derived RTL + logical-inset rules + the directional-icon mirror table + the two permitted manual-Directionality islands

| | |
|---|---|
| **Epic** | [E09 — Localization & RTL Foundation](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E09-T01, E07 |
| **Skills** | eng-rtl-and-bidi-layout, eng-write-dart-test |

## Goal

App-wide RTL is confirmed to be a *consequence* of `supportedLocales: [ar, fa, ckb]` + `GlobalWidgetsLocalizations` (E07's composition root) — there is no hardcoded app-wide `Directionality(TextDirection.rtl)` anywhere. This task makes the widget-layer direction contract structural: feature code uses direction-relative APIs only (`EdgeInsetsDirectional`/`AlignmentDirectional`/`Positioned.directional`, logical `start`/`end`); the curated directional-icon mirror table is authored as a single reference (`l10n/icon_mirror_policy.dart` + doc) — mirror back/next/chevron/progress/sign-off via the auto-mirroring `Icons.arrow_*` family, never media/clock/phone/numeral glyphs and **never** the muṣḥaf; and exactly two manual-`Directionality` islands are documented and helper-wrapped (a forced-LTR Latin technical token, and the Settings language preview). Any logic that needs direction reads `Directionality.of(context)` and never assumes RTL. The whole contract is provable by the physical-side grep gate (E09-T02) plus widget tests that pump under each locale.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §2 | The core of this task: RTL is derived from the locale (no hardcoded app-wide `Directionality`); direction-relative APIs only and the physical-side grep ban over `features/**`; the two permitted manual-`Directionality` islands (forced-LTR Latin token; Settings language preview); "we refuse to assume RTL in logic" — read `Directionality.of(context)`. Use the verbatim `NavigationBar` logical-order example and the two-island snippet as the shape to implement. |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 | The mirror/physical-side rules are a *gate*, not a convention: the physical-side grep (`EdgeInsets.only(left:/right:`, `Alignment.center{Left,Right}`, `Positioned(left:/right:`) and the per-locale RTL golden are always-on, mostly compile-time/grep. This task supplies the source the grep guards and the widget tests the gate runs. |
| `docs/design-system/12-localization-and-rtl.md` §1 | RTL by geometry, not a flipped flag: every inset is logical `start`/`end`; the bottom-nav RTL order (Today rightmost) is the *visual result* of logical-order children under RTL, never a manual reversal; reading/focus order is a tested invariant. |
| `docs/design-system/12-localization-and-rtl.md` §2 | **The authoritative mirror table** — copy it verbatim into the policy: mirror back/next/chevron/progress/sign-off-flow/page-turn *direction*; never mirror media-play/clock/phone/numeral glyphs; **never** mirror/flip/rotate/reflect the muṣḥaf glyph page, ayah-end marker, or sajda sign. "Mirroring everything is as wrong as mirroring nothing." Icon-only mirrored controls still carry a localized semantic label (the label is E08/E09-T01's; this task only pins the mirror yes/no). |
| `docs/design-system/12-localization-and-rtl.md` §8 | The sacred/chrome boundary this task must not cross: no mirroring/`NumberFormat`/bidi/UI-font reaches a glyph of the muṣḥaf page; the page-turn *direction* may be RTL but the page *content* is the immutable glyph layer (E05) and is never mirrored. |
| `docs/design-system/11-voice-and-tone.md` §1 | Adab is the first gate even on a layout task: the icon-only mirrored controls (back/next/sign-off) must read with a reverent, calm localized label; this task introduces no copy and no streak/score surface. |
| Skill `eng-rtl-and-bidi-layout` (+ `template.dart`) | Rules 1–4 and 9 are this task's checklist: locale-derived direction; logical-inset-only layout; read `Directionality.of(context)`; mirror only directional glyphs via `Icons.arrow_*`; the chrome-only boundary. Use `template.dart`'s locale-derived (never hardcoded) setup, the logical-inset widget, the forced-LTR Latin island, and the Settings language-preview island as scaffolds. Rules 5–8 (bidi helper, numerals, dates) are **siblings' work**, not this task. |
| Skill `eng-write-dart-test` (+ `template.dart`) §7 | RTL is asserted by construction, per locale: pump each surface under `Directionality(textDirection: rtl)` / the locale for `ar`/`fa`/`ckb`; widget tests use in-memory Riverpod fakes; the throwing `HttpOverrides` offline guard is installed by the shared bootstrap. RTL *layout* tests may use the font-independent strategy; the real-font per-locale golden suite itself is E09-T10. |
| CLAIMS register | **None attach.** This task is pure layout geometry — it mirrors icons and resolves logical insets but originates no user-facing number, scheduling rule, or methodology claim (epic DoD: "No CLAIMS attach by construction"). It surfaces no copy; the labels it leaves room for are authored and registered elsewhere. |
| Sibling E09-T01 | Supplies the `AppLocalizations` accessor and the foundation `app_ar.arb` keys this task's example surfaces read (`navToday`, `navMushaf`, …); this task consumes that pipeline, it does not extend it. |
| Sibling E09-T02 | Owns the physical-side grep over `features/**` (and the hardcoded-string/ASCII-digit/banned-phrase greps). This task writes the direction-relative source that grep guards and provides a deliberate-violation fixture so T02's gate is proven to bite. |
| Sibling E09-T05 | Owns `bidi.dart` (FSI/PDI isolation). The mirrored-icon labels and any mixed run on the surfaces this task touches are isolated by T05's helper — this task does not concatenate or isolate text. |
| Sibling E09-T10 | Wires the per-locale RTL + numeral golden suite on the **real** bundled fonts into CI. This task's widget tests are the font-independent precursor; T10 captures the real-font goldens of the same surfaces. |
| E07 app-shell-walking-skeleton | Supplies `MaterialApp.router`, `localizationsDelegates`, `supportedLocales: [ar, fa, ckb]`, and the bottom-nav whose RTL order this task's logical-layout rules make correct by construction. This task **confirms** that wiring yields RTL; it does not author the shell. |

## Implementation notes

TEST-FIRST is NOT required for the layout source (it is geometry verified by goldens/widget pumps, not correctness-critical arithmetic), but the **two widget tests below are written before** the islands' helpers so the forced-LTR and language-preview islands have a failing assertion first. The mirror policy is a curated table + a thin lookup, not new math.

1. **Confirm, don't author, locale-derived RTL.** Add a widget test (not new production code) that pumps E07's `MaterialApp.router` under each of `Locale('ar')`, `Locale('fa')`, `Locale.fromSubtags(languageCode: 'ckb')` and asserts `Directionality.of(context) == TextDirection.rtl` with **no** `Directionality` widget hardcoded above the router. A grep assertion (or a `flutter analyze` custom-lint, whichever E09-T02 chose) proves `Directionality(textDirection: TextDirection.rtl)` appears in zero files under `lib/` except the two sanctioned islands in `l10n/`. Per impl-12 §2.

2. **Author the directional-icon mirror policy as one reference.** Create `packages/l10n/lib/src/icon_mirror_policy.dart` (the `l10n` package, alongside `bidi.dart`/`numerals.dart`) holding a curated, documented table — not per-widget intuition (ds-12 §2). Model it as a small immutable enum/record set, e.g. a `MirrorPolicy` with `mirror` / `neverMirror` / `neverMirrorSacred` categories and a `const` map keyed by the semantic role (back, next, chevron, progress, signOffFlow, pageTurnDirection → `mirror`; mediaPlay, clock, phone, numeralGlyph → `neverMirror`; mushafPage, ayahEndMarker, sajdaSign → `neverMirrorSacred`). Directional roles resolve to the auto-mirroring `Icons.arrow_back`/`Icons.arrow_forward` family (which already respects ambient direction — the policy *documents* this, it does not re-implement mirroring); `neverMirror`/`neverMirrorSacred` roles must never be wrapped in a `Transform.flip`/`matrix4` mirror. The sacred category exists to make a reviewer-visible, grep-visible refusal: nothing in this package or `features/**` may flip a `neverMirrorSacred` role. Put the table's prose (the verbatim ds-12 §2 rows) in the file's `///` doc comment so the policy and its source live together.

3. **Direction-relative layout is the only layout.** All positioning in this task's example surfaces and in the shared widgets it touches uses `EdgeInsetsDirectional`, `AlignmentDirectional`, `Positioned.directional`, and logical `start`/`end` over the `space.*` scale (E06 tokens) — never `EdgeInsets.only(left:/right:)`, `Alignment.centerLeft/Right`, or `Positioned(left:/right:)`. The bottom nav is laid out in *logical* order (Today first → Settings last) so RTL renders Today at the right edge automatically; this task adds no manual reversal. Per impl-12 §2 and ds-12 §1.

4. **Read direction from context, never as a constant.** Provide a tiny convenience (e.g. `bool isRtl(BuildContext c) => Directionality.of(c) == TextDirection.rtl`) in `l10n` *only if a call site needs it* — do not add it speculatively. No production logic in this task or its surfaces hardcodes `TextDirection.rtl`; the two islands below are the only places `TextDirection` is named literally.

5. **Island (a): forced-LTR Latin technical token.** Add `packages/l10n/lib/src/forced_ltr.dart` exposing one widget, e.g. `ForcedLtrText(this.token)` → `Directionality(textDirection: TextDirection.ltr, child: Text(token))`, for a Latin-only technical string (a version string, a backup file's SHA-256 hex, an asset-pack id) that would visually scramble inside RTL chrome. It is forced LTR *as a whole island*, not bidi-isolated mid-run (that is T05's job for mixed runs); the token here is pure-Latin and stands alone. Per impl-12 §2.

6. **Island (b): Settings language preview.** Add a `LanguagePreview(sampleText, previewLocale)` widget that renders a sample in the *candidate* locale's direction — `Directionality(textDirection: candidateDir, child: Text(sample))` — where `candidateDir` is derived from the previewed locale, not from the ambient one (so previewing an LTR locale, if ever offered, shows LTR even while the app is RTL). This is the only place direction is computed from a locale other than the active one. Per impl-12 §2. The widget lives in `l10n` (the reusable island); the Settings *screen* that hosts it is E16's.

7. **Files & package boundary.** New source lands in `packages/l10n/lib/src/` (`icon_mirror_policy.dart`, `forced_ltr.dart`, `language_preview.dart`), exported from the package barrel; this is the same `l10n` package that holds `bidi.dart` (T05) and `numerals.dart` (T06). No `features/**` file is rewritten here beyond confirming the shell's logical layout; feature screens consume these widgets later. The `engine` package is untouched (it holds no strings, no direction, no Flutter import).

8. **Pitfalls to avoid.** (a) Re-implementing mirroring with `Transform`/`matrix4` instead of trusting `Icons.arrow_*` auto-mirroring — the policy *documents* the framework behavior, it does not duplicate it. (b) Mirroring everything "because the app is RTL" — a flipped play/clock/phone glyph is a recognizability bug (ds-12 §2). (c) Flipping/rotating/reflecting any muṣḥaf glyph, ayah marker, or sajda sign for any visual goal — that alters scripture and ends the project (ds-12 §2, §8). (d) A hardcoded app-wide `Directionality(TextDirection.rtl)` "to be safe" — it hides physical-side bugs and breaks the LTR island. (e) Assuming `TextDirection.rtl` as a constant in logic instead of reading `Directionality.of(context)`. (f) Bidi-isolating inside the forced-LTR island, or hard-splicing a token into RTL copy — leave mixed-run isolation to T05. (g) Letting the language preview read ambient direction instead of the previewed locale's.

## Acceptance criteria

- [ ] No hardcoded app-wide `Directionality(TextDirection.rtl)` exists; `Directionality(textDirection: TextDirection.*)` appears in exactly two production files — `l10n/forced_ltr.dart` (LTR) and `l10n/language_preview.dart` (candidate-locale dir) — verifiable by grep over `lib/`.
- [ ] A widget test pumps E07's router under `ar`, `fa`, and `ckb` and asserts the ambient `Directionality.of(context)` is `TextDirection.rtl` in all three with no `Directionality` ancestor hardcoded above the app.
- [ ] `packages/l10n/lib/src/icon_mirror_policy.dart` exists with the curated table: directional roles (back/next/chevron/progress/sign-off/page-turn) → `mirror`; media-play/clock/phone/numeral → `neverMirror`; muṣḥaf page/ayah-end marker/sajda sign → `neverMirrorSacred`; the verbatim ds-12 §2 rows in its `///` doc.
- [ ] The policy resolves directional roles to the auto-mirroring `Icons.arrow_*` family and never wraps a `neverMirror`/`neverMirrorSacred` role in a mirror transform; no `Transform`/`matrix4` flip is applied to any sacred role anywhere.
- [ ] All positioning in this task's surfaces uses `EdgeInsetsDirectional`/`AlignmentDirectional`/`Positioned.directional` and logical `start`/`end`; the physical-side grep (E09-T02) is green over `features/**` and the new `l10n` source.
- [ ] `ForcedLtrText` forces LTR around a pure-Latin technical token as a whole island; `LanguagePreview` renders the sample in the *previewed* locale's direction (not the ambient one).
- [ ] Direction-needing logic reads `Directionality.of(context)`; no production file outside the two islands names `TextDirection.rtl`/`.ltr` as a constant.
- [ ] Every new public declaration carries a `///` doc comment; the file carries the REUSE `GPL-3.0-or-later` SPDX header; `dart format` and the analyzer are clean.

## Tests

All tests obey `eng-write-dart-test`: `flutter test` (these widgets need a binding), in-memory Riverpod fakes where a provider is touched, the throwing `HttpOverrides` offline guard installed by the shared bootstrap, the REUSE SPDX header, full-word names, no `DateTime.now()`.

`packages/l10n/test/icon_mirror_policy_test.dart` — unit (`flutter_test`):
- Every directional role (back, next, chevron, progress, signOffFlow, pageTurnDirection) maps to `mirror`.
- Every real-world/fixed-convention role (mediaPlay, clock, phone, numeralGlyph) maps to `neverMirror`.
- Every sacred role (mushafPage, ayahEndMarker, sajdaSign) maps to `neverMirrorSacred`; a guard asserts the policy exposes no API that returns a mirror transform for a sacred role (the refusal is structural, not just data).

`packages/l10n/test/forced_ltr_test.dart` — widget (written first, fails before the island exists):
- Pumped inside an RTL host, `ForcedLtrText('1.2.0+build')` resolves `Directionality.of` to `TextDirection.ltr` for its subtree while the host stays RTL.

`packages/l10n/test/language_preview_test.dart` — widget (written first):
- `LanguagePreview` previewing an RTL locale renders the sample RTL; previewing an LTR locale (sentinel) renders it LTR even while the ambient app direction is RTL — proving the preview reads the *previewed* locale, not the ambient one.

`apps/.../test/rtl_shell_direction_test.dart` (or the shell package's test dir) — widget:
- Pump the E07 shell under each of `ar`/`fa`/`ckb`; assert ambient direction is RTL and that the first `NavigationDestination` (Today, logical-first) renders at the right edge (font-independent layout assertion via `tester.getRect`), confirming the RTL nav order is the visual result of logical order, not a manual reversal.

A deliberate-violation fixture for E09-T02 (a file containing `EdgeInsets.only(left: 16)` and `Directionality(textDirection: TextDirection.rtl)` at app scope) confirms the physical-side and hardcoded-direction greps fail on it (kept out of the build, referenced by T02's gate test per `eng-add-ci-check`).

The real-font, per-locale RTL **golden** capture of these surfaces is **E09-T10**, not this task — these tests use the font-independent strategy and stay green across contributor machines.

## Definition of Done

- [ ] All acceptance criteria met; the widget/unit suite is green locally and in CI; the E09-T02 physical-side and hardcoded-`Directionality` greps are green over the new source and bite on the deliberate-violation fixture.
- [ ] **Offline / no-network preserved:** nothing here opens a socket or loads a font/locale at runtime; all direction and mirror logic is local; the throwing `HttpOverrides` guard is installed in the test bootstrap ([PRD C1, §19.3]).
- [ ] **No AI / no microphone:** no ML, translation service, ASR, or microphone dependency is introduced; this is pure widget-layer geometry ([PRD C2]).
- [ ] **Quran text fidelity / sacred boundary held:** the mirror policy's `neverMirrorSacred` category forbids mirroring/flipping/rotating/reflecting the muṣḥaf glyph page, ayah-end marker, and sajda sign; no `NumberFormat`, bidi control, UI font, or mirror transform reaches a glyph of the page; the page-turn *direction* may be RTL but the page *content* is E05's immutable layer ([PRD R1, R2, §11.2]; ds-12 §2, §8).
- [ ] **RTL + fa/ckb/ar is structural, not a phase:** RTL is confirmed to come from the locale (no hardcoded app-wide `Directionality`); all positioning is logical `start`/`end`; the physical-side grep is green; the ambient direction is RTL in all three locales by widget test ([PRD C4, §13.2, §20 gate 5]).
- [ ] **Accessibility seam respected:** icon-only mirrored controls (back/next/sign-off) leave room for the localized `Semantics` label E08 audits and E09-T01 stores; this task adds no streak/score/shame surface and respects the per-locale RTL reading/focus-order invariant E08 shares ([PRD §18]; ds-12 §1, §2).
- [ ] **Sect-neutral adab:** no copy is authored here; the controls this task mirrors stay calm and reverent in their (sibling-authored) labels; no banned phrase, no fiqh ruling, nothing speaks for the Quran ([PRD R3, R6]; ds-11 §1).
- [ ] **Deterministic tests:** the widget/unit tests pump under explicit locales with no wall clock and no network; RTL is asserted by construction per locale; layout assertions are font-independent (the real-font golden is E09-T10).
- [ ] **No CLAIMS attach by construction:** this task originates no user-facing factual number, scheduling rule, or methodology claim — it mirrors icons and resolves insets; any claim is registered by the feature epic that authors the copy these surfaces will later carry.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
