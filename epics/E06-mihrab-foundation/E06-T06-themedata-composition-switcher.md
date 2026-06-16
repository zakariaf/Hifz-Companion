# E06-T06 — Compose the four ThemeData (roles + all extensions + TextTheme) and wire the appearance switcher into the app shell

| | |
|---|---|
| **Epic** | [E06 — Mihrab Design Foundation](EPIC.md) |
| **Size** | M (≈1–2 days) |
| **Depends on** | E06-T01, E06-T03, E06-T04 |
| **Skills** | eng-write-to-coding-standards |

## Goal

One file in the design-system subtree assembles each appearance's complete `ThemeData(useMaterial3: true)` from the parts the dependency tasks ship: the `ColorScheme` (E06-T03), the custom `TextTheme` (E06-T04), and the four bespoke `ThemeExtension`s — `MihrabColors` (E06-T02, via T03's per-appearance instances), `SpacingTokens`/`MotionTokens`/`HapticTokens` (E06-T01) — registered in `extensions: [...]`, so `light → sepia → dark → night` transitions interpolate through each extension's `lerp`. A `buildMihrabTheme(MihrabAppearance)` function returns the assembled theme for any appearance, and the appearance switcher is wired into E01's `MaterialApp.router` shell: an app-scope Riverpod store holds the `AppearanceSetting`, the shell reads it plus `MediaQuery.platformBrightnessOf(context)` through E06-T03's pure `resolveAppearance` resolver, and passes the resolved theme into `MaterialApp.router`'s `theme:`/`darkTheme:`/`themeMode:` — the whole tree `Directionality.rtl` by construction from the locale (E01), never a per-widget flag. End state: a contributor flips the appearance setting and the entire shell re-themes across all four appearances, in fa/ckb/ar, with no widget reaching a raw token.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/02-material-and-platform-foundations.md` §9 | The token-store mechanism this task realizes: M3 roles live in `ThemeData`'s `ColorScheme`/`TextTheme`; **every bespoke family lives in a `ThemeExtension` registered on `ThemeData`** with `copyWith`/`lerp` so "light → sepia → dark transitions interpolate smoothly"; read only through `Theme.of(context).extension<T>()`, never a global constant. This is the single composition point where all four extensions are attached. |
| `docs/design-system/02-material-and-platform-foundations.md` §1 | One root `MaterialApp` with `ThemeData(useMaterial3: true)` (the default-true value, left untouched) for the appearances; **RTL is structural** — `Directionality(TextDirection.rtl)` app-wide carries M3's automatic mirroring; no per-screen theme override except the reader's sepia/night surfaces (which are appearances here, not overrides). |
| `docs/design-system/03-color-and-themes.md` §3 | The four-appearance set + the **follow-system default for Light/Dark with Sepia/Night explicit** + **no sleep claim** for Night: the appearance table is the contract the switcher honours; `themeMode`/resolution maps system light→Light, system dark→Dark, and the two explicit appearances override. |
| `docs/design-system/03-color-and-themes.md` §4 | Dark/Night use the off-black `#121413`-family surface and re-toned accents; the `MihrabColors` reader-surface tokens transform the *backdrop*, never the glyph layer — the composed theme must pair each `ColorScheme` with its matching `MihrabColors` instance, not Light's. |
| `docs/design-system/02-material-and-platform-foundations.md` §5 | Component theming with restraint: the composed `ThemeData` sets `NavigationBarThemeData`/`FilledButtonThemeData`/`SegmentedButtonThemeData`/`ListTileThemeData`/`CardThemeData` defaults so E06-T08/T09's skeleton widgets resolve label styles from the `TextTheme` (zero Arabic letter-spacing) and colors from roles — **no `Badge`/streak/celebration component theme exists to configure.** |
| Skill `eng-write-to-coding-standards` (+ `template.dart`) | Effective Dart casing (`buildMihrabTheme`, file `mihrab_theme.dart`); full-word names; `///` on every public API; immutable inputs; **no user-facing string hardcoded in Dart** (the switcher's labels are E09 ARB keys); **RTL structural from locale, not per-widget**; the appearance store is a Riverpod `Notifier` with the single write path (read-only state, mutate through the notifier); REUSE `GPL-3.0-or-later` SPDX header on every file; no `print`/network/AI path. |
| Skill `eng-create-riverpod-store` (referenced, owned by E07) | The shape of the app-scope `AppearanceSettingNotifier` (a `Notifier<AppearanceSetting>` with `setAppearance(...)`, immutable state, no `DateTime.now()`); E06 ships an **in-memory** notifier (default `AppearanceSetting.followSystem`); **persisting the setting to Drift is out of scope** (E07/Settings owns persistence) — call this out so a reviewer does not expect a DB write here. |
| CLAIMS register | **None.** This task ships no user-facing number, copy, or factual claim — it assembles themes and wires a presentation control. The switcher's visible labels ("Light/Sepia/Dark/Night", "Follow system") are E09 ARB keys, not hardcoded here; Night carries **no** sleep/eye-health string (03 §3 guardrail), asserted by the no-forbidden-string check. |
| Sibling **E06-T01** | Supplies `SpacingTokens`/`MotionTokens`/`HapticTokens` (each with `copyWith`/`lerp`, `.standard()` const, **no celebrate/success tier**); this is the **only** task that registers them in `extensions: [...]` — T01 defined them but registered nothing. |
| Sibling **E06-T03** (dependency) | Supplies the four `ColorScheme`s, the `MihrabAppearance` enum + `colorSchemeFor`, the `AppearanceSetting` enum (incl. `followSystem`, default), and the **pure** `resolveAppearance(setting, platformBrightness)`; this task consumes them and is where `platformBrightness` is finally read (via `MediaQuery.platformBrightnessOf(context)`) and fed into the resolver. |
| Sibling **E06-T04** (dependency) | Supplies `buildMihrabTextTheme(TypeTokens)` and the note that component themes must source their label style from it; this task calls it once per theme and wires the component-theme defaults T04 flagged. |
| Sibling **E06-T02** | Supplies `MihrabColors` (heat-map ramp, track/decay, reader surfaces, the `warning` semantic — **no success/danger**); its **per-appearance instances** are paired with each `ColorScheme` at composition here (T03 pins the M3 roles, T02 owns the bespoke roles). |
| Siblings **E06-T05 / E06-T07 / E06-T08 / E06-T09 / E06-T11** | T05's pipeline-wall guard scope grows to cover this file (the composed `ThemeData` stays on the UI side of the wall — no `package:quran` import, no QPC glyph reaches the `TextTheme`); T07's `MotionTokens` must resolve via `Theme.of(context).extension<MotionTokens>()!` — this task's registration makes that resolve at runtime; T08/T09 consume the composed theme and the wired switcher; T11 runs the four-appearance × three-locale goldens of the shell and the token-discipline check over this file. |

## Implementation notes

This task is assembly and wiring; the correctness-critical *values* are pinned test-first in their owning tasks (color in T03, type in T04, tokens in T01). Here, the testable contracts are **structural**: every appearance's `ThemeData` carries all four extensions, the resolver feeds the right theme, and a theme `lerp` interpolates rather than snapping. Write the composition widget/unit assertions (Tests) alongside the code; no new token value is introduced.

1. **Files & package.** The design system lives inside the `features` umbrella package (E01: the design system lives inside `features`). Add:
   - `packages/features/lib/src/design_system/theme/mihrab_theme.dart` — `ThemeData buildMihrabTheme(MihrabAppearance appearance)` plus any small private per-appearance helpers; the single composition site that joins `ColorScheme` + `TextTheme` + the four extensions.
   - `packages/features/lib/src/design_system/theme/appearance_controller.dart` — the app-scope `AppearanceSettingNotifier extends Notifier<AppearanceSetting>` and its provider, holding the in-memory `AppearanceSetting` (default `AppearanceSetting.followSystem`) with a `setAppearance(AppearanceSetting)` single-write-path mutation.
   Export `buildMihrabTheme`, the notifier, and its provider through the `features` barrel under the `design_system` namespace; keep `lib/src/` internals private. REUSE SPDX header on every new file. `material`/`widgets`/`riverpod` imports only — no Drift, no `dart:io`, no `package:quran`, no network.

2. **`buildMihrabTheme(appearance)` — the composition.** For each `MihrabAppearance`:
   - Resolve `colorSchemeFor(appearance)` (T03) and `buildMihrabTextTheme(const TypeTokens.defaults())` (T04).
   - `ThemeData(useMaterial3: true, colorScheme: scheme, textTheme: textTheme, extensions: <ThemeExtension<dynamic>>[ mihrabColorsFor(appearance), SpacingTokens.standard(), MotionTokens.standard(), HapticTokens.standard() ])` — `useMaterial3` stays at its default-true value (02 §1); spacing/motion/haptic are appearance-invariant (one `.standard()` each), but **`MihrabColors` is per-appearance** (T02/T03: Dark/Night re-tone reader surfaces) so it is selected by `appearance`, never Light's instance reused.
   - Set the component-theme defaults T04/T08/T09 depend on: `navigationBarTheme`, `filledButtonTheme`, `segmentedButtonTheme`, `listTileTheme`, `cardTheme` resolve their label/text style from `textTheme` (zero Arabic `letterSpacing`) and their colors from roles — never an ad-hoc `TextStyle`. Keep these minimal here (defaults only); full component anatomy is E10. **Do not** configure a `Badge`/streak/celebration theme — none exists (02 §5).
   - The function is **total** (every `MihrabAppearance` returns a `ThemeData`, no throw) per coding-standards §5.2/§6.

3. **The appearance store (in-memory, app-scope).** `AppearanceSettingNotifier extends Notifier<AppearanceSetting>` with `build()` returning `AppearanceSetting.followSystem` and `void setAppearance(AppearanceSetting next) => state = next;` — immutable enum state, read-only to widgets, mutated only through `setAppearance` (the single write path; eng-create-riverpod-store). **No `DateTime.now()`, no Drift, no persistence** — persisting the chosen appearance is E07/Settings's job; document this in the `///` so the boundary is explicit. The provider is created at the `ProviderScope` composition root (E01's `app/lib/composition/providers.dart`), not in a view initializer.

