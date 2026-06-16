# 02 — Material 3 & Platform Foundations

This file fixes the substrate every other Mihrab file builds on: **how Material 3 (M3) is adopted in Flutter, how it is adapted to feel native on iOS without forking the UI, and how design tokens are stored so a palette, type-ramp, spacing, or motion change is a one-file edit.** Material 3 is the natural foundation here — it is the default design language in current Flutter, it ships a tokenised and accessibility-aware color/type/elevation/motion system, and it mirrors correctly for RTL — but it arrives with playful, expressive, dynamically-coloured defaults that a reverence-first muṣḥaf app must deliberately *restrain*. This document defines what we adopt verbatim, what we restrain, and the Flutter machinery (`ColorScheme.fromSeed`, `ThemeData`, `ThemeExtension`, `.adaptive`) that turns the spec into a single auditable theme. It owns no token *values* — those live in the files named in the [README token-discipline table](README.md#token-discipline) — it defines the *system* those values plug into. Sibling files consume it: color roles feed [03-color-and-themes.md](03-color-and-themes.md), the type-scale structure feeds [04-typography.md](04-typography.md), touch and spacing feed [05-layout-spacing-touch.md](05-layout-spacing-touch.md), the motion ladder feeds [06-motion-and-haptics.md](06-motion-and-haptics.md), components feed [07-components.md](07-components.md), RTL mirroring feeds [12-localization-and-rtl.md](12-localization-and-rtl.md), and the contrast gates feed [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md). The principles it serves — calm-not-cute, tradition-as-interface, reverence-first — are argued in [01-design-principles.md](01-design-principles.md). The full evidence dossier is [`research/material3-flutter-design.md`](research/material3-flutter-design.md).

---

## At a glance — adopt / adapt / restrain

| M3 / Flutter capability | Our stance | Why |
|---|---|---|
| `ColorScheme.fromSeed` + color roles | **Adopt** verbatim | One seed → harmonised light/dark; roles, not hex, survive theme/contrast changes |
| Tone-based surface containers (`surfaceContainer*`) | **Adopt** | Quieter, neutral elevation; the muṣḥaf is never veiled in brand tint |
| M3 type scale (Display…Label × 3) | **Adopt structure, override values** | Keep role slots; supply Arabic-script faces and line-heights |
| `Durations` + standard easing | **Adopt the short/medium rungs only** | Calm, low-arousal motion |
| `.adaptive` constructors | **Adopt** | Native iOS feel, one codebase, our colors retained |
| `useMaterial3` | **Adopt (it is the default)** | M3 is the baseline, not an opt-in |
| M3 Expressive spring motion | **Restrain (do not adopt)** | Bouncy/overshoot motion is the wrong register for worship |
| Dynamic (wallpaper) color | **Restrain (do not adopt)** | Unpredictable surroundings would clash with the reverent identity |
| `Badge` counters, streak chips, celebratory components | **Refuse** | Gamification of worship is forbidden (PRD R3/C6) |
| `ThemeData` + `ThemeExtension` token store | **Adopt** | Auditable single source of truth; no scattered constants |

---

## 1. Material 3 is the baseline, adopted through `useMaterial3`

**Statement.** Mihrab is a Material 3 app. We do not treat M3 as an experimental opt-in or maintain a Material 2 fallback; `useMaterial3` is left at its default-true value, and the whole component, color, type, and motion system is the M3 one.

**Evidence.**
- `useMaterial3` has been **`true` by default since the Flutter 3.16 release (November 2023)**; setting it `false` is a temporary workaround on a deprecation path, so M3 is the framework baseline rather than an opt-in ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- Migrating to M3 swaps whole component families onto a supported path: **`NavigationBar`** (pill-shaped indicator) replaces `BottomNavigationBar`, **`NavigationDrawer`** replaces `Drawer`, and **`SegmentedButton`** (selection by a Dart `Set`) replaces `ToggleButtons`; M3 also adds **`FilledButton` / `FilledButton.tonal`** ("very similar to an `ElevatedButton` without the elevation changes and drop shadow") ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- The same M3 system mirrors correctly for RTL by construction: when a layout flips LTR↔RTL, the navigation bar, overflow menu, and directional icons "switch sides, with the same specifications for spacing and height as LTR" ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).

