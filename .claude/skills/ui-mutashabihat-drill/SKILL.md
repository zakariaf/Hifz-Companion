---
name: ui-mutashabihat-drill
description: Build the Hifz app's mutashābihāt discrimination-drill UI — confusable siblings (the whole group, never one alone) presented back-to-back with the distinguishing word(s) highlighted as a coordinate overlay on the immutable glyph page, plus the calm personal confusion-hotspots view. Use whenever building the Mutashābihāt trainer screen, a discrimination drill, the anchor-word highlight, or the "you keep swapping these two" hotspots list.
---

# ui-mutashabihat-drill

The discrimination-drill UI: the standalone **Mutashābihāt** trainer that puts confusable siblings back-to-back (recite branch A, then branch B), draws the **distinguishing word(s)** as a highlight overlay on the faithful glyph page, and surfaces the user's personal **confusion hotspots** ("you keep swapping these two") as calm, actionable information. This screen is the *operational form* of the science: interference is cured by **discriminative contrast (juxtaposition), not more spacing** (`docs/science/05-interference-and-mutashabihat.md` §5).

Two rules outrank every layout goal here. First, a drill **always exercises the whole group, never one sibling alone** — retrieving one twin can suppress the other (retrieval-induced forgetting; `docs/science/05-interference-and-mutashabihat.md` §4). Second, the distinguishing word is shown by **highlighting coordinates over the immutable KFGQPC glyph layer — never by re-typesetting, reshaping, or rebuilding the sacred text** (`docs/PRD.md` §11.2, R1; `docs/science/05-interference-and-mutashabihat.md` §6).

## When to use

Use when building or placing:
- the standalone **Mutashābihāt** trainer screen (browse groups, run drills, view hotspots — `docs/PRD.md` §9.3, §12.4)
- a **discrimination drill** that presents a confusable group back-to-back (branch A → branch B → …)
- the **anchor-word highlight** — the distinguishing phrase drawn over the glyph page as a targeted micro-drill
- the personal **confusion-hotspots** view ("you keep swapping these two") sourced from the user's own logged swaps

Do NOT use this skill for:
- the data/engine layer — the confusables dataset, the `confusion_edge` graph, `expandMutashabihat(...)` co-scheduling, confusion-aware difficulty bumps → use **domain-mutashabihat-system**
- drawing the immutable page itself + the coordinate-overlay painter → use **ui-mushaf-page-view**
- the recite/reveal/grade flow where a **swap-error is actually logged** as a confusion edge → use **ui-recite-grade-flow**
- the page-card row, track chip, or decay indicator on Today/Progress → use **ui-page-card**
- any user-facing copy / methodology claim conscience-check → use **domain-adab-and-religious-integrity**

This screen *composes* the page view and *reads* the engine's data; it owns the drill choreography and the hotspots presentation, nothing more.

## The canonical pattern

1. **The drill exercises the whole group, never one sibling.** A discrimination drill always presents the **contrasting pair (or full group)** back-to-back; the View is forbidden from rendering a single sibling as an isolated review when an unpracticed twin exists. The group arrives as one immutable read model (group members + their distinguishing-word indices) from **domain-mutashabihat-system**; the View iterates members A→B→…, never slicing one out. `docs/science/05-interference-and-mutashabihat.md` §4 (retrieval-induced forgetting → whole-group drills) and §7 Rule ("exercise the whole group, never one sibling alone"); `docs/PRD.md` §9.2.1.

2. **Juxtaposition, not spacing — the siblings sit adjacent in time.** The drill's value is *temporal contrast*: members are shown immediately back-to-back in one session, not spread across screens/days. Do not insert spacing, a results interstitial, or an unrelated page between siblings — that removes the discrimination benefit. `docs/science/05-interference-and-mutashabihat.md` §5 (discriminative-contrast hypothesis; spacing is the enemy of discrimination); `docs/PRD.md` §9.2.1.

3. **Anchor the distinguishing word as a coordinate overlay on the immutable page.** Each member renders through **ui-mushaf-page-view** (its dedicated KFGQPC glyph font), and the distinguishing phrase is drawn as a **highlight rectangle over the glyph layer**, computed from `mutashabih_member.distinguishing_word_index_json` and the bundled word geometry. Never edit, reshape, reflow, or re-typeset the text to build a drill; the marker is coordinates only. `docs/science/05-interference-and-mutashabihat.md` §6 (anchor hinting as overlay); `docs/PRD.md` §9.2.3, §11.2, R1; `docs/design-system/07-components.md` §1 (overlays as coordinate rects over the glyph layer).

