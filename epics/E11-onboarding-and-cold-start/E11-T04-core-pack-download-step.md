# E11-T04 — Core-pack download step: calm awaitingFirstDownload/downloadInterrupted/ready states over installCorePack, fail-closed

| | |
|---|---|
| **Epic** | [E11 — Onboarding & Cold-Start](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E11-T01, E05 |
| **Skills** | domain-asset-pack-integrity, eng-add-localized-string |

## Goal

A `DownloadStep` view inside the onboarding feature module renders E05's already-sequenced `installCorePack` (download → verify → promote → build reference DB → stamp `text_checksum_verified_at`) as three calm onboarding states — `awaitingFirstDownload`, `downloadInterrupted`, `ready` — plus the in-flight `downloading` / `verifying` and the terminal `integrityFailure` states. The step shows progress in locale numerals, always offers a non-blaming Retry, never advances past itself until the pack is `ready`, and surfaces the airplane-mode-after proof. The download/verify/promote mechanics themselves are E05's; this task only embeds the step, watches E05's `DownloadState`, and paints calm RTL copy over it — and it is the structural guarantee that no later onboarding step (coverage, confidence) can render a muṣḥaf glyph before `text_checksum_verified_at` is stamped, because the step controller refuses to advance.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §12.1 | The download's exact slot in the onboarding sequence — after language + muṣḥaf confirmation, **before** coverage capture — and the "one-time core-pack download … with progress and integrity check (§11.1.1)" line this step renders |
| `docs/PRD.md` §11.1.1 (via skill) | The fail-closed contract this step's UI must honor: a pack is rejected + re-fetched unless its hash matches exactly, and the app **refuses to render Quran text** from any unverified asset — surfaced as the `integrityFailure` state, never a degraded render |
| `docs/PRD.md` R1, R3, R5, C1, C2 | R1 text fidelity (fail-closed is existential) · R3 (offline-at-first-run is explained, never scolded) · R5 (no microphone — the step touches no audio) · C1 (this is the one and only socket) · C2 (no AI/ASR anywhere in the path) |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 | The **verbatim state table** this UI paints: `awaitingFirstDownload` → "needs a one-time download … on any connection, once" + Retry; `downloadInterrupted` → resume/retry, the `.part` discarded; `ready` → "the single network moment is over; offline forever". "Offline at first run is not a failure to scold." |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §3 | The total verify state machine behind `verifying` / `integrityFailure`: match → promote · mismatch → re-fetch **once** → refuse to render + calm error + Retry · missing/truncated = mismatch. The UI mirrors these as states; it never re-implements the hash logic |
| `docs/design-system/11-voice-and-tone.md` §1, §4, §5 | §1 adab (gentleness outranks copy convention) · §4 empathy-then-path on hard news (offline / interrupted / integrity failure all open with understanding + a path, never fault) · §5 the app is a servant — no exclamation marks, no blame, no "error!" |
| `docs/design-system/01-design-principles.md` §2, §5 | §2 calm-not-cute (no spinner theatrics, no success confetti on `ready`) · §5 private-by-feel (the in-context honest line "this sends nothing about you" and the airplane-mode proof are perceptible facts, not reassurance) |
| `docs/design-system/10-privacy-and-trust-ux.md` | The airplane-mode proof line and the in-context download sentence ("Downloading the Quran files once from a public open-source repository. This sends nothing about you.") this step surfaces; `type.body` / `color.text.secondary` calm styling |
| `docs/science/CLAIMS.md` C-048 | The privacy/offline claim behind the in-context download sentence and the airplane-mode-after proof copy — the only user-facing claim this step asserts; its wording traces to this row |
| Skill `domain-asset-pack-integrity` (+ `template.dart`) | The `DownloadPhase` enum (`idle`/`awaitingFirstDownload`/`downloading`/`downloadInterrupted`/`verifying`/`ready`/`integrityFailure`), the `DownloadState`, the `CorePackDownloadController` (`start`/`retry`/`cancel`), and `corePackDownloadProvider` — all **owned by E05**; this task consumes them, adds no networking import, and only maps each phase to localized copy + controls |
| Skill `eng-add-localized-string` (+ `template.md`) | Every string lands in `app_ar.arb` (ar template) + transcreated `fa`/`ckb`; the progress percentage is `numberFormatFor(locale)`-formatted (fa/ckb arabext, ar arab) inside an ICU placeholder, never spliced; adab gate first; no exclamation marks |
| Sibling E11-T01 | Supplies the step controller and the `/onboarding` route; this task plugs a `DownloadStep` widget into that sequence and gates `canAdvance` on `phase == ready`. T01 owns sequencing; this task owns one step's view + advance-guard |
| Sibling E11-T05 | The coverage-capture grid that follows — it renders muṣḥaf-order juz cells and is the **first** step that could touch reference data; this step's refuse-to-advance guard is what protects it from rendering before `text_checksum_verified_at` is stamped |
| Sibling E11-T10 | Owns the final ar/fa/ckb transcreation lock, the `Semantics`/RTL pass, and the per-locale goldens + offline `HttpOverrides` guard across all steps; this task ships its keys and a first golden, T10 consolidates |

## Implementation notes

This is presentation over an E05-owned controller; the correctness-critical part is the **advance-guard** (no muṣḥaf renders before `ready`) and the **offline behavior** (every state reachable with the radio off), both test-first.

1. **File**: `packages/features/lib/src/onboarding/widgets/download_step.dart` — a dumb `ConsumerWidget` leaf view under the onboarding module (T01's anatomy: `onboarding_screen.dart` View ↔ `onboarding_view_model.dart` ↔ `widgets/` ↔ `onboarding_providers.dart`). The step **imports no networking package** — `dio`/`http`/`dart:io HttpClient` stay quarantined in `/assets` (E05). It `ref.watch(corePackDownloadProvider)` (E05's provider) and renders.
2. **State → view mapping** (one `switch` over E05's `DownloadPhase`, exhaustive, no `default`):
   - `idle` / `awaitingFirstDownload` → calm "one-time download needed … on any connection, once" body + a primary **Retry/Start** button calling `controller.start()`. This is the offline-at-first-run state; it is not an error surface.
   - `downloading` → a determinate progress indicator fed by `state.received / state.total`, the percentage rendered via `numberFormatFor(locale)` in an ICU placeholder, plus the in-context honest line (C-048) and a Cancel that calls `controller.cancel()`.
   - `downloadInterrupted` → calm "the download stopped; you can continue" body + Retry; copy notes nothing partial is kept (the `.part` is discarded by E05).
   - `verifying` → a brief, calm "checking the files" state (no progress bar needed); not a failure.
   - `integrityFailure` → the fail-closed surface: a calm, honest, non-blaming message + Retry. It **must not** offer "continue anyway", a skip, or any path that renders Quran text. `state.failedFile` is **not** shown raw to the user (it is diagnostic, not copy).
   - `ready` → a quiet confirmation (no confetti, no exclamation), the **airplane-mode-after proof** line (C-048), and the controller signals the step is complete.
3. **Advance-guard (TEST-FIRST, correctness-critical)**: expose `bool get canAdvance => phase == DownloadPhase.ready` to T01's step controller, and have the onboarding sequence refuse to move to E11-T05 (coverage) until `ready`. No "Next" affordance is enabled in any other phase. This is the structural enforcement of the epic DoD: "no coverage/confidence step renders any muṣḥaf glyph before `text_checksum_verified_at` is stamped." Write the guard test before the widget.
4. **Trigger policy**: call `controller.start()` once on first entry to the step (e.g. from `initState`/a one-shot `ref.listen`, never inside `build`). Retry re-runs the same `start()` pipeline. Never auto-loop on `integrityFailure` — E05 already re-fetches exactly once internally; the UI offers manual Retry only, no unbounded retry.
5. **Strings** (per `eng-add-localized-string`): keys under an `onboardingDownload*` namespace in `app_ar.arb` first (ar template), then transcreated `fa`/`ckb` (ckb canonical-encoded, flagged provisional). The progress percent is a `plural`-free interpolated message with a `numberFormatFor(locale)`-formatted `{percent}` placeholder. No literal in the widget; all copy via `l10n.*`. No exclamation marks; the integrity-failure and offline strings follow empathy → fact → path → choice. The privacy/airplane-mode copy traces to **C-048**.
6. **RTL / calm styling**: the step renders inside the app's `Directionality.rtl`; logical start/end insets only; `type.body` / `color.text.secondary` per the privacy-trust-ux tokens; progress fill mirrored for RTL. No cloud iconography, no sync spinner aesthetic.
7. **Pitfalls to avoid**:
   - Importing a networking package into `features/` (the banned-import gate fails the build) — watch E05's provider instead.
   - Re-implementing the hash/state machine here — the verify logic is E05's; this widget only reacts to `DownloadPhase`.
   - Enabling "Next" in any phase but `ready`, or offering a "continue anyway" / skip on `integrityFailure` (would breach fail-closed and R1).
   - Showing `state.failedFile`, a raw `DioException`, a stack trace, or a numeric error code to the user.
   - Exclamation marks, "Error!", "Failed", or any blaming/offline-shame copy; success celebration on `ready`.
   - Splicing `"$percent%"` or ASCII digits instead of the `numberFormatFor(locale)` placeholder.
   - Calling `controller.start()` from `build` (re-fires on every rebuild) or auto-retrying on integrity failure.

## Acceptance criteria

- [ ] `download_step.dart` exists under `packages/features/lib/src/onboarding/widgets/`, is a dumb `ConsumerWidget`, and contains **no** `import 'package:dio…'` / `package:http` / `dart:io` networking symbol (verifiable by grep over the file).
- [ ] The view renders a distinct, calm surface for each `DownloadPhase` (`idle`/`awaitingFirstDownload`, `downloading`, `downloadInterrupted`, `verifying`, `integrityFailure`, `ready`) via one exhaustive `switch` — no `default`, no unhandled phase.
- [ ] `downloading` shows determinate progress from `received/total` with the percentage in the active locale's numeral set; a Cancel cancels via E05's controller; the in-context "this sends nothing about you" line (C-048) is present.
- [ ] Every non-`ready` state offers a non-blaming **Retry/Start** (or Cancel where downloading); `integrityFailure` offers **only** Retry — no skip, no "continue anyway", no degraded-render path; `state.failedFile`/raw errors are not shown.
- [ ] The step exposes `canAdvance == (phase == ready)`; the onboarding sequence cannot reach E11-T05 until `ready`; "Next" is disabled/absent in every other phase.
- [ ] The `ready` state shows a quiet confirmation (no exclamation, no celebration) and the airplane-mode-after proof line (C-048).
- [ ] `controller.start()` is invoked once on step entry (not in `build`); Retry re-runs `start()`; the UI never auto-loops on `integrityFailure`.
- [ ] Every user-facing string resolves through `AppLocalizations` (`l10n.onboardingDownload*`); keys exist in `app_ar.arb` (ar template) + `fa` + `ckb` (ckb flagged provisional); no exclamation marks; copy passes the adab gate.

## Tests

`packages/features/test/onboarding/download_step_test.dart` (widget) and `packages/features/test/onboarding/download_step_golden_test.dart` (per-locale golden), `flutter_test`, deterministic, no real network. The download controller is overridden with a **fake** `corePackDownloadProvider` emitting scripted `DownloadState`s (E05 owns the live one; this suite never opens a socket). Real bundled fonts, never `Ahem`. Required cases:

- **Phase → surface mapping**: for each `DownloadPhase`, pumping a fake state shows the expected calm copy and controls (Retry present on offline/interrupted/integrity; Cancel on downloading; quiet confirmation on `ready`).
- **Advance-guard (TEST-FIRST)**: `canAdvance` is `true` **only** for `ready`; a test drives the step through every other phase and asserts no enabled "Next"/advance affordance and that the sequence stays on the download step.
- **Fail-closed surface**: in `integrityFailure`, the only forward control is Retry; assert there is no "continue"/"skip" affordance and no muṣḥaf glyph / reference-data widget is mounted; `state.failedFile` is not rendered as text.
- **Progress numerals**: `downloading` at a known `received/total` renders the percentage in the locale numeral set (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar) — not ASCII digits.
- **No exclamation / blame**: a string sweep over every rendered phase asserts no `!`, no "error"/"failed"/blame token in any locale.
- **Start-once**: entering the step calls the fake controller's `start()` exactly once across rebuilds; Retry calls it again; `integrityFailure` does not auto-retry.
- **Offline guard**: the whole suite runs under an `HttpOverrides` that throws on any socket — proving the *step* opens none (the real download lives in E05); a thrown override fails the test loudly.
- **Per-locale goldens** (fa/ckb/ar, real bundled fonts): the `awaitingFirstDownload`, `downloading`, `integrityFailure`, and `ready` surfaces, RTL, calm tokens, locale numerals — ckb wraps rather than truncates.

## Definition of Done

- [ ] All acceptance criteria met; widget + golden suites green locally and in CI across the offline / l10n / a11y gates.
- [ ] **Offline / no-network (non-negotiable):** the step opens no socket — it watches E05's provider; no networking import in `features/`; the `HttpOverrides`-throwing test proves the radio stays off in the step, and the `ready` state surfaces the airplane-mode-after proof (C-048).
- [ ] **No AI / no audio (non-negotiable):** the path touches no microphone, ASR, or model; it downloads inert, checksum-verified bytes only (C2, R5).
- [ ] **Text fidelity (non-negotiable):** the step is fail-closed — `integrityFailure` offers only Retry and **refuses to render Quran text**; the advance-guard prevents any later step from rendering a muṣḥaf glyph before `text_checksum_verified_at` is stamped (R1, §11.1.1).
- [ ] **RTL + fa/ckb/ar localization:** every string ships ar (template) + fa + ckb transcreated through `gen_l10n` (no hardcoded text); the progress percent renders in the locale numeral set; the surface reads start→end (right→left); ckb wraps; the l10n completeness + RTL-golden gate is green.
- [ ] **Accessibility:** each state's primary action and status is `Semantics`-labelled (e.g. "checking the files" / "one-time download needed"), hit targets ≥48dp, redundant color+label, readable in grayscale; the per-screen audit gate passes (final consolidation in E11-T10).
- [ ] **Sect-neutral adab / no shame:** no exclamation marks, no "error!"/blame copy; offline / interrupted / integrity-failure each open with empathy and a path; `ready` is a quiet confirmation, not a celebration; every string passes the adab gate.
- [ ] **Deterministic tests:** the suite uses a fake `corePackDownloadProvider` with scripted states, real bundled fonts, no hidden clock and no real network; the advance-guard and fail-closed cases were written before the widget.
