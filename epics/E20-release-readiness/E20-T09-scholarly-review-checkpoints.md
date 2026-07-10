# E20-T09 — Recorded scholarly checkpoints: the on-device muṣḥaf proof (gate 8) and the mutashābihāt dataset sign-off (gate 7)

| | |
|---|---|
| **Epic** | [E20 — Release Readiness](EPIC.md) |
| **Size** | M (≈1-2 days of coordination + the reviews themselves) |
| **Depends on** | E20-T08 |
| **Skills** | domain-mushaf-text-integrity, domain-mutashabihat-system, domain-adab-and-religious-integrity, eng-add-ci-check |

## Goal

Drive and **record** the two *external* human checkpoints of PRD §20 that no machine gate can supply — the checks a qualified scholar performs, not the developer: **gate 8**, a qualified ḥāfiẓ/scholar (competent in Ḥafṣ ʿan ʿĀṣim) proofs the *rendered* muṣḥaf on a **real device running the release build** — sample pages against a reference Madani muṣḥaf, sajda marks, ayah numbering, basmala placement — confirming that what the pipeline's green SHA-256 and golden gates protect is also what a ḥāfiẓ actually sees; and **gate 7**, a scholar signs off the mutashābihāt dataset as scoped to **objective near-identical/identical wording only** (never thematic or interpretive similarity), with the sign-off cryptographically bound to the exact dataset bytes (SHA-256) the release ships. The deliverable is two committed release artifacts in `docs/release/`, beside E20-T08's conscience-pass record; each closes SHIP or HOLD, and **a missing, pending, or HOLD artifact blocks the release regardless of green CI** — gates 7–8 are recorded sign-off artifacts, not checkboxes (testing-strategy §8). This task authors no screen, string, or production code; a finding files against the owning epic (E05/E13 for rendering, E14 for the dataset). It is fail-closed by construction: **an absent or empty dataset cannot be signed off** — the checkpoint records HOLD, never "vacuously passed."

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/PRD.md` §20 (§20.7, §20.8) | The two human gates verbatim: the mutashābihāt dataset scholar sign-off (gate 7) and the manual muṣḥaf review on device (gate 8); "all must pass" — a recorded sign-off is part of the release contract |
| `docs/PRD.md` §4 (R1, R4) | The covenants these checkpoints close: R1 text fidelity is only *proven to a ḥāfiẓ* by a ḥāfiẓ's eyes on a real device; the mutashābihāt dataset is scholar-reviewed, objective-wording-only — "any one, gotten wrong, ends the project" |
| `docs/engineering/11-testing-strategy.md` §8 | The gate→job mapping this record plugs into: gate 7 = `restraint` (dataset hash) **+ recorded scholar sign-off**; gates 7–8 carry a recorded human sign-off artifact; no merge/release on a skipped gate; the on-device visual proof (not the Linux goldens) is the cross-OS fidelity check |
| `docs/engineering/11-testing-strategy.md` §9 | The text-integrity hash layer the sign-offs bind to: the mutashābihāt dataset and muṣḥaf assets are SHA-256-hashed against the binary-baked manifest — the artifact quotes the same hash it signs |
| `docs/design-system/13-islamic-identity-and-adab.md` §1, §5, §6 | What the scholar's eye checks beyond bytes: the page as the unit of reverence (never decorated, never reflowed), the riwāyah named ("Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf"), neutrality by omission, and the scholar-review boundary — pending review is flagged, never silently passed |
| Skill `domain-mushaf-text-integrity` | The proof's substance: byte-exact Tanzil text, KFGQPC per-page glyph fonts (never the OS shaper), fixed QUL layout, markers as coordinate overlays — the machine half is green gates; the human half is this on-device proof, which "remains a release gate" |
| Skill `domain-mutashabihat-system` | The dataset contract gate 7 verifies: scholar-reviewed confusables scoped to objective near-identical wording, the group (never one sibling alone), no interpretive/thematic edges, no tafsīr leakage; a dataset change re-opens the sign-off |
| Skill `domain-adab-and-religious-integrity` | The checkpoint discipline: when unsure, stop and flag for scholarly review — never improvise; the record is a sober artifact (no celebration); a HOLD outranks the calendar |
| Skill `eng-add-ci-check` | Where the artifacts plug in: the E20-T01 mapping rows for gates 7–8 point at these files; the release workflow (E20-T02) refuses to publish when the artifact for the tagged version is absent or HOLD |
| `docs/science/CLAIMS.md` — **C-027** | The dataset-scope claim gate 7 signs: "objective near-identical/identical wording only (scholar-reviewed)" — its own Notes column says **"needs scholarly sign-off before locking"**; this task is that sign-off, recorded |
| `docs/science/CLAIMS.md` — **C-047** | The honesty covenant: where review is pending, the app says so plainly — this record is the source of truth for whether the in-app "needs scholarly review" flags may come down |
| Sibling **E20-T08** | The internal conscience pass that precedes this task and flags both checkpoints as pending; this task performs and records them beside it in `docs/release/`; T08's record links here |
| Sibling **E20-T01** | Owns the committed gate→job mapping; this task updates the gate-7 and gate-8 rows to point at the two artifact paths (that row edit is the only repo change besides the artifacts) |
| Sibling **E20-T02** | Owns `release.yml`'s refuse-to-publish discipline; the artifact-presence check for the tagged version is T02's job — this task supplies the artifact contract (path, version binding, SHIP/HOLD field) it checks |
| Owning epics **E05 / E13 / E14** | Where findings go: a rendering defect files against E05/E13, a dataset defect against E14 — this task fixes nothing in place |

## Implementation notes

This task is coordination + recording. The only permitted repo changes: the two artifacts in `docs/release/`, and the E20-T01 mapping-row update pointing at them.

1. **Create the two artifacts** (beside T08's conscience pass, same net-new `docs/release/` directory): `docs/release/mushaf-ondevice-proof-v<version>.md` (gate 8) and `docs/release/mutashabihat-dataset-signoff-v<version>.md` (gate 7). Each opens with: reviewer name + qualification (ḥāfiẓ/scholar, riwāyah competence), review date, the exact build reviewed (version, git tag, commit SHA), the device (real hardware, release build — **never** a simulator or debug build), and — for gate 7 — the dataset's SHA-256 exactly as it appears in the binary-baked manifest.
2. **Gate 8 protocol (on-device muṣḥaf proof):** a stratified page sample proofed against a physical reference Madani muṣḥaf — at minimum: the first and last page of several juz across the muṣḥaf, every page carrying a sajda mark, juz/ḥizb boundary pages, basmala treatment (including Sūrat at-Tawbah's absence), ayah-numbering spot checks, and the pages the goldens found most fragile. For each item: confirm glyphs, diacritics, and markers match the reference; confirm weak-line/ayah overlays sit *over* the glyph layer without altering it; confirm zoom/sepia/dark transform the rendered layer, never re-typeset; confirm the riwāyah label is visible where the muṣḥaf is presented. Record a per-item verdict.
3. **Gate 7 protocol (dataset sign-off):** the scholar reviews the shipped mutashābihāt dataset — every group — for: objective near-identical/identical wording only (C-027), no thematic/interpretive/tafsīr-flavored edges, riwāyah consistency with the shipped muṣḥaf, and group completeness (siblings travel together, never one alone — `domain-mutashabihat-system`). The sign-off binds to the dataset content hash; **any later change to the dataset bytes re-opens the checkpoint** (the hash mismatch makes the stale artifact visibly invalid).
4. **Fail-closed on the dataset.** If the release candidate ships **no** dataset (or an empty one), gate 7 records **HOLD — nothing to sign** and the release is blocked; an absent dataset is never "vacuously compliant." (This is live: as of this writing the built app bundles no mutashābihāt dataset — that finding files against E14, and this checkpoint stays HOLD until real, hashed data ships.)
5. **Findings never patched here.** A wrong diacritic, a misplaced marker, a mis-scoped confusable group → file against E05/E13/E14 with the artifact linking the issue; re-run the affected checkpoint after the owning epic's fix lands. This task adds no code, no string, no dataset row.
6. **Wire the contract:** update E20-T01's gate→job mapping rows so gate 7 = `restraint` dataset hash **+** `docs/release/mutashabihat-dataset-signoff-v<version>.md`, gate 8 = on-device proof artifact path; E20-T02's release workflow then refuses to publish a tag whose two artifacts are missing or HOLD.
7. **Do not conflate with the endorsement.** The named-scholar public endorsement (PRD §21, a launch gate for the traditional segment) is a *separate* marketing/trust milestone — these two checkpoints are technical-religious release gates and neither substitutes for the other.
8. **Pitfalls:** proofing on a simulator/debug build or from screenshots; sampling only "easy" pages; a sign-off not bound to the dataset hash (silent post-sign-off swap); treating green Linux goldens as the proof (they are gate 2's machine half — the human proof is precisely the cross-OS/on-device check); recording a pending review as passed; celebration or verdict emoji in the artifacts (sober records, per T08's register).

## Acceptance criteria

- [ ] `docs/release/mushaf-ondevice-proof-v<version>.md` exists: named + qualified reviewer, date, real device, release build (version/tag/commit), the stratified page-sample protocol of note 2 executed with per-item verdicts, and a closing SHIP/HOLD.
- [ ] `docs/release/mutashabihat-dataset-signoff-v<version>.md` exists: named + qualified reviewer, date, the dataset SHA-256 quoted verbatim from the binary-baked manifest, the C-027 scope verdict (objective wording only, no interpretive edges, riwāyah-consistent, groups complete), and a closing SHIP/HOLD — **HOLD recorded if the dataset is absent/empty (fail-closed)**.
- [ ] Both artifacts bind to the exact reviewed build; a dataset-byte or rendering-relevant change after sign-off visibly invalidates the artifact (hash/tag mismatch) and re-opens the checkpoint.
- [ ] E20-T01's gate→job mapping rows for gates 7 and 8 point at the two artifact paths; E20-T02's release contract treats a missing/HOLD artifact as a red gate.
- [ ] Zero production code, strings, screens, or dataset rows were authored or edited by this task; every finding is filed against its owning epic (E05/E13/E14) and linked from the artifact.
- [ ] The in-app "needs scholarly review" flags governed by these checkpoints (C-047 honesty) come down **only** when the corresponding artifact closes SHIP — and that removal is the owning epic's change, referenced from the artifact.

## Tests

This task authors no test code; it consumes and quotes existing deterministic gates.

- The `restraint` SHA-256 re-hash (testing-strategy §9) green at review time — the gate-7 artifact quotes the dataset hash from the same manifest the gate verifies; a mismatch between artifact and manifest is a red release condition (checked by T02's contract).
- The pinned-Linux muṣḥaf goldens and the runtime fail-closed asset verifier green at review time — the gate-8 artifact records them as the machine half its on-device proof completes; it never substitutes for them, nor they for it.
- E20-T02's artifact-presence/verdict check (owned there): a tag with a missing or HOLD artifact for either checkpoint does not publish — this task's artifact format (path + version + SHIP/HOLD) is what that check parses.

## Definition of Done

- [ ] All acceptance criteria met; both artifacts committed as release-blocking records; the release proceeds only with both at SHIP for the tagged version (PRD §20; testing-strategy §8: human checkpoints are recorded sign-off artifacts).
- [ ] **Offline / no-network**: this task adds no network use, no dependency, no code path; the reviews happen on-device and on-paper (PRD C1).
- [ ] **No AI / no microphone**: nothing here records, transcribes, or automates the scholar's judgment — these checkpoints exist precisely because the judgment is human (C2, R5).
- [ ] **Quran text fidelity (R1)**: the on-device proof is the human completion of the byte-exact/SHA-256/golden machine gates — recorded by a qualified ḥāfiẓ against a reference muṣḥaf, on real hardware, release build; pending = HOLD, never waved through (domain-mushaf-text-integrity).
- [ ] **Scholar-reviewed mutashābihāt (R4)**: the dataset sign-off is bound to the shipped bytes, scoped to objective wording only (C-027), fail-closed on absence; a dataset change re-opens it (domain-mutashabihat-system).
- [ ] **Sect-neutral adab**: the artifacts are sober, name the riwāyah, issue no fiqh ruling, and never speak for the Quran; a pending review stays plainly flagged in-app (C-047; domain-adab-and-religious-integrity).
- [ ] **No gamification / no shame**: the records carry no celebration, badge, or verdict theatrics — SHIP/HOLD, reviewer, date, evidence (R3/C6 register, per E20-T08).
- [ ] **Deterministic binding**: both artifacts pin version + tag + commit + (for gate 7) content hash, so "what was reviewed" is reproducible and any drift is mechanically visible; the E20-T01 mapping and E20-T02 contract reference exactly these paths.
