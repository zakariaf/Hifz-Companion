---
name: ui-destructive-confirm
description: Build or modify the Hifz app's irreversible-destructive-action confirmation — the erase-all-data / wipe-a-profile double-confirmation flow that states the concrete consequence, makes the safe (cancel) choice visually primary, and uses thumb-zone difficulty as the safety margin. Use whenever building an erase-all / wipe / delete-profile / irreversible action, a two-step "type to confirm" or "hold to confirm" gate, or any consequence dialog for an action that cannot be undone — and to be sure it is an honest safeguard, never an obstruction dark pattern.
---

# ui-destructive-confirm

The confirmation gate for an **irreversible** destructive action — erase-all-data, wipe a profile, abort-and-discard. Because there is **no server and no soft-delete**, "erase" actually erases: nothing is recoverable elsewhere ([PRD §16](../../docs/PRD.md) right-to-be-forgotten by construction). That truthfulness is the whole design problem: the gate must make the consequence *concrete and felt* before the user commits, make the **safe (cancel) path the easy, visually-primary one**, and use the thumb-zone's natural difficulty as the safety margin — without ever sliding into the *obstruction* / *interface-interference* dark patterns the rest of the industry uses to trap users in the opposite direction.

This control is the UI face of [PRD §16](../../docs/PRD.md) (Erase: one action wipes all local data) and [`docs/design-system/10-privacy-and-trust-ux.md`](../../docs/design-system/10-privacy-and-trust-ux.md) §8 (real erasure, stated honestly) and §9 (safe default visually primary, consequential action one deliberate step away). It is a *safeguard*, not a deterrent: the goal is that a user who means it can erase in two clear steps, and a user who tapped by accident is caught — never that erasing is made artificially painful.

## When to use

Use when building or placing:
- the **erase-all-data** action and its confirmation (wipe every profile, card, `review_log`, config on this device)
- a **wipe / delete a single profile** confirmation, or **abort-and-discard** a session/draft
- any **double-confirmation** gate (a second confirm step, a "type ERASE to confirm", a "hold to confirm") for an action that **cannot be undone**
- the **concrete-consequence text** ("This permanently erases all hifz records for everyone on this device — it cannot be undone") that an irreversible action must show before it commits

Do NOT use this skill for:
- the **export / `.hifzbackup` file format**, encryption envelope, and replace-vs-merge restore semantics → use **domain-backup-format**
- placing the **erase / export entry points** inside the grouped Settings surface, or a reversible single-choice preference → use **ui-settings-picker**
- the **profile list / create / rename / switch** affordance the wipe-profile action sits beside → use **ui-profile-switcher**
- the actual **transactional wipe write** (the repository method that deletes the rows) and its app-scope provider → use **eng-create-riverpod-store**
- the **schema / DAO** the wipe operates over (and the append-only `review_log` it must not "soft-delete") → use **eng-add-persisted-model**
- the **plain-language, empathy-then-consequence wording** in fa/ckb/ar (and its banned-phrase lint) → use **eng-add-localized-string** + **domain-adab-and-religious-integrity**

If the action can be undone, or only re-renders data (a calendar/theme switch), it is **not** a destructive confirm — it is a reversible **ui-settings-picker** change and needs no consequence gate.

## The canonical pattern

