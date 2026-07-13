# E18-T03 — ReminderController notifier: persist-before-republish, then schedule via the injected boundary

| | |
|---|---|
| **Epic** | [E18 — Reminders](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E18-T01, E18-T02 |
| **Skills** | eng-create-riverpod-store, eng-define-service-boundary, eng-write-dart-test |

## Goal

The `ReminderController` — a Riverpod 3.x `AsyncNotifier` — is the single orchestration seam behind the reminder toggle and time. It exposes one immutable UI-state value (built from E18-T02's persisted prefs: enabled, time-of-day-as-integers, catch-up-note-enabled) and three user-driven mutations: enable/disable, set time, toggle the catch-up note. Every mutation follows one strict ordering guarantee: the write **commits transactionally through the T02 repository first**, then the in-memory state republishes, and **only after the commit** does the controller call E18-T01's injected `NotificationScheduler` (`scheduleDaily` on enable/time-change, `cancelAll` on disable — one tap silences). No view ever reaches the scheduler or the OS; "today", if the scheduling call needs it, comes from the injected clock boundary — never `DateTime.now()`. The controller passes the persisted time-of-day *through* to the boundary; the DST-correct fire-moment mapping is E18-T04's, the reconcile triggers (start/reboot/permission) are E18-T05's, the widget is E18-T06's, and no copy is authored here (E18-T10). The call-order invariant is pinned test-first with a fake repository and a fake scheduler recording into one shared log.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §14 | The behavior contract these mutations realize: local-only (`flutter_local_notifications`), **one** calm daily reminder at a user-set time, fully optional and easily silenced, no nagging escalation — the controller schedules exactly one daily fire and cancels it on a single disable |
| `docs/PRD.md` §17, R5, C1 | Device-local, no network, no account: the controller's only side effects are the T02 write and the T01 boundary call — nothing else, provably (offline guard in tests) |
| `docs/engineering/04-flutter-and-state-patterns.md` §4 | The single write path verbatim: one repository `db.transaction` per mutation; "the controller's `await` returns only after commit"; **no optimistic UI** that republishes before commit, no debounced/"save later" write; no widget/controller touches a DAO directly |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.1, §1.2 | Ownership: presentation state = `Notifier`/`AsyncNotifier` over one immutable value; the repository, scheduler, and clock arrive as DI `Provider`s; live services are wired once in `main`'s `ProviderScope` — the controller constructs nothing |
| `docs/engineering/07-dates-calendars-and-correctness.md` §5 | "Today" enters only via the injected `todayProvider`/clock edge; the reminder keys off the **local civil day**; the `timezone`/`TZDateTime` edge (decision 14) lives in the shell scheduler — **never** in this controller |
| `CLAUDE.md` #10 | Persist-on-every-change: transactional commit **before** republishing in-memory state — the non-negotiable this task makes structural for reminder prefs |
| `docs/design-system/10-privacy-and-trust-ux.md` §9, §10 | The protective default this seam enforces mechanically: the reminder is reversible and easily silenced — disable is one mutation ending in `cancelAll`, never a buried multi-step path; one neutral optional daily reminder, no escalation logic anywhere in the store |
| Skill `eng-create-riverpod-store` (+ `template.dart`) | Item 1 (`Notifier`/`AsyncNotifier` only — no legacy providers, no Bloc, no `get_it`), item 3 (persist-before-republish, the controller's `await` returns after commit), item 5 (immutable UI state, no second cache), item 6 (propagate write failure as a calm error state, never swallow), item 7 (collaborators injected as `Provider`s), item 8 (no `DateTime.now()` in shell logic), item 11 (stores never navigate), item 12 (value types only, no hard-coded strings) |
| Skill `eng-define-service-boundary` items 3–7 | Consume the boundary as a Riverpod `Provider<NotificationScheduler>` via `ref` (item 3); it is wired once at the composition root (item 4); the test double is a plain fake installed with `overrideWith` — and controllers are tested by faking the **repository**, not the Notifier (item 5); "now" enters only through the injected clock (item 6); a mutating boundary is consumed through the single write path (item 7) |
| Skill `ui-reminder-row`, canonical pattern item 6 | The exact stitch this task builds: "persist the choice through the single write path, then schedule as a side effect" — `scheduleDaily`/`cancelAll` called **after** the write commits, never a view reaching the OS directly |
| Skill `eng-write-dart-test` | Item 3 (inject `today`; a fixed clock, never the host wall clock), item 8 (throwing `HttpOverrides` offline guard on the suite), item 11 (tests held to coding standards) |
| Sibling **E18-T01** | Supplies the `NotificationScheduler` interface (`scheduleDaily`, `cancelAll`), the live impl, the deterministic fake, and the composition-root `Provider`; this task consumes the interface via `ref` and never imports `flutter_local_notifications`/`timezone` |
| Sibling **E18-T02** | Supplies the immutable reminder-prefs value type and the repository whose transaction body IS the durable write; this task calls its named methods and adds no table, DAO, or schema change |
| Sibling **E18-T04** | Owns the pure local-civil-day → fire-moment computation the scheduler consumes; this controller passes the persisted time-of-day through and computes **no** DST offset, no `TZDateTime` |
| Sibling **E18-T05** | Owns the reconciler and its triggers (app start, reboot, permission grant) treating the OS schedule as a derived cache; it may reuse this controller's scheduling call, but no trigger logic lands here — T03 is the user-driven mutation path only |
| Siblings **E18-T06 / E18-T08** | The dumb `ReminderRow` widget and the in-context permission flow call these mutation methods; no widget code, no permission UX, no navigation in this task |
| Siblings **E18-T09 / E18-T10** | T09 owns the catch-up-note *semantics* (what the note says and when it accompanies the notification); T10 owns every string. This controller only persists and republishes the `catchUpNoteEnabled` flag — it authors zero copy |

## Implementation notes

This task is orchestration-only: no schema (T02), no OS API (T01), no fire-moment math (T04), no trigger logic (T05), no widget (T06), no string (T10). It is correctness-critical for the crash-safety non-negotiable (CLAUDE.md #10) → the call-order guarantee is pinned **test-first**, before any wiring polish.

1. **Files** (in the `features` umbrella package, `lib/src/reminders/`, per eng-add-feature-module conventions): `reminder_controller.dart` — the `ReminderController extends AsyncNotifier<...>` plus its provider declaration; state is E18-T02's immutable prefs value (or a thin immutable wrapper over it) — do **not** duplicate its fields into a second type that can drift.
2. **Shape.** `build()` loads the persisted prefs through the T02 repository's read surface (async → `AsyncNotifier`); the controller holds no other state, no derived "next fire time" (the OS schedule is T05's derived cache, never mirrored in memory). Modern provider only; importing `flutter_riverpod/legacy.dart` is a CI-failing grep (eng-create-riverpod-store item 1).
3. **Three mutations, one ordering.** `setEnabled(bool)`, `setReminderTime(hour, minute)` (integers, matching T02's storage), `setCatchUpNoteEnabled(bool)`. Each method, in this exact order: (a) `await` the T02 repository method — one `db.transaction`, returns only after commit; (b) republish the new immutable state; (c) fire the scheduler side effect. Steps (b) and (c) run **only** on a committed write — the OS schedule must never get ahead of the disk.
4. **Scheduling side effect per mutation.** Enable → `scheduleDaily` with the persisted time-of-day passed through (and the injected `today`/clock value if the T01 signature requires the civil day — read via the clock `Provider`, never computed here); time change while enabled → `scheduleDaily` with the new persisted value (the boundary/reconciler owns replace-not-duplicate semantics, T01/T05); disable → `cancelAll` — one tap silences, and the OS holds nothing stale (PRD §14; design-system 10 §9 via ui-reminder-row).
5. **Catch-up toggle persists only.** `setCatchUpNoteEnabled` follows the same persist → republish path; whether/how the flag alters the scheduled notification is T09's semantics (via T05's reconcile) — this task does not invent a second notification or body.
6. **No clock reads, no timezone.** No `DateTime.now()`, `Calendar.current`, or `TimeZone.current` anywhere in the controller; no `timezone`/`flutter_timezone` import (that edge is T01's live impl per engineering 07 §5 decision 14). The CI grep banning `DateTime.now()` outside the clock edge must stay green over this file.
7. **Failure is calm and behind-the-disk.** Repository failure propagates as `AsyncError` (no `try?`-style swallow, no debounce/"save later"): the state keeps the last **committed** value and **no scheduler call happens** — a failed write must not flip the toggle optimistically nor touch the OS schedule. The View renders the error as a calm retry; the error copy itself is T10/feature-layer, not a string in this store.
8. **The store stays a store.** No navigation (the router/T06 decides screens), no permission request (T08 wraps the enable flow and calls back into these methods), no hard-coded user-facing string, no streak/score/badge state (PRD R3) — value types only.
9. **Profile keying follows T02.** If E18-T02 scopes reminder prefs per profile, key this controller with `family` on the stable, equatable `ProfileId` per eng-create-riverpod-store item 9 (never a mutable object); if T02 stores one device-wide record, a single app-scope notifier is correct — defer to T02's model, do not decide it here.
10. **Pitfalls to avoid:** republishing or calling the scheduler before the commit returns (the exact crash-safety breach this task exists to prevent); a view calling `NotificationScheduler` directly; computing a `TZDateTime`/DST offset in the controller (T04/T01's); reading the wall clock; caching "next fire time" in state as a second source of truth; legacy providers/`StateProvider`; swallowing a write error into a silently-flipped toggle; adding reconcile-on-start logic (T05's).

## Acceptance criteria

- [ ] `reminders/reminder_controller.dart` exists in the `features` package as an `AsyncNotifier` + provider; it imports the T01 interface, the T02 repository, and the clock `Provider` only — no `flutter_local_notifications`, no `timezone`, no DAO, no Drift symbol, no `DateTime.now()` (verifiable by grep over the file).
- [ ] State is one immutable value built from the persisted T02 prefs; no second cache and no stored derived fire time.
- [ ] Each of the three mutations awaits the T02 repository transaction and republishes **only after** commit; the scheduler is invoked **only after** commit — the recorded call order is commit → republish → schedule in every green run.
- [ ] Enabling (or changing the time while enabled) results in exactly one `scheduleDaily` call carrying the persisted time-of-day passed through unmodified; disabling results in exactly one `cancelAll` call.
- [ ] `setCatchUpNoteEnabled` persists and republishes the flag through the same path; it invents no notification of its own.
- [ ] A failing repository write leaves the published state at the last committed value, surfaces `AsyncError`, and produces **zero** scheduler calls.
- [ ] No navigation, no permission request, no user-facing string, and no reconcile-trigger logic exists in this file (those are T06/T08/T10/T05 respectively).
- [ ] The controller is consumed only through its provider; the scheduler and repository arrive via `ref` from composition-root `Provider`s — nothing is constructed inside the store.
- [ ] Modern Riverpod only: no `flutter_riverpod/legacy.dart` import, no `StateProvider`/`StateNotifierProvider`, no `get_it`, no Bloc (the CI legacy-import grep stays green over this file).

## Tests

All deterministic and offline by construction: plain fakes via `overrideWith` (no mock framework), a **fixed injected clock** (a literal `CalendarDate` — no host wall-clock read anywhere in the suite), and the suite-wide throwing `HttpOverrides` guard (eng-write-dart-test items 3/8). Per eng-define-service-boundary item 5, the controller is tested by faking the **repository** (and the T01 scheduler fake), never by faking the Notifier.

- `features/test/reminders/reminder_controller_test.dart` (unit, `ProviderContainer` — **written first**):
  - **the ordering invariant**: a recording fake repository and a recording fake scheduler (plus a state listener) all append to one shared event log; for every mutation the log shows `repo.commit` **before** the first state republish and **before** any scheduler call — and no republish or scheduler event precedes the commit;
  - enable → exactly one `scheduleDaily` recorded with the exact persisted hour/minute passed through; time change while enabled → one `scheduleDaily` with the new value; **disable → exactly one `cancelAll`** and no `scheduleDaily`;
  - `setCatchUpNoteEnabled` → one repository write + republish, **zero** scheduler calls of its own;
  - `build()` publishes the prefs the fake repository seeds — the store adds/derives nothing.
- `features/test/reminders/reminder_controller_failure_test.dart` (unit) — the fake repository throws on write: the mutation surfaces `AsyncError`, the published value remains the last committed prefs (no optimistic flip), the event log contains **no** scheduler call and **no** republish of the un-committed value; a subsequent successful mutation recovers cleanly.
- Wiring hygiene (in `reminder_controller_test.dart`): a `ProviderContainer` built **without** the repository/scheduler overrides throws loudly when the controller is read (the un-overridden placeholder contract, eng-define-service-boundary item 4) — a forgotten composition-root wire is a startup failure, never silent null prefs.
- Both suites inject the fixed clock and run under the throwing-`HttpOverrides` offline guard; nothing in them reads the host clock or opens a socket. (The DST/fire-moment vectors are E18-T04's; reconcile idempotency/convergence is E18-T05's; widget interaction is E18-T06's.)

## Definition of Done

- [ ] All acceptance criteria met; the ordering-invariant and failure suites were written first and are green in CI.
- [ ] **Offline / no-network**: the controller's only side effects are the T02 write and the T01 boundary call; the throwing-`HttpOverrides` guard passes; no networking import anywhere near this file (PRD §17, C1).
- [ ] **No AI / no microphone**: nothing here records, listens, or infers; the controller moves a toggle, a time, and a flag (R5).
- [ ] **Quran text fidelity (R1)**: N/A by construction, asserted — this task renders no Quran text and touches no muṣḥaf surface.
- [ ] **Single write path (CLAUDE.md #10)**: every mutation commits one repository transaction before any in-memory republish, and OS scheduling runs only after the commit; no view reaches the scheduler or the OS directly; a failed write never flips state or touches the OS schedule.
- [ ] **No gamification / no shame (R3)**: the store carries no streak, score, badge, or escalation state; it schedules exactly one daily fire and one tap silences it (`cancelAll`); nothing here re-engages a lapsed user.
- [ ] **Never "safe to drop" / engine untouched**: this task calls no engine API and alters no schedule semantics; the reminder is a peripheral surface and implies nothing about a page's revision state.
- [ ] **Date correctness**: no `DateTime.now()`/`Calendar.current`/`TimeZone.current` in the controller; "today" (if needed by the boundary signature) is the injected clock's `CalendarDate`; no `timezone` import — the DST edge stays in T01/T04 (engineering 07 §5).
- [ ] **RTL + fa/ckb/ar**: N/A for strings by construction — this store holds value types only and authors zero user-facing copy (all reminder strings are E18-T10); nothing hard-coded slips in (grep-verified).
- [ ] **Accessibility**: no widget ships here; the published immutable state carries everything E18-T06 needs to announce the switch state per locale, and the error state supports a calm retry surface.
- [ ] **Sect-neutral adab**: this task ships no religious or user-facing content, so no scholarly-review item opens here; the adab contribution is mechanical — one daily fire, one-tap silence, zero escalation state — and every future reminder string flows through E18-T10's banned-phrase gate, never this store.
- [ ] **Deterministic tests**: fixed injected clock, plain fakes over the repository and scheduler, shared-log order assertions, offline guard — identical inputs give identical logs on any machine; all gates stay green.
