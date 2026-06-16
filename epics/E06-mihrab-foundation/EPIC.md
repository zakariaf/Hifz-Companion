# E06 — Mihrab Design Foundation

Build the Mihrab design system in Flutter: the typed token API (`color.*`, `type.*`, `space.*`, `motion.*`/`haptic.*` as `ColorScheme`/`TextTheme` plus `ThemeExtension`s), the four reading appearances (Light · Sepia · Dark · Night) seeded from one calm Quran-green, the hard separation between the modern Perso-Arabic UI type pipeline and the immutable muṣḥaf glyph pipeline, and exactly the skeleton presentation widgets the walking skeleton (E07) needs to render a screen. This epic is presentation-only and RTL-native by construction — it holds no engine math, no date logic, no persistence, and no Quran glyphs; it builds the calm, reverent surface every later feature epic paints onto.

## Why this epic exists

The product's central pillar is *calm, not cute*, because the daily ritual it serves carries spiritual weight and must lower arousal, not farm it ([PRD §2 design-principle 1; design-system 05 §5](../../docs/PRD.md)); calm here is a **measurable specification** — low saturation in the blue–green region, audited contrast, no celebratory motion — not a matter of taste ([design-system 03 §1; 06 §2](../../docs/design-system/03-color-and-themes.md)). If those rules live only in prose, every feature epic re-decides them and the calm erodes one screen at a time. E06 turns the design system into one auditable token tree so a palette, type-ramp, spacing, or motion change is a **one-file edit** and no widget can hardcode a raw hex, dp, or duration ([design-system 02 §9](../../docs/design-system/02-material-and-platform-foundations.md)).

Two non-negotiables make this foundation correctness-critical, not cosmetic. First, **text fidelity is existential** ([PRD R1](../../docs/PRD.md)): the single most important typographic decision is that the Quran and the interface live in **two separate rendering pipelines that share no `TextStyle`, no metrics, and no shaper** ([design-system 04 §1](../../docs/design-system/04-typography.md)). E06 builds the UI pipeline (`type.*` over Vazirmatn/Estedad) deliberately distinct from — and structurally walled off from — the muṣḥaf glyph pipeline E05 owns, so a user never mistakes interface for scripture and no UI font can ever reach a Quran asset. Second, **no gamification of worship** ([PRD R3/C6](../../docs/PRD.md)): the token system refuses a `color.success`, refuses M3 Expressive spring motion, and refuses any `motion.celebrate.*` or "success" haptic tier — those are not tokens we restrained, they are tiers that **do not exist** ([design-system 02 §5; 06 §2, §4](../../docs/design-system/02-material-and-platform-foundations.md)). Building the foundation before any feature means the reverent, non-coercive register is enforced by structure (a contrast gate, a missing token, a banned-curve check) rather than by hoping every later screen remembers the rule.

Finally, all three locales are RTL ([PRD C4](../../docs/PRD.md)). RTL is **the layout's geometry, not a mode** — every inset is logical start/end and the whole tree is `Directionality.rtl` by construction ([design-system 05 §3](../../docs/design-system/05-layout-spacing-touch.md)). The skeleton components built here are RTL-native from their first commit, so E07's walking skeleton and E10's full component library extend an already-correct surface instead of retrofitting mirroring later.

## Scope

### In scope