1. **Erasure is real and irreversible — say so concretely, both halves.** Because there is no server and no soft-delete, the confirmation states the *full* consequence in plain words: *what* is destroyed (all profiles / this profile's records), *that it is permanent*, and *that nothing is recoverable elsewhere* — a guarantee most apps cannot truthfully make, and the responsibility that comes with it. Never an empty "Are you sure?". `docs/design-system/10-privacy-and-trust-ux.md` §8 ("Erasure is real, immediate, honest"; "because there is no server, nothing is recoverable elsewhere"; state both the power and the responsibility) + `docs/PRD.md` §16 (one action wipes all local data; right-to-be-forgotten by construction). Wording itself is **eng-add-localized-string** / **domain-adab-and-religious-integrity**.

2. **The safe choice is the easy, visually-primary one; the destructive choice is one deliberate step away.** Follow warning-science: **Cancel / Keep my data is the visually-primary `FilledButton`**, and the destructive action is a plainer, secondary affordance (text/outlined) the user must deliberately reach — never the default focused button, never the brightest one. This is the protective-default rule applied to a one-off action. `docs/design-system/10-privacy-and-trust-ux.md` §9 (safe option is the default *and* visually primary; the consequential action is one deliberate step away, never hidden; one decision per screen) — Felt et al. 2015 safe-choice promotion.

3. **Double-confirm proportional to the blast radius — a second deliberate gesture, not friction-for-friction.** A whole-device erase warrants a stronger second step (a second confirm screen, or a *type the word* / *hold-to-confirm* gesture) so it cannot fire on a single stray tap; a single-profile wipe may need only the one consequence dialog. Use the *minimum* step that defeats an accidental tap — never escalate beyond it. `docs/design-system/10-privacy-and-trust-ux.md` §11 (avoid **obstruction** — destructive actions are clear, never artificially hard) + §9 (consequential action one deliberate step away); thumb-zone difficulty as the margin per `docs/design-system/05-layout-spacing-touch.md` §5.

4. **Place the destructive control in the hard-to-reach top corner; keep the safe action in the thumb band.** Inside the confirmation, the **safe (Cancel) action lives low in the green thumb band**; the destructive trigger and its entry point sit in the harder-to-reach **top-start corner**, using thumb-zone difficulty as a *natural* safety margin — never as manufactured friction. Logical-direction placement, so the same layout serves fa/ckb/ar. `docs/design-system/05-layout-spacing-touch.md` §5 ("destructive actions sit in the hard-to-reach top-start corner and require confirmation, using thumb-zone difficulty as a natural safety margin"; "never place a destructive control in the easy-reach bottom zone where a resting thumb could trigger it").

5. **Lead with understanding, end with a real choice — never command, threaten, or shame.** The consequence copy opens calmly and states the honest fact, then leaves the choice with the user; it never uses the loss/fear of forgetting as leverage ("you'll lose your hifz"), never commands ("you must"), and never shames. The two options are framed as equals the user owns. `docs/design-system/11-voice-and-tone.md` §4 (lead with empathy, not blame; never use the spiritual stakes as leverage) + §6 (phrase as invitation/information, never command — no "must/should/have to"). Enforced via **domain-adab-and-religious-integrity** and the banned-phrase lint.

6. **No dark patterns — this is the most-tempting place to obstruct, and we refuse.** The gate is audited against all five dark-pattern strategies: no **obstruction** (the destructive path is clear, not a maze), no **interface interference** (the destructive button is never disguised as the safe one, and Cancel is never the buried/greyed option), no **sneaking** (nothing hidden about what is erased), no **forced action** (no account/upgrade/unrelated step gates erase), no **nagging**. The asymmetry only ever protects the *user's* data, never the app's retention. `docs/design-system/10-privacy-and-trust-ux.md` §11 (the five strategies as a release gate: obstruction/interface-interference/sneaking/forced-action/nagging = defects) + §8 (never a "soft delete" that secretly retains; never hide or gate erase).

7. **The destructive write goes through the single write path, transactionally — and the `review_log` is truly deleted, not soft-deleted.** On confirm, the wipe is one transactional repository call (persist/delete then republish) through a store method — never a view mutating persisted state; erasing the append-only `review_log` means *deleting its rows*, never a hidden "deleted" flag that retains data. `docs/design-system/10-privacy-and-trust-ux.md` §8 (never a soft-delete that secretly retains data; "delete" actually deletes) — route the write via **eng-create-riverpod-store** (single write path, persist-before-republish), over the schema/DAO of **eng-add-persisted-model**.

8. **Confirming erases quietly — no celebration, no shaming animation, a single gentle caution at most.** Completing an erase fires **no** celebratory motion or haptic (there is no `motion.celebrate.*` and no "success" haptic), and equally no alarming red flourish; if a tactile cue is warranted at the warning step it is a single `haptic.warning` (light, paired with the warning state) that never repeats or escalates. The result is a calm state change and a factual confirmation. `docs/design-system/06-motion-and-haptics.md` §2 (no celebratory motion anywhere — none on completion of anything) + §4 (`haptic.warning` is light, single, informational; no "success"/reward haptic; never escalate to pressure).

9. **Reduce-motion and RTL-native, fully semantic.** Any transition into/out of the confirmation obeys `MediaQuery.disableAnimations` (cross-fade or instant cut); the dialog is laid out with `EdgeInsetsDirectional` and mirrors across **fa/ckb/ar**; the consequence text, both button labels, and the action's outcome carry localized `Semantics` so a screen-reader user hears the full consequence and which button is destructive before acting; a visible focus ring sits on the **safe** action, not the destructive one. `docs/design-system/06-motion-and-haptics.md` §5 (the OS reduce-motion flag always wins; nothing here is conveyed by motion alone) + `docs/design-system/05-layout-spacing-touch.md` §5 (logical-direction template across all three locales); RTL/bidi mechanics via **eng-rtl-and-bidi-layout**, strings + semantics via **eng-add-localized-string**.

## Do / Don't

| Do | Don't |
|---|---|
| State the concrete consequence: *what* is erased, *that it is permanent*, *that nothing is recoverable elsewhere* | Show an empty "Are you sure?" with no consequence, or hide that erase is irreversible |
| Make **Cancel / Keep my data** the visually-primary `FilledButton` and the default focus | Make the destructive button the bright/default one, or bury Cancel as a greyed text link |
| Add a second deliberate step (confirm screen / type-the-word / hold) sized to the blast radius | Escalate to friction-for-friction's-sake, or let a whole-device erase fire on one stray tap |
| Put the destructive trigger in the hard-to-reach **top-start** corner; keep the safe action **low** in the thumb band | Place erase/delete-profile in the easy-reach bottom zone where a resting thumb hits it |
| Lead with understanding and leave the choice with the user | Threaten ("you'll lose your hifz"), command ("you must"), or shame the user |
| Route the confirmed wipe through one transactional store method (persist-then-republish) | Mutate/delete persisted rows directly in a view, or skip the single write path |
| Truly delete the rows, including the `review_log` | Soft-delete (a hidden "deleted" flag) that secretly retains data |
| Audit the gate against the five dark-pattern strategies — asymmetry protects the *user* only | Obstruct, disguise the destructive button, sneak, or gate erase behind an account/upgrade |
| Erase quietly — calm state change, at most one single `haptic.warning` at the warning step | Fire confetti/fanfare on completion, a red alarm flourish, or a repeating/escalating buzz |
| `EdgeInsetsDirectional`, reduce-motion honoured, localized `Semantics` naming the consequence + which button is destructive, focus ring on the safe action | Hardcode LTR, animate through reduce-motion, or leave the destructive button unlabeled / focused by default |

## Checklist

Before this control is done:

- [ ] The confirmation states the **concrete, irreversible** consequence in plain words — *what* is erased, *that it is permanent*, *that nothing is recoverable elsewhere* — never a bare "Are you sure?".
- [ ] **Cancel / Keep my data** is the visually-primary `FilledButton` and the default focus; the destructive action is a plainer, secondary affordance one deliberate step away (never hidden, never the bright/default button).
- [ ] A **second deliberate gesture** (confirm screen / type-the-word / hold-to-confirm) is sized to the blast radius — strong enough that a whole-device erase can't fire on one stray tap, never escalated past that.
- [ ] The destructive trigger sits in the hard-to-reach **top-start** corner; the safe action sits **low** in the thumb band; no destructive control lives in the easy-reach bottom zone.
- [ ] Consequence copy **leads with understanding and ends with a real choice**; no loss/fear leverage ("you'll lose your hifz"), no command ("you must/should"), no shaming — passes the banned-phrase lint in fa/ckb/ar.
- [ ] The gate is audited against the **five dark-pattern strategies** (obstruction, interface interference, sneaking, forced action, nagging); the asymmetry protects the user's data only, never the app's retention.
- [ ] On confirm, the wipe is **one transactional store/repository call** (persist/delete then republish); no view mutates persisted state directly.
- [ ] Erasure is **real**, including the append-only `review_log` (rows deleted, no hidden "deleted" flag / soft-delete); after erase, nothing about the user persists on-device.
- [ ] Completion is **quiet**: no celebratory motion or haptic, no alarming red flourish; at most a single, non-repeating `haptic.warning` at the warning step.
- [ ] Transitions obey `MediaQuery.disableAnimations` (cross-fade / instant cut); layout is `EdgeInsetsDirectional` and mirrors in **fa, ckb, ar**.
- [ ] Localized `Semantics` announce the full consequence and **which button is destructive**; the visible focus ring is on the **safe** action.
- [ ] No microphone, recording, AI, network call, or telemetry is introduced by the erase flow; it works fully offline (an `HttpOverrides` guard proves no socket opens on erase).
- [ ] Widget/golden tests cover: the consequence text is present; Cancel is primary + focused; the destructive write routes through the single write path; the `review_log` rows are gone after erase; RTL goldens in fa/ckb/ar; an offline guard.

The erase gate is the one screen where the industry's instinct is to *trap* the user and ours is the exact opposite: protect the data while keeping the honest path clear. If any version makes Cancel the buried option, disguises the destructive button, threatens the user, or soft-deletes, stop and run it through **domain-adab-and-religious-integrity** and the §11 dark-pattern review before shipping.

## Files

- `template.dart` — copy-paste scaffold: a domain-blind `DestructiveConfirmSheet` leaf (concrete-consequence text + primary-Cancel / secondary-destructive layout, RTL + `Semantics`), an optional `_TypeToConfirm` / hold gate sized to the blast radius, the feature-layer `EraseController` calling the single-write-path wipe (persist/delete-then-republish, real `review_log` deletion), and a widget/golden + offline-guard test stub. Fill the `// TODO` markers; reference tokens (`color.*`, `type.*`, `space.*`, `touch.min`, `motion.*`, `haptic.warning`) and engine/data names (`review_log`, `activeProfileId`) by name only.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-backup-format** (the `.hifzbackup` export the user is offered *before* erasing, plus restore semantics), **ui-settings-picker** (the grouped Settings surface the erase/export entry points live in, and reversible preference changes that need no consequence gate), **ui-profile-switcher** (the profile list the wipe-profile action sits beside), **eng-create-riverpod-store** (the single write path / transactional wipe), **eng-add-persisted-model** (the schema/DAO and the append-only `review_log` the erase truly deletes), **eng-rtl-and-bidi-layout** (`EdgeInsetsDirectional` + RTL mirroring), **eng-add-localized-string** (the empathy-then-consequence copy + `Semantics` in fa/ckb/ar), **domain-adab-and-religious-integrity** (the conscience-check on consequence wording — no threat/command/shame, no loss-of-hifz leverage).