4. **Wire into E01's `MaterialApp.router` shell.** In `app/lib/app.dart` (E01's `HifzApp`/`MaterialApp.router`), inside a `Consumer`/`ConsumerWidget`:
   - Read `final setting = ref.watch(appearanceSettingProvider);` and `final platformBrightness = MediaQuery.platformBrightnessOf(context);` — this is the **one** place `MediaQuery.platformBrightnessOf` is read; the resolver (T03) stays pure.
   - `final appearance = resolveAppearance(setting, platformBrightness);` then pass `theme: buildMihrabTheme(appearance)` into `MaterialApp.router`. Provide both `theme:` and `darkTheme:` and let `themeMode:` follow the resolution so the OS light/dark setting drives `followSystem` correctly: e.g. `theme: buildMihrabTheme(MihrabAppearance.light)`, `darkTheme: buildMihrabTheme(MihrabAppearance.dark)`, `themeMode: themeModeFor(setting)`, **but** when `setting` is an explicit Sepia/Night (light/dark-polarity overrides M3 cannot express with two slots), set both `theme:`/`darkTheme:` to `buildMihrabTheme(appearance)` and pin `themeMode` to that appearance's brightness so the explicit choice wins regardless of OS (03 §3). Keep the mapping in one small documented helper so the "two-slot M3 vs four appearances" reconciliation is auditable, not scattered.
   - Do **not** introduce or branch on a `Directionality` flag — E01 already sets RTL by construction from the locale; the themes are direction-agnostic (color/type/space/motion carry no direction).