- **Token mechanism (the substrate).** One root `ThemeData(useMaterial3: true)` per appearance driven by `ColorScheme.fromSeed(seedColor: <calm green>, brightness:, contrastLevel:)`; a custom `TextTheme` mapping `type.*` onto the M3 role slots; and typed `ThemeExtension`s for every bespoke family — `MihrabColors` (heat-map ramp, track-chip, decay, reader surfaces, the warning semantic), `SpacingTokens` (`space.1`…`space.8`), `MotionTokens` (`motion.duration.*`, `motion.curve.*`), `HapticTokens` (the three pulses) — each with `copyWith`/`lerp`, read only via `Theme.of(context).extension<T>()`, no raw value in any widget ([design-system 02 §9](../../docs/design-system/02-material-and-platform-foundations.md)).
- **The four reading appearances**, each its own audited `ColorScheme` + `MihrabColors` from the one green seed: **Light** (positive-polarity default), **Sepia** (warm paper), **Dark** (off-black `#121413`, desaturated, never pure black), **Night** (Dark warmed *and* luminance-reduced, no sleep claim) — pinned to the values and contrast posture in [design-system 03 §3, §4, §7](../../docs/design-system/03-color-and-themes.md).
- **The UI type pipeline:** `type.family.ui` = Vazirmatn, `type.family.uiFallback` = Estedad, both bundled (no `google_fonts` runtime fetch); the six-step ramp (`display`/`title`/`body`/`label`/`caption` + the `numeral` rule) at the Arabic-script sizes, line-height ≈1.5–1.6, zero letter-spacing, set as component-theme defaults ([design-system 04 §2, §4, §6](../../docs/design-system/04-typography.md)).
- **The pipeline wall:** the `type.*`/`TextTheme` system is provably never handed to a muṣḥaf path; a build-time assertion / analyzer scope keeps QPC glyph rendering (owned by E05/`quran`) out of the UI type pipeline and vice-versa — the structural restatement of the §1 "two pipelines, one rule" guarantee ([design-system 04 §1](../../docs/design-system/04-typography.md); [PRD R1](../../docs/PRD.md)).
- **The heat-map ramp tokens** (`color.heatmap.strong`→`faded`), monotonic-in-luminance, single-hue green-receding-to-neutral, defined as data — the *visual grammar* and the "never a scoreboard" rule are E15's; E06 only ships the audited token values ([design-system 03 §5](../../docs/design-system/03-color-and-themes.md)).
- **Exactly the skeleton components E07's walking skeleton needs**, presentation-only and RTL-native: a `MihrabScaffold` chrome wrapper (full-bleed content, bottom-action band placement), the five-tab `NavigationBar` chrome in RTL order (Today · Muṣḥaf · Mutashābihāt · Progress · Settings) wired to no real routes, a calm `MihrabCard`/`ListTile` row, the `FilledButton`/`SegmentedButton` styling, and the appearance switcher control — each a dumb View taking only display data, each with a `#Preview` matrix across the four appearances and the three locales.
- **The reduce-motion + reduced-energy plumbing:** a small helper reading `MediaQuery.disableAnimations` so every animated token collapses to a cross-fade/cut, and the directional `motion.transition.pageTurn` shaped start→end in RTL ([design-system 06 §3, §5](../../docs/design-system/06-motion-and-haptics.md)).
- **The token / appearance / RTL golden harness:** the four-appearance × three-locale golden screenshots of the skeleton components and the contrast-audit fixture that re-runs the WCAG 2.2 AA tables on every token change, plugged into E01's pinned-OS golden lane.

### Out of scope