**In practice.**
- A single root `MaterialApp(theme:, darkTheme:, themeMode:)` with `ThemeData(useMaterial3: true)` (the default) for both brightnesses; no per-screen theme overrides except the reader's sepia/night surfaces (§3).
- Use the M3 component vocabulary, restrained (§5 below): `NavigationBar` for the five-tab bottom nav (**Today · Muṣḥaf · Mutashābihāt · Progress · Settings**, mirrored RTL per PRD §12), `FilledButton`/`FilledButton.tonal` for recite/grade actions, `SegmentedButton` where a grade or term-set choice fits, `Card`/`ListTile` for the Today list — anatomy specified in [07-components.md](07-components.md).
- RTL is structural, not a theme flag: `Directionality(TextDirection.rtl)` app-wide, so M3's automatic mirroring carries the nav bar, directional icons, and progress indicators for fa, ckb, and ar at once — the mirroring policy lives in [12-localization-and-rtl.md](12-localization-and-rtl.md).

**Anti-patterns — we will never:**
- Ship `useMaterial3: false` or maintain a parallel Material 2 theme.
- Hardcode left/right positioning that defeats M3's RTL mirroring for fa/ckb/ar.
- Reach for a non-Material custom-painted control where a restrained M3 component already does the job.

---

## 2. Color is role-based: one seed, `ColorScheme.fromSeed`, no raw hex in widgets

**Statement.** Every color in the app is a **named M3 role**, generated from a single designed seed via `ColorScheme.fromSeed` for both light and dark. Widgets reference roles (`colorScheme.surface`, `colorScheme.onSurfaceVariant`, …); they never reference raw hex or a tonal-palette value.

**Evidence.**
- M3 builds every theme from five key colors, each expanding into a 13-tone palette, with specific tones assigned to named **color roles**; the cardinal rule is to **"always apply color roles rather than static values or tonal-palette values, as these colors will break with light/dark themes, contrast control, and other features"** ([Material 3: Color roles](https://m3.material.io/styles/color/roles)).
- Roles come in **on-color pairs** — `primary`/`onPrimary`, `surface`/`onSurface`, `error`/`onError`, etc. — each `on…` guaranteed legible on its partner; Flutter's `ColorScheme` exposes exactly these plus utility roles (`outline`, `outlineVariant`, `inverseSurface`, `surfaceTint`, `scrim`, `shadow`) ([Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).
- **`ColorScheme.fromSeed(seedColor, brightness, dynamicSchemeVariant, contrastLevel)`** "constructs a set of tonal palettes" whose colors "are designed to work well together and meet contrast requirements for accessibility"; the default variant `tonalSpot` "has pastel palettes and won't be too colorful even if the `seedColor` has a high chroma value," and `contrastLevel` (−1.0…1.0, default 0.0) tunes the pairs ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)).
- The same seed with `Brightness.light` and `Brightness.dark` yields harmonised schemes — only brightness changes — so a calm green/sepia identity stays coherent across modes ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).

