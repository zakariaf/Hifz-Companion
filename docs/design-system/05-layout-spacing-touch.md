# 05 — Layout, Spacing & Touch

This file owns the **`space.*`** token family and the layout, grid, and touch-ergonomics rules that arrange everything else: how much air sits between elements, how panels and lists align to a grid, how the whole UI flips for RTL, how large and how reachable every tap target is, and what the recurring screen templates look like. It is the spatial counterpart to the color and type systems — it never sets a color (see [03-color-and-themes.md](03-color-and-themes.md)) or a font value (see [04-typography.md](04-typography.md)); it sets *distance*. It is built on the Material 3 + Flutter foundations in [02-material-and-platform-foundations.md](02-material-and-platform-foundations.md), implements the bidi/mirroring policy detailed in [12-localization-and-rtl.md](12-localization-and-rtl.md), and meets the hard touch-target and reach requirements enforced in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md). The governing intent is Pillar 2 — *calm, not cute*: generous, predictable space is how a daily ritual carrying spiritual weight lowers arousal instead of farming it, and the recite/grade flow ([07-components.md](07-components.md)) must be tappable quickly, one-handed, by a ḥāfiẓ who opens the app every day.

## At a glance

| Concern | Decision | Token / value | Owner |
|---|---|---|---|
| Base spacing unit | 4dp scale on an 8dp grid | `space.1`=4 … `space.8`=48 | this file |
| Default component padding | 16dp (`space.4`) inside cards/sheets | `space.4` | this file |
| Default list-row gap | 8dp (`space.2`) | `space.2` | this file |
| Screen edge margin (compact) | 16dp logical (start/end) | `space.4` | this file |
| Minimum touch target | 48 × 48dp, ≥8dp apart | `touch.min` = 48, gap `space.2` | this file |
| Directional insets | logical `start`/`end`, never `left`/`right` | `EdgeInsetsDirectional` | this file + [12](12-localization-and-rtl.md) |
| Layout direction | `TextDirection.rtl` app-wide | — | [12-localization-and-rtl.md](12-localization-and-rtl.md) |
| Responsive breakpoint | compact (<600dp) is the only required target; medium/expanded optional | M3 window size classes | this file |
| Primary-action placement | bottom band, within one-handed thumb reach | screen templates §5 | this file |

---

## 1. The spacing scale: a 4dp step on an 8dp grid

**Statement.** All spacing in the app is drawn from one numeric scale — `space.1` through `space.8` — built on a 4dp step and an 8dp layout grid. No widget hardcodes a raw dp margin; it references a `space.*` token. This is the single mechanism that makes the interface feel calm and consistent rather than ad-hoc.