- **The full Mihrab component library** — page card, recite/grade band, heat-map widget, catch-up banner, settings pickers, every component anatomy/state/copy → **E10** (this epic ships only the handful of skeleton widgets E07 needs to render).
- **The walking-skeleton wiring** — the `app/` composition root, `go_router` routes, Riverpod stores, the real Today/Muṣḥaf/Progress slices that consume these tokens and skeleton widgets → **E07**.
- **Muṣḥaf glyph rendering, QPC font selection, overlay painting, the reader's own zoom** — the *other* type pipeline → **E05** (`quran`); E06 only builds the wall between them and the surrounding reader-surface *tokens*.
- **Accessibility as a release program** — the screen-reader `Semantics` labels, the reduce-motion per-locale acceptance pass, the text-scale reflow audit as gates → **E08** (E06 honors the contracts and ships the contrast-audit fixture; E08 owns the audit checklist).
- **Localization content** — transcreated `fa`/`ckb`/`ar` ARB strings, term-sets, numeral/calendar formatting paths → **E09** (E06's skeleton previews use placeholder/`l10n.*` keys, not hardcoded text, and render the locale numerals via the formatter E09 owns).
- **Any number behind a CLAIMS id, any methodology copy, the science screen, the certainty label** → **E19** (no user-facing factual claim ships in this presentation-only epic).
- **Sorani glyph-coverage CI gate + the font version pin** — the per-codepoint no-tofu render check that locks the bundled UI font → **E09** (E06 declares the bundled faces; E09 owns the coverage gate before locking, [design-system 04 §3](../../docs/design-system/04-typography.md)).

## Dependencies

### Depends on

- **E01 repo-scaffold-and-ci** — the pub workspace, the thin `app/` shell with `MaterialApp` already RTL-by-construction, the `features` umbrella and bundled-UI-font declarations the design system lives inside, the dependency allow-list (no `google_fonts` runtime fetch), and the pinned-OS golden + journeys CI lanes this epic's appearance/RTL goldens plug into.

### Enables

- **E07 app-shell-walking-skeleton** — consumes the four themes, the token tree, the `MihrabScaffold`, the RTL `NavigationBar` chrome, and the skeleton card/button widgets to render its first end-to-end vertical slice.
- **E10 mihrab-component-library** — every full component (page card, recite/grade band, pickers, banners) is built from these tokens and skeleton primitives; E10 replaces layouts, never the foundation.
- **E08 accessibility-foundation** — extends the contrast-audit fixture and the reduce-motion plumbing into the release accessibility program.
- **E09 localization-rtl-foundation** — the bundled UI faces and the `type.numeral` rule are where the Sorani-coverage gate and the per-locale numeral path attach.
- (transitively) **E12–E16, E19** — every feature surface (Today, reader chrome, mutashābihāt, progress, settings, science screen) paints onto the appearances, type ramp, spacing, motion, and haptic vocabulary fixed here.

## Foundation inputs

| Input | Where (doc / skill) | What this epic takes from it |
|---|---|---|
| M3 + token-store mechanism | docs/design-system/02-material-and-platform-foundations.md | §1 `useMaterial3` baseline + RTL-by-construction; §2 role-based color from one `fromSeed` seed, no raw hex in widgets; §3 tone-based surface containers, the muṣḥaf never veiled; §4 adopt the M3 type *role structure*, override values for Arabic; §5 restrained components, no badge/streak/celebration surface; §6 short/medium motion rungs only, no Expressive springs; §8 dynamic color refused (one fixed seed); §9 `ThemeData` for roles + `ThemeExtension` for everything else, `copyWith`/`lerp`, 48dp touch + verified contrast as hard gates |
| Color & appearances | docs/design-system/03-color-and-themes.md | §1 calm = low-saturation blue–green spec; §2 green as reverent ground, never reward (no `color.success`); §3 the four appearances + positive-polarity default + no sleep claim; §4 off-black `#121413` Dark, desaturated tones; §5 the heat-map single-hue luminance ramp token *values*; §6 the tiny semantic set (only `warning`, no `success`/`danger` for routine state); §7 the WCAG 2.2 AA audit tables, re-run per appearance |
| Typography & the pipeline wall | docs/design-system/04-typography.md | §1 two pipelines, one rule — UI type never touches the Quran; §2 Vazirmatn + Estedad, bundled, no CDN; §4 the six-step Arabic-script ramp + `type.*`→M3-slot mapping; §5 locale-numeral rule (`type.numeral`); §6 line-height 1.5–1.6, zero letter-spacing as theme defaults; §7 reflow-not-truncate under OS text-scale; §8 FSI/PDI bidi isolation for mixed runs |
| Layout, spacing & touch | docs/design-system/05-layout-spacing-touch.md | §1 the `space.1`…`space.8` 4dp-on-8dp scale in a `SpacingTokens` extension; §2 compact-only grid + logical insets; §3 RTL is the geometry — `EdgeInsetsDirectional`/`AlignmentDirectional`, bottom nav home at trailing/right edge; §4 48×48dp touch targets ≥8dp apart; §5 the bottom-action screen template the `MihrabScaffold` encodes |
| Motion & haptics | docs/design-system/06-motion-and-haptics.md | §1 the `motion.*` tokens (short=150 / medium=250, standard easing) in a `MotionTokens` extension; §2 **no celebratory motion tier exists** (no confetti/`motion.celebrate.*`); §3 page-turn reads start→end in RTL; §4 the three-pulse `haptic.*` vocabulary, no success/reward haptic; §5 reduce-motion honored absolutely via `MediaQuery.disableAnimations` |
| Skill: coding standards | .claude/skills/eng-write-to-coding-standards/SKILL.md | Effective Dart casing; full-word unit-bearing names (`durationMedium`, not `dm`); immutable token value types with `copyWith`; `///` on public token/widget APIs; no user-facing string hardcoded in Dart (strings via `l10n.*`); `Directionality.rtl` structural not per-widget; no `print`, no network, no AI path; the REUSE SPDX header on every file |

## Deliverables

- [ ] Four `ThemeData` builders (Light · Sepia · Dark · Night), each from the one calm-green seed via `ColorScheme.fromSeed` with pinned roles, exposing `contrastLevel`, selectable via an appearance setting that defaults to "follow system" for Light/Dark and offers Sepia/Night explicitly.
- [ ] The typed `ThemeExtension`s — `MihrabColors`, `SpacingTokens`, `MotionTokens`, `HapticTokens` — each with `copyWith`/`lerp`, the audited token values, and `///` docs; read only through `Theme.of(context).extension<T>()`.
- [ ] The custom `TextTheme` mapping `type.display`→`displayLarge/Medium` … `type.caption`→`bodySmall`, set on every `ThemeData`, with line-height 1.5–1.6 and zero letter-spacing as component defaults; Vazirmatn + Estedad bundled, runtime font fetch disabled.
- [ ] The pipeline-wall guard: a build-time assertion / analyzer scope proving no `type.*`/`TextTheme` path can reach a QPC/Quran asset, and no Quran-glyph reference appears in the UI type code.
- [ ] The skeleton presentation widgets E07 needs — `MihrabScaffold`, the RTL five-tab `NavigationBar` chrome, `MihrabCard`/list row, the `FilledButton`/`SegmentedButton` styling, the appearance switcher — each a dumb View, each RTL-native, each with a `#Preview` matrix across four appearances × three locales.
- [ ] The reduce-motion helper (collapses every `motion.*` transition to cross-fade/cut on `disableAnimations`) and the directional `motion.transition.pageTurn` shaped start→end in RTL.
- [ ] The contrast-audit fixture re-running the WCAG 2.2 AA tables (text/accent ≥4.5:1, graphical anchor ≥3:1) for all four appearances on any token change, failing CI on a regression.
- [ ] The four-appearance × three-locale golden screenshots of the skeleton components, on E01's pinned-OS golden lane, green.
- [ ] Token-discipline check: no raw hex / off-scale dp / bare `Duration` / `letterSpacing` on an Arabic run appears in any widget; every value resolves to a named token.

## Definition of Done

- [ ] **Offline / no-network by construction:** this epic adds no network path and no `google_fonts` runtime fetch; the UI faces are bundled assets and the E01 dependency allow-list stays green with the design-system code included.
- [ ] **No AI / no microphone:** no ML/ASR/audio path is introduced; the appearance switcher and skeleton widgets are presentation-only with no recognition surface ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Text fidelity — the pipeline wall holds:** the UI type pipeline (`type.*`/`TextTheme` over Vazirmatn/Estedad) shares no `TextStyle`, metric, or shaper with the muṣḥaf glyph pipeline; the build-time guard proves no UI-font path reaches a Quran asset and no QPC glyph is routed through `TextTheme`; a deliberate violation fails the guard ([PRD R1](../../docs/PRD.md); [design-system 04 §1](../../docs/design-system/04-typography.md)).
- [ ] **No gamification of worship by structure:** there is no `color.success`/`color.semantic.danger` for routine state, no `Badge`/streak/score surface, no M3 Expressive spring curve, no `motion.celebrate.*` token, and no success/reward haptic anywhere in the tokens or skeleton widgets ([PRD R3/C6](../../docs/PRD.md)).
- [ ] **RTL + fa/ckb/ar:** every inset is logical start/end (`EdgeInsetsDirectional`/`AlignmentDirectional`), the tree is `Directionality.rtl` by construction, the five-tab nav home sits at the trailing/right edge, and the skeleton goldens render correctly in all three locales; ckb's longer transcreated labels reflow within the same insets without a separate layout.
- [ ] **Accessibility contracts honored:** every interactive skeleton control is ≥48×48dp with ≥8dp spacing; type scales with the OS `TextScaler` and reflows rather than truncates; the WCAG 2.2 AA contrast audit passes in all four appearances (Sepia/Night re-measured, not inherited); reduce-motion collapses all animation to cross-fade/cut (E08 owns the full audit program).
- [ ] **Calm is enforced, not hoped:** the seed is one desaturated green; the heat-map ramp is monotonic-in-luminance single-hue (no red→green, no rainbow); decay/missed-day tokens are calm neutral/green-family, never alarm-red; Night carries no sleep claim.
- [ ] **Token discipline holds:** no widget hardcodes a hex, an off-scale dp, a bare `Duration`/`Curve`, or `letterSpacing` on an Arabic run; M3 roles live in `ThemeData`, every bespoke family in a `ThemeExtension`, and each token family is owned by exactly one file per the README token map.
- [ ] **Sect-neutral adab:** no muṣḥaf is decorated, no green is laid over glyphs as ornament, no celebratory or coercive surface ships; the foundation is reverent ground that serves the page, never competes with it.
- [ ] **Tests green:** the contrast-audit fixture, the pipeline-wall guard, the token-discipline check, and the four-appearance × three-locale skeleton goldens all run on the E01 CI lanes and pass on the epic's final PR.

## Tasks

| ID | Task | Size | Depends on |
|---|---|---|---|
| E06-T01 | [SpacingTokens, MotionTokens & HapticTokens ThemeExtensions with copyWith/lerp + unit tests](E06-T01-token-extensions-space-motion-haptic.md) | M | E01 |
| E06-T02 | [MihrabColors ThemeExtension: heat-map ramp, track/decay, reader surfaces, the warning semantic — no success/danger token](E06-T02-mihrab-colors-extension.md) | M | E01 |
| E06-T03 | [The four ColorSchemes from one green seed (Light · Sepia · Dark · Night) + appearance selection](E06-T03-four-appearances-colorschemes.md) | M | E06-T02 |
| E06-T04 | [UI type pipeline: bundled Vazirmatn/Estedad, the six-step TextTheme, line-height + zero letter-spacing defaults](E06-T04-ui-type-pipeline-texttheme.md) | M | E01 |
| E06-T05 | [The pipeline wall: build-time guard that no UI-type path reaches a QPC/Quran asset (test-first)](E06-T05-ui-quran-pipeline-wall-guard.md) | S | E06-T04 |
| E06-T06 | [Compose the four ThemeData (roles + all extensions + TextTheme) and wire the appearance switcher into the app shell](E06-T06-themedata-composition-switcher.md) | M | E06-T01, E06-T03, E06-T04 |
| E06-T07 | [Reduce-motion helper + directional start→end pageTurn transition (test-first on disableAnimations)](E06-T07-reduce-motion-directional-transition.md) | S | E06-T01 |
| E06-T08 | [MihrabScaffold chrome + the RTL five-tab NavigationBar skeleton (bottom-action template, no real routes)](E06-T08-scaffold-rtl-navbar-skeleton.md) | M | E06-T06 |
| E06-T09 | [Skeleton presentation widgets E07 needs: MihrabCard/list row, FilledButton/SegmentedButton styling, appearance switcher control](E06-T09-skeleton-presentation-widgets.md) | M | E06-T06 |
| E06-T10 | [Contrast-audit fixture: WCAG 2.2 AA tables re-run per appearance, fail CI on regression (test-first)](E06-T10-contrast-audit-fixture.md) | M | E06-T03 |
| E06-T11 | [Four-appearance × three-locale skeleton goldens + the token-discipline (no-raw-value) check on E01's lanes](E06-T11-appearance-locale-goldens-token-discipline.md) | M | E06-T08, E06-T09, E06-T10 |

## Risks

- **Tokens defined, then bypassed.** A contributor reaches for a raw `Color(0xFF…)`, an off-scale `EdgeInsets.all(13)`, or a bare `Duration` "just this once," and the calm erodes invisibly. *Mitigation:* the token-discipline check (E06-T11) greps widget code for raw hex / off-scale dp / literal `Duration`/`Curve` / Arabic-run `letterSpacing` and fails CI; every bespoke family is owned by exactly one file per the README token map ([design-system 02 §9](../../docs/design-system/02-material-and-platform-foundations.md)).
- **The pipeline wall is asserted in prose but not in code.** The UI/muṣḥaf separation is the text-fidelity guarantee ([PRD R1](../../docs/PRD.md)); if it is only a convention, a future "render this ayah in a nice card" PR could route a Quran string through `TextTheme`. *Mitigation:* E06-T05 lands a test-first build-time guard proving no `type.*`/`TextTheme` path reaches a QPC/Quran asset, exercised by a deliberate violation that must fail, complementing E05's runtime refusal-to-render and the `quran`-isolation gate from E01.
- **Sepia/Night assumed to inherit Light's contrast.** A palette that passes AA in Light can fail when re-toned for warm paper or off-black ([design-system 03 §7](../../docs/design-system/03-color-and-themes.md)). *Mitigation:* the contrast-audit fixture (E06-T10) recomputes the WCAG tables independently for all four appearances and fails on any pair below floor; no appearance ships unaudited.
- **A "success green" or celebration creeps back as polish.** M3 ships a `Badge` and Expressive springs; a well-meaning "saved!" flash or juz-complete confetti is one import away and would gamify worship ([PRD R3/C6](../../docs/PRD.md)). *Mitigation:* there is no `color.success`, no `motion.celebrate.*`, and no success haptic token *to reach for*; "saved/verified" reads via icon + text in `color.accent.green`; the absence is the enforcement ([design-system 03 §6; 06 §2](../../docs/design-system/03-color-and-themes.md)).
- **Skeleton widgets grow into features.** "While I'm here" additions (a real page card, a grade band, a heat-map) belong to E10 and would land without E10's full anatomy/state/copy rigor. *Mitigation:* scope is the exact handful of presentation primitives E07's slice needs; anything richer is rejected in review and filed against E10; the widgets are dumb Views taking display data only.
- **RTL bolted on after an LTR-first build.** Authoring with physical `left`/`right` then "adding RTL" reproduces the mirrored-Latin layout these readers scan with friction ([design-system 05 §3](../../docs/design-system/05-layout-spacing-touch.md)). *Mitigation:* every inset is `EdgeInsetsDirectional` from the first commit, the tree is `Directionality.rtl` by construction, and the three-locale goldens (E06-T11) catch any physical-direction leak before merge.
- **The bundled UI font silently drops a Sorani glyph.** "Supports Arabic" does not imply "covers Sorani," and a tofu glyph is a release blocker ([design-system 04 §3](../../docs/design-system/04-typography.md)). *Mitigation:* E06 declares Vazirmatn + Estedad as bundled but does **not** lock the font version; the per-codepoint no-tofu coverage gate that pins it is owned by E09 and runs before the lock — E06's scope ends at declaring the faces and the `type.numeral` rule.

## References

- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/PRD.md — C1, C2, C4, C6, R1, R3, R5, §2 (design principles), §12 (IA / bottom nav order), §13 (localization & RTL), §18 (accessibility), §19.1 (bundled fonts, no CDN)
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/02-material-and-platform-foundations.md — §1, §2, §3, §4, §5, §6, §8, §9
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/03-color-and-themes.md — §1, §2, §3, §4, §5, §6, §7
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/04-typography.md — §1, §2, §3, §4, §5, §6, §7, §8
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/05-layout-spacing-touch.md — §1, §2, §3, §4, §5
- /Users/zakariafatahi/Projects/MobileApps/hifz/docs/design-system/06-motion-and-haptics.md — §1, §2, §3, §4, §5
- /Users/zakariafatahi/Projects/MobileApps/hifz/.claude/skills/eng-write-to-coding-standards/SKILL.md
- /Users/zakariafatahi/Projects/MobileApps/hifz/epics/E01-repo-scaffold-and-ci/EPIC.md — the workspace, app shell, bundled-font declarations, and golden/journeys CI lanes this epic builds inside

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