**In practice.**
- [03-color-and-themes.md](03-color-and-themes.md) **owns** the seed and all `color.*` token values; this file only fixes the *mechanism*: drive `ThemeData.colorScheme` from `ColorScheme.fromSeed(seedColor: <calm Quran-green/sepia seed>, brightness: …)` for light and dark.
- Every surface and text color in Dart is a role — `color.bg.primary` → `colorScheme.surface`, `color.text.primary` → `colorScheme.onSurface`, `color.text.secondary` → `colorScheme.onSurfaceVariant`, `color.accent.green` → `colorScheme.primary` — so a palette change is a one-line seed edit, not a sweep through widgets.
- `tonalSpot`'s pastel bias is exactly the calm register we want; the generated on-color pairs are a **starting point that we still verify** against measured WCAG ratios for our seed (see §8) rather than trusting blindly.
- RTL note: color carries no direction, but the heat-map and decay colors must never be the *only* signal — they are paired with locale numerals and labels in fa/ckb/ar ([08-data-visualization.md](08-data-visualization.md), [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Write a raw `Color(0xFF…)` or a `colorScheme.primary.withOpacity(...)`-style ad-hoc tint inside a widget; color enters only as a role token defined in [03-color-and-themes.md](03-color-and-themes.md).
- Hand-pick a tonal-palette tone (e.g. "primary40") directly — roles only, so light/dark/contrast variants stay correct.
- Use the deprecated `background`/`onBackground` roles; use `surface`/`onSurface` (and `surfaceContainerHighest` in place of the deprecated `surfaceVariant`) ([Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).

---

## 3. Elevation is quiet: tone-based surface containers, not a brand-tinted veil

**Statement.** Raised surfaces are expressed with M3's **tone-based surface containers** (neutral lightness steps), kept low and effectively shadowless. The sacred page is never veiled in a primary-coloured `surfaceTint` overlay, and the sepia/night reader surfaces are separate roles transforming the rendered glyph layer — never a re-tint of the Quran text.

**Evidence.**
- M3 moved from a primary-tinted **`surfaceTint`** elevation overlay (whose opacity grew with elevation) to a **tone-based surface system**: a neutral ladder — `surfaceDim`, `surfaceBright`, and `surfaceContainerLowest`/`Low`/`Container`/`High`/`Highest` — so a raised component picks a flatter, lighter container tone instead of a dynamic brand tint; the stated intent is "to eventually remove surface tint color from the framework" ([Material 3: Introducing Tone-based Surfaces](https://m3.material.io/blog/tone-based-surface-color-m3); [Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).
- M3 defines six elevation levels with fixed dp — **Level 0 = 0dp, 1 = 1dp, 2 = 3dp, 3 = 6dp, 4 = 8dp, 5 = 12dp** — with conventional assignments: Level 0 for flat surfaces, Level 1 for elevated cards and bottom sheets, Level 2 for the navigation bar and menus, Level 3 for FAB/dialogs, Levels 4–5 mostly hover states ([Material 3: Elevation tokens](https://m3.material.io/styles/elevation/tokens)).
- Tonal elevation derives from the primary color, so a green primary would tint raised surfaces green; the tone-based containers express the same hierarchy in cleaner neutral steps ([Material 3: Elevation tokens](https://m3.material.io/styles/elevation/tokens); [Flutter: Material.surfaceTintColor](https://api.flutter.dev/flutter/material/Material/surfaceTintColor.html)).
- This serves the reverence pillar directly: faithful page rendering means the muṣḥaf is drawn through bundled per-page glyph fonts and never decorated or re-typeset ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based); PRD R1, §11.2).

**In practice.**
- Map surfaces to neutral container tones: app background → `surface`; Today-list cards and the recite sheet → `surfaceContainerLow`/`surfaceContainer`; the `NavigationBar` → `surfaceContainer`/`High` (Level 2); modal dialogs and bottom sheets → `surfaceContainerHigh`/`Highest` (Level 3). Concrete `color.surface.*` values live in [03-color-and-themes.md](03-color-and-themes.md); elevation token assignment per component lives in [07-components.md](07-components.md).
- Keep elevation **Level 0–1** for content and only raise true modals to Level 3; suppress decorative drop shadows on Quran content. The muṣḥaf reader page sits on a plain surface with **no shadow and no surface tint**.
- Reader themes (light / sepia / dark) are separate surface roles / `ThemeExtension` tokens that transform the *rendered glyph layer's* backdrop (zoom, sepia wash, night inversion of the surface) — never an edit or re-tint of the glyph text itself (PRD §11.2; [04-typography.md](04-typography.md)).
- RTL note: elevation and surfaces are direction-agnostic; the reader's page-turn direction (RTL swipe) is a layout/motion concern handled in [05-layout-spacing-touch.md](05-layout-spacing-touch.md) and [06-motion-and-haptics.md](06-motion-and-haptics.md), not here.

**Anti-patterns — we will never:**
- Paint a `surfaceTint`/primary-tinted elevation veil over the muṣḥaf, the heat-map, or any content surface.
- Stack decorative shadows or high elevation to create visual "polish"; flatness is the reverent default.
- Recolour or re-tint the Quran glyph layer to achieve a sepia/night look — only the surrounding surface changes.

---

## 4. Type adopts the M3 *role structure*, overrides its *values* for Arabic script

**Statement.** Our text styles map onto the M3 type-scale roles so every component stays consistent, but the concrete font faces, sizes, and line-heights are **overridden for Arabic script** (taller line-heights, a Perso-Arabic UI face, verified Sorani coverage). The Quran text is never touched by this scale.

**Evidence.**
- M3 typography is five roles — **Display, Headline, Title, Body, Label**, each in Large/Medium/Small (15 baseline styles) — expressed as design tokens carrying size, line-height, weight, and letter-spacing ([Material 3: Typography](https://m3.material.io/styles/typography)).
- Flutter's M3 default is **`Typography.material2021`**, which "creates a typography instance using Material Design 3 2021 defaults" and applies `ColorScheme` `onSurface`/`surface` colors **uniformly**, "with no color variation based on style as in previous versions"; the named `TextTheme` slots (`displayLarge…labelSmall`) map straight onto the M3 roles ([Flutter: Typography.material2021](https://api.flutter.dev/flutter/material/Typography/Typography.material2021.html)).
- The *reference* scale is Latin/Roboto, so Arabic-script type needs taller line-heights and a script-appropriate face — and legibility is governed by familiarity ("you read best what you read most"), so the UI must use letterform skeletons fa/ckb/ar readers see every day ([Nedeljković et al., 2020, *J. Eye Movement Research*](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)).
- Fonts must be **bundled assets, not runtime-fetched**: bundled fonts "are always available, load instantly, and work offline," and production guidance is to ship the files and set `GoogleFonts.config.allowRuntimeFetching = false` so a missing declaration fails at compile time rather than silently falling back ([google_fonts package](https://pub.dev/packages/google_fonts)).

**In practice.**
- [04-typography.md](04-typography.md) **owns** all `type.*` values; this file fixes the contract: supply a custom `TextTheme` to `ThemeData(textTheme:)` that keeps the `displayLarge…labelSmall` slots but replaces faces and metrics for Arabic script (e.g. Vazirmatn / Estedad / Noto Naskh for fa/ar, a CI-verified Sorani face for ckb), all bundled in the app binary with runtime font fetching disabled.
- Token-to-slot mapping is fixed here so components resolve consistently: `type.display` → `displayLarge/Medium`, `type.title` → `titleLarge/Medium`, `type.body` → `bodyLarge/Medium`, `type.label` → `labelLarge`, `type.caption` → `bodySmall` — exact sizes/line-heights in [04-typography.md](04-typography.md).
- **The Quran is excluded from this scale entirely.** Quran text is immutable KFGQPC per-page glyph rendering (PRD §11; Pillar 1); it is not a `type.*` token and is never styled by `TextTheme`.
- RTL/locale note: the bundled UI face must cover Sorani's extra letters (پ چ ژ ڤ ک گ ڕ ڵ ۆ ێ ە ھ), CI-verified before locking (PRD §13.5); numerals render in the locale set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) — a `type.numeral` concern owned by [04-typography.md](04-typography.md) and [12-localization-and-rtl.md](12-localization-and-rtl.md).

**Anti-patterns — we will never:**
- Ship the raw Latin/Roboto `material2021` metrics for Arabic UI text (clipped diacritics, cramped lines).
- Fetch a UI font at runtime from a font CDN; every UI face is a bundled asset with `allowRuntimeFetching = false` (PRD §19.1).
- Route any Quran glyph through the `TextTheme`/type scale, or treat the muṣḥaf as a styleable `type.*` token.

---

## 5. Components are M3, used with restraint — never as a gamification surface

**Statement.** We use the standard M3 component set so the app feels coherent and inherits accessibility and RTL behaviour for free, but every component is chosen and tuned for calm: no counters, badges, streak chips, or celebratory flourishes anywhere.

**Evidence.**
- Each M3 component reads its colors from `ColorScheme` roles and its surface from tone-based containers — dialogs/sheets use `surfaceContainerHigh`/`Highest` with `onSurface`; cards/menus use `surface` with elevation — so using the standard widgets keeps the theme coherent automatically ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration); [Flutter: ColorScheme class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)).
- M3 adds emphasis components — **`FilledButton` / `FilledButton.tonal`** (elevation-less emphasis) and **`SegmentedButton`** (Set-based selection) — and a **`Badge`** counter widget among others ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- The product constraints forbid gamifying worship: no leaderboards, XP, badges on ayāt, or confetti, and progress is a calm non-shaming heat-map, not a streak (PRD R3, C6); the evidence against extrinsic reward is the overjustification meta-analysis — tangible rewards reliably *undermine* intrinsic motivation ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).

**In practice.**
- Allowed, restrained: `NavigationBar` (five tabs, RTL-mirrored), `FilledButton`/`FilledButton.tonal` (recite / sign-off / grade), `SegmentedButton` (4-level grade Again/Hard/Good/Easy, or term-set choice), `Card`/`ListTile` (Today list), `AlertDialog.adaptive` (confirmations), `CircularProgressIndicator.adaptive` (the one-time asset download). Full anatomy, states, and accessibility per component in [07-components.md](07-components.md).
- `Badge` is permitted **only** for neutral, informational counts where one genuinely aids the task (e.g. "3 pages due today" as plain information) — never as an XP/score/streak surface, and never attached to an ayah or juz as an achievement.
- Decay and progress are shown via the retention heat-map ([08-data-visualization.md](08-data-visualization.md)), not via component badges or trophies.
- RTL note: because components read logical directions, the same restrained set mirrors automatically for fa/ckb/ar; the back/next chevrons in the recite flow use directional `Icons` that auto-mirror (§7, [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Use `Badge`, chips, or any component as an XP, points, streak, or trophy surface on recitation or ayāt (PRD R3/C6).
- Add celebratory components (confetti overlays, achievement dialogs) on completing a page, juz, or khatm.
- Build a dashboard of vanity metrics; the home surface is the calm tradition-shaped "Today," not a stats console (PRD §2, §12.2).

---

## 6. Motion is calm: M3 duration/easing tokens, short/medium rungs only — never Expressive springs

**Statement.** Motion uses M3's standard easing and the short/medium rungs of the `Durations` ladder. We deliberately do **not** adopt Material 3 Expressive's spring/overshoot motion, and we honour the OS "reduce motion" setting.

**Evidence.**
- M3 motion is a token system: named **easing** tokens (`standard`, and `emphasized` for hero/expanding transitions, where emphasized "draws extra attention at the end of an animation and is usually paired with longer durations") plus a duration ladder ([Material 3: Easing & duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)).
- Flutter exposes the ladder as **`Durations`**: short1–4 = **50/100/150/200ms**, medium1–4 = **250/300/350/400ms**, long1–4 = **450/500/550/600ms**, extralong1–4 = **700/800/900/1000ms** ([Flutter: Durations class](https://api.flutter.dev/flutter/material/Durations-class.html)).
- The emphasized curve is a three-point cubic that overshoots-then-settles; Flutter's `Curves.easeInOutCubicEmphasized` is `ThreePointCubic(...)`, and the legacy standard easing was `Curves.fastOutSlowIn` ([Flutter: ThreePointCubic](https://api.flutter.dev/flutter/animation/ThreePointCubic-class.html); [Flutter: animation curves source](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart)).
- Newer **Material 3 Expressive** motion replaces fixed easing/duration with a **spring** model (stiffness + damping), "replacing the duration-based animation system with a new engine grounded in physics" — a more bouncy register a reverent app should avoid ([Material 3: Motion overview](https://m3.material.io/styles/motion/overview/how-it-works)). Calm design lowers arousal; arousal is driven by saturation/brightness and motion energy, not hue ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)).

**In practice.**
- [06-motion-and-haptics.md](06-motion-and-haptics.md) **owns** all `motion.*` values; this file fixes the bounds: `motion.duration.short`/`medium` map to `Durations.short3`–`medium2` (**150–300ms**) for page-turns, reveal-on-tap, and grade transitions; `motion.curve.standard` is `Curves.fastOutSlowIn`/`Easing.standard`.
- `emphasized` easing with a single `long` duration is reserved for at most one hero — the page-to-recite transition — and used sparingly.
- Honour the platform "reduce motion" flag (`MediaQuery.disableAnimations` / `MediaQuery.of(context).accessibleNavigation`): cross-fade or instant-cut instead of animating; detailed in [06-motion-and-haptics.md](06-motion-and-haptics.md) and [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md).
- RTL note: page-turn motion in the reader runs **start→end in RTL** (right-to-left page advance); use directional transitions so fa/ckb/ar advance the way the script reads.

**Anti-patterns — we will never:**
- Adopt M3 Expressive spring/overshoot motion, bouncy physics, or any celebratory animation on worship actions.
- Use `long`/`extralong` durations for routine UI, or chain animations into a "delightful" sequence.
- Animate through a "reduce motion" request; that setting always wins.

---

## 7. iOS feel without forking: `.adaptive` constructors keep one codebase and our colors

**Statement.** A single Material codebase is made to feel native on iOS through Flutter's `.adaptive` constructors and a small amount of platform-aware tuning — never by maintaining a forked Cupertino UI. Adaptive widgets adopt the iOS control's *shape/behaviour* while keeping our `ColorScheme` identity.

**Evidence.**
- Flutter ships `.adaptive` constructors that "substitute the corresponding Cupertino components when the app is run on an iOS device": `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive`, `Checkbox.adaptive`, `Radio.adaptive`, and `AlertDialog.adaptive` ([Flutter: Automatic platform adaptations](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations)).
- Adaptive ≠ responsive: "responsive design is about fitting the UI _into_ the space and adaptive design is about the UI being _usable_ in the space" — adaptive selects platform-appropriate controls/inputs ([Flutter: Adaptive & responsive design](https://docs.flutter.dev/ui/adaptive-responsive)).
- Flutter's tracking issue **"Material 3 iOS Adaptations"** governs which Material widgets adopt iOS conventions automatically versus opt-in, with the stated philosophy of avoiding forked layouts while letting apps "be indistinguishable from native iOS apps" through "small improvements that are automatic or easy-to-use" ([flutter/flutter #94821](https://github.com/flutter/flutter/issues/94821)).
- M3's RTL mirroring (icons, nav, reading flow) carries across both platforms, so adaptive iOS behaviour and RTL coexist without extra forks ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).

**In practice.**
- Use `Switch.adaptive` for settings toggles, `CircularProgressIndicator.adaptive` for the one-time core-pack download (PRD §11.1), `AlertDialog.adaptive` for confirmations (erase, import/replace), `Slider.adaptive` for the Quran zoom/font-size control — each renders the Cupertino control on iOS while keeping our seeded `ColorScheme` colors, so the app reads as native iOS without a green-system-default look.
- Where no adaptive constructor exists, read platform once (`Theme.of(context).platform` / `defaultTargetPlatform`) and branch minimally; prefer automatic adaptation over hand-built Cupertino screens.
- Adaptive is for *control idiom*, not a separate visual identity: the calm green/sepia palette, type, spacing, and motion are identical on both platforms — only platform-conventional controls and gestures (edge-swipe back, iOS switches) differ.
- RTL note: adaptive controls inherit `Directionality`, so the iOS switch, dialogs, and progress sit correctly in fa/ckb/ar layouts; verify with RTL golden screenshots on min-iOS (PRD §20).

**Anti-patterns — we will never:**
- Fork the UI into parallel Material and Cupertino screen trees, or branch heavily on `Platform.isIOS` for layout.
- Let an adaptive control adopt iOS *default colors* (e.g. system green) — adaptive keeps our `ColorScheme`.
- Adapt away core identity (palette, type, reverence) per platform; only control idiom adapts.

---

## 8. Dynamic (wallpaper) color is refused; the designed seed is the floor and the ceiling

**Statement.** We ship a single, fixed, designed seed and do **not** adopt Android's wallpaper-derived dynamic color. The muṣḥaf's surroundings must be predictable and reverent on every device.

**Evidence.**
- Android 12+ can generate a **dynamic color** scheme from the user's wallpaper; Flutter surfaces it through the **`dynamic_color`** package's `DynamicColorBuilder`, "a stateful widget that provides the device's dynamic colors in a light and dark `ColorScheme`," supported on "Android S+" (Android 12 / API 31) and absent on iOS; the standard pattern uses `ColorScheme.fromSeed` as the fallback ([dynamic_color package](https://pub.dev/packages/dynamic_color)).
- Because the wallpaper palette is unavailable on iOS and pre-12 Android, a fixed designed scheme is required as the floor regardless ([dynamic_color package](https://pub.dev/packages/dynamic_color); [Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html)).
- A wallpaper-derived palette would make the reverent identity unpredictable — directly against the calm pillar, where arousal is driven by saturation/brightness ([Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)) and an honest, stable color rhetoric is required for the decay encoding ([Borland & Taylor, 2007](https://doi.org/10.1109/MCG.2007.323435)).

**In practice.**
- Do not depend on `dynamic_color`; the seed defined in [03-color-and-themes.md](03-color-and-themes.md) is the only source of palette on every device and OS version.
- This keeps the heat-map ramp, track chips, and decay colors stable and auditable — a contributor can reproduce the exact palette from the seed without a device's wallpaper.

**Anti-patterns — we will never:**
- Let device wallpaper recolour the app, the muṣḥaf surround, or the retention heat-map.
- Ship a build whose colors differ unpredictably between users on the same OS.

---

## 9. Tokens are auditable: `ThemeData` for M3 roles, `ThemeExtension` for everything else

**Statement.** All theme values live in the theme tree as typed tokens — M3 roles/scale in `ThemeData`'s `ColorScheme`/`TextTheme`, and every bespoke domain (heat-map ramp, track chips, decay indicators, reader surfaces, spacing scale) in immutable `ThemeExtension`s — so there are no scattered constants and each token family is owned by exactly one file.

**Evidence.**
- Flutter's M3 theme is itself a token store: `ThemeData(colorScheme:, textTheme:, …)` holds the role/scale tokens and components resolve them at build time ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- For tokens M3 does not name, the idiomatic mechanism is **`ThemeExtension<T>`** — "an interface that defines custom additions to a `ThemeData` object" — which requires `copyWith` and `lerp` and is read via `Theme.of(context).extension<T>()`; `lerp` lets custom tokens "interpolate smoothly during theme transitions," keeping them in the theme tree rather than scattered as constants ([Flutter: ThemeExtension class](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)).
- Touch and contrast minimums are part of the same contract: M3 specifies a **minimum 48 × 48dp touch target** (≈9mm) with ≥8dp spacing, clearing WCAG SC 2.5.5 (≥44px) and SC 2.5.8 (≥24px) ([Material 3: structure/accessibility](https://m3.material.io/foundations/designing/structure); [material-components-android #1279](https://github.com/material-components/material-components-android/issues/1279)); generated `fromSeed` pairs are "designed to … meet contrast requirements" but must still be verified against measured ratios ([Flutter: ColorScheme.fromSeed](https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html); [WCAG 2.2](https://www.w3.org/TR/WCAG22/)).

**In practice.**
- M3 roles/scale live in `ThemeData` (`colorScheme` from the seed, custom `textTheme`); bespoke domains live in typed `ThemeExtension`s: the heat-map ramp (`color.heatmap.*`), track chips (sabaq/sabqi/manzil), decay indicators, sepia/night reader surfaces, and the 4dp `space.*` scale with `touch.min` = 48dp. Ownership is fixed by the [README token-discipline table](README.md#token-discipline): `color.*` → [03](03-color-and-themes.md), `type.*` → [04](04-typography.md), `space.*`/`touch.min` → [05](05-layout-spacing-touch.md), `motion.*`/`haptic.*` → [06](06-motion-and-haptics.md).
- Each extension implements `copyWith` and `lerp` so light → sepia → dark transitions interpolate smoothly, and is accessed only through `Theme.of(context).extension<T>()` — never a global constant.
- Accessibility minimums are hard gates wired into the tokens: `touch.min` = 48dp on every interactive target (the daily recite/grade taps are large), ≥8dp spacing, and WCAG-verified contrast on every on-color pair and on the heat-map — generated `fromSeed` pairs are measured, not assumed (detailed in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).
- RTL/locale note: tokens are direction- and locale-neutral values; their *application* uses logical insets (`EdgeInsetsDirectional`) and locale numerals so one token set serves fa, ckb, and ar without forking ([05-layout-spacing-touch.md](05-layout-spacing-touch.md), [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- The sacred QPC glyph fonts are explicitly **not tokens** — they are immutable bundled assets governed by Pillar 1 and PRD R1, referenced and never restyled.

**Anti-patterns — we will never:**
- Scatter colors, sizes, durations, or spacing as free-floating `const`s outside `ThemeData`/`ThemeExtension`.
- Let two files own the same token family, or inline a raw value where a named token exists.
- Ship a touch target below 48dp or an unverified on-color pair; both are release gates (PRD §20).

---

## References

- Borland, D., & Taylor, R. M., II. (2007). Rainbow Color Map (Still) Considered Harmful. *IEEE Computer Graphics and Applications*, 27(2), 14–17. https://doi.org/10.1109/MCG.2007.323435
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Flutter. *Migrate to Material 3* (`useMaterial3` true by default since 3.16; component replacements; tone-based surfaces; Typography 2021). https://docs.flutter.dev/release/breaking-changes/material-3-migration
- Flutter API. *ColorScheme class* (color roles; on-color pairs; deprecated `background`/`onBackground`/`surfaceVariant`; surface containers). https://api.flutter.dev/flutter/material/ColorScheme-class.html
- Flutter API. *ColorScheme.fromSeed constructor* (tonal palettes; `tonalSpot` default; `contrastLevel`; meets contrast requirements). https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
- Flutter API. *Typography.material2021* (M3 2021 defaults; uniform on-surface color; `displayLarge…labelSmall` slots). https://api.flutter.dev/flutter/material/Typography/Typography.material2021.html
- Flutter API. *Material.surfaceTintColor*. https://api.flutter.dev/flutter/material/Material/surfaceTintColor.html
- Flutter API. *Durations class* (short/medium/long/extra-long millisecond values). https://api.flutter.dev/flutter/material/Durations-class.html
- Flutter API. *ThreePointCubic class* (emphasized three-point cubic curve). https://api.flutter.dev/flutter/animation/ThreePointCubic-class.html
- Flutter API. *ThemeExtension class* (`copyWith`/`lerp`; `Theme.of(context).extension<T>()`; custom theme additions). https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Flutter (source). *animation/curves.dart* (legacy `fastOutSlowIn` standard easing; M3 `Easing` replacements). https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/animation/curves.dart
- Flutter. *Adaptive & responsive design* (adaptive vs responsive distinction). https://docs.flutter.dev/ui/adaptive-responsive
- Flutter. *Automatic platform adaptations* (`.adaptive` constructors substitute Cupertino components on iOS). https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations
- flutter/flutter. *Issue #94821: Material 3 iOS Adaptations* (automatic vs opt-in adaptation; "indistinguishable from native iOS"). https://github.com/flutter/flutter/issues/94821
- Material Design 3. *Color roles* ("always apply color roles rather than static values"). https://m3.material.io/styles/color/roles
- Material Design 3. *Introducing Tone-based Surfaces in Material 3* (surface containers; intent to remove surface tint). https://m3.material.io/blog/tone-based-surface-color-m3
- Material Design 3. *Elevation tokens* (levels 0–5 → 0/1/3/6/8/12dp; shadow vs tonal elevation). https://m3.material.io/styles/elevation/tokens
- Material Design 3. *Typography* (Display/Headline/Title/Body/Label × 3; type-scale tokens; Roboto reference). https://m3.material.io/styles/typography
- Material Design 3. *Easing and duration: tokens & specs* (standard/emphasized easing; duration ladder). https://m3.material.io/styles/motion/easing-and-duration/tokens-specs
- Material Design 3. *Motion overview / how it works* (Expressive spring motion engine). https://m3.material.io/styles/motion/overview/how-it-works
- Material Design 3. *Bidirectionality & RTL* (mirroring; NavigationBar/icons switch sides). https://m3.material.io/foundations/layout/bidirectionality-rtl
- Material Design 3. *Designing for structure / accessibility* (48 × 48dp touch targets; ≥8dp spacing). https://m3.material.io/foundations/designing/structure
- material-components/material-components-android. *Issue #1279: 48 × 48dp touch target* (≈9mm; WCAG 2.5.5/2.5.8 ≥44/24). https://github.com/material-components/material-components-android/issues/1279
- pub.dev. *dynamic_color package* (`DynamicColorBuilder`; Android S+ wallpaper color; `fromSeed` fallback; no iOS). https://pub.dev/packages/dynamic_color
- pub.dev. *google_fonts package* (bundle fonts for offline; `allowRuntimeFetching = false`). https://pub.dev/packages/google_fonts
- Nedeljković, U., Jovančić, K., & Pušnik, N. (2020). You read best what you read most: An eye tracking study. *Journal of Eye Movement Research*, 13(2). https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/
- Quranic Universal Library (QUL), Tarteel. *Glyph-Based Fonts* (604 per-page KFGQPC/QPC fonts; each glyph a whole word; renders without OS shaping). https://qul.tarteel.ai/docs/glyph-based
- Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General*, 123(4), 394–409. https://psycnet.apa.org/record/1995-08699-001
- W3C (2023, updated 2024). Web Content Accessibility Guidelines (WCAG) 2.2 — W3C Recommendation (SC 1.4.1; SC 2.5.5; SC 2.5.8). https://www.w3.org/TR/WCAG22/