**Evidence.**
- Material Design aligns components to an **8dp square baseline grid** for mobile, with most measurements in 8dp increments and **margins/gutters of 8, 16, 24, or 40dp**; smaller elements such as icons may align to a finer **4dp grid** ([Material 3: Grids & spacing](https://m3.material.io/foundations/layout/understanding-layout/spacing); [Material 2: Understanding layout](https://m2.material.io/design/layout/understanding-layout.html)).
- A single, regular spacing system is what produces "visually balanced layouts"; consistent margin and gutter widths — not bespoke per-screen values — are the unit of layout consistency ([Material 2: Responsive layout grid](https://m2.material.io/design/layout/responsive-layout-grid.html)).
- In Flutter the idiomatic way to keep these values in one auditable place (rather than scattered constants) is a typed `ThemeExtension`, which lives in the theme tree, gives one source of truth across light/dark/sepia, and interpolates via `lerp` during theme transitions ([Flutter: ThemeExtension class](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)).

**In practice.**

| Token | Value | Typical use |
|---|---|---|
| `space.1` | 4dp | hairline gaps; icon-to-label inside a chip; baseline nudge |
| `space.2` | 8dp | gap between list rows; spacing between adjacent tap targets |
| `space.3` | 12dp | compact vertical rhythm inside dense rows |
| `space.4` | 16dp | **default** padding inside cards/sheets; compact screen edge margin |
| `space.5` | 20dp | section padding on roomier screens |
| `space.6` | 24dp | gap between major sections of a screen |
| `space.7` | 32dp | breathing room around a single focal element (e.g. the grade prompt) |
| `space.8` | 48dp | large separations; top/bottom of a focused recite view |

- The scale is defined once in a `SpacingTokens extends ThemeExtension<SpacingTokens>` and read as `Theme.of(context).extension<SpacingTokens>()!.space4`, mirroring the token-discipline pattern the README assigns to this file. Arabic-script line-heights and type sizes are owned separately by `type.*` ([04-typography.md](04-typography.md)) — spacing handles only the gaps *between* type blocks, so generous line-height for fa/ckb/ar does not double-count with vertical `space.*`.
- Because the same scale drives all three locales, switching from Persian to Sorani to Arabic changes string length and glyph height but never the grid — the layout stays steady when a fa label is short and its ckb transcreation is long ([12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Hardcode a raw `EdgeInsets.all(13)` or any off-scale dp value in a widget; every gap resolves to a `space.*` token.
- Introduce a parallel, undocumented spacing constant in a feature folder — one scale, owned here.
- Tighten spacing to cram more onto a screen; when content overflows we paginate or scroll, never compress the calm (Pillar 2).

---

## 2. Grid, margins & gutters

**Statement.** Screens are laid out on the 8dp grid with a consistent edge **margin** and inter-column **gutter**, expressed as logical start/end insets. The compact phone window (the only required form factor) uses a single content column with a 16dp edge margin; the grid exists so panels, list rows, the bottom nav, and the heat-map all align to the same vertical keylines.

**Evidence.**
- The Material responsive grid is defined by **consistent margin and gutter widths** following the 8dp baseline grid, adapting to screen size and orientation while keeping alignment consistent ([Material 2: Responsive layout grid](https://m2.material.io/design/layout/responsive-layout-grid.html); [Material 3: Grids & spacing](https://m3.material.io/foundations/layout/understanding-layout/spacing)).
- M3 defines canonical **window size classes**: **compact (0–599dp)** is the single-column, touch-first baseline; **medium (600–839dp)** and **expanded (840–1199dp)** are the larger-screen adaptation points — opinionated breakpoints derived from Google's research on real device sizes ([Material 3: Applying layout / breakpoints](https://m3.material.io/foundations/layout/applying-layout)).
- Keylines are the vertical/horizontal lines used to align objects in a UI; aligning list content, leading icons, and section headers to shared keylines is what makes a screen read as ordered rather than ragged ([Material 2: Understanding layout](https://m2.material.io/design/layout/understanding-layout.html)).

**In practice.**

| Surface | Edge margin | Internal gutter |
|---|---|---|
| Today list, Progress, Settings (compact) | `space.4` (16dp) start/end | `space.2`–`space.4` between rows/cards |
| Bottom `NavigationBar` | full-bleed; items on grid | M3 default item spacing |
| Heat-map grid (Progress) | `space.4` outer | `space.1` (4dp) between cells |
| Muṣḥaf reader page | minimal chrome; page art governs its own margins | n/a (immutable glyph layer, [11 PRD](../PRD.md)) |

- Target form factor is **compact**: a phone in one hand. We design and gold-test for `<600dp` width and treat medium/expanded as a graceful bonus (a centered, max-width content column), never a required build — the primary user recites alone with a phone, not a tablet split-view.
- The muṣḥaf reader is the exception to the grid: its margins come from the bundled per-page glyph art, never recomputed, because the Quran page is rendered as an immutable image of the printed page and is never re-typeset for any layout goal (Pillar 1; [PRD R1, §11.2](../PRD.md)). The grid governs the *chrome around* the page, never the page.
- All keylines are expressed start/end so leading icons, track chips, and decay indicators align to the same RTL-correct keyline across fa/ckb/ar.

**Anti-patterns — we will never:**
- Build a tablet/desktop multi-pane layout the product does not need; complexity that wasn't requested is not added.
- Let the muṣḥaf page inherit the UI content grid or its margins — the page is sacred art, not a grid cell.
- Use pixel positions or absolute coordinates for chrome; everything aligns to the 8dp grid and resolves with `MediaQuery`/`SafeArea`.

---

## 3. RTL is the layout's geometry, not a mode

**Statement.** The app is RTL by construction for all three locales (fa, ckb, ar). Every inset, alignment, and directional widget is expressed with **logical start/end** semantics so the layout flips automatically; left/right are never named. RTL is not a setting that mirrors an LTR design — it *is* the design, true to the miḥrāb the system is named for.

**Evidence.**
- Flutter's `EdgeInsetsDirectional` is "an immutable set of offsets… whose horizontal components are dependent on the writing direction," using `start`/`end` rather than `left`/`right` and **automatically flipping** horizontal padding when text direction changes — "ideal for internationalized applications… without requiring separate layout logic" ([Flutter: EdgeInsetsDirectional](https://api.flutter.dev/flutter/painting/EdgeInsetsDirectional-class.html)).
- Material 3's bidirectionality contract is that when a layout mirrors LTR↔RTL, elements and reading flow move to the opposite side and directional components (navigation bar, overflow menu, directional icons) "switch sides, with the same specifications for spacing and height as LTR" — i.e. mirror the *position*, keep the *metrics* ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).
- Legibility is governed by familiarity — readers "read best what they read most" — so the layout must follow the script's native reading geometry, not a flipped Latin one, for these readers to scan it without friction ([Nedeljković et al., 2020](https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/)).

**In practice.**
- `Directionality(TextDirection.rtl)` wraps the app (owned by [12-localization-and-rtl.md](12-localization-and-rtl.md)); **this file's contribution is that every spacing value is applied through `EdgeInsetsDirectional` / `AlignmentDirectional`** and `space.*` tokens are direction-agnostic by nature — a 16dp start inset becomes a 16dp right inset in RTL with zero extra code.
- The bottom nav is laid out so **"home" (Today) sits at the trailing/rightmost edge** in RTL order — Today · Muṣḥaf · Mutashābihāt · Progress · Settings reads right-to-left ([PRD §12](../PRD.md)). Spacing between nav items uses the M3 default; this file only guarantees the items sit on the grid.
- Leading icons (track chips, decay indicators, list affordances) sit at the **start** (right) of a row; chevrons/next-affordances at the **end** (left) and mirror automatically. Mixed runs — a localized-numeral page number inside RTL text, or a Latin technical string — keep their own direction via bidi isolation (FSI/PDI), owned by [12-localization-and-rtl.md](12-localization-and-rtl.md), so a "Juz ۷" label never breaks the row's alignment.
- The same templates serve all three locales unchanged; ckb's longer transcreated labels reflow within the same start/end insets without a separate layout.

**Anti-patterns — we will never:**
- Write `EdgeInsets.only(left:)` / `Alignment.centerLeft` or any physical-direction inset in a user-facing widget.
- Ship an "RTL mode" bolted onto an LTR-first layout; RTL is the default and only direction.
- Mirror an icon whose meaning is absolute (a logo, a play triangle for audio) — only directional/navigational glyphs flip ([Material 3: Bidirectionality & RTL](https://m3.material.io/foundations/layout/bidirectionality-rtl)).

---

## 4. Touch targets: 48 × 48dp, ≥8dp apart, sized by Fitts's law

**Statement.** Every interactive control is at least **48 × 48dp** with at least **8dp** of clear space from its neighbors, regardless of how small its visible glyph is. The daily recite/grade controls — tapped quickly, often one-handed, every day — are made *larger and lower* than the minimum because the cost of a mis-tap on a sacred-text grade is high.

**Evidence.**
- Material 3 specifies a **minimum touch target of 48 × 48dp** (≈9mm physical) even when the visible icon is 24dp, with **≥8dp spacing** between targets ([Material 3: structure/accessibility](https://m3.material.io/foundations/designing/structure); [material-components-android #1279](https://github.com/material-components/material-components-android/issues/1279)).
- This clears both WCAG 2.2 thresholds: **SC 2.5.8 Target Size (Minimum) ≥24×24px (AA)** and **SC 2.5.5 Target Size (Enhanced) ≥44×44px (AAA)** — 48dp passes the higher AAA bar ([WCAG 2.2](https://www.w3.org/TR/WCAG22/); [material-components-android #1279](https://github.com/material-components/material-components-android/issues/1279)).
- Fitts's law (Fitts, 1954) formalizes *why* size and spacing matter: movement time to acquire a target rises with distance and falls with target width — `MT = a + b·log₂(2A/W)` — so larger, closer targets are acquired faster and with fewer errors, the foundational speed-accuracy law of pointing ([Fitts's law, Wikipedia](https://en.wikipedia.org/wiki/Fitts%27s_law); [Nielsen Norman Group: Fitts's Law](https://www.nngroup.com/articles/fitts-law/)).

**In practice.**

| Control | Visible size | Hit target | Spacing |
|---|---|---|---|
| Grade buttons (Again/Hard/Good/Easy) | full-width band, tall | ≥56dp tall, ≥48dp wide each | `space.2` (8dp) between |
| Stumble-line tap zones (reveal-on-tap) | line-height of glyph row | ≥48dp tall hit area, padded if the glyph line is shorter | grid-aligned |
| Track chips, decay indicators | ~24dp glyph | 48 × 48dp hit area | `space.2` apart |
| Bottom nav items | M3 default | M3 `NavigationBar` (≥48dp) | M3 default |
| Teacher sign-off toggle | switch | `.adaptive` switch, 48dp row | `space.4` padding |

- The four-level **grade band** is the most-used control: it is rendered as a full-width row of large `FilledButton`s ([02-material-and-platform-foundations.md](02-material-and-platform-foundations.md)), each ≥48dp wide and ≥56dp tall, separated by `space.2`, so a one-thumb tap rarely misses — and the highest-stakes action (a sacred-text grade) never sits on a 24dp pinpoint.
- **Stumble-line tapping** during reveal-on-tap maps a tap to a line index. Because a glyph line can be visually shorter than 48dp, its *hit area* is expanded with vertical padding to ≥48dp while the glyph itself is untouched — the tap target grows, the immutable muṣḥaf page does not ([PRD §8.1, §11.2](../PRD.md)).
- Spacing between adjacent targets is `space.2` (8dp) minimum so a stretch-tap on one grade does not catch the next — directly applying the Fitts/Material spacing rule. Larger Quran-zoom and OS text-scale must not shrink hit areas below 48dp; verified in the accessibility release checklist ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Ship an interactive control smaller than 48 × 48dp, however small its icon, or place two targets closer than 8dp.
- Put the primary daily action (grade) behind a tiny icon or a long-press only; it is large, labeled, and obvious.
- Expand a tap target by reflowing or re-typesetting the muṣḥaf glyph layer — only the transparent hit region grows ([PRD R1](../PRD.md)).

---

## 5. Thumb ergonomics & screen templates: primary actions live where the thumb rests

**Statement.** The app is used one-handed, daily, often in a quiet moment after ṣalāh. Every recurring screen follows one template: calm content scrolls in the upper and middle area; the **primary action lives in the bottom band, inside the one-handed thumb-reach zone**; destructive or rare actions sit in the harder-to-reach top corners. The recite/grade flow especially keeps its controls low so a ḥāfiẓ can grade a page without shifting grip.

**Evidence.**
- Observing 1,333 people, Hoober found mobile devices are held **one-handed 49%, cradled 36%, two-handed 15%** of the time; thumb reach is charted as green (easy), yellow (a stretch), and red (requires shifting grip) — the bottom-center is the comfortable zone, the top corners the hard one ([Hoober, 2013, UXmatters](https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php)).
- The applied design rule is to "keep frequently used links in the easy-to-reach zone and infrequently used links in the hard-to-reach zone," with roughly **75% of interactions thumb-driven**; primary navigation and actions belong in the natural thumb zone, secondary/destructive actions can sit out of easy reach ([Ingram, 2016, Smashing Magazine](https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/)).
- Fitts's law reinforces the placement: a target near the thumb's resting point (small movement amplitude `A`) is acquired faster and more accurately than one in a far corner ([Fitts's law, Wikipedia](https://en.wikipedia.org/wiki/Fitts%27s_law); [NN/g: Fitts's Law](https://www.nngroup.com/articles/fitts-law/)).
- A daily ritual carrying spiritual weight should lower arousal, not farm it — generous bottom-anchored ergonomics serve calm, the central design pillar (Pillar 2; [Valdez & Mehrabian, 1994](https://psycnet.apa.org/record/1995-08699-001)).

**In practice.**

| Screen | Content zone (scroll) | Primary action (thumb zone) | Top corners (rare/destructive) |
|---|---|---|---|
| **Today** | finite "revise today" list, Far→Near→New | "Begin" / next-item tap, low | settings shortcut |
| **Recite flow** | hidden page → reveal-on-tap glyph area | grade band + sign-off toggle, bottom | close/abort |
| **Muṣḥaf reader** | immutable page, RTL swipe | jump/zoom controls near bottom | overlay toggles |
| **Mutashābihāt** | group browser / drill | "start drill", low | — |
| **Progress** | retention heat-map (scroll) | tap a juz to drill down | export/erase |
| **Onboarding** | one decision per screen | single bottom "Continue" | back at top-start |

- The **bottom band** sits above the M3 `NavigationBar` with `space.4` padding and a `SafeArea` inset, so the primary action clears the home indicator and the nav while staying in the green thumb zone for a right- or left-handed grip. Because the layout is logical-direction, the same template serves all three RTL locales without re-placement.
- The **recite/grade flow** is the ergonomic heart: page hidden at top, reveal-on-tap in the middle, the large grade band and optional teacher sign-off pinned to the bottom ([PRD §12.2](../PRD.md); [07-components.md](07-components.md)). A ḥāfiẓ grades page after page with a single resting thumb — no reach to the top, no grip shift between recitations.
- **Destructive actions** — erase-all-data, abort a session — sit in the hard-to-reach top-start corner and require confirmation, using the thumb-zone difficulty as a natural safety margin rather than as friction-for-friction's-sake.
- One reused template across screens means a fa, ckb, or ar user learns the spatial language once: action is always low, content always scrolls above it.

**Anti-patterns — we will never:**
- Put the primary daily action (begin / grade / continue) in a top corner or behind a top app-bar control out of thumb reach.
- Place a destructive control (erase, delete profile) in the easy-reach bottom zone where a resting thumb could trigger it.
- Use a different action-placement convention per screen; the bottom-action template is uniform so the one-handed habit transfers.
- Add a floating action button that celebrates or gamifies completion — there is no confetti, no reward surface (Pillar 2; [PRD R3, C6](../PRD.md)).

---

## References

- Fitts, P. M. (1954). *The information capacity of the human motor system in controlling the amplitude of movement.* (As summarized.) Fitts's law — movement time, index of difficulty, speed-accuracy tradeoff. https://en.wikipedia.org/wiki/Fitts%27s_law
- Flutter API. *EdgeInsetsDirectional class* — start/end offsets dependent on writing direction; automatic RTL flipping. https://api.flutter.dev/flutter/painting/EdgeInsetsDirectional-class.html
- Flutter API. *ThemeExtension class* — typed custom theme tokens (`copyWith`/`lerp`); one source of truth across light/dark/sepia. https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Hoober, S. (2013). *How Do Users Really Hold Mobile Devices?* UXmatters. 1,333 observations; one-handed 49% / cradled 36% / two-handed 15%; thumb-reach (green/yellow/red) charts. https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php
- Ingram, S. (2016). *The Thumb Zone: Designing for Mobile Users.* Smashing Magazine. ~75% of interactions thumb-driven; keep frequent actions in the easy-reach zone. https://www.smashingmagazine.com/2016/09/the-thumb-zone-designing-for-mobile-users/
- Material Design 3. *Grids & spacing (Understanding layout).* 8dp baseline grid; 4dp increment for fine elements; margins/gutters in 8dp steps. https://m3.material.io/foundations/layout/understanding-layout/spacing
- Material Design 3. *Applying layout / breakpoints* — window size classes: compact (0–599dp), medium (600–839dp), expanded (840–1199dp). https://m3.material.io/foundations/layout/applying-layout
- Material Design 3. *Bidirectionality & RTL* — mirror position, keep metrics; directional components switch sides. https://m3.material.io/foundations/layout/bidirectionality-rtl
- Material Design 3. *Designing for structure (accessibility)* — minimum 48 × 48dp touch target, ≥8dp spacing. https://m3.material.io/foundations/designing/structure
- Material Design 2. *Understanding layout* — 8dp baseline grid, keylines, spacing. https://m2.material.io/design/layout/understanding-layout.html
- Material Design 2. *Responsive layout grid* — consistent margins and gutters on the 8dp grid. https://m2.material.io/design/layout/responsive-layout-grid.html
- material-components/material-components-android. *Issue #1279: why 48 × 48dp* — 48dp ≈ 9mm; WCAG 2.5.5 (≥44px AAA) / 2.5.8 (≥24px AA). https://github.com/material-components/material-components-android/issues/1279
- Nedeljković, U., Jovančić, K., & Pušnik, N. (2020). *You read best what you read most: An eye tracking study.* Journal of Eye Movement Research, 13(2). https://pmc.ncbi.nlm.nih.gov/articles/PMC7963459/
- Nielsen Norman Group. *Fitts's Law and Its Applications in UX.* Larger, closer targets are faster and lower-error. https://www.nngroup.com/articles/fitts-law/
- Valdez, P., & Mehrabian, A. (1994). *Effects of color on emotions.* Journal of Experimental Psychology: General, 123(4), 394–409. (Calm/low-arousal pillar.) https://psycnet.apa.org/record/1995-08699-001
- W3C (2023, updated 2024). *Web Content Accessibility Guidelines (WCAG) 2.2* — SC 2.5.5 Target Size (Enhanced), SC 2.5.8 Target Size (Minimum). https://www.w3.org/TR/WCAG22/
