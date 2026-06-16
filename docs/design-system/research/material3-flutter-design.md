# Material 3 + Flutter Theming — Research Note

**Topic:** Material 3 (Material You) as the theming foundation for a Flutter app — M3 color roles and tonal surfaces, the type scale, components, elevation/surface-tint, the motion system (easing + duration tokens), adaptive/iOS considerations in Flutter, and design-token practice (`ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`). Read as the evidence dossier behind `02-material-and-platform-foundations.md`, `03-color-and-themes.md`, `04-typography.md`, `06-motion-and-haptics.md`, and `07-components.md`. Companion notes cover Arabic/Persian/Kurdish type (`arabic-persian-kurdish-typography.md`), calm/non-gamified design (`calm-non-gamified-design.md`), and RTL/accessibility (`accessibility-rtl-inclusive.md`).

**Compiled:** 2026-06-16 · Verified against `api.flutter.dev`, `docs.flutter.dev`, `m3.material.io`, the `flutter/flutter` source/issue tracker, `material-components/material-components-android`, and `pub.dev`. Where M3 spec pages render client-side and could not be fetched directly, the same token values were cross-checked against Flutter's API docs and migration pages, which mirror the spec.

The Hifz Companion is Flutter, offline, RTL (fa/ckb/ar), free, and reverence-first. Material 3 is the natural substrate — it is the default design language in current Flutter, it ships a tokenised, accessibility-aware color/type/elevation system, and it mirrors correctly for RTL. The job of this note is to extract the *parts of M3 we adopt verbatim* (the color-role contract, the type scale, the elevation tones, the motion tokens), the *parts we deliberately restrain* (M3's playful expressive motion, dynamic wallpaper color, and component flourishes that would gamify or decorate the muṣḥaf), and the *Flutter-specific machinery* (`ColorScheme.fromSeed`, `ThemeExtension`, `.adaptive` constructors) that turns the spec into a single auditable theme.

---

## What the evidence says

### 1. The M3 color system is role-based, not value-based — and Flutter implements it as `ColorScheme`

- M3 builds every theme from **five key colors** (primary, secondary, tertiary, neutral, neutral-variant); each key color expands into a **tonal palette of 13 tones**, and specific tones are assigned to named **color roles** used by components ([Material 3: Color roles](https://m3.material.io/styles/color/roles); [Material 3: Color overview](https://m3.material.io/styles/color/overview)).
- The cardinal rule is **"always apply color roles rather than static values or tonal-palette values, as these colors will break with light/dark themes, contrast control, and other features"** ([Material 3: Color roles](https://m3.material.io/styles/color/roles)). Roles, not hex, are the unit of design.
- Roles come in **on-color pairs**: every container/accent role has a matching `on…` role guaranteed to be legible on it — `primary`/`onPrimary`, `primaryContainer`/`onPrimaryContainer`, `surface`/`onSurface`, `error`/`onError`, etc. Flutter's `ColorScheme` exposes exactly these: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary`, `tertiary`, `error`, `onError`, `errorContainer`, plus utility roles `outline`, `outlineVariant`, `inverseSurface`, `onInverseSurface`, `inversePrimary`, `surfaceTint`, `scrim`, and `shadow` ([Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).
- Flutter generates the whole scheme from one seed: **`ColorScheme.fromSeed(seedColor, brightness, dynamicSchemeVariant, contrastLevel)`** "constructs a set of tonal palettes based on the Material 3 color system," producing colors "designed to work well together and meet contrast requirements for accessibility." The default variant is `tonalSpot`, which "provides pastel palettes and won't be too colorful" even from a high-chroma seed; `contrastLevel` ranges −1.0…1.0 for accessibility ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)).
- The same seed used with `Brightness.light` and `Brightness.dark` yields **harmonised light/dark schemes** — only the brightness changes, so a calm sepia/green identity stays coherent across modes ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).

### 2. Tone-based surface containers replaced the "surface tint" overlay — a quieter, more legible elevation model

- M3 originally signalled elevation by painting a **`surfaceTint`** overlay (a primary-tinted veil whose opacity grew with elevation) on top of `surface`. Flutter implemented this via `ElevationOverlay.applySurfaceTint` and `Material.surfaceTintColor` ([Flutter: ElevationOverlay.applySurfaceTint](https://api.flutter.dev/flutter/material/ElevationOverlay/applySurfaceTint.html)).
- M3 then introduced a **tone-based surface system**: a ladder of pre-computed neutral roles — `surfaceDim`, `surfaceBright`, and the five containers `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest` — so a raised component picks a *flatter, lighter container tone* instead of receiving a dynamic primary tint ([Material 3: Tone-based surfaces](https://m3.material.io/blog/tone-based-surface-color-m3); [Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).
- The intent is explicit: M3's tone-based surfaces "provide more flexibility, with the intention to eventually remove surface tint color from the framework" ([Material 3: Tone-based surfaces](https://m3.material.io/blog/tone-based-surface-color-m3), via Flutter elevation docs). In current Flutter the legacy `surfaceVariant` is **deprecated in favour of `surfaceContainerHighest`**, and `background`/`onBackground` are deprecated in favour of `surface`/`onSurface` ([Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).

### 3. M3 defines six elevation levels (0–5) mapped to dp and to surface tones

- The elevation scale is six discrete levels with fixed dp values: **Level 0 = 0dp, Level 1 = 1dp, Level 2 = 3dp, Level 3 = 6dp, Level 4 = 8dp, Level 5 = 12dp** ([Material 3: Elevation tokens](https://m3.material.io/styles/elevation/tokens)).
- Components sit at conventional levels: **Level 0** for flat filled/outlined surfaces; **Level 1** for elevated cards and bottom sheets; **Level 2** for the navigation bar and menus; **Level 3** for FAB and dialogs; **Levels 4–5** mainly for hover states, less relevant on mobile ([Material 3: Elevation tokens](https://m3.material.io/styles/elevation/tokens)).
- M3 offers two elevation channels — **shadow elevation** (a cast shadow) and **tonal elevation** (a lighter/tinted surface). Tonal elevation derives from the primary color, so a green primary tints raised surfaces green; tone-based surface containers express the same hierarchy with cleaner neutral steps ([Material 3: Elevation tokens](https://m3.material.io/styles/elevation/tokens); [Flutter: Material.surfaceTintColor](https://api.flutter.dev/flutter/material/Material/surfaceTintColor.html)).

### 4. The M3 type scale is five roles × three sizes — Flutter ships it as `Typography.material2021`

- M3 typography is organised into **five roles — Display, Headline, Title, Body, Label — each in Large/Medium/Small**, i.e. 15 baseline styles (plus a parallel "emphasized" set), all expressed as design tokens ([Material 3: Typography](https://m3.material.io/styles/typography)).
- Reference sizes (Roboto, Regular/Medium only): **Display** 57/45/36; **Title** 22/16/14; **Body** 16/14/12; **Label Large** 14 ([Material 3: Typography](https://m3.material.io/styles/typography), via M3 type-scale references). Each role carries its own size, line-height, weight, and letter-spacing token — type is a token set, not ad-hoc font sizes.
- Flutter's M3 default is **`Typography.material2021`**, which "creates a typography instance using Material Design 3 2021 defaults" via the `englishLike2021` / `dense2021` / `tall2021` `TextTheme`s, and (unlike 2018/2014) applies `ColorScheme` `onSurface`/`surface` colors **uniformly**, "with no color variation based on style as in previous versions" ([Flutter: Typography.material2021](https://api.flutter.dev/flutter/material/Typography/Typography.material2021.html)). The named slots map straight onto M3 roles: `displayLarge…labelSmall`.
- Practical caveat for us: the *reference* scale is Latin/Roboto. Arabic-script type needs taller line-heights and a script-appropriate UI face (Vazirmatn/Estedad/Noto Naskh), so we keep the M3 **role structure** but override the **values** per script — see `arabic-persian-kurdish-typography.md` and §1 of the implications below.

### 5. Material 3 replaced or added a family of components; M2 ones are deprecated paths

- Migrating to M3 swaps component families: **`NavigationBar`** (pill-shaped indicator) replaces `BottomNavigationBar`; **`NavigationDrawer`** replaces `Drawer`; **`SegmentedButton<T>`** (selection by `Set`) replaces `ToggleButtons` ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- M3 adds **`FilledButton` / `FilledButton.tonal`** (elevation-less emphasis), **`SearchBar`/`SearchAnchor`**, **`DropdownMenu`**, **`MenuBar`/`MenuAnchor`**, **`Badge`**, `Dialog.fullscreen`, and `SliverAppBar.medium()/.large()` ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- Each M3 component reads its colors from `ColorScheme` roles and its surface from tone-based containers — e.g. dialogs/bottom sheets use `surfaceContainerHigh`/`Highest` with `onSurface`; cards/menus use `surface` with elevation ([Flutter: Card.surfaceTintColor](https://api.flutter.dev/flutter/material/Card/surfaceTintColor.html); [Flutter: Dialog.surfaceTintColor](https://api.flutter.dev/flutter/material/Dialog/surfaceTintColor.html)).
- **`useMaterial3` is `true` by default** since Flutter 3.16 (Nov 2023); setting it `false` is a temporary workaround on a deprecation path, so M3 is the baseline, not an opt-in ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).

### 6. M3 motion is a token system — easing curves + a duration ladder — exposed in Flutter as `Easing` and `Durations`

- M3 defines named **easing** tokens: `standard` (and `standardAccelerate`/`standardDecelerate`) for routine UI, and **`emphasized`** (with accelerate/decelerate variants) for hero/expanding transitions; emphasized "draws extra attention at the end of an animation and is usually paired with longer durations" ([Material 3: Easing & duration](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)).
- Flutter exposes the duration ladder as **`Durations`**: short1–4 = **50/100/150/200ms**, medium1–4 = **250/300/350/400ms**, long1–4 = **450/500/550/600ms**, extralong1–4 = **700/800/900/1000ms** ([Flutter: Durations class](https://api.flutter.dev/flutter/material/Durations-class.html)). Short = small selection/state changes; medium = component transitions; long/extra-long = full-screen and ambient motion.
- The emphasized curve is a **three-point cubic** (it overshoots-then-settles); Flutter's equivalent `Curves.easeInOutCubicEmphasized` is `ThreePointCubic(Offset(0.05,0), Offset(0.133,0.06), Offset(0.166,0.4), Offset(0.208,0.82), Offset(0.25,1))` ([Flutter: ThreePointCubic](https://api.flutter.dev/flutter/animation/ThreePointCubic-class.html); [Flutter: Curves.easeInOutCubicEmphasized](https://api.flutter.dev/flutter/animation/Curves/easeInOutCubicEmphasized-constant.html)). The legacy M2 `standardEasing` was `Curves.fastOutSlowIn` ([Flutter: animation curves source](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart)).
- Newer **Material 3 Expressive** motion swaps fixed easing/duration for a **spring** model (stiffness + damping ratio), "replacing the duration-based animation system with a new engine grounded in physics" ([Material 3: Motion overview](https://m3.material.io/styles/motion/overview/how-it-works); Compose M3 Expressive write-up). This is *more* expressive/bouncy — exactly the register a reverent app should mostly avoid (see implication 6 below).

### 7. Dynamic color is a real M3 feature but optional — Flutter gates it behind a plugin and a fallback

- Android 12+ generates a **dynamic color** scheme from the user's wallpaper; Flutter surfaces it via the **`dynamic_color`** package's `DynamicColorBuilder`, which yields a light and dark `ColorScheme` from the OS `CorePalette`, with `ColorScheme.fromSeed` as the fallback ([dynamic_color package](https://pub.dev/packages/dynamic_color)).
- The package is explicitly conditional: on API ≥ 31 it uses the system palette; **on older Android and on iOS it falls back to your seeded scheme** ([dynamic_color package](https://pub.dev/packages/dynamic_color)). So wallpaper-driven theming can never be assumed present — a fixed brand scheme is always required as the floor.

### 8. Flutter's adaptive layer lets one Material codebase feel native on iOS — without forking the UI

- Flutter ships **`.adaptive` constructors** that render the Cupertino control on iOS/macOS and the Material control elsewhere: `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive`, and `AlertDialog.adaptive` ([Flutter: Adaptive & responsive design](https://docs.flutter.dev/ui/adaptive-responsive)). Notably, `Switch.adaptive` "will get the actual iOS Switch design on iOS… while still using your ColorScheme colors, not iOS default system green."
- For finer control, platform is read from **`Theme.of(context).platform`** or the global **`defaultTargetPlatform`** ([Flutter: Adaptive & responsive design](https://docs.flutter.dev/ui/adaptive-responsive)).
- Flutter's tracking issue **"Material 3 iOS Adaptations"** governs which Material widgets adopt iOS conventions automatically (icons, page transitions, edge-swipe back, typography) versus opt-in (`.adaptive` switches, dialogs); the stated philosophy is to avoid forked layouts while still letting apps "be indistinguishable from native iOS apps," favouring "small improvements that are automatic or easy-to-use" ([flutter/flutter #94821](https://github.com/flutter/flutter/issues/94821)).
- Adaptive ≠ responsive: Flutter frames **responsive** as fitting the UI into available space (via `MediaQuery`, `LayoutBuilder`, `SafeArea`) and **adaptive** as making it *usable* on each platform/input ([Flutter: Adaptive & responsive design](https://docs.flutter.dev/ui/adaptive-responsive)).

### 9. M3 mirrors correctly for RTL, and the contract is "use logical, not physical, directions"

- M3's bidirectionality guidance: when a layout flips LTR↔RTL ("mirroring"), elements and reading flow move to the opposite side; the `NavigationBar`, overflow menu, and directional icons "switch sides, with the same specifications for spacing and height as LTR" ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).
- Flutter realises this through **`Directionality`** (set `TextDirection.rtl`), automatic mirroring for RTL locales, directional insets/alignment via **`EdgeInsetsDirectional`** and **`AlignmentDirectional`** (start/end, never left/right), and automatic icon mirroring on directional `Icons` ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl); RTL developer guides). M3 components are built on these primitives, so they mirror for free when the app is RTL.

### 10. Touch-target and contrast minimums are part of the M3 + accessibility contract

- M3 specifies a **minimum touch target of 48 × 48dp** (≈9mm physical) even when the visible icon is 24dp, with **≥8dp spacing** between targets for comfortable density ([Material 3: Accessibility/structure](https://m3.material.io/foundations/designing/structure); [material-components-android #1279](https://github.com/material-components/material-components-android/issues/1279)).
- This aligns with WCAG: targets should be **≥24dp** to meet SC 2.5.8 (AA) and **≥44px** for SC 2.5.5 (AAA); M3's 48dp default clears both ([material-components-android #1279](https://github.com/material-components/material-components-android/issues/1279)).
- `ColorScheme.fromSeed`'s on-color pairs and `contrastLevel` parameter are designed to "meet contrast requirements for accessibility," but generated pairs must still be **verified** against WCAG ratios for our chosen seed, not assumed ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)).

### 11. Design-token practice in Flutter: `ThemeData` + `ColorScheme`/`TextTheme` for M3 roles, `ThemeExtension` for everything else

- Flutter's M3 theme is itself a token store: `ThemeData(colorScheme:, textTheme:, …)` holds the role/scale tokens, and components resolve them at build time ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- For tokens M3 does not name (e.g. our heat-map color ramp, track-chip colors, decay indicators, sepia reader surfaces, spacing scale), the idiomatic mechanism is **`ThemeExtension<T>`** — "an interface that defines custom additions to a `ThemeData`," requiring `copyWith` and `lerp`, accessed via `Theme.of(context).extension<T>()` ([Flutter: ThemeExtension class](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)).
- `ThemeExtension` keeps custom tokens "in the theme tree, not scattered as constants," gives one source of truth across light/dark/platform variants, and — because of `lerp` — **interpolates smoothly during theme transitions** ([Flutter: ThemeExtension class](https://api.flutter.dev/flutter/material/ThemeExtension-class.html); community ThemeExtension token guides). Material's `ColorScheme`/`TextTheme` are "ok only if your design follows the Material spec exactly"; custom domains belong in extensions you fully control.
- Fonts must be **bundled assets**, not runtime-fetched: bundled fonts "are always available, load instantly, and work offline," and production guidance is to ship the font files and set `GoogleFonts.config.allowRuntimeFetching = false` so a missing declaration fails at compile time rather than silently falling back ([google_fonts package](https://pub.dev/packages/google_fonts)).

---

## Implications for Hifz Companion

1. **Adopt M3 roles as the only color vocabulary; ban raw hex in widgets.** Drive the whole theme from `ColorScheme.fromSeed(seedColor: <calm Quran-green/sepia seed>, brightness: …)` for both light and dark, so the identity stays harmonised across modes. Every surface and text color in code references a role (`colorScheme.surface`, `colorScheme.onSurfaceVariant`, …) — this owns `color.*` in the token map (`03-color-and-themes.md`).

2. **Use tone-based surface containers, not surface-tint, for the muṣḥaf and reader.** Prefer `surfaceContainerLow/Container/High` neutral steps over primary-tinted elevation so the sacred page is never veiled in brand color. Sepia and night reader themes are *separate surface roles / extension tokens transforming the rendered glyph layer* (PRD §11.2), never a re-tint of the text.

3. **Keep elevation low and shadowless.** Reverence-first means flat: cards and list items at Level 0–1, the `NavigationBar` at Level 2, only modal dialogs/sheets raised (Level 3). No decorative shadows on Quran content. This sets `elevation` tokens in `07-components.md`.

4. **Inherit the M3 type-scale *structure*, override its *values* for Arabic script.** Map our text styles onto `displayLarge…labelSmall` so components stay consistent, but supply a script-appropriate `TextTheme` (taller line-heights, Vazirmatn/Estedad/Noto Naskh for fa/ar, a verified Sorani face for ckb) bundled as assets with runtime fetching disabled. Quran text itself is *never* themed by this scale — it is immutable KFGQPC glyph rendering (PRD §11). Owns `type.*` (`04-typography.md`).

5. **Use M3 components, restrained.** `NavigationBar` for the five-tab bottom nav (RTL-mirrored), `FilledButton`/`FilledButton.tonal` for the recite/grade actions, `SegmentedButton` for grade selection where apt, `Card`/`ListTile` for the Today list. Avoid `Badge` counters, streak chips, and any component used as a gamification surface (PRD R3/C6).

6. **Motion: standard easing, short/medium durations only — never Expressive springs.** Use `Easing.standard` / `Curves.fastOutSlowIn` with `Durations.short3`–`medium2` (150–300ms) for page-turns, reveals, and grade transitions; reserve `emphasized` + a `long` duration for at most the page-to-recite hero. Disallow bouncy spring/overshoot motion and confetti — calm, low-arousal motion only (`06-motion-and-haptics.md`). Respect the OS "reduce motion" flag.

7. **Do NOT adopt dynamic (wallpaper) color.** A wallpaper-derived palette would make the muṣḥaf's surroundings unpredictable and could clash with the reverent identity; it is also absent on iOS and pre-12 Android anyway. Ship a **fixed, designed seed** and skip `dynamic_color` — the brand scheme is the floor and the ceiling.

8. **Use `.adaptive` controls for native iOS feel without forking the UI.** `Switch.adaptive` for settings toggles, `CircularProgressIndicator.adaptive` for the one-time asset download, `AlertDialog.adaptive` for confirmations — all keep our `ColorScheme` colors while matching platform convention. Read `Theme.of(context).platform` only where an adaptive constructor doesn't exist.

9. **Build RTL on logical directions everywhere.** `Directionality(TextDirection.rtl)` app-wide; `EdgeInsetsDirectional`/`AlignmentDirectional` and start/end semantics in every layout; rely on M3's automatic mirroring for `NavigationBar`, directional icons, and progress. RTL golden screenshots per locale gate releases (PRD §13.2, §20). Detailed in `12-localization-and-rtl.md`.

10. **Make tokens auditable via `ThemeData` + `ThemeExtension`.** M3 roles/scale live in `ThemeData`; bespoke domains — the retention heat-map ramp, track chips (sabaq/sabqi/manzil), decay indicators, reader surfaces, the `space.*` scale — live in typed, immutable `ThemeExtension`s accessed through `Theme.of(context).extension<T>()`, with `lerp` for smooth light/dark/sepia transitions. One source of truth, no scattered constants — the README token-discipline table assigns ownership.

11. **Enforce accessibility minimums as hard gates.** 48×48dp touch targets (the daily recite/grade taps are large), ≥8dp spacing, and WCAG-verified contrast on every on-color pair and on the heat-map (which must never rely on color alone — pair with labels/patterns, PRD §18). Verify generated `fromSeed` pairs against measured ratios; don't trust the generator blindly. Detailed in `09-accessibility-and-inclusivity.md`.

---

## Citations

1. Material Design 3 — *Color roles*. https://m3.material.io/styles/color/roles
2. Material Design 3 — *Color overview / Create personal color schemes*. https://m3.material.io/styles/color/overview
3. Flutter API — *ColorScheme class* (color roles; deprecated `background`/`onBackground`/`surfaceVariant`; surface containers). https://api.flutter.dev/flutter/material/ColorScheme-class.html
4. Flutter API — *ColorScheme.fromSeed constructor* (tonal palettes; `dynamicSchemeVariant` tonalSpot; `contrastLevel`; accessibility). https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
5. Flutter — *Migrate to Material 3* (useMaterial3 default since 3.16; component replacements; surfaceTint; typography 2021). https://docs.flutter.dev/release/breaking-changes/material-3-migration
6. Material Design 3 — *Introducing Tone-based Surfaces in Material 3* (surface containers; intent to remove surface tint). https://m3.material.io/blog/tone-based-surface-color-m3
7. Flutter API — *ElevationOverlay.applySurfaceTint*. https://api.flutter.dev/flutter/material/ElevationOverlay/applySurfaceTint.html
8. Flutter API — *Material.surfaceTintColor*. https://api.flutter.dev/flutter/material/Material/surfaceTintColor.html
9. Material Design 3 — *Elevation tokens* (levels 0–5 → 0/1/3/6/8/12dp; shadow vs tonal). https://m3.material.io/styles/elevation/tokens
10. Material Design 3 — *Elevation overview*. https://m3.material.io/styles/elevation/overview
11. Material Design 3 — *Typography* (Display/Headline/Title/Body/Label; type-scale tokens; Roboto). https://m3.material.io/styles/typography
12. Flutter API — *Typography.material2021* (M3 2021 defaults; englishLike/dense/tall 2021; uniform color). https://api.flutter.dev/flutter/material/Typography/Typography.material2021.html
13. Flutter API — *Card.surfaceTintColor*. https://api.flutter.dev/flutter/material/Card/surfaceTintColor.html
14. Flutter API — *Dialog.surfaceTintColor*. https://api.flutter.dev/flutter/material/Dialog/surfaceTintColor.html
15. Material Design 3 — *Easing and duration: tokens & specs* (standard/emphasized easing; durations). https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
16. Flutter API — *Durations class* (short/medium/long/extra-long ms values). https://api.flutter.dev/flutter/material/Durations-class.html
17. Flutter API — *ThreePointCubic class* (emphasized three-point cubic). https://api.flutter.dev/flutter/animation/ThreePointCubic-class.html
18. Flutter API — *Curves.easeInOutCubicEmphasized constant* (control-point values). https://api.flutter.dev/flutter/animation/Curves/easeInOutCubicEmphasized-constant.html
19. Flutter source — *animation/curves.dart* (legacy standard/accelerate/decelerate easing; M3 `Easing` replacements). https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart
20. Material Design 3 — *Motion overview / how it works* (springs; Expressive motion engine). https://m3.material.io/styles/motion/overview/how-it-works
21. pub.dev — *dynamic_color package* (DynamicColorBuilder; CorePalette; API≥31 with fromSeed fallback). https://pub.dev/packages/dynamic_color
22. Flutter — *Adaptive & responsive design* (`.adaptive` constructors; `Theme.of(context).platform`/`defaultTargetPlatform`; responsive vs adaptive). https://docs.flutter.dev/ui/adaptive-responsive
23. flutter/flutter — *Issue #94821: Material 3 iOS Adaptations* (which widgets adapt; automatic vs opt-in philosophy). https://github.com/flutter/flutter/issues/94821
24. Material Design 3 — *Bidirectionality & RTL* (mirroring; NavigationBar/icons switch sides). https://m3.material.io/foundations/layout/bidirectionality-rtl
25. Material Design 3 — *Accessibility / designing for structure* (48×48dp targets, spacing). https://m3.material.io/foundations/designing/structure
26. material-components/material-components-android — *Issue #1279: why 48×48dp touch target* (48dp ≈9mm; WCAG 2.5.5/2.5.8 ≥44/24). https://github.com/material-components/material-components-android/issues/1279
27. Flutter API — *ThemeExtension class* (copyWith/lerp; `Theme.of(context).extension<T>()`; custom theme additions). https://api.flutter.dev/flutter/material/ThemeExtension-class.html
28. pub.dev — *google_fonts package* (bundle fonts for offline; `allowRuntimeFetching = false`). https://pub.dev/packages/google_fonts
