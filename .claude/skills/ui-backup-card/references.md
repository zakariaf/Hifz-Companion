# references — ui-backup-card

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it. Reference a rule by its section — never re-derive a header offset, a cipher choice, or a merge rule here (that is **domain-backup-format**'s job).

## Primary

- `docs/design-system/10-privacy-and-trust-ux.md` §8 (*Local-first ownership and real erasure are the privacy features*) — **The core of this card.** Backup is a privacy *feature*: "Your backup is a file you keep. We never upload it, and only you can restore from it." Both halves of ownership are stated — the power *and* the responsibility. Erasure is real/immediate/honest: "because there is no server, nothing is recoverable elsewhere," erase sits in the **hard-to-reach top corner** behind a confirmation. Export/import/erase are one deliberate action each, fully transcreated for fa/ckb/ar, with **locale numerals + calendar** in any backup-date display. Never imply a backup is uploaded/synced; the app performs no network transfer for user data; never offer a "soft delete."

- `docs/design-system/10-privacy-and-trust-ux.md` §9 (*For the few real choices, default to the safe path*) — The **encryption toggle** is one of three genuine choices: protective option is the **default and the visually primary** one, reversible, one plain honest sentence ("Locks your backup file with a password only you hold."). No pre-ticked boxes; the safe choice is the easy choice; one decision per screen.

- `docs/design-system/10-privacy-and-trust-ux.md` §11 (*Audit every screen against the five dark-pattern strategies*) — The release gate for this card: no **nagging** (the stale-backup note offers, never nags), no **obstruction** (export/import/erase/silence are one tap each), no **sneaking** (no hidden network; nothing pre-checked), no **interface interference** (the protective option is never buried; honest hierarchy), no **forced action** (no account/upgrade gate; the only required network step is the one-time asset download elsewhere).

- `docs/engineering/10-backup-format.md` §9 (*Export & erase flows*) — What the card's buttons actually trigger: export builds the snapshot in `/data` → serializes/encrypts in `backup/` (off the UI isolate) → writes an atomic temp file → hands it to the **OS share sheet** (the app performs **no network transfer**); the default file name is e.g. `Hifz-2026-06-16.hifzbackup`. Erase is one confirmed, irreversible action; the erase UI states plainly it is irreversible and that any existing backup file is the only remaining copy.

- `docs/engineering/10-backup-format.md` §7 (*Import: replace vs merge*) — The restore surface offers **two explicit, separately-confirmed** modes: **Replace** ("This will replace all data currently in Hifz Companion") and **Merge** ("This will add the imported reviews to your existing history"). Merge is the teacher↔student transfer; it is a deduplicating **set-union** over the append-only `review_log` — never an overwrite, never a duplicate. Both run in one transaction.

- `docs/design-system/11-voice-and-tone.md` §2 (*the four fixed voice attributes*) — The card's voice is *plain & warm* + *honest*: "Backup saved. All profiles, on this phone." over "Your archive has been successfully persisted." Sentence case; no exclamation marks; no emoji; state the fact, then the option, then stop; buttons are verbs in the locale's idiom ("Save backup").

## Supporting

- `docs/design-system/10-privacy-and-trust-ux.md` §2 (*Make the invisible guarantee perceptible*) — **Never** show a fake "securing…/syncing…" animation — there is no server to sync with and a theatrical spinner would be a lie. Real progress only (the actual CPU/crypto work), then the honest integrity result.

- `docs/design-system/10-privacy-and-trust-ux.md` §3 (*Honesty must be specific and verifiable*) — Say the few load-bearing, checkable facts plainly; "your hifz record stays on this phone" over "your data is safe with us." Rhetorical reassurance ("your privacy is paramount") is forbidden in place of a checkable statement — this is why the no-recovery tradeoff is a *fact*, not a feeling.

- `docs/design-system/10-privacy-and-trust-ux.md` §10 (*The reminder layer stays calm and peripheral*) — The stale-backup nudge takes only the attention the task needs: a calm, optional note, no guilt, no fear, no escalating cadence — continuous with the app's honesty about attention.

- `docs/engineering/10-backup-format.md` §2 (*Default form: plaintext, versioned JSON — and why not mandatory encryption*) — The export screen **states plainly** that an *unencrypted* backup is readable by anyone who opens the file, and offers the one-tap encryption toggle. Honesty about what the file is *is* the trust feature. Default is plaintext (portability), encryption is opt-in.

- `docs/engineering/10-backup-format.md` §6 (*Optional encryption envelope*) — **No recovery.** The passphrase is never stored, never in `flutter_secure_storage`, never logged; the export screen states honestly that a forgotten passphrase means the file is unrecoverable. A wrong passphrase and a corrupted file surface the *same* error (`wrongPasswordOrDamaged`) — the card never claims to know which.

- `docs/engineering/10-backup-format.md` §1 (*Module boundary*) — Export/import perform **zero network I/O**; the OS share sheet moves the file in the shell, the `backup/` package opens no socket. The card's controller orchestrates `/data` read → `backup/` serialize → OS share, and nothing more.

- `docs/design-system/11-voice-and-tone.md` §3 (*tone-by-context matrix*) — The error row is the canonical backup case: cause → consequence → next step, no blame, no mascot apology — "Couldn't read this backup file. The password may be wrong — try again. Your data on this phone is unchanged." Old/stale state leads with a calm fact + a path, never "you're behind."

- `docs/design-system/11-voice-and-tone.md` §4 (*lead with empathy when the news is hard*) — The no-recovery tradeoff is hard news: acknowledge → the honest fact → a path (make a backup now / keep the file somewhere safe) → the user's choice. Never open with fault; never amplify the spiritual fear of loss.

- `docs/design-system/11-voice-and-tone.md` §7 (*no transactional or pressuring framing*) — No "upgrade/premium/unlock," no manufactured urgency, no streak, no engagement metric on the status line. Backup status is a status, never a score to maintain.

- `docs/design-system/11-voice-and-tone.md` §8/§9 (*one voice across fa/ar/ckb; tone is a per-locale QA gate*) — The tradeoff, erase, and encryption lines are **transcreated**, not literally translated, and pass the per-locale native-speaker (register) review; numerals/dates are formatted via `intl` per locale in `type.numeral`, never concatenated; mixed Latin/number runs (the file name) are FSI/PDI-isolated. The never-ship lint blocks guilt/loss framing and "safe" reassurance.

## Sibling skills

- **domain-backup-format** — the `.hifzbackup` file bytes: container header, `schemaVersion`, SHA-256 integrity, the Argon2id→ChaCha20-Poly1305 envelope, and the replace/merge set-union algorithm this card drives. Never re-derive an offset or a cipher here — the card calls `HifzBackup.export/import`.
- **ui-settings-picker** — the grouped Settings template the card lives in (destructive controls out of easy thumb reach), and the single-write-path/`Semantics`/RTL conventions every Settings control shares.
- **ui-destructive-confirm** — the irreversible-erase double-confirmation gate (consequence stated, cancel visually primary, thumb-zone difficulty as the safety margin) that this card's erase entry point opens.
- **ui-profile-switcher** — the export scope (this profile vs all) and the teacher↔student halaqa merge path the restore surface enables.
- **domain-calendars-and-hifzdate** — the `CalendarDate` value type and display-only calendar rules behind the "Last backup: <date>" status line; the injected "today".
- **eng-create-riverpod-store** — the persist-before-republish controller method that runs export/import/erase and the encryption toggle, then republishes the card's status.
- **eng-define-service-boundary** — the injected OS share sheet, file picker, backup IO, and clock as Riverpod-overridden boundaries — never a global singleton, never `DateTime.now()` in the View.
- **eng-add-localized-string** — the tradeoff/erase/encryption/status strings and the date format, as transcreated ARB values for fa/ckb/ar.
- **eng-rtl-and-bidi-layout** — `EdgeInsetsDirectional` geometry, locale numerals on the date, and FSI/PDI isolation of the backup file name inside RTL chrome.
- **eng-write-dart-test** — the widget test asserting no cloud/sync/account chrome and that actions route through the controller, plus the RTL goldens per locale.
- **domain-adab-and-religious-integrity** — the conscience-check on the tradeoff, encryption, stale-nudge, and erase copy (no guilt/fear/loss, no "safe" reassurance).
