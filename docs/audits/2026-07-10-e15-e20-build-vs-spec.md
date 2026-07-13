# E15–E20 build-vs-spec comparison — 2026-07-10

E15–E19 were built **before** their per-task files existed ("built blind" from each EPIC.md + the design docs). On 2026-07-10 the missing 61 task files were retro-authored from the governing docs (deliberately without reading the built code, so the specs record *intent*), and the build was then audited against them: one comparison auditor per epic (every acceptance criterion checked, file:line evidence), then one adjudicator per epic who **adversarially re-verified every claimed gap** before accepting it, and classified each surviving item as:

- **add-to-code** — the spec demand stands; build it;
- **amend-task-file** — the build diverged acceptably (or the retro-spec over-reached); amend the spec to the justified reality;
- **remove-from-code** — the build contains something the docs forbid;
- **defer** — real, consciously postponed.

Companion document: `2026-07-10-full-app-audit.md` (the whole-app audit; its F-findings overlap several items below).

## The cross-epic verdict

Built blind, the epics consistently got the **non-negotiables right** — engine-honest data, min-leaning aggregates, persist-before-republish, append-only logs, calm adab copy, no gamification, offline — and consistently fell short on **breadth**: secondary surfaces, cross-feature handoffs, and above all **tests** (E15 shipped 2 test files against ~35 specced; E19's golden/a11y closure and E15-T10's suite don't exist). Architectural divergences are mostly defensible simplifications that should be *amended into the specs*, not rebuilt. Two built details actively violate the project's own honesty posture and must be **removed**:

1. **E19 (blocker): the C-048 grade coercion.** The build coerces the CLAIMS register's deliberate `[TRAD-equivalent project rule]` grade into `[TRAD]` in both the register and the drift gate (whose own test pins the coercion) — so the science screen labels the app's *own design rule* as "traditional scholarship." This inverts E19-T01's explicit stop-and-raise instruction on exactly the surface built to earn scholars' trust. Remove the coercion; raise the CLAIMS.md amendment instead.
2. **E15 (major): the crisp per-page percentage** (e.g. ۸۷٪) on zoom-sheet cells — more precise than the detail sheet's own range-in-words, precisely what C-025/T04 forbid.

## Per-epic summaries

### E15 — Progress & Heat-map · 8 partial, 2 divergent, 1 not-built (T10)

The hardest parts are real: R computed on read via the pure engine, a genuinely min-leaning juz roll-up pinned by test, VSUP muting from provenance, glyph-free, offline, no scoreboard. But the mihrab reskin replaced the doc-mandated 604-cell whole-Quran overview with a 30-juz tile wall + per-juz zoom — the "keep your Quran green" at-a-glance map never appears on one screen. The detail sheet is a navigational dead end (no recite/reader handoff, hardcoded Gregorian), the forecast is one 7-day total, and T10's golden/CVD/offline suite doesn't exist.

Key adjustments (17 total): **remove** the crisp percentage · restore the 604-cell overview · add recite/reader handoffs + calendar wiring to the detail sheet · per-day forecast rows · move weakest-first sorting out of the widget · re-key providers to family+autoDispose · build T10's test suite (blocker) · backfill per-task tests · amend specs to bless the reskin's tile-wall banner/legend/star aesthetic.

### E16 — Settings, Profiles & Teacher · 4 met, 6 partial, 2 divergent

Built to a materially different shape (one scrolling Settings surface, shared picker primitive, full profiles screen instead of a chip) — but the core disciplines hold: persist-before-republish writers, structural display-transform boundary, halaqa write-isolation proven by test, riwāyah named, per-locale goldens + adab lint. Real losses: **active profile never persisted** (documented `app_meta.active_profile` key unimplemented — every cold start reverts to the first profile; the top fix), the PRD §15.2 numeral picker silently dropped, no stored Quran font-size preference, and the headline "calendar flip leaves due_at byte-identical" test is vacuous as written.

Key adjustments (14): persist/restore active profile · write the real display-transform invariant test · ratify-or-reverse the numeral-picker drop via explicit amendment · add a quick profile affordance outside Settings · persist Quran zoom per profile · delete the dead `packages/profiles` stub · several spec amendments to the shipped architecture.

### E17 — Backup & Restore · 1 met, 7 partial, 1 divergent

The format core is high-fidelity (container byte-for-byte per doc 10 §3, canonical payload, true set-union merge, 44 tests green under the TZ matrix). The shell layer falls short: no BackupController/status line/stale nudge, Argon2id runs on the UI isolate, **a full-history temp `.hifzbackup` survives "Erase everything"**, and the erase gate uses double-tap instead of the specced hold-to-confirm. The headline divergence is safety-critical: **import coerces hostile Argon2 params into range and derives anyway** (spec demands validate-and-refuse with zero KDF calls), maps unknown KDF ids to "wrong password," and skips NFC passphrase normalization; an unspecced honesty defect — **encryption-ON with an empty passphrase silently exports plaintext**.

Key adjustments (15): validate-and-refuse Argon2 params · NFC normalization (with decision-log amendment) · off-isolate export/import · backup controller + dated status line · temp-file sweep · hold-to-confirm erase · require a passphrase when encryption is on · amend the spec's merge-weight rule (max, not summed) to the built, idempotence-preserving reality.

### E18 — Reminders · 4 partial, 7 divergent (behaviorally faithful, architecturally different)

Everything the epic's DoD actually gates is present and tested: off-by-default opt-in, persist-before-schedule, cancel-then-arm convergence, pure DST-safe fire-time math, locale-numeral RTL goldens, calm traced copy behind the CI adab gate. Almost no task's specified *shape* exists (no dedicated table, no permission gateway class, no standalone reconciler) — mostly post-hoc over-specification; amend. The one substantive question: **enabling commits the pref regardless of the OS grant** (switch can read "on" while the OS blocks) — decide and codify the permission-honesty model.

Key adjustments (14): codify the permission model (top item) · seeded stale-state convergence proof · DST gap/ambiguity vectors · a failure path with scripted-failure fakes · the rest are spec amendments to the built shape.

### E19 — Science Screen & Claims · 2 partial, 6 divergent, 2 missing (T08, T10)

A leaner but real trust surface: typed fail-closed 47-claim register parity-gated against CLAIMS.md on every PR, calm source rows, correct mounting, full fa/ckb/ar, quarantined link launcher. Structural substitutions are defensible (amend). The blocker is the **C-048 grade coercion** (above). Also genuine: the specced referenced-claim-id scan over app source/ARB (the machine-checkable half of non-negotiable 7) was never built, T10's a11y/golden closure is mostly absent, and the grade legend sits below the fold of a 47-row scroll.

Key adjustments (16): remove the C-048 coercion (blocker) · build the claim-id scan · build the a11y/golden/offline closure · make the legend reachable · plus spec amendments to the shipped projection architecture.

### E20 — Release Readiness · all 9 not-built (verified)

Nothing of E20's own deliverables exists, though earlier epics laid real scaffolding (five-job ci.yml, the tool/ gate scripts with meta-tests, LICENSE §7 exception, DCO text, REUSE wiring, throwing-HttpOverrides bootstrap). `release.yml` is a stub: subset gate re-run, build/sign/attest still commented TODO, release builds debug-signed. No airplane-mode acceptance test, no SECURITY/PRIVACY.md, no PrivacyInfo.xcprivacy, no fastlane tree, no verify-yourself doc, no `docs/release/` records. Gate 7 is fail-closed HOLD by construction — no mutashābihāt dataset ships (files against E14).

Key adjustments (10): complete `release.yml` (the keystone — everything else feeds it or is checked by it) · gate→job mapping as a checked artifact · airplane-mode acceptance journey · trust pack + privacy posture + store metadata + verify-yourself.md · human checkpoints (T08/T09) correctly deferred until a release candidate exists.

## Where this feeds the master backlog

Combined with the full-app audit's priority order, the E15–E20 items slot in as: the two **remove-from-code** honesty items (E19 C-048, E15 percentage) belong immediately after the runnable-build fix (they are cheap and reputation-critical); the E16 active-profile persistence joins the teacher-loop cluster; E17's import-hardening cluster is its own safety item; the test backfills (E15-T10, E19-T10, per-task suites) gate E20; and E20 itself remains the final wave, now with actionable specs.

*Full per-task verdicts with file:line evidence: workflow journal `wf_726ad15b-910` (12 agents: 6 comparison auditors + 6 adversarial adjudicators; 5 auditor claims rejected on re-verification and excluded above).*