4. **Reveal-on-tap, then contrast — retrieval before the answer.** Like the recite flow, each branch is **hidden first**: the ḥāfiẓ recites the continuation from memory, then taps to reveal, *then* the anchor highlight is shown so attention lands on the divergence. Revealing the answer first collapses the retrieval practice. Use `motion.duration.short` for the reveal and the standard easing set — no bounce, no success choreography. `docs/design-system/07-components.md` §5 (reveal-on-tap is retrieval practice; standard short/medium durations, OS Reduce-Motion respected); `docs/science/05-interference-and-mutashabihat.md` §6.

5. **The effortful feel is the point — frame it as a desirable difficulty, never gamify it.** Interleaved contrast *feels harder* than blocked repetition (a metacognitive illusion); copy names that difficulty as the mechanism, calmly, without smoothing it away into something "satisfying." No points, badges, streaks, scores, or confetti on the drill or the sacred text. `docs/science/05-interference-and-mutashabihat.md` §5 (desirable difficulty; never gamify) and §8 (no gamification of the drill); `docs/design-system/07-components.md` Pillar 2 framing (calm, not cute) and §1 anti-patterns (no confetti/streak/badge).

6. **Confusion hotspots are calm information, never a scoreboard.** The hotspots view lists the user's own most-confused pairs ("you keep swapping these two") sourced from `confusion_edge` (read-only here), each row a tap into its drill. It is actionable, calm information — never points, a leaderboard, a guilt mechanic, or a "fix your weaknesses" alarm grid, and a pair is never labeled "cured" or "safe to stop drilling." `docs/PRD.md` §9.3, §12.4; `docs/science/05-interference-and-mutashabihat.md` §8 (no scoreboard; honest "reduces swaps", never "cured"/"safe to drop").

7. **Honest framing — reduces confusion, does not abolish it; the teacher outranks the machine.** Drill copy says discrimination training *reduces* swaps; it never promises elimination, never marks a pair resolved, and always yields to a teacher's correction (a teacher can pin a pair into drills; the app records the verdict, it does not arbitrate recitation). `docs/science/05-interference-and-mutashabihat.md` §8 (bounded, not abolished; teacher sign-off authoritative); `docs/PRD.md` R6, §8.2.

