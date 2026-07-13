# E16-T10 — Teacher / halaqa loop wiring: switch student → sign off (E12) → next, each verdict into that student's own append-only review_log

| | |
|---|---|
| **Epic** | [E16 — Settings, Profiles & Teacher Sign-off](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E16-T09, E12 |
| **Skills** | ui-teacher-signoff, ui-profile-switcher, eng-create-riverpod-store, domain-grading-pipeline, domain-adab-and-religious-integrity, eng-write-dart-test |

## Goal

The device-local halaqa journey becomes real: a teacher on one shared phone switches to a student profile, hands off to E12's recite + teacher sign-off flow **unchanged**, and returns to switch to the next student — with every verdict landing in *that* student's own append-only `review_log` (`source = teacher`, optional `teacher_label`). This task owns only the **re-scope-then-handoff wiring**: (1) an awaited, persist-before-republish profile switch through E16-T08's `ProfilesNotifier`/`activeProfileProvider` that re-scopes every `family`-keyed read model **before** any verdict surface mounts; (2) a `go_router` push into the E12-T07/T08 recite + sign-off route, which this task re-implements in no part; (3) the quiet return that leaves the teacher at the E16-T09 switcher for the next student. It draws no "Teacher present" toggle, no verdict surface, no Again/Hard/Good/Easy band, no teacher-sourced marker (all E12's), and writes no grade itself — the only grading write is E12-T06's `recordReview` into the append-only `review_log`. A profile switch is a re-scope, never a review: it appends, updates, and re-grades nothing, and a committed teacher verdict is never silently re-graded by any switch or return (R6, §7.12). No roster, no dashboard, no server, no per-student score — the switcher plus the sign-off *is* halaqa mode (§15.3, §8.2).

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` R6 | The covenant this wiring serves: teacher sign-off is a first-class grade that **overrides** self-rating and algorithmic state; the app never claims authority over a teacher — copy and UX frame it as an aid to *talaqqī* and the *sanad* chain, never a replacement |
| `docs/PRD.md` §8.2 | The halaqa spec: a **physically present** teacher taps the verdict on the same device, `sourceConfidence = 1.0`; "in local halaqa mode (§15), a teacher switches between student profiles on one device to sign off each"; sign-offs are recorded in the append-only `review_log` with `source = teacher` + an optional teacher label — a local audit trail respecting the *sanad* idea without any server |
| `docs/PRD.md` §7.12 | The release-blocking invariant the loop must not break: "a teacher sign-off always supersedes self-rating and algorithmic state for that page" — no switch, navigation, or return leg may re-grade, drop, or overwrite a committed teacher verdict |
| `docs/PRD.md` §15.3 | Halaqa is a *profiles* feature: a quick switcher so a teacher signs off each student in turn on one device; **per-student `review_log` with teacher labels**; profiles are device-local; sharing across devices is export/import (§16), never a server |
| `docs/PRD.md` §10.2, §10.3 | The row the write lands in (`review_log` carries a `profile_id` FK, `source /* self\|teacher */`, `teacher_label NULLABLE`) and its append-only law: never updated or deleted by normal flows — the loop calls no UPDATE/DELETE because none exists to call |
| `docs/engineering/04-flutter-and-state-patterns.md` §1.2 | The profile gate: `activeProfileProvider` is the single value a switch changes; every `family`-keyed feature provider recomputes for the new id; no global mutable "current user" singleton |
| `docs/engineering/04-flutter-and-state-patterns.md` §4 | The single write path: "grade a page, teacher sign-off, … switch the active profile's settings" are each one named repository method — one `db.transaction`, append `review_log` first, commit **before** anything is observable; no widget/controller calls a DAO write directly |
| `docs/engineering/04-flutter-and-state-patterns.md` §5 | Per-profile keying (`family` by `ProfileId`) is what makes the re-scope leak-proof: "no leakage between students"; no un-keyed "current profile data" a switch could leave stale |
| `docs/design-system/07-components.md` §7 | The sign-off control this task hands off to (owned by E12): `Switch.adaptive` "Teacher present", authoritative verdict, teacher-sourced marker; "in local halaqa mode, a teacher switches between student profiles on one device to sign off each in turn; the control and profile switcher are device-local, never a server dashboard"; copy is autonomy-supportive ("for your teacher to confirm"), never app-as-authority |
| Skill `ui-profile-switcher` | Canonical pattern 4 (halaqa = switch student → recite → sign off → next; **the switcher is the only halaqa-specific UI** — the sign-off itself is ui-teacher-signoff), pattern 6 (device-local, export/import only, no socket), pattern 9 (a switch is quiet; no per-profile score/rank/"completion %") |
| Skill `ui-teacher-signoff` | Canonical pattern 3 (the teacher verdict is authoritative; the UI must never silently re-grade over it), pattern 4 (one append-only `review_log` row, `source = teacher` + label, fully offline), pattern 6 (halaqa = profile switch then sign off, on one device, never a remote dashboard), pattern 7 (servant-to-teacher copy in fa/ckb/ar) |
| Skill `domain-grading-pipeline` | Why this task writes nothing: the `(grade, error_lines, source)` normalization, per-source confidence, sacred-text guard, and teacher-overrides math all live in E12-T06's pipeline — the halaqa loop introduces **no second grading path** |
| Skill `domain-adab-and-religious-integrity` (the conscience pass) | The floor for the loop's copy: servant-to-teacher framing, no app-as-authority, no fiqh ruling, no gamification of the halaqa, no guilt/comparison copy toward a struggling student; religious copy never ships without scholarly review |
| `docs/science/CLAIMS.md` — **C-046** | The framing claim behind any handoff copy: "an aid to revision and a servant to your teacher — not a replacement for oral correction, and not a fatwa" ([TRAD]) — the register every string on this loop keeps |
| `docs/science/CLAIMS.md` — **C-038**, **C-021** | Why the loop defers to a present human and protects the write: the Quran is corrected face-to-face in a chain to the Prophet ﷺ (C-038, [TRAD]); a teacher's correction strengthens a page more than self-rating (C-021, [MA]/[TRAD]) — which is exactly why a teacher row landing in the *wrong student's* log is unacceptable |
| Sibling **E16-T08** | Supplies the `Profile` value type, `ProfilesNotifier`, and `activeProfileProvider` single write path the loop awaits; this task adds no second profile store, model, or schema |
| Sibling **E16-T09** | Supplies the quick switcher widget and its switch-re-scopes-read-models + opens-no-socket tests; this task *composes* that switcher into the loop — it does not re-draw or fork it |
| Siblings **E12-T06 / T07 / T08** | Own `recordReview` (the only grading write), the recite route, the "Teacher present" toggle, the authoritative verdict + stumble capture, and the teacher-sourced marker; this task pushes that route unchanged and re-implements none of it |
| Sibling **E16-T12** | Consolidates fa/ckb/ar ARB coverage, per-locale RTL goldens, and the epic-wide offline guard; any entry-point string or surface this task adds joins that suite |

## Implementation notes

This task is wiring-only: it draws no grading surface and performs no `review_log` write of its own. Its whole value is an **ordering and scoping guarantee** — the app is re-scoped to the right student *before* any verdict surface exists, so every write E12 performs lands in that student's log. The write-isolation and never-re-grade invariants are pinned **test-first**, before any polish.

1. **Files** (in the `features` umbrella package, `lib/src/profiles/`, per eng-add-feature-module):
   - `halaqa_loop.dart` — a thin loop command (a method on the profiles view-model or a small controller per eng-create-riverpod-store) exposing `signOffStudent(ProfileId)`: `await` the E16-T08 switch, then push the E12 recite route. No new store, no new schema, no new DAO, no widget state.
   - Optionally a quiet entry affordance in the Profiles section that *composes* the E16-T09 switcher — nothing more; if the switcher alone suffices, add no widget at all.
2. **The ordering guarantee is the task.** `signOffStudent` must (a) call `ProfilesNotifier`'s persist-before-republish switch and `await` its transactional commit, then (b) push the E12-T07 route via `go_router`. Never push first; never fire-and-forget the switch — a verdict tapped against a mid-flight switch is precisely the wrong-student bug this task exists to prevent.
3. **Re-scope by construction, not by copying.** `activeProfileProvider` is the gate (eng 04 §1.2) and every per-student read model is `family`-keyed (§5). Pass no `ProfileId` into the recite route and cache none in a widget — E12's controller reads the active profile at commit time, which the awaited switch has already re-pointed.
4. **Hand off unchanged; draw nothing of E12's.** No Again/Hard/Good/Easy band, no "Teacher present" `Switch.adaptive`, no verdict surface, no stumble capture, no teacher-sourced marker appears in any file this task adds (verifiable by grep); the loop's tree before handoff contains no grade widget.
5. **A switch is a re-scope, never a review.** Switching students touches only the active-profile value; it appends nothing to any `review_log`, updates/deletes nothing (§10.3 — the DAO exposes no UPDATE/DELETE; assert the append surface stays untouched too), and never re-grades a committed teacher verdict (R6, §7.12).
6. **The return leg: the teacher chooses the next student.** When E12's route pops, land the teacher back with the E16-T09 switcher at hand. No automatic student queue, no auto-advance, no "up next" roster — the next switch is the teacher's own tap (ui-profile-switcher pattern 4: the switcher *is* the halaqa UI). No per-student score, percentage, rank, or comparison anywhere on the loop.
7. **Copy: minimal, reviewed, servant-to-teacher.** At most one entry-point label beyond T09's existing strings; every string is an `l10n.*` ARB key in fa/ckb/ar (eng-add-localized-string), in the autonomy-supportive "for your teacher to confirm" register (07-components §7; C-046), flagged for scholarly review; never "the app says you passed", never a fiqh ruling, never app-as-authority.
8. **Quiet between students.** No confetti, chime, streak, or haptic fanfare on switch, handoff, return, or a teacher Good/Easy (E12 enforces its side; this task adds no celebration channel of its own — R3).
9. **RTL + a11y on anything added:** ≥48dp `touch.min` rows, `EdgeInsetsDirectional` only, user-typed student names bidi-isolated (FSI/PDI) so a mixed-script name never breaks the RTL row, a localized `Semantics` label + state, visible focus ring (eng-rtl-and-bidi-layout; 07-components §6).
10. **Pitfalls to avoid:** pushing the recite route before the switch commit resolves; passing or caching a `ProfileId` into the route (the stale-student bug); re-implementing any E12 surface "for convenience"; a roster/dashboard/auto-advance queue; a switch that writes `review_log`; `DateTime.now()` anywhere in the wiring (the injected `CalendarDate` belongs to E12's write path); any socket (profiles are device-local; moving a student's record to a teacher's device is E17's export/import, never this loop).

## Acceptance criteria

- [ ] `profiles/halaqa_loop.dart` exists in the `features` package; grep over this task's files finds no grade band, no "Teacher present" toggle, no verdict/marker widget, no `review_log` write, no `DateTime.now()`, no socket.
- [ ] The loop command `await`s the E16-T08 persist-before-republish switch to student S, then pushes the E12 recite route; the push never precedes the switch's transactional commit (pinned by a recorded-order test).
- [ ] A teacher sign-off run through the handoff appends exactly **one** row to S's own append-only `review_log` with `source = teacher` (+ optional `teacher_label`) — and appends **nothing** to any other profile's log.
- [ ] Switching students never appends, updates, deletes, or re-grades any `review_log` row; a committed teacher verdict is unchanged after any number of switches (R6, §7.12, §10.3).
- [ ] The return leg lands the teacher at the E16-T09 switcher for the next student; no roster, dashboard, auto-advance queue, per-student score/percentage, or comparison surface exists anywhere on the loop.
- [ ] Every string this task adds is an `l10n.*` ARB key in fa/ckb/ar in the servant-to-teacher register ("for your teacher to confirm" family), flagged for scholarly review; no app-as-authority or fiqh phrasing (C-046).
- [ ] Any affordance added is ≥48dp, RTL by geometry, bidi-isolates student names, and exposes a `Semantics` label + state with a visible focus ring.
- [ ] The whole loop — switch → sign off → next — runs in airplane mode; the `HttpOverrides` guard proves no socket opens on any leg.

## Tests

All deterministic and offline: two seeded profiles ("student A" / "student B" fixtures), the injected `CalendarDate` inside E12's write path, and the E12 write boundary exercised through a fake — a recording `recordReview` double (eng-define-service-boundary) or the real repository over in-memory Drift — never a mock of Drift internals. The isolation and never-re-grade invariants are **written first**.

- `features/test/profiles/halaqa_write_isolation_test.dart` (the halaqa-writes-correct-student test) — **written first**:
  - switch to student A via the loop, drive E12's sign-off through the fake boundary: the appended row carries **A's** `profile_id`, `source = teacher` (+ `teacher_label` when provided), and B's `review_log` gains zero rows;
  - repeat toward B and assert the mirror — no cross-profile bleed in either direction;
  - exactly one append per verdict (the wiring introduces no double write).
- `features/test/profiles/halaqa_ordering_test.dart` — a recording `ProfilesNotifier` + a fake `go_router` pin the sequence: the switch's commit resolves **before** the recite-route push is issued; the profile E12's write reads at commit equals the student just switched to; a deliberately delayed switch still blocks the push (no race window).
- `features/test/profiles/halaqa_never_regrades_test.dart` — commit a teacher verdict for A, then switch A→B→A: A's `review_log` rows are unchanged in count and content; the recording double shows the DAO surface received appends only — no UPDATE/DELETE-shaped call ever occurred (§10.3); the §7.12 supersedes-invariant is untouched by navigation.
- `features/test/profiles/halaqa_no_grade_surface_test.dart` (widget) — pumping the loop's entry/return surfaces finds no Again/Hard/Good/Easy button, no `Switch.adaptive` "Teacher present", no verdict or teacher-marker widget (those exist only inside the pushed E12 route), and no celebration widget or haptic fanfare fires on switch or return.
- Offline guard: the suite runs under an `HttpOverrides` that fails any socket open (eng-write-dart-test). Per-locale (fa/ckb/ar) RTL goldens of the Profiles surfaces including any loop entry affordance land in E16-T12's consolidated suite.

## Definition of Done

- [ ] All acceptance criteria met; the write-isolation, ordering, and never-re-grade tests were written first and are green in CI.
- [ ] **Offline / no-network**: switch → sign off → next works entirely in airplane mode; the `HttpOverrides` guard passes on every leg; moving a student's record across devices remains E17's export/import, never this loop, never a server (§15.3).
- [ ] **No AI / no microphone**: the loop introduces no recording, transcription, or mistake detection; the verdict is a physically-present human's tap on the same device (C2, R5, §8.2–§8.3).
- [ ] **Quran text fidelity (R1)**: this task renders no Quran text; the recite surface it pushes is E12's over the immutable glyph page — nothing here masks, reflows, or re-typesets anything.
- [ ] **Servant to the teacher (R6, §7.12)**: the loop re-scopes and defers — the verdict is the teacher's, written authoritative by E12; no switch or return re-grades it; copy never claims app authority and issues no fiqh ruling (C-046, C-038).
- [ ] **Never "safe to drop" (decay axiom)**: no copy on the loop implies any student's page is "done", "mastered", or safe to stop revising.
- [ ] **No gamification / no shame (R3)**: switch, handoff, and return are quiet — no confetti, chime, streak, badge, or haptic fanfare; no per-student score, rank, "completion %", or comparison; no guilt copy toward a struggling student.
- [ ] **Privacy (§15.3, §17)**: profiles stay typed display names with no PII; no roster, dashboard, or server surveillance; each student's record lives only in their own append-only `review_log` with zero cross-profile bleed.
- [ ] **Single write path, dumb views**: the only persisted writes on the loop are E16-T08's profile switch and E12-T06's `recordReview`, each one transaction, persist-before-republish (eng 04 §4); no view mutates state; no `DateTime.now()` in the wiring.
- [ ] **RTL + fa/ckb/ar localization**: every added string ships through the ARB pipeline in all three locales, transcreated and flagged for scholarly review; layout RTL by geometry; student names bidi-isolated; goldens consolidated in E16-T12.
- [ ] **Accessibility (WCAG 2.2 AA)**: ≥48dp targets, localized `Semantics` labels + state, visible focus ring; the full switch → sign off → next journey is operable with a screen reader.
- [ ] **Deterministic tests**: seeded fixtures and fakes only, the injected clock, no hidden network; the halaqa-writes-correct-student, ordering, and never-re-grade suites plus the offline guard stay green in CI on every PR.
