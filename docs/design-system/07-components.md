# 07 — Components

This file specifies the **component library** — the small set of reusable widgets the daily flow is built from: the **daily-session list** and its rows, the **recite/grade flow** (reveal-on-tap, the four-level grade band, the optional teacher sign-off), the **page card** that represents one muṣḥaf page, the **track chip** and **decay indicator** that label it, and the **heat-map cell** on Progress. For each it gives the anatomy, the interaction states, the accessibility contract, and the science note that justifies its shape. It owns **no token values** — it references `color.*` ([03-color-and-themes.md](03-color-and-themes.md)), `type.*` ([04-typography.md](04-typography.md)), `space.*` and `touch.min` ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)), and `motion.*`/`haptic.*` ([06-motion-and-haptics.md](06-motion-and-haptics.md)) by name only — and it builds every component from the restrained Material 3 + Flutter widget set established in [02-material-and-platform-foundations.md](02-material-and-platform-foundations.md). The governing intents are Pillar 3 (*tradition is the interface* — the day looks like sabaq/sabqi/manzil, the algorithm is invisible) and Pillar 2 (*calm, not cute* — no component is ever a gamification surface). Every component is RTL-native across fa/ckb/ar; the heat-map's full visual encoding lives in [08-data-visualization.md](08-data-visualization.md), and the per-locale screen-reader semantics here are enforced by [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md).

## At a glance

| Component | Built from (M3/Flutter) | Owns | Key states |
|---|---|---|---|
| Daily-session list | `ListView` + section headers (Far→Near→New) | — | loading, populated, all-done, catch-up |
| Page-card row | `ListTile` / `Card` (Level 0–1) | — | default, weak, due-today, pulled-forward, done, locked |
| Track chip | `Chip` (non-interactive label) | — | sabaq / sabqi / manzil (static) |
| Decay indicator | custom paint on the row | — | strong → decaying (color + glyph + label) |
| Recite/grade flow | full-screen route + grade band | — | hidden, revealing, grading, signed-off |
| Grade band | row of `FilledButton`s | — | enabled, pressed, disabled-until-revealed |
| Teacher sign-off | `Switch.adaptive` + verdict | — | self (default) / teacher (authoritative) |
| Heat-map cell | `GridView` cell, custom paint | — | strong … faded, weak-overlay, selected |

---

## 1. The daily-session list: a finite, capped, tradition-ordered list — not a feed

**Statement.** The Today screen is a single **finite, capped** list grouped into the three traditional sections — **Far (manzil) → Near (sabqi) → New (sabaq)**, recited old-before-new — and it ends. It is never an infinite feed, never a count-up of "items completed," and it has an explicit, calm **all-done** terminal state. The grouping is the tradition a teacher recognizes; the spaced-repetition ordering *inside* each group is invisible.