8. **No AI, no microphone, no inference — and the dataset awaits scholarly sign-off.** The group set is a bundled, scholar-reviewed **objective-wording-only** static dataset; nothing is inferred at runtime, no audio is captured, no model judges the swap. Until the dataset has named scholarly sign-off, drill copy stays framed as an aid to revision, a servant to the teacher. `docs/PRD.md` C2 (no AI/ML/audio), R4 (scholar-reviewed, objective wording), §21 (awaiting sign-off); `docs/science/05-interference-and-mutashabihat.md` §3 (objective wording only) and §7 (no model/heuristic; user's own swaps only).

9. **RTL-native across fa/ckb/ar, term-sets not hardcoded English.** The trainer is RTL by geometry (`Directionality.rtl`, `EdgeInsetsDirectional`); page/juz identity uses locale numerals (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar), bidi-isolated; every label ("distinguishing word", "you keep swapping these two") is a transcreated term-set string, wrapping rather than truncating sacred-adjacent vocabulary. `docs/design-system/07-components.md` §1 (RTL by geometry; localized term-sets, never hardcoded English) and §2 (locale numerals, bidi-isolated runs); `docs/PRD.md` §13.3, §13.4.

10. **Live as a feature module with the single write path.** The screen is a dumb `View` + 1:1 `ViewModel` under the `mutashabihat` feature (`docs/PRD.md` §19.2), reading group/hotspot read models via Riverpod and never mutating persisted state directly — any drill-outcome write (e.g. a logged swap) routes through **domain-mutashabihat-system** / **ui-recite-grade-flow**, persist-before-republish. The Mutashābihāt tab sits in the RTL bottom-nav order **Today · Muṣḥaf · Mutashābihāt · Progress · Settings**. `docs/PRD.md` §12 (bottom-nav RTL order), §19.2; see **eng-add-feature-module** and **eng-create-riverpod-store**.

## Do / Don't

| Do | Don't |
|---|---|
| Iterate the whole group A→B→… in one drill | Surface a single sibling as an isolated review when a twin exists |
| Show siblings immediately back-to-back (temporal juxtaposition) | Insert spacing, an interstitial, or an unrelated page between siblings |
| Draw the distinguishing word as a coordinate `Rect` over the glyph layer (via **ui-mushaf-page-view**) | Edit, reshape, reflow, or re-typeset Quran text to build a drill |
| Hide each branch, reveal-on-tap, *then* show the anchor highlight | Reveal the continuation (or the highlight) before a recall attempt |
| Compute the anchor from `distinguishing_word_index_json` + bundled word geometry | Infer "similar verses" or the diverging word with a model/heuristic at runtime |
| Frame contrast as a desirable difficulty, calmly | Smooth away the effort, or add points/badges/streaks/confetti |
| Render hotspots from `confusion_edge` as calm, tappable info | Turn hotspots into a scoreboard, leaderboard, or guilt grid |
| Say drills *reduce* swaps; defer to the teacher | Claim a pair "cured" / "resolved" / "safe to stop drilling" |
| Reference tokens by name: `motion.duration.short`, `type.body`, `color.text.secondary`, `space.*`, `touch.min` | Hardcode hex / 150ms / 48dp / English labels at the call site |
| RTL by geometry, locale numerals bidi-isolated, term-set strings that wrap | Hardcode English labels or let sacred-adjacent vocabulary truncate |

## Checklist

Before this screen is done:

- [ ] Every drill presents the **whole group** (contrasting pair or full group); no code path renders one sibling alone when an unpracticed twin exists.
- [ ] Siblings render **back-to-back in time** with no spacing/interstitial/unrelated page between them (juxtaposition preserved).
- [ ] Each member renders through `ui-mushaf-page-view`'s immutable glyph page; the distinguishing word is a coordinate `Rect` overlay from `distinguishing_word_index_json` — text is never edited, reshaped, reflowed, or re-typeset.
- [ ] Each branch is **hidden → reveal-on-tap → then anchor highlight**; reveal uses `motion.duration.short` + standard easing, no bounce/celebration, OS Reduce-Motion respected.
- [ ] No points/badges/streaks/scores/confetti anywhere on the drill, the anchor, or the hotspots; contrast difficulty is framed calmly as the mechanism, not a defect.
- [ ] Confusion hotspots read `confusion_edge` (read-only in this View) and render as calm, tappable rows; no scoreboard/leaderboard/guilt grid; no "cured" / "safe to stop" / "safe to drop" label anywhere.
- [ ] Copy says drills *reduce* (never abolish) swaps and defers to the teacher; a teacher-pinned pair is honored; the app records, never arbitrates, recitation.
- [ ] No microphone, no audio capture, no AI/ML, no runtime inference; the group set is the bundled scholar-reviewed objective-wording dataset, and copy stays "aid to revision" until named scholarly sign-off (R4, §21).
- [ ] RTL by geometry (`Directionality.rtl`, `EdgeInsetsDirectional`); page/juz numerals in the locale set, bidi-isolated; all labels are transcreated term-set strings that wrap, never truncate, across fa/ckb/ar.
- [ ] Screen is a dumb `View` + 1:1 `ViewModel` in the `mutashabihat` feature, reading group/hotspot read models via Riverpod; any write routes through the single write path; the Mutashābihāt tab keeps RTL bottom-nav order.
- [ ] Works fully offline (no network in the drill path) and passes the muṣḥaf golden with the real per-page font(s).

This screen surfaces *methodology* (how to discriminate confusable wording), never a fiqh ruling, and stays madhhab/sect-neutral; the wording divergence is shown objectively with **zero** bundled tafsīr or translation to "explain the difference". Run **domain-adab-and-religious-integrity** over every drill string and hotspot label.

## Files

- `template.dart` — copy-paste scaffold: a `MutashabihatTrainerScreen` route, a `DiscriminationDrillView` that iterates the whole group back-to-back with reveal-on-tap and the anchor-word overlay (composed over `ui-mushaf-page-view`), a `ConfusionHotspotsView` reading `confusion_edge` as calm rows, RTL `Directionality` + term-set labels, tokens referenced by name only, and `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-mutashabihat-system** (the confusables dataset, the `confusion_edge` graph, `expandMutashabihat(...)` co-scheduling and the difficulty bumps this View reads but never computes), **ui-mushaf-page-view** (the immutable glyph page + coordinate-overlay painter each drill member composes), **ui-recite-grade-flow** (where a swap-error is actually logged as a confusion edge), **ui-page-card** (the track chip + decay indicator on Today/Progress), **domain-adab-and-religious-integrity** (the conscience-check on every drill string, hotspot label, and methodology claim), **eng-add-feature-module** (the `mutashabihat` feature folder, route, and bottom-nav entry), **eng-create-riverpod-store** (the group/hotspot read models and single write path), **eng-rtl-and-bidi-layout** (the RTL/bidi + locale-numeral primitives), **eng-write-dart-test** (the muṣḥaf golden + offline-guard tests for the drill).
