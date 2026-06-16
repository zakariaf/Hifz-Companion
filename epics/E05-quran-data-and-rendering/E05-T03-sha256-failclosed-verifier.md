# E05-T03 — Chunked SHA-256 verifier + total fail-closed state machine (single-byte-flip + truncation golden-rejected) — test-first

| | |
|---|---|
| **Epic** | [E05 — Quran Data & Immutable Rendering](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E05-T01 (the `MushafEdition` triple, the `ManifestEntry`/`CorePackManifest` schema, and the binary-baked `EmbeddedManifest.core` whose `sha256` digests this verifier compares against) |
| **Skills** | domain-asset-pack-integrity, eng-write-dart-test |

## Goal

The integrity heart of the Quran-data spine exists in `assets` as two pure, correctness-critical functions: `sha256OfFile`, which streams a file through `crypto`'s `startChunkedConversion` (bounded memory — never `readAsBytes`) to a lowercase hex digest; and `verifyAndPromote`, the **total** fail-closed state machine that compares that digest against the manifest entry baked into the signed binary (never a sidecar `SHA256SUMS`) and resolves every branch with no soft path — match → promote; mismatch → delete + re-fetch **exactly once**; still mismatch → refuse to render Quran text; missing/truncated → treated as mismatch. Written test-first: the known SHA-256 anchors for the empty input and `"abc"`, a **single-byte-flipped** `quran-uthmani.db` that is golden-**rejected** (the avalanche guarantee proven, not assumed), and a **truncated** download that is golden-rejected, all exist and fail before the implementation lands. No soft path; SHA-256 only; exactly one re-fetch.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §3 | The verbatim `sha256OfFile` shape (`AccumulatorSink<Digest>` + `sha256.startChunkedConversion`, streamed `file.openRead()`, lowercase hex `output.events.single.toString()`); `digestMatches` as exact string equality on the canonical hex form (integrity, not a secret — no constant-time need); the **total state-machine table** (match→promote · mismatch→delete+re-fetch once · match-after-refetch→promote · mismatch-after-refetch→refuse to render Quran text + calm error + Retry · missing/truncated→treated as mismatch); the fixed anchors `sha256("") = e3b0c442…b855` and `sha256("abc") = ba7816bf…15ad`; the three asserted behaviors — real files hash to their manifest digests, a **single-byte-flipped** `quran-uthmani.db` is rejected, a **truncated** download is rejected; "what we refuse": no soft path, no sidecar checksum, no MD5/SHA-1, no `readAsBytes`, no unbounded re-fetch |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §1, §2 | The expected digest is the **independent trust channel** — the manifest in the signed binary, never a sidecar (§1); the sequencing that surrounds this verifier (`fetchToTemp` returns an **unverified** `.part`; `installCorePack` calls `sha256OfFile`, deletes + re-fetches once on mismatch, returns `CorePackResult.integrityFailure` on second mismatch) — this task owns the verify+state-machine slice that E05-T04 sequences, not the loop body itself |
| `docs/PRD.md` §11.1.1 | "A downloaded pack is **rejected and re-fetched** unless its hash matches exactly; the app **refuses to render Quran text** from any unverified asset" — the product-level statement of the state machine this task makes structural; the pinned SHA-256 checksums ship in the app binary |
| `docs/PRD.md` §11.3 step 3 | Runtime re-verifies every downloaded pack's SHA-256 before first use and refuses unverified Quran assets — the runtime half of the integrity pipeline (CI half is E05-T10) |
| Skill **domain-asset-pack-integrity** (+ `template.dart`) | Canonical pattern step 4 (verify with chunked SHA-256, fail-closed: the total state machine, no soft path / no MD5-SHA1 / no unbounded retry, compare against the digest in the signed binary not a sidecar); the Do/Don't rows "Hash with `crypto` `startChunkedConversion`" / "`readAsBytes` a multi-hundred-MB pack", "Compare against the digest baked into the signed binary" / "Trust a sidecar `SHA256SUMS`", "Fail-closed: mismatch → re-fetch once → refuse to render Quran text" / "Log-and-continue", "Use SHA-256 only" / "MD5 / SHA-1, or loop re-fetch unboundedly"; the checklist line "a single-byte-flipped and a truncated copy are golden-rejected in tests" |
| Skill **eng-write-dart-test** (+ `template.dart`) | Pattern §2 (the `assets` verifier is plain `package:test`, file ending `_test.dart`, run with `dart test` — no `flutter_test`, no widget binding); §8 (the throwing `HttpOverrides` offline guard — this verifier touches **no** network, so the bootstrap's throwing override must stay green; this is *not* the downloader test that opts out); §10 (assert behaviour with a real `expect`, no coverage-percentage gate); §11 (REUSE SPDX header, full-word names, typed `catch`, `dart format`); the Do/Don't "Add an `expect` that asserts behaviour" and "typed `catch`" |
| `docs/science/CLAIMS.md` C-048 | "The app works fully offline … only network use is a one-time, **checksum-verified** public asset download, then airplane-mode forever" — the SHA-256 fail-closed verifier *is* the "checksum-verified" half of that promise. No on-screen number is rendered by this task; C-048 is cited because this verifier is the mechanism behind that user-facing claim (the copy itself ships in onboarding/science screens, not here) |
| Siblings: E05-T01, E05-T02, E05-T04, E05-T06, E05-T10 | **T01** supplies `ManifestEntry.sha256`/`bytes` and `EmbeddedManifest.core` this verifier reads. **T02** supplies `fetchToTemp` returning the unverified `.part` `File` this verifier hashes (its deterministic fake feeds tampered/truncated bytes here). **T04** sequences this verifier inside `installCorePack` (the delete-and-re-fetch-once orchestration lives in T04; the per-file decision logic lives here). **T06** reuses `sha256OfFile`/`digestMatches` to gate each of the 604 fonts before `FontLoader`. **T10** asserts the *same* manifest digests against the real release + the authoritative Tanzil hash in CI — this task proves the runtime check; T10 proves the build-time check |

## Implementation notes

**TEST-FIRST (correctness-critical):** write `sha256_of_file_test.dart` and `verify_and_promote_test.dart` first; the empty/`"abc"` anchors, the single-byte-flip rejection, and the truncation rejection must exist and **fail** before `sha256OfFile`/`verifyAndPromote` are implemented. This is the runtime guard behind R1 — a wrong diacritic ends the project — so the rejections are the spec, and the implementation is whatever makes them go red→green.

1. **`sha256OfFile`** → `packages/assets/lib/src/integrity/sha256_of_file.dart`. Verbatim per engineering 09 §3: `final output = AccumulatorSink<Digest>();` → `final input = sha256.startChunkedConversion(output);` → `await for (final chunk in file.openRead()) input.add(chunk);` → `input.close();` → `return output.events.single.toString();` (lowercase hex). Imports `package:crypto` and `package:convert` (for `AccumulatorSink`) and `dart:io File` only. **Never** `file.readAsBytes()` — a reciter pack is hundreds of MB and would OOM low-end Android; the streamed `openRead()` keeps memory bounded. A missing/unreadable file surfaces as a typed I/O error caught by the state machine (treated as mismatch), not an uncaught throw.

2. **`digestMatches`** → same library or `integrity/digest_match.dart`. Exact string equality on the canonical lowercase hex form: `bool digestMatches(String actual, String expected) => actual == expected;`. No constant-time compare (this is integrity, not a secret — engineering 09 §3 says so explicitly); do not over-engineer it.

3. **`verifyAndPromote`** → `packages/assets/lib/src/integrity/verify_and_promote.dart`. A **total** function over the §3 table. Take a `ManifestEntry` (the expected `sha256` from the binary-baked manifest), a re-fetch callback, and the file-system boundary as injected dependencies (per eng-define-service-boundary — no global `getApplicationDocumentsDirectory()`/`File` singletons, so the test drives it with a deterministic fake). Model the outcome as a **sealed** result type — e.g. `sealed class VerifyOutcome` with `Promoted(File verified)`, `Refused(String fileName)` — never a nullable `File?` or a bool-plus-out-param (a `null` "verified file" is exactly the ambiguous soft path this forecloses). Branches, every one enumerated:
   - hash **matches** first attempt → promote (move temp `.part` → documents) → `Promoted`.
   - hash **mismatches** first attempt → `await tmp.delete()` → re-fetch **once** via the callback.
   - re-fetched hash **matches** → promote → `Promoted`.
   - re-fetched hash **mismatches** → `await retry.delete()` → `Refused(entry.name)` (the caller refuses to render Quran text — no degraded render, no flag-later).
   - file **missing / truncated / unreadable** (the `openRead()` stream ends short or `File` doesn't exist) → treated **identically to mismatch** (the digest of a truncated file differs by the avalanche property; an absent file is a mismatch by construction).
   No third path. No log-and-continue. **Exactly one** re-fetch — a counter or a straight-line two-call structure, never a loop that could retry unboundedly (a tampering CDN edge must not become an infinite-retry battery drain).

4. **Trust channel = the signed binary, never a sidecar.** `verifyAndPromote` reads the expected digest **only** from the `ManifestEntry` (E05-T01's `EmbeddedManifest.core`, a Dart constant compiled into the binary). It must never open, parse, or fall back to a `SHA256SUMS` file shipped beside the pack — an attacker who can swap the pack can swap its sidecar. Make this structural: the function's expected-digest parameter is a `String` from the manifest, and there is no file-read code path for "the expected hash."

5. **SHA-256 only.** `package:crypto`'s `sha256` and nothing else — no `md5`, no `sha1` import anywhere in this slice. The SRI model and FIPS 180-4 are the rationale (engineering 09 §3); MD5/SHA-1 are cryptographically broken for integrity and excluded.

6. **Boundary & purity.** This slice does no networking — the only socket in the app is E05-T02's downloader, and the re-fetch here is a **callback** the caller (E05-T04) supplies, not a `dio`/`HttpClient` call in this file. Grep-clean of `package:dio`/`package:http`/`dart:io HttpClient` in these files; the throwing `HttpOverrides` from the test bootstrap must never trip on this task's tests (they touch the disk, not the network).

7. **Pitfalls to avoid:** `readAsBytes` instead of streamed `openRead()` (OOM on a large pack — the explicit refusal); returning a nullable `File?`/bool from `verifyAndPromote` (re-introduces the soft path the sealed result forecloses); a `while`/`for` re-fetch loop or a retry count > 1 (unbounded retry is refused — exactly one); reading or falling back to a sidecar `SHA256SUMS` (the trust channel is the binary manifest); importing `md5`/`sha1`, or comparing a truncated hex prefix instead of the full digest; treating a missing/short file as anything other than a mismatch (a silent "skip" would let an absent muṣḥaf byte reach the screen); uppercasing/normalizing the hex (the canonical form is lowercase — `Digest.toString()`); adding a networking import to do the re-fetch in-file (it is the caller's injected callback).

## Acceptance criteria

- [ ] `sha256OfFile` exists in `packages/assets/lib/src/integrity/sha256_of_file.dart`, hashes via `crypto`'s `startChunkedConversion` over a streamed `file.openRead()` (bounded memory), returns the lowercase hex digest, and contains **no** `readAsBytes` call (verifiable by grep).
- [ ] `sha256OfFile` reproduces the published anchors exactly: an empty file → `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`; a file containing `"abc"` → `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`.
- [ ] `digestMatches` is exact lowercase-hex string equality; no constant-time compare, no prefix/substring match.
- [ ] `verifyAndPromote` is a **total** function returning a **sealed** result (`Promoted`/`Refused`), never a nullable `File?` or a bare bool; every branch of the §3 table is reached by a test.
- [ ] On first-attempt **match** the temp file is promoted to documents and `Promoted` is returned; on first-attempt **mismatch** the temp file is deleted and exactly **one** re-fetch occurs.
- [ ] On a **second** mismatch the re-fetched temp is deleted and `Refused(fileName)` is returned — no promotion, no degraded render, no third attempt.
- [ ] A **single-byte-flipped** `quran-uthmani.db` and a **truncated** `quran-uthmani.db` are both **rejected** (digest differs → mismatch path), proving the avalanche guarantee structurally.
- [ ] A **missing** / unreadable file is treated identically to a mismatch (it follows the delete-and-re-fetch-once → refuse path), never silently skipped or promoted.
- [ ] The expected digest is read **only** from the injected `ManifestEntry` (the binary-baked manifest); no code path opens or falls back to a sidecar `SHA256SUMS`.
- [ ] No networking import (`dio`/`http`/`dart:io HttpClient`) appears in these files; the re-fetch is an injected callback, not an in-file network call.
- [ ] SHA-256 only — no `md5`/`sha1` import anywhere in the slice; `dart format` + analyzer/lint clean; the REUSE SPDX header is present on every file.

## Tests

All tests are plain **`package:test`** under `packages/assets/test/integrity/`, run with `dart test` (the `assets` package is not Flutter-bound for this slice — per eng-write-dart-test §2). The shared test bootstrap installs the **throwing `HttpOverrides`** offline guard (eng-write-dart-test §8); these tests must **not** trip it (they touch the disk via a temp dir / a fake file-system boundary, never the network — this is explicitly *not* the downloader test that opts out). Fixtures use a temp directory created in `setUp` and torn down in `tearDown`, or an in-memory fake `File`/file-system boundary; bytes are constructed directly (no clock, no randomness). Required cases, written **FIRST**:

**`packages/assets/test/integrity/sha256_of_file_test.dart`**
- **Empty-input anchor**: a zero-byte file hashes to `e3b0c442…b855` (exact `==`).
- **`"abc"` anchor**: a file containing the three ASCII bytes `abc` hashes to `ba7816bf…15ad` (exact `==`).
- **Chunk-boundary stability**: a file larger than one `openRead()` chunk hashes to the same digest as the in-memory `sha256.convert(bytes)` of its bytes — proving the streamed accumulation matches the one-shot conversion across chunk boundaries (the bounded-memory path is correct, not just cheap).
- **Determinism**: the same file hashed twice yields the identical digest.

**`packages/assets/test/integrity/verify_and_promote_test.dart`** — the fail-closed table, branch by branch, with a deterministic fake file boundary + a re-fetch callback whose outputs the test scripts:
- **Match → promote**: a temp file whose bytes hash to the manifest digest is promoted to the documents boundary and `Promoted` is returned; the re-fetch callback is **never** invoked.
- **Single-byte-flip → rejected (the avalanche guarantee, proven)**: take a known-good `quran-uthmani.db` fixture, flip exactly one byte, and assert its digest ≠ the manifest digest, the temp is deleted, and — with the re-fetch also returning the flipped bytes — the outcome is `Refused('quran-uthmani.db')`. (R1's existential check: a single altered diacritic can never pass.)
- **Truncation → rejected**: a `quran-uthmani.db` fixture truncated by N bytes hashes ≠ the manifest digest and resolves to `Refused` (with the re-fetch also truncated); a re-fetch that returns the **full** bytes resolves to `Promoted` (proving the re-fetch path heals a transient short download).
- **Mismatch then match → promote after exactly one re-fetch**: first fetch tampered, re-fetch clean → `Promoted`; assert the re-fetch callback was invoked **exactly once** (a call counter), never twice.
- **Mismatch then mismatch → refuse**: both fetches tampered → `Refused(fileName)`; the re-fetch callback invoked **exactly once**; no promotion to documents occurred (the documents boundary is untouched).
- **Missing / truncated read → treated as mismatch**: an absent or short-reading file follows the same delete-and-re-fetch-once → refuse path; it is never promoted and never silently skipped.
- **No-soft-path exhaustiveness**: a `switch` over the sealed `VerifyOutcome` with no `default` compiles, proving the result type has no third "render anyway" state.
- **Trust-channel isolation**: the expected digest comes only from the injected `ManifestEntry`; a deliberately-wrong sidecar file placed in the fixture directory has **no** effect on the outcome (the verifier never reads it).

No golden, widget, or integration test in this task — there is nothing rendered or fetched. The CI checksum gate against the *real* release packs and the authoritative Tanzil hash is E05-T10; the real-font visual-diff is E05-T11.

## Definition of Done

- [ ] All acceptance criteria met; both suites green under `dart test` locally and in CI on every PR; written test-first (the anchors + single-byte-flip + truncation rejections existed and failed before the implementation).
- [ ] **Offline / no-network (non-negotiable):** these files import no networking symbol; the re-fetch is an injected callback; the throwing `HttpOverrides` offline guard stays green and is never tripped by this task's disk-only tests; E01's banned-import + dependency-allow-list gates stay green.
- [ ] **No AI / no microphone:** nothing in the hash or verify path touches AI, ASR, or audio; the verifier is pure byte-comparison arithmetic.
- [ ] **Quran text fidelity (existential):** a single-byte-flipped `quran-uthmani.db` and a truncated download are both golden-**rejected**, proving the avalanche guarantee; the verifier reads the expected digest only from the binary-baked manifest, never a sidecar; SHA-256 only, no MD5/SHA-1.
- [ ] **Fail-closed verification:** the state machine is **total** (match→promote · mismatch→delete+re-fetch once · still mismatch→refuse to render Quran text · missing/truncated→mismatch), modelled as a sealed result with no nullable/soft path; **exactly one** re-fetch (no unbounded loop); the refuse branch yields no render.
- [ ] **RTL + fa/ckb/ar localization:** N/A by construction — this slice produces no user-facing string. The calm honest "could not verify · Retry" copy and its FSI/PDI-isolated, locale-numeral presentation live in the onboarding state surface (E05-T04 / E11 via `l10n`); this task returns a typed `Refused(fileName)` the chrome maps, never hardcoded copy.
- [ ] **Accessibility:** N/A — no widget, no `Semantics`; the error surface that carries them is E05-T04.
- [ ] **Sect-neutral adab:** the verifier encodes no riwāyah/madhhab assumption; it compares opaque bytes to an opaque digest; when in doubt it **refuses**, never degrades — the adab of reverence toward an unverified muṣḥaf is "do not show it," made structural here.
- [ ] **Nothing safe to drop:** the verifier marks nothing optional; a missing/short file is a refusal, not a skip — no Quran byte is ever waved through.
- [ ] **Deterministic tests:** plain `dart test`, no clock, no network, no randomness; fixtures are direct byte/temp-file constructions; every `public` member has a `///` doc comment; typed `catch` on the I/O boundary; the REUSE SPDX header is present; `dart format` + analyzer/lint clean.
