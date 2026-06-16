# references — ui-destructive-confirm

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/design-system/10-privacy-and-trust-ux.md` §8 (Local-first ownership and real erasure) — **The rule.** Because there is no server, "delete" actually deletes: one action wipes all local data (right-to-be-forgotten by construction), and the copy says plainly that *nothing is recoverable elsewhere* — a guarantee most apps cannot make. State **both halves** (the power and the responsibility). Never a "soft delete" that secretly retains data, never imply erasure when something persists, never hide or gate the erase action.

- `docs/design-system/10-privacy-and-trust-ux.md` §9 (For the few real choices, default to the safe path) — **Safe choice is primary.** Warning-science (Felt et al. 2015): the protective option is the **default and the visually-primary** control (a `FilledButton` in the bottom thumb band), and the consequential action is a plainer, secondary affordance **one deliberate step away** — never hidden, never the brightest/default button. One decision per screen. Opinionated, never coercive.

- `docs/design-system/10-privacy-and-trust-ux.md` §11 (Audit every screen against the five dark-pattern strategies) — **No obstruction, no interface interference.** The five strategies are a release gate: **obstruction** (export/import/erase are one clear path each, never artificially hard), **interface interference** (the safe option is never visually buried; the destructive button is never disguised as the safe one), **sneaking**, **forced action** (no account/upgrade/unrelated gate), **nagging**. Any instance is a logged defect. The asymmetry here only ever protects the *user's* data.

- `docs/PRD.md` §16 (Backup & Data Portability — Erase) — **One action wipes all local data** (right-to-be-forgotten by construction). Export is offered first (a versioned, encryption-optional `.hifzbackup` of all profiles/cards/logs/configs) and the app performs **no** network transfer; the erase that follows is local and complete.

## Supporting

- `docs/design-system/05-layout-spacing-touch.md` §5 (Thumb ergonomics & screen templates) — **Placement is the safety margin.** "Destructive actions — erase-all-data, abort a session — sit in the hard-to-reach **top-start** corner and require confirmation, using thumb-zone difficulty as a natural safety margin rather than as friction-for-friction's-sake." Never place a destructive control (erase, delete profile) in the easy-reach bottom zone where a resting thumb could trigger it; keep the **safe/primary** action low in the green thumb band. Logical-direction layout serves all three RTL locales.

- `docs/design-system/11-voice-and-tone.md` §4 (Lead with empathy when the news is hard) — **Consequence copy, never blame or fear-leverage.** Open with understanding, state the honest fact, end with the user's real choice; never amplify the fear a ḥāfiẓ already carries — "you'll lose your hifz" is the exact backfiring appeal we forbid.

- `docs/design-system/11-voice-and-tone.md` §6 (Phrase as invitation and information, never as command) — **No mandate words.** "you must / have to / should / don't" and scolding imperatives are banned in product copy (a banned-phrase lint per locale); offer the two options as equals the user owns, never dictate one.

- `docs/design-system/06-motion-and-haptics.md` §2 (Motion never celebrates) — **No celebration, ever.** There is no `motion.celebrate.*`, no confetti, no "success" tier — completing an erase is a calm, factual state change, never a flourish (and equally never an alarming red one).

- `docs/design-system/06-motion-and-haptics.md` §4 (The haptic vocabulary is tiny, light, meaning-bearing) — **`haptic.warning` is gentle and single.** At most one light `haptic.warning` (paired with the warning state) at the confirm step; it never repeats, never escalates, never manufactures urgency or guilt, and there is no "success"/reward haptic.

- `docs/design-system/06-motion-and-haptics.md` §5 (Reduce-motion is honoured absolutely) — **The OS flag always wins.** Any transition into/out of the confirmation reads `MediaQuery.disableAnimations` and becomes a cross-fade or instant cut; nothing here is conveyed by motion alone, so reduce-motion hides no meaning.

- `docs/PRD.md` §4 R3 / R5 — **The requirements behind it.** R3: no gamification, no guilt/fear/loss copy (binds the consequence wording and the no-celebration completion). R5: privacy is part of religious trust — the erase flow opens no socket and sends nothing; the truthful "delete actually deletes" posture is itself the trust signal.

- `docs/PRD.md` §19.3 (Determinism & offline guarantees) — **No socket on erase.** The only permitted network use is the one-time asset download; a build-time check asserts no analytics/backend SDKs. The erase flow must introduce no `HttpClient` and no `DateTime.now()` — verified by an `HttpOverrides` offline guard.

## Sibling skills

- **domain-backup-format** — the offline `.hifzbackup` export offered *before* an erase, its encryption envelope, and replace-vs-merge restore semantics (the recoverable copy the user keeps; the app never uploads it).
- **ui-settings-picker** — the grouped Settings surface the erase/export entry points sit in, and the *reversible* single-choice preferences (calendar/theme/numerals) that re-render data and need **no** consequence gate.
- **ui-profile-switcher** — the local profile list/switch the wipe-a-profile action sits beside; switching re-scopes, this skill erases.
- **eng-create-riverpod-store** — the app-scope provider + single write path (persist/delete-then-republish) that performs the transactional wipe.
- **eng-add-persisted-model** — the schema/DAO the wipe deletes over, including the append-only `review_log` whose rows must be truly removed (no soft-delete flag).
- **eng-rtl-and-bidi-layout** — `EdgeInsetsDirectional` mirroring across fa/ckb/ar for the dialog and its buttons.
- **eng-add-localized-string** — the empathy-then-consequence copy, both button labels, and the `Semantics` consequence announcement in fa/ckb/ar (banned-phrase lint).
- **domain-adab-and-religious-integrity** — the always-on conscience-check on the consequence wording: no threat, no command, no shame, no loss-of-hifz leverage.