**Evidence.**
- Traditional muraja'ah is a three-track day — sabaq (new), sabqi (recent), manzil/dhor (far) — recited **old-before-new**; this is the workflow huffaz and teachers already run on paper, and the engine reproduces its *shape* exactly while only reordering *within* a track ([PRD §6.2, §7.8](../PRD.md); `research/RESEARCH-FINDINGS.md` §1). The day is "recited OLD before NEW (manzil → near → new)" ([PRD §7.8](../PRD.md)).
- A bounded, capped queue is a researched requirement, not a preference: the dominant failure of existing trackers is dumping an overwhelming or rigid pile of due items, and the demanded fix is to "cap daily reviews, prioritize weak ajzaa', and degrade gracefully after missed days" (`research/RESEARCH-FINDINGS.md` §2, §3).
- Calm technology asks for "the smallest possible amount of attention" and a tool that hands over the task and gets out of the way, the opposite of an engagement-farming feed ([Case, 2015, *Principles of Calm Technology*](https://calmtech.com/); [Weiser & Brown, 1996](https://calmtech.com/papers/coming-age-calm-technology)).
- The most-admired Quran UIs are clutter-free and book-like with "no dashboard" — quality here correlates with *removing* UI, not adding counters ([Ayah — App Store](https://apps.apple.com/us/app/ayah-quran-app/id706037876)).

**In practice.**

| Section header | Track | Order within section | Source |
|---|---|---|---|
| Far-revision (manzil) | FAR | weakest-R first, mutashābihāt siblings adjacent | [PRD §7.8](../PRD.md) |
| Near-revision (sabqi) | NEAR | weakest-R first within recent window | [PRD §7.8](../PRD.md) |
| New lesson (sabaq) | NEW | sabaq lines, repeated to sign-off | [PRD §7.8](../PRD.md) |

- Sections render as `ListView` slivers with a quiet header in `type.title`, separated by `space.6`; rows within a section sit `space.2` apart on the `space.*` grid ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)). Section labels are **localized term-sets** (المراجعة البعيدة / مرور دور / مەنزڵ), switchable per region, never hardcoded English ([PRD §13.4](../PRD.md); [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- **States:** *loading* (a brief `surfaceContainerLow` skeleton while the engine builds the day — no spinner theatre); *populated* (the grouped list); *all-done* (a calm closing surface, e.g. "Today's revision is complete," in `color.text.secondary` — informational, never a confetti/celebration moment, per Pillar 2); *catch-up* (after missed days, a gentle banner offering the re-spread plan, never a red overdue pile — [PRD §7.9, §12.2](../PRD.md)).
- The list is **RTL by geometry**: section headers and leading affordances sit at the **start** (right), chevrons at the **end** (left), via `EdgeInsetsDirectional` ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)). The same template serves fa/ckb/ar unchanged; ckb's longer transcreated section labels reflow within the same insets.
- A `Semantics` container announces the list as "Revise today" with section roles, so a screen-reader user hears the three tracks as ordered groups, in their locale ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html); [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Make Today an infinite scroll, a "for you" feed, or an ever-growing inbox; the list is finite, capped to the time budget, and ends ([PRD §12.2](../PRD.md)).
- Celebrate the all-done state with confetti, a streak increment, a badge, or an exclamation mark ([PRD R3, C6](../PRD.md); [Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).
- Reorder the three sections away from manzil → near → new, or hide the tradition behind a generic "due cards" list — the grouping *is* the interface (Pillar 3).
- Render a red shame-pile after missed days instead of the calm catch-up plan ([PRD §7.9](../PRD.md)).

---

## 2. The page card: one muṣḥaf page, the atomic row

**Statement.** The recurring row is a **page card**: it represents exactly one muṣḥaf page (the scheduled unit), and it carries — in the muṣḥaf's own RTL reading order — a **leading** track chip + decay indicator, a **headline** of localized page/juz identity, an optional **supporting** line (next-due or weak hint), and a **trailing** chevron into the recite flow. It is a `ListTile`/`Card` at elevation Level 0–1; it never renders Quran glyphs itself and never shows the algorithm's internal numbers (D/S/R).

**Evidence.**
- The natural scheduling unit is the **page**, because huffaz recite a whole page in one continuous breath-chain and serial recall is order-dependent — you cannot meaningfully surface verse 4 without verses 1–3 as the running cue (`research/RESEARCH-FINDINGS.md` §3; [PRD §7.1](../PRD.md)). One card = one page (604 cards) keeps the count comprehensible.
- Material 3's list-item anatomy is exactly this shape: a **leading** element, a **headline** (primary text), optional **supporting** (secondary) text, and a **trailing** element, in one, two, or three lines ([Material 3: Lists](https://m3.material.io/components/lists/guidelines)). Flutter's `ListTile` realises it directly: "a single fixed-height row that typically contains some text as well as a leading or trailing icon," with `leading` / `title` / `subtitle` / `trailing` slots ([Flutter: ListTile class](https://api.flutter.dev/flutter/material/ListTile-class.html)).
- Reverence-first means flat: cards and list items sit at Level 0–1 with no decorative shadow, so a page is never veiled in brand color or dramatized ([Material 3: Elevation tokens](https://m3.material.io/styles/elevation/tokens); material3 research note, implication 3).
- The algorithm is demoted to a silent page-selector; users see named cycles and traditional state, never a "retention slider" or raw stability number ([PRD §2, §7](../PRD.md)).

**In practice.**

| Slot (logical) | Position (RTL) | Content | Token |
|---|---|---|---|
| Leading | start (right) | track chip (§3) + decay indicator (§4) | `space.2` gap |
| Headline | center | localized "Page ۲۵۳ · Juz ۱۳" (locale numerals) | `type.body` |
| Supporting | center, below | optional: "next: in ۳ days" or "weak line ۷" | `type.caption`, `color.text.secondary` |
| Trailing | end (left) | chevron → recite flow | mirrors automatically |

- **States** drive only *border/surface emphasis and the decay indicator*, never the page art: *default* (`surface`); *weak* (`weak_flag` true → a quiet `color.semantic.warning` outline + a weak hint in supporting text, never an alarm); *due-today* (in the day's list by definition); *pulled-forward* (an SR pull-forward — shown identically to any due item, with no "the algorithm chose this" exposure); *done* (this session — a checked, dimmed row, removable); *locked* (`manual_lock` — a teacher pinned it; a small lock affordance signals the human override, [PRD §7.4](../PRD.md)).
- Numerals are rendered in the locale set — Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar — and the "Page N · Juz M" string keeps mixed Latin/numeral runs bidi-isolated so the row never breaks alignment ([PRD §13.3](../PRD.md); [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- The whole row is one ≥48dp `touch.min` hit target into the recite flow; the chip and indicator inside it are *labels*, not separate tappable controls, so there is one unambiguous tap per row (recognition over recall — [NN/g: 10 Usability Heuristics #6](https://www.nngroup.com/articles/ten-usability-heuristics/); [05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- `Semantics` reads the row as one labelled item: "Page 253, Juz 13, far-revision, weak" in the user's locale, so the leading glyphs are *announced as words* rather than as decorations ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html); [WCAG 2.2 SC 1.3.1](https://www.w3.org/TR/WCAG22/)).

**Anti-patterns — we will never:**
- Render Quran glyphs inside the row, or re-typeset any āyah for a preview — the muṣḥaf is shown only in the immutable reader/recite surface ([PRD R1, §11.2](../PRD.md); Pillar 1).
- Surface the engine's internal D/S/R, a percentage "score," or "safe to drop" on a card; state is shown as track + decay, never as a number that invites gaming ([PRD §7.12](../PRD.md)).
- Make the track chip or decay indicator a second tappable target inside the row; one row, one action.
- Raise the card on a decorative shadow or tint it with brand color to "pop" — Quran content stays flat and calm.

---

## 3. The track chip: the visible name of the tradition

**Statement.** A small, **non-interactive** chip labels each card's track in the user's own vocabulary — **sabaq / sabqi / manzil** (localized) — using shape and a tradition-tied color family, never a streak counter or a "level." It is the single most important carrier of Pillar 3: the chip is how the invisible lifecycle phase becomes the familiar word a teacher uses.

**Evidence.**
- Material 3 chips are "compact components representing an input, attribute, or action"; the **assist/filter/input/suggestion** taxonomy is for *interactive* chips ([Material 3: Chips](https://m3.material.io/components/chips/guidelines)). Our track chip is the **attribute/label** use — display-only — so it deliberately omits the interactive affordances (no trailing remove icon, no selected state).
- The three tracks are not three algorithms but three **lifecycle phases of one page card**, distinguished by stability band; the label is the only place this phase is named to the user ([PRD §6.2, §7.4](../PRD.md); `research/RESEARCH-FINDINGS.md` §7).
- The vocabulary is **regional** and must be swappable — the ar/fa/ckb term-sets differ and await native + scholarly review — so the chip text is a string resource, never a baked-in glyph ([PRD §13.4, §21](../PRD.md)).
- Color must not be the *only* signal (color-blind safety): every chip pairs its color family with its text label ([WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)).

**In practice.**

| Track | Default label (ar) | Color family | Shape note |
|---|---|---|---|
| FAR (manzil) | المراجعة البعيدة / المنزل | `color.accent.green` family (the maintenance core) | rounded, calm |
| NEAR (sabqi) | المراجعة القريبة | a secondary neutral-tinted family | rounded |
| NEW (sabaq) | السبق / الحفظ الجديد | a tertiary neutral-tinted family | rounded |

- The chip is rendered as a label-only `Chip` (or a styled `Container` with the same metrics) at the row **start**, before the decay indicator, with `space.1` between glyph and text; it inherits `type.label` and never exceeds the row's vertical rhythm ([04-typography.md](04-typography.md); [05-layout-spacing-touch.md](05-layout-spacing-touch.md)). All concrete colors are owned by [03-color-and-themes.md](03-color-and-themes.md).
- Because the label is a term-set string, switching region or locale re-labels every chip with no layout change; ckb's longer terms (پێداچوونەوەی دوور) reflow within the chip, and the chip wraps rather than truncating sacred-adjacent vocabulary.
- For screen readers the chip is part of the row's `Semantics` label ("…far-revision…"), not a separately focusable node — it informs, it is not operated ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)).

**Anti-patterns — we will never:**
- Make the chip interactive (filter/remove/select) on a card; it is a label, and tapping the row begins recitation, not a filter.
- Encode the track by color alone, or use alarming red for any track — manzil green is *maintenance*, not danger ([WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/); [08-data-visualization.md](08-data-visualization.md)).
- Add a count, XP, or "streak" to the chip, or stack badges on it (Pillar 2; [PRD R3](../PRD.md)).
- Hardcode the track name in English or any single dialect; the term-set is regional and reviewed ([PRD §13.4, §21](../PRD.md)).

---

## 4. The decay indicator: honest, redundant, never an alarm

**Statement.** Each card carries a small **decay indicator** that shows how solid the page is — strong, holding, or decaying — using a **single-hue lightness ramp plus a glyph plus a text label**, so the same fact is encoded three ways. It is the per-row echo of the retention heat-map: it makes invisible decay visible without ever framing a page as "safe to drop" or shaming the user.

**Evidence.**
- "Nothing decays silently" is a release-blocking contract: the app surfaces decay honestly and is **forbidden from ever telling a ḥāfiẓ a page is "safe to drop"** ([PRD §7.12, R3](../PRD.md)).
- The rainbow/jet colormap introduces false boundaries and is "still considered harmful," so the honest encoding is a **sequential single-hue lightness ramp** — green receding to a muted neutral, never a red scoreboard ([Borland & Taylor, 2007](https://doi.org/10.1109/MCG.2007.323435); [08-data-visualization.md](08-data-visualization.md)).
- Color must never be the sole carrier of meaning — pair it with text/shape — both for color-blind users and for the non-text-contrast bar ([WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)).
- Honest competence feedback (this page solid, that one decaying) is the *one* form of feedback the motivation meta-analysis shows **helps** intrinsic motivation, where badges/points undermine it ([Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).

**In practice.**

| Level | Color token (owned by 03) | Glyph | Label (localized) |
|---|---|---|---|
| Strong | `color.heatmap.strong` | filled / solid | "solid" |
| Holding | mid ramp step | half | "holding" |
| Decaying | `color.heatmap.faded` | hollow / receding | "needs revision" |

- Rendered as a tiny custom-painted swatch + glyph at the row start (after the track chip), with the text label available in the supporting line and always in the `Semantics` description; the swatch never exceeds `space.4` so it stays a quiet indicator, not a gauge ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- The level derives from the engine's retrievability `R` (rolled up min-leaning, like juz health) but the **number is never shown** — only the three calm bands, so the user reads "needs revision," not "R = 0.83" ([PRD §10.3](../PRD.md)).
- Identical encoding across light/sepia/dark themes and all three locales; the label is a term-set string so "needs revision" transcreates to fa/ckb/ar rather than translating literally ([11-voice-and-tone.md](11-voice-and-tone.md); [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Show decay as red/amber "danger," a downward-trend arrow, or a falling-grade animation; decay is muted neutral, calmly stated ([08-data-visualization.md](08-data-visualization.md)).
- Rely on color alone — the glyph and label always accompany it ([WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)).
- Ever render a "safe to drop," "mastered," or "you can stop revising this" state — the indicator only ranges from solid to needs-revision ([PRD §7.12](../PRD.md)).
- Expose the raw retrievability number or a percentage that could become a score to chase ([PRD §7.12](../PRD.md)).

---

## 5. The recite/grade flow: reveal-on-tap, then a four-level grade

**Statement.** Tapping a page opens a **full-screen recite flow**: the page is **hidden**, the ḥāfiẓ recites from memory, then **reveals line-by-line on tap** to self-check, marks the lines where they stumbled, and grades the page with a **four-level band — Again / Hard / Good / Easy**. The grade band stays disabled until at least one reveal, so a grade always follows an actual recall attempt. No audio, no microphone, no AI — recall is judged by the human, exactly as talaqqī does.

**Evidence.**
- The PRD specifies the flow verbatim: "page hidden → recite from memory → reveal-on-tap → mark stumble lines → grade (Again/Hard/Good/Easy) → next," with an optional teacher sign-off toggle in-flow ([PRD §12.2, §8.1](../PRD.md)).
- Reveal-on-tap is a **retrieval-practice** device: hiding the text forces effortful recall before the answer is shown, the mechanism that builds durable memory; revealing first would collapse it into mere re-reading (`research/RESEARCH-FINDINGS.md` §3). The four FSRS grades map to G=1..4 and drive the stability/difficulty update ([PRD §7.7](../PRD.md); `research/RESEARCH-FINDINGS.md` §3).
- **Where** you stumbled (line indices) is "the most valuable signal in hifz" — richer than a binary pass/fail — so the flow captures stumble lines, not just a verdict ([PRD §6.3, §8.1](../PRD.md)).
- The four grades are a `FilledButton` row — M3's elevation-less emphasis button for a primary action — kept large and low in the thumb zone (≥56dp tall, ≥48dp wide, `space.2` apart) because a mis-tap on a sacred-text grade is costly ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration); [05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- Error prevention beats error messages: gating the grade until a reveal, and previewing before commit, are textbook heuristics, and so is "user control and freedom" — a clearly marked exit/undo from a mistaken grade ([NN/g: 10 Usability Heuristics #3 and #5](https://www.nngroup.com/articles/ten-usability-heuristics/)).

**In practice.**

| Stage | Surface | Controls (thumb zone) | Motion |
|---|---|---|---|
| Hidden | top: immutable page, masked | "I have recited" / first reveal | `motion.duration.short` reveal |
| Revealing | reveal lines on tap; tap stumble lines | line hit-areas ≥48dp tall | per-line fade, no bounce |
| Grading | grade band enabled | Again / Hard / Good / Easy | `motion.duration.short3`–`medium2` advance |
| Signed-off | optional teacher verdict (§7) | `Switch.adaptive` + verdict | none celebratory |

- The grade is **suggested** from the stumble count but stays user-confirmable, so honesty is nudged without being coerced; a sacred-text guard caps the grade at *Hard* when a dropped/added/swapped word is marked — a page with a missed word is never "Good" ([PRD §7.7, §8.1](../PRD.md)).
- **Stumble-line tapping** maps a tap to a line index by expanding each glyph line's *hit area* to ≥48dp with transparent padding — the tap target grows, the immutable glyph layer is never touched, and the error position is drawn as an overlay of coordinates, never by re-typesetting ([PRD §8.1, §11.2](../PRD.md); [05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- Page-turn and reveal use **standard easing, short/medium durations** only; the page→recite hero is the *only* place an `emphasized` curve with a `long` duration is permitted, and even that is calm — no overshoot, no confetti, no success chime ([06-motion-and-haptics.md](06-motion-and-haptics.md); material3 research note, implication 6). The OS Reduce-Motion flag is respected.
- The grade band is RTL: the four buttons read right-to-left in the user's verb set ("needed help / minor mistakes / recited clean / effortless"), localized and bidi-safe ([PRD §6.3, §13.4](../PRD.md)). A `Semantics` label states each button's verdict and its consequence ("again — review again soon") so a non-visual user grades confidently ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html); [WCAG 2.2 SC 1.3.1](https://www.w3.org/TR/WCAG22/)).
- A just-submitted grade is **undoable** (a brief, non-intrusive "undo" affordance) so a fat-fingered tap on a sacred-text grade is recoverable without dread ([NN/g #3](https://www.nngroup.com/articles/ten-usability-heuristics/)).

**Anti-patterns — we will never:**
- Reveal the page before a recall attempt, or let the grade band be tapped before a reveal — that destroys retrieval practice and invites dishonest grading ([PRD §8.1](../PRD.md); `research/RESEARCH-FINDINGS.md` §3).
- Add a microphone, recording, speech-to-text, or any automatic mistake detection — recall is judged by a human, always ([PRD C2, §8.3, R5](../PRD.md)).
- Celebrate a Good/Easy grade with confetti, a chime, a streak bump, or haptic fanfare; advancing to the next page is quiet ([PRD R3, C6](../PRD.md); [06-motion-and-haptics.md](06-motion-and-haptics.md)).
- Mark a page "Good" when a word was dropped/added/swapped — the sacred-text guard caps it at Hard ([PRD §7.7](../PRD.md)).
- Make a sacred-text grade irreversible with no undo, or hide the exit/abort out of thumb reach ([NN/g #3](https://www.nngroup.com/articles/ten-usability-heuristics/); [05-layout-spacing-touch.md](05-layout-spacing-touch.md)).

---

## 6. Grade band & component states: one explicit, predictable state model

**Statement.** Every interactive component declares an explicit set of **interaction states** — enabled, pressed, disabled, focused, selected — drawn with M3 **state layers** over the role color, never with ad-hoc opacity. The grade band is the canonical case: clearly *enabled* only after a reveal, with a visible *pressed* state, a visible *focus* ring, and a *disabled* (pre-reveal) state that reads as waiting, not broken.

**Evidence.**
- Material 3 defines a uniform state model — enabled, disabled, hover, focus, pressed, dragged — expressed as **state layers** (a translucent overlay of the on-color) so every component signals interactivity the same way ([Material 3: Interaction states](https://m3.material.io/foundations/interaction/states/overview)). Flutter components read these from `ColorScheme` roles ([Flutter: Migrate to Material 3](https://docs.flutter.dev/release/breaking-changes/material-3-migration)).
- A **visible focus indicator** is a WCAG 2.2 AA requirement (SC 2.4.7 Focus Visible), so keyboard/switch-control and external-keyboard users can see where they are ([WCAG 2.2 SC 2.4.7](https://www.w3.org/TR/WCAG22/)).
- "Visibility of system status" and "error prevention" are core heuristics: a disabled-until-revealed grade band *shows* the user the system's state and prevents the premature-grade error ([NN/g #1 and #5](https://www.nngroup.com/articles/ten-usability-heuristics/)).
- Where a grade is genuinely a single mutually-exclusive choice, `SegmentedButton` is the M3 control — "a Material button that allows the user to select from a limited set of options," single-selection by default ([Flutter: SegmentedButton class](https://api.flutter.dev/flutter/material/SegmentedButton-class.html)) — but the four large `FilledButton`s win here for thumb-zone size (§5).

**In practice.**

| State | Visual (via tokens) | Where it matters |
|---|---|---|
| Enabled | role color, full | grade band after reveal; row tap |
| Pressed | + M3 pressed state layer | every tap gives quiet feedback |
| Disabled | dimmed role + no state layer | grade band before reveal |
| Focused | visible focus ring (`color.outline`) | external keyboard / switch control |
| Selected | filled emphasis | teacher verdict, settings toggles |

- State layers and the focus ring use **owned `color.*` roles** only ([03-color-and-themes.md](03-color-and-themes.md)); this file sets *which state each component exposes*, never the hex. Pressed feedback is visual (state layer) and, at most, a single restrained haptic tick — never a celebratory pattern ([06-motion-and-haptics.md](06-motion-and-haptics.md)).
- The disabled grade band is styled as **waiting, not error**: a calm dimmed band with a quiet hint ("reveal to grade"), so the user reads intent, not a bug (visibility of system status — [NN/g #1](https://www.nngroup.com/articles/ten-usability-heuristics/)).
- States are mirrored correctly in RTL (the focus ring and state layer follow the component, not a physical side) and announced to assistive tech via `Semantics` flags (enabled/disabled/selected), so the state model is perceivable non-visually too ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html); [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Invent per-component opacity or color for states instead of M3 state layers over a role color ([Material 3: Interaction states](https://m3.material.io/foundations/interaction/states/overview)).
- Ship a control with no visible focus indicator ([WCAG 2.2 SC 2.4.7](https://www.w3.org/TR/WCAG22/)).
- Let a disabled state read as a crash or a dead button — it is visibly *waiting*, with a hint ([NN/g #1](https://www.nngroup.com/articles/ten-usability-heuristics/)).
- Use a pressed/selected state as a reward surface (a glow, a pop, a sparkle); state feedback is functional and quiet (Pillar 2).

---

## 7. The teacher sign-off control: the human override, made first-class

**Statement.** The recite flow carries an optional **teacher sign-off** control — an `.adaptive` toggle that switches the grade's source from **self** (default, lower confidence) to **teacher** (authoritative). A teacher verdict overrides self-rating and algorithmic state for that page; the control is visibly distinct so it is never confused with a self-grade, honoring talaqqī as a first-class input the app serves and never replaces.

**Evidence.**
- Teacher sign-off is a release-blocking invariant: "a teacher sign-off always supersedes self-rating and algorithmic state for that page" ([PRD §7.12, R6](../PRD.md)). Self-rating carries `sourceConfidence ≈ 0.5`; a present teacher carries `1.0` and can graduate/demote a page ([PRD §8.1, §8.2](../PRD.md)).
- Gamified accountability is felt as a hollow substitute for the talaqqī relationship — a human teacher "provides accountability that streaks and badges can only imitate" — so the design *defers* to the teacher rather than faking accountability ([Tarteel — App Store reviews](https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396); islamic-app-design-patterns research note §5).
- Controlling, commanding language provokes reactance; autonomy-supportive framing persuades — so the sign-off is framed as an aid the teacher operates, never as the app asserting authority over the qārī ([Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x); README Pillar 7).
- `Switch.adaptive` renders the native iOS switch on iOS while keeping our `ColorScheme` colors, giving platform-correct feel without forking the UI ([Flutter: Adaptive & responsive design](https://docs.flutter.dev/ui/adaptive-responsive); material3 research note, implication 8).

**In practice.**
- The control is a labelled `Switch.adaptive` ("Teacher present") pinned in the grade band's lower region; flipping it changes the verdict's **source**, optionally captures a teacher label, and writes `source = teacher` to the append-only `review_log` — a local audit trail honoring the *sanad* idea with no server ([PRD §8.2, §10.2](../PRD.md)).
- A teacher-sourced grade is **visually marked** on the resulting card/log (a distinct, calm affordance) so self and teacher inputs are never conflated; a teacher verdict can set/clear weak-flags and graduate/demote where a self-grade cannot ([PRD §8.2](../PRD.md)).
- In **local halaqa mode**, a teacher switches between student profiles on one device to sign off each in turn; the control and profile switcher are device-local, never a server dashboard ([PRD §8.2, §15.3](../PRD.md)).
- The toggle is a ≥48dp row with a `Semantics` label and state ("Teacher present, off"), localized; its copy stays autonomy-supportive in fa/ckb/ar ("for your teacher to confirm"), never commanding ([11-voice-and-tone.md](11-voice-and-tone.md); [Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html)).

**Anti-patterns — we will never:**
- Let an algorithmic or self-grade silently override a teacher sign-off; the teacher always wins ([PRD §7.12, R6](../PRD.md)).
- Frame the app as the authority ("the app says you passed") rather than the teacher; copy defers to the human chain ([Miller et al., 2007](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x)).
- Fake teacher-grade accountability with streaks/badges in place of the real talaqqī signal (islamic-app-design-patterns research note §5; [PRD R3](../PRD.md)).
- Require a network/account for sign-off, or send the review log anywhere; it is local and append-only ([PRD C1, §8.2](../PRD.md)).

---

## 8. The heat-map cell: a calm, redundantly-encoded square — never a scoreboard tile

**Statement.** On Progress, the whole-Quran retention map is built from one repeated component: a small **heat-map cell** (one per page or juz) painted on a single-hue lightness ramp, **redundantly encoded** (color + a value/glyph + an accessible label), tappable to drill into detail. The cell is the emotional hook ("keep your Quran green") expressed honestly; it is never a streak tile, never a red alarm grid, never a competitive score.

**Evidence.**
- The full visualization rules (ramp, VSUP-style muting of uncertain cells, min-leaning juz roll-up, redundant encoding) are owned by [08-data-visualization.md](08-data-visualization.md); this section specifies only the **cell as a component**.
- Sequential single-hue is the honest encoding; rainbow/jet is "still considered harmful," so a cell ranges green → muted neutral, never green→red ([Borland & Taylor, 2007](https://doi.org/10.1109/MCG.2007.323435)).
- Every cell must satisfy non-color encoding (SC 1.4.1) — color is paired with a number/label so a color-blind user reads health without hue ([WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)).
- Juz health uses a **min-leaning** aggregate — one weak page is what fails you in ṣalāh, so the roll-up surfaces the weakest link rather than an average that hides it ([PRD §10.3](../PRD.md)).
- The map informs and never becomes a streak; a calm, non-shaming retention map replaces the entire extrinsic-reward apparatus ([PRD R3, §12.5](../PRD.md); [Deci, Koestner & Ryan, 1999](https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627)).

**In practice.**
- Cells are laid out in a `GridView` with `space.1` (4dp) gaps and a `space.4` outer margin ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)); the grid reads in muṣḥaf order (juz 1 at the start/right in RTL) so the spatial map matches the book a ḥāfiẓ carries.
- Each cell's fill is a `color.heatmap.*` step (owned by 03); a weak-page overlay (a small marker) and the cell's locale-numeral label make the encoding triple-redundant, and tapping a juz cell drills to its pages ([PRD §12.5](../PRD.md)).
- A cell exposes a `Semantics` label — "Juz 13: needs revision, weakest page 253" in the user's locale — and a *selected* state with a visible focus ring when navigated, so the map is fully operable non-visually ([Flutter: Semantics class](https://api.flutter.dev/flutter/widgets/Semantics-class.html); [WCAG 2.2 SC 2.4.7](https://www.w3.org/TR/WCAG22/)).
- Identical cell rendering across light/sepia/dark; the ramp is re-toned per theme but the encoding and the min-leaning roll-up are invariant ([08-data-visualization.md](08-data-visualization.md)).

**Anti-patterns — we will never:**
- Color cells on a green→red (jet/rainbow) danger scale, or use a saturated alarm red anywhere on the map ([Borland & Taylor, 2007](https://doi.org/10.1109/MCG.2007.323435); [08-data-visualization.md](08-data-visualization.md)).
- Encode health by color alone — every cell carries a label/value for color-independence ([WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)).
- Average a juz so one weak page hides behind strong neighbors — the roll-up is min-leaning ([PRD §10.3](../PRD.md)).
- Turn the map into a streak calendar, a leaderboard tile, or a "completion %" trophy to chase ([PRD R3, §12.5](../PRD.md)).

---

## References

- Borland, D., & Taylor, R. M., II. (2007). Rainbow Color Map (Still) Considered Harmful. *IEEE Computer Graphics and Applications*, 27(2), 14–17. https://doi.org/10.1109/MCG.2007.323435
- Case, A. (2015). *Calm Technology: Principles and Patterns for Non-Intrusive Design* (O'Reilly) / *Principles of Calm Technology* — "technology should require the smallest possible amount of attention." https://calmtech.com/
- Deci, E. L., Koestner, R., & Ryan, R. M. (1999). A Meta-Analytic Review of Experiments Examining the Effects of Extrinsic Rewards on Intrinsic Motivation. *Psychological Bulletin*, 125(6), 627–668. https://psycnet.apa.org/doi/10.1037/0033-2909.125.6.627
- Flutter API. *Adaptive & responsive design* — `.adaptive` constructors (`Switch.adaptive`) keep `ColorScheme` colors while matching platform convention. https://docs.flutter.dev/ui/adaptive-responsive
- Flutter API. *ListTile class* — "a single fixed-height row… leading/title/subtitle/trailing"; used in `ListView`s. https://api.flutter.dev/flutter/material/ListTile-class.html
- Flutter API. *SegmentedButton class* — "a Material button that allows the user to select from a limited set of options"; single-selection by default. https://api.flutter.dev/flutter/material/SegmentedButton-class.html
- Flutter API. *Semantics class* — "annotates the widget tree with a description of the meaning of the widgets," used by assistive technologies. https://api.flutter.dev/flutter/widgets/Semantics-class.html
- Flutter. *Migrate to Material 3* — `FilledButton` (elevation-less emphasis); components read state/colors from `ColorScheme` roles; `useMaterial3` default. https://docs.flutter.dev/release/breaking-changes/material-3-migration
- Material Design 3. *Chips* — "compact components representing an input, attribute, or action"; assist/filter/input/suggestion taxonomy. https://m3.material.io/components/chips/guidelines
- Material Design 3. *Elevation tokens* — levels 0–5; shadow vs tonal elevation. https://m3.material.io/styles/elevation/tokens
- Material Design 3. *Interaction states (overview)* — enabled/disabled/hover/focus/pressed/dragged; state layers. https://m3.material.io/foundations/interaction/states/overview
- Material Design 3. *Lists (guidelines)* — list-item anatomy: leading element, headline, supporting text, trailing element; one/two/three-line variants. https://m3.material.io/components/lists/guidelines
- Miller, C. H., Lane, L. T., Deatrick, L. M., Young, A. M., & Potts, K. A. (2007). Psychological Reactance and Promotional Health Messages. *Human Communication Research*, 33(2), 219–240. https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1468-2958.2007.00297.x
- Nielsen, J. (1994, updated). *10 Usability Heuristics for User Interface Design* — #1 Visibility of system status, #3 User control and freedom, #5 Error prevention, #6 Recognition rather than recall. Nielsen Norman Group. https://www.nngroup.com/articles/ten-usability-heuristics/
- Tarteel — *AI Quran Memorization* (App Store listing and reviews) — reviewers note a teacher "provides accountability that streaks and badges can only imitate." https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396
- W3C (2023, updated 2024). *Web Content Accessibility Guidelines (WCAG) 2.2* — SC 1.3.1 Info and Relationships; SC 1.4.1 Use of Color; SC 2.4.7 Focus Visible; SC 2.5.5/2.5.8 Target Size. https://www.w3.org/TR/WCAG22/
- Weiser, M., & Brown, J. S. (1996). *The Coming Age of Calm Technology.* Xerox PARC. https://calmtech.com/papers/coming-age-calm-technology
- Ayah — Quran App (Abdullah Bajaber). App Store listing — "no visual clutter," "no dashboard," mimics a physical muṣḥaf. https://apps.apple.com/us/app/ayah-quran-app/id706037876