5. **The switcher control surface (placement only; full control is E06-T09).** This task wires the *state path* (notifier → resolver → theme) and exposes the provider; the actual segmented/radio **appearance switcher widget** is E06-T09 and the Settings picker is E15/Settings. Here, expose the read/write hooks (`appearanceSettingProvider`, `setAppearance`) so T09's control and any preview can drive the live theme; do not build the final styled control in this task.

6. **Pitfalls to avoid:**
   - Reusing Light's `MihrabColors` for all four `ThemeData` (Dark/Night reader surfaces silently render with light tones) — pair each scheme with its own appearance instance.
   - Forgetting to register an extension in `extensions: [...]` — `Theme.of(context).extension<MotionTokens>()` then returns `null` and T07's `…!` throws at runtime; **all four** extensions must be present on every appearance's theme.
   - Setting `useMaterial3: false` or maintaining a parallel M2 theme (02 §1 anti-pattern).
   - Reading `MediaQuery.platformBrightnessOf`/`DateTime.now()` inside the resolver or the notifier — the resolver stays pure (T03), the brightness read happens once at the shell boundary.
   - Collapsing the four appearances into M3's two `theme:`/`darkTheme:` slots and losing Sepia/Night (they are explicit, not OS-derived — 03 §3); the reconciliation helper keeps the explicit choice winning.
   - Hardcoding a switcher label, a "Night = better sleep" string, or any user-facing copy in Dart — labels are E09 ARB keys; Night carries no sleep claim (03 §3).
   - Persisting the appearance to Drift here, or creating the notifier in a view `build()` (re-created on rebuild, state lost) — in-memory + app-scope only; persistence is E07/Settings.
   - Adding a `dynamic_color`/`DynamicColorBuilder` path (02 §8 — refused); the seed is the only palette source.
   - Any `package:quran`/QPC-glyph reference reaching the composed `TextTheme` (the wall — E06-T05 greps this file's scope).

## Acceptance criteria

- [ ] `mihrab_theme.dart` and `appearance_controller.dart` exist under `packages/features/lib/src/design_system/theme/`; both carry the REUSE `GPL-3.0-or-later` SPDX header; `buildMihrabTheme`, the notifier, and its provider are exported through the `features` barrel; `lib/src/` internals stay private; imports are `material`/`widgets`/`riverpod` only (no Drift, no `dart:io`, no `package:quran`, no `dynamic_color`, no network) — verifiable by grep.
- [ ] `buildMihrabTheme(appearance)` is total (returns a `ThemeData` for every `MihrabAppearance`, no throw), sets `useMaterial3: true` (default), and supplies `colorSchemeFor(appearance)` + `buildMihrabTextTheme(...)`.
- [ ] Every appearance's `ThemeData.extensions` contains exactly one each of `MihrabColors`, `SpacingTokens`, `MotionTokens`, `HapticTokens`; `Theme.of(context).extension<T>()` returns non-null for all four `T` on all four appearances.
- [ ] The `MihrabColors` on each theme is the **per-appearance** instance (Dark/Night ≠ Light's) — the reader-surface roles differ across appearances; spacing/motion/haptic are the shared `.standard()` instances.
- [ ] Component-theme defaults (`navigationBarTheme`, `filledButtonTheme`, `segmentedButtonTheme`, `listTileTheme`, `cardTheme`) source their label/text style from the composed `TextTheme` (zero Arabic `letterSpacing`) and colors from roles; no ad-hoc `TextStyle(letterSpacing: …)`; no `Badge`/streak/celebration theme is configured.
- [ ] `AppearanceSettingNotifier extends Notifier<AppearanceSetting>`, `build()` returns `AppearanceSetting.followSystem`, and `setAppearance` is the only mutation (state is read-only to widgets); no `DateTime.now()`, no Drift/persistence in this file.
- [ ] `app/lib/app.dart` reads `appearanceSettingProvider` and `MediaQuery.platformBrightnessOf(context)` (the one read site), resolves via `resolveAppearance`, and passes the resolved theme into `MaterialApp.router`; the reconciliation helper keeps an explicit Sepia/Night choice winning over the OS setting and follow-system maps system light→Light / dark→Dark.
- [ ] No `Directionality` flag is introduced (RTL stays structural from the locale — E01); the four themes render identically under `Directionality.rtl` for fa/ckb/ar.
- [ ] No user-facing string is hardcoded; no sleep/eye-health string or comment appears near Night; `dart format --set-exit-if-changed` and `dart analyze --fatal-infos` are clean; `///` on every public API.

## Tests

All tests are `flutter_test` (these are `ThemeData`/`ColorScheme`/widget concerns, not pure-`engine` arithmetic), under `packages/features/test/design_system/theme/` and (for the shell wiring) `app/test/`, each carrying the REUSE SPDX header and installing the shared throwing-`HttpOverrides` offline bootstrap (eng-write-dart-test) so a stray network/font fetch is a named failure.

`mihrab_theme_test.dart` — composition contract:
- **All four extensions present, per appearance**: for each `MihrabAppearance`, `buildMihrabTheme(a).extension<MihrabColors>()`, `<SpacingTokens>()`, `<MotionTokens>()`, `<HapticTokens>()` are all non-null (the registration-completeness proof — the exact failure that would make T07's `…!` throw at runtime).
- **Per-appearance `MihrabColors` paired correctly**: `buildMihrabTheme(MihrabAppearance.dark).extension<MihrabColors>()` is the Dark instance and differs from the Light instance on at least one reader-surface role; spacing/motion/haptic are the shared `.standard()` values across appearances.
- **Roles & type flow through**: `theme.colorScheme` equals `colorSchemeFor(appearance)`; `theme.textTheme.bodyLarge!.letterSpacing == 0` and its `fontFamily == 'Vazirmatn'` (the zero-Arabic-spacing / UI-face invariant survives composition); `theme.useMaterial3 == true`.
- **Theme `lerp` interpolates, not snaps**: `ThemeData.lerp(buildMihrabTheme(light), buildMihrabTheme(dark), 0.5)` yields a theme whose `SpacingTokens`/`MotionTokens` are the per-field midpoints (`closeTo(_, 1e-6)`) — proving the extensions' `lerp` is engaged by the framework's transition machinery (02 §9).
- **No forbidden surface**: a guard asserting no component theme configures a `Badge`/streak/celebration style and no `dynamic_color` path is reachable; totality — `buildMihrabTheme` returns non-null for every `MihrabAppearance.values` member.

`appearance_controller_test.dart` — store contract (`ProviderContainer`, no widget pump):
- **Default is follow-system**: a fresh container reads `appearanceSettingProvider == AppearanceSetting.followSystem`.
- **Single-write-path mutation**: `setAppearance(AppearanceSetting.sepia)` updates the state to `sepia`; state is otherwise read-only; no `DateTime.now()` is reachable (deterministic).
- **No persistence**: the notifier holds in-memory state only — a second fresh container starts again at `followSystem` (proving nothing was written to disk; persistence is E07/Settings).

`app/test/appearance_switch_test.dart` — shell wiring (`pumpWidget` over the real `HifzApp` with overridden providers and `MediaQuery`):
- **Switcher re-themes the shell**: pump with `appearanceSettingProvider` overridable; setting `light` → the in-tree `Theme.of(context).colorScheme` equals Light's; flipping to `night` re-themes to Night's `ColorScheme` — the full state path (notifier → resolver → theme) works end-to-end.
- **Follow-system honours platform brightness**: with `setting == followSystem`, pumping under `MediaQuery(platformBrightness: Brightness.dark)` resolves to Dark; `Brightness.light` resolves to Light.
- **Explicit overrides win over the OS**: `setting == sepia` under `MediaQuery(platformBrightness: Brightness.dark)` still themes to Sepia (explicit beats follow-system — 03 §3).
- **RTL by construction**: the pumped shell reports `Directionality.of(context) == TextDirection.rtl` for an fa locale; the resolved theme is identical to its LTR composition (color/type/space carry no direction).

Offline guard: every suite runs under the throwing-`HttpOverrides`; none reaches the network (no font fetch, no `dynamic_color`). Goldens are **not** in this task — the four-appearance × three-locale skeleton goldens are E06-T11; this suite proves the *composition and wiring*, T11 proves the *pixels*.

## Definition of Done

- [ ] All acceptance criteria met; all suites green locally and on the E01 `flutter test` lane.
- [ ] **Offline / no-network by construction:** no network path, no `google_fonts` runtime fetch, no `dynamic_color`; the composed themes are pure in-binary data; the throwing `HttpOverrides` is installed in every suite and nothing reaches the network; the E01 dependency-allow-list stays green with this code included ([PRD C1](../../docs/PRD.md); 02 §8).
- [ ] **No AI / no microphone:** no ML/ASR/audio/recognition path; the theme composition, the appearance store, and the wired switcher are presentation-only ([PRD C2, R5](../../docs/PRD.md)).
- [ ] **Quran text fidelity — the pipeline wall holds:** this file composes the **UI** `TextTheme` only; no `package:quran` import, no QPC glyph, no muṣḥaf string is routed through the composed `ThemeData`; reader-surface tokens transform the backdrop, never the glyph layer; E06-T05's guard scope covers this file and a deliberate violation fails it ([PRD R1](../../docs/PRD.md); 04 §1).
- [ ] **No gamification of worship — by structure:** the composed themes register no `color.success`, no celebrate motion tier, no success/reward haptic, and no `Badge`/streak/celebration component theme — there is nothing of the kind to configure (the absence is the enforcement) ([PRD R3/C6](../../docs/PRD.md); 02 §5; 06 §2).
- [ ] **RTL + fa/ckb/ar:** RTL stays structural from the locale (E01) — no `Directionality` flag is added; the four appearances render identically under `Directionality.rtl`; the wired shell reports `TextDirection.rtl` for fa/ckb/ar; no user-facing string is introduced (switcher labels are E09 ARB keys).
- [ ] **Accessibility contracts honored:** every appearance's `ThemeData` carries the audited `ColorScheme` (T03) and the `SpacingTokens` whose `touch.min`/gap values back ≥48×48dp targets; `contrastLevel` flows from the schemes; the independent contrast re-audit per appearance is E06-T10 and stays green.
- [ ] **Sect-neutral adab + calm enforced:** one desaturated green seed across all four themes; Dark/Night never pure black; **Night carries no sleep claim** (no sleep/eye-health string or comment near it); no celebratory or coercive surface is themed — reverent ground that serves the page ([design-system 03 §3](../../docs/design-system/03-color-and-themes.md)).
- [ ] **Token discipline holds:** M3 roles live in `ThemeData`'s `ColorScheme`/`TextTheme`, every bespoke family in a registered `ThemeExtension`; no widget hardcodes a hex/dp/`Duration`/Arabic `letterSpacing`; the composition reads tokens from their owning files and never re-declares a value (E06-T11 greps this).
- [ ] **Deterministic tests:** the appearance store uses injected/overridable state with no wall clock; the shell wiring pumps explicit `MediaQuery` brightness/locale; theme `lerp` is asserted with `closeTo(_, 1e-6)`; every suite is reproducible on any contributor machine and in CI.
- [ ] **Coding standards:** REUSE SPDX header; full-word/unit-bearing names; `///` on all public APIs; the appearance notifier mutates only through its single write path; `dart format` + `dart analyze --fatal-infos` clean; no `print`, no `!`/`late`/`dynamic` shortcuts on theme/store values.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
