# E17-T02 — Container codec (test-first): the §3 binary header + the normative restore-side parse order, one distinct `BackupError` per stage

| | |
|---|---|
| **Epic** | [E17 — Backup & Restore](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E17-T01 |
| **Skills** | domain-backup-format, eng-write-dart-test, eng-write-to-coding-standards |

## Goal

The `.hifzbackup` container becomes real bytes, test-first. The **writer** emits the fixed big-endian header — magic `HIFZBK` (`48 49 46 5A 42 4B`) + `0x1F` separator + 1-byte format version `0x01` + 1-byte mode (`0x01` plaintext · `0x02` encrypted) + UInt32 BE body length + 3 reserved zero bytes + 32-byte body SHA-256 — followed by the body; minimum valid file 49 bytes; byte-deterministic so T04's goldens are stable. The **reader** executes the eight-step normative parse order of `docs/engineering/10-backup-format.md` §3, returning the correct **distinct** typed `BackupError` at each stage, cheap structural checks before any heavy work, total over arbitrary hostile bytes. This task owns ONLY the binary header grammar and the staged-parse dispatch: step 7's AEAD body is E17-T05's, step 8's payload decode is E17-T03's, and the assembled end-to-end integrity harness (committed goldens, flipped-byte sweep, ≥2 `TZ`) is E17-T04's. Everything lands on the E17-T01 scaffold — the enums, façade signatures, and pure-dependency wall already exist.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/10-backup-format.md` §3 | The normative layout table + restore-side parse order (both reproduced verbatim below); all multi-byte ints big-endian; min valid file = 16 (header) + 32 (hash) + 1 (body) = **49 bytes**; two version axes checked separately (container **format version** in the header, payload **`schemaVersion`** inside the JSON); "we refuse to put `schemaVersion` in the cleartext header of an encrypted file" (fingerprint leak) and "we refuse to trust the body-length field without cross-checking the actual file length" |
| `docs/engineering/10-backup-format.md` §5 | The digest covers **the body only** (bytes `[48 …]`) — "the header is fixed-format and validated structurally, so a flipped header byte is caught by the magic/version/length checks rather than the hash"; the compare is length **and** content; corruption detection, not tamper resistance; no MD5/SHA-1 |
| `docs/engineering/10-backup-format.md` §1 | The exact `BackupError` members this parse returns — `notAHifzBackup` / `newerFormat` / `unknownMode` / `integrityFailed` / `wrongPasswordOrDamaged` / `malformedPayload` — "Distinct, user-mappable failure reasons … Never a generic catch-all" |
| `docs/engineering/10-backup-format.md` §At-a-glance, Container row | "Magic `HIFZBK\x1F` + 1-byte format version + 1-byte mode + JSON or encrypted envelope; self-describing and self-validating" — the one-line contract this codec implements |
| `docs/engineering/10-backup-format.md` §6 | AAD = **the file's 16-byte binary header** — the writer must expose the finalized header prefix so T05 seals/opens against it without re-deriving offsets |
| `docs/PRD.md` §7.12 | The silent-loss covenant this staging enforces: deterministic, identical inputs → identical outcome; a half-copied file must never import as silently-partial history (doc 10 §3's "we refuse to skip integrity on plaintext backups" cites it) |
| Skill `domain-backup-format` (+ `template.dart`) | Pattern 4 (one self-describing, self-validating header; two version axes), Pattern 5 (the normative parse order, a distinct typed error per stage, cheap checks reject hostile input before hashing/decryption), Pattern 6 (SHA-256 in both modes, fail-closed); the template's `_readHeader`/`_writeHeaderPrefix`/`_finalizeHeader` TODO scaffolds. **Known typo, surfaced not silently picked**: the skill prose and the EPIC scope line say "2 reserved zero bytes" — the doc §3 **table** (offset 13, size 3, `00 00 00`) is normative, and only it makes the arithmetic work (16-byte header, hash at 16, body at 48, min 49) |
| Skill `eng-write-dart-test` | Pattern 1 (right tier: pure `package:test`, no widget binding, no simulator — doc 10 §10 requires it for all `backup/` tests), Pattern 11 (test code held to the coding standards); test-first is the epic's rule for the format half |
| Skill `eng-write-to-coding-standards` | Pattern 6 (throwing confined to I/O boundaries with **one typed error**; `on`-typed catches, never bare; no swallowed errors on a backup path), Pattern 2 (full-word names with units — offsets/sizes as named constants), Pattern 4 (`///` on every public API) |
| Sibling **E17-T01** | Supplies the scaffold this task fills: the `BackupMode`/`BackupError` enums, the `HifzBackup.export`/`import` façade signatures (bodies stubbed), and the pubspec dependency wall (models + `crypto` only) — this task adds no dependency |
| Sibling **E17-T03** | Owns step 8's body (JSON decode, `schemaVersion` gate, forward-migration, `malformedPayload`); this task hands it the verified body bytes through a dispatch seam and never decodes JSON itself |
| Sibling **E17-T04** | Owns the assembled integrity/format harness — committed golden files, the exhaustive flipped-byte property sweep, truncation matrix, timezone invariance under ≥2 `TZ`; this task ships only the codec-level unit pins it will build on |
| Sibling **E17-T05** | Owns step 7's body (Argon2id → ChaCha20-Poly1305, the single `wrongPasswordOrDamaged`); consumes the 16-byte header-prefix AAD hook this task exposes |

## Implementation notes

1. **Files** (inside the T01 `backup/` package, e.g. `lib/src/container.dart` + `lib/src/container_constants.dart`): every offset/size/value from the §3 table is a full-word named constant with a `///` doc tracing to the doc row — never an inline magic number (eng-write-to-coding-standards Pattern 2/4).
2. **The writer emits exactly the §3 table** (each row below becomes a golden offset assert in the writer test):

   | Offset | Size | Field | Value |
   |---|---|---|---|
   | 0 | 6 | Magic | ASCII `HIFZBK` = `48 49 46 5A 42 4B` |
   | 6 | 1 | Separator | `0x1F` (US — unit separator; makes the magic non-text-pasteable) |
   | 7 | 1 | Format version | `0x01` |
   | 8 | 1 | Mode | `0x01` = plaintext JSON · `0x02` = encrypted-JSON envelope |
   | 9 | 4 | Body length `n` | UInt32 big-endian; rejected if `16 + 32 + n` ≠ file length |
   | 13 | 3 | Reserved | `00 00 00` (must be zero in v1; non-zero ⇒ reject) |
   | 16 | 32 | Body SHA-256 | digest over bytes `[48 …]` (the body) — §5 |
   | 48 | n | Body | mode `0x01`: canonical UTF-8 JSON (T03) · mode `0x02`: encryption envelope (T05) |

3. **Writer rules:** all multi-byte integers big-endian (`ByteData` + `Endian.big`); **byte-deterministic** — no clock, no randomness, no locale anywhere in the container layer, so the same `(mode, body)` always yields identical bytes (T04's golden stability depends on this); the digest is `sha256` (Dart-team `crypto`, already a T01 dependency) over the body it frames; expose the finalized 16-byte header prefix (offsets 0–15, length field included) as a small API so T05 uses it verbatim as the AEAD AAD (§6) — never a re-derived copy.
4. **The reader executes the normative parse order** (doc 10 §3, reproduced — one distinct error per stage, earlier stage wins):
   1. Length ≥ 49, else `notAHifzBackup`.
   2. Magic `HIFZBK` + `0x1F`, else `notAHifzBackup`.
   3. Format version: `> 0x01` ⇒ `newerFormat`; other non-`0x01` ⇒ `notAHifzBackup`.
   4. Mode ∈ {`0x01`, `0x02`}, else `unknownMode`.
   5. Body-length field matches file size (`16 + 32 + n == file length`), else `notAHifzBackup`.
   6. Verify body SHA-256 (§5); mismatch ⇒ `integrityFailed` (in mode `0x02` the hash covers the ciphertext envelope, so a mismatch is pre-decryption corruption — still `integrityFailed`).
   7. Mode `0x02`: decrypt the envelope; AEAD failure ⇒ `wrongPasswordOrDamaged` — **dispatch seam only; T05 fills the body**.
   8. JSON decode + `schemaVersion` gate (`> current` ⇒ `newerFormat`; decode/validation failure ⇒ `malformedPayload`) — **dispatch seam only; T03 fills the body**.
5. **Reserved-byte rejection:** the §3 table mandates non-zero ⇒ reject, but the step list names no error for it — map it to `notAHifzBackup` alongside the other structural rejections (steps 1/2/5), checked with step 5 **before** the hash, and record that mapping in a `///` doc so it is a stated decision, not silent drift.
6. **Dispatch seams, not implementations, for steps 7–8:** the verified body bytes flow into the T01 stubs through a seam the codec's tests can observe (a recording stub asserts the seam receives exactly the verified bytes). No JSON decoding, no KDF, no cipher code lands in this task.
7. **Totality is structural:** step 1 guarantees 49 bytes exist before any fixed-offset read; step 5 guarantees the body slice before hashing. No `RangeError`/`FormatException`/`ArgumentError` may escape for **any** input bytes — every failure surfaces as exactly one typed `BackupError` through T01's façade shape (coding-standards Pattern 6: one typed error at an I/O boundary, `on`-typed catches, never bare). Format-version and the other cheap checks always precede the SHA-256 — never hash a file that fails steps 1–5.
8. **Pitfalls to avoid:** putting `schemaVersion` in the cleartext header (§3 refusal — it lives in T03's payload); trusting the declared `n` without the `16 + 32 + n == file length` cross-check; hashing before the structural checks pass; a generic catch-all error or a bare `catch`; a digest compare that checks content but not length (§5 snippet requires both); following the "2 reserved bytes" typo instead of the doc table; letting a timestamp, RNG, or locale into the container layer (breaks byte-determinism).

## Acceptance criteria

- [ ] The writer produces, for any `(mode, body)`, a file matching the §3 table byte-for-byte — magic at 0, `0x1F` at 6, `0x01` at 7, mode at 8, UInt32 BE `n` at 9, `00 00 00` at 13–15, body SHA-256 at 16–47, body at 48 — and a 1-byte body yields exactly 49 bytes.
- [ ] The writer is byte-deterministic: two writes of the same `(mode, body)` are identical; no clock/randomness/locale is reachable from the container layer (verifiable by grep over the codec files).
- [ ] The reader implements steps 1–8 in the normative order; each failing stage returns its distinct `BackupError`; a file failing multiple stages reports the **earliest** stage's error.
- [ ] Format `> 0x01` ⇒ `newerFormat`; other non-`0x01` ⇒ `notAHifzBackup`; mode ∉ {`0x01`, `0x02`} ⇒ `unknownMode`; short-file/magic/length-field/reserved-nonzero failures ⇒ `notAHifzBackup`; body-hash mismatch ⇒ `integrityFailed`.
- [ ] Steps 7–8 are dispatch seams into the T01 stubs (T05/T03 fill them later); the seam receives exactly the verified body bytes; no JSON decode and no crypto is implemented in this task.
- [ ] No raw exception escapes the reader for any input (typed `BackupError` only); the codec adds no dependency — the T01 wall (models + `crypto`, no Drift/`sqlite3`/networking/`dart:io`) holds.
- [ ] The finalized 16-byte header prefix is exposed for T05's AAD; every offset/size/value is a named, `///`-documented constant tracing to §3.

## Tests

All pure-Dart `package:test` (doc 10 §10; eng-write-dart-test Pattern 1), deterministic and offline by construction — the package cannot open a socket, and E01's banned-import/no-network gate proves it. Fixed byte fixtures, no clock, no randomness. **Written first.**

- `backup/test/container_writer_test.dart` — **written first**: golden header-offset asserts against the §3 table (every field asserted at its documented offset, for a known stub body, under both mode bytes at the framing level); the 49-byte minimum for a 1-byte body; byte-determinism (two writes → identical bytes); the stored digest equals `sha256` of the body slice `[48 …]` **and covers nothing else** (mutating a header byte leaves the expected digest unchanged — §5's structural-vs-hash split).
- `backup/test/container_parse_order_test.dart` — every stage, every boundary: lengths 0/1/6/7/8/15/16/47/48 ⇒ `notAHifzBackup` (step 1); wrong magic byte or separator ⇒ `notAHifzBackup` (step 2); format `0x02` ⇒ `newerFormat` and format `0x00` ⇒ `notAHifzBackup` (step 3); mode `0x00`/`0x03`/`0xFF` ⇒ `unknownMode` (step 4); declared-`n`-vs-actual mismatch — header-internal truncation, mid-body truncation, the tag-trimmed analogue of an encrypted body, and extra trailing bytes — ⇒ `notAHifzBackup` (step 5); any non-zero reserved byte ⇒ `notAHifzBackup`; one deterministic flipped body byte ⇒ `integrityFailed` (step 6 — the exhaustive flipped-byte sweep and committed golden files are T04's); stage precedence (bad magic **and** bad mode ⇒ `notAHifzBackup`, the earlier stage).
- `backup/test/container_round_trip_test.dart` — write → read of an opaque stub body round-trips body bytes + mode intact through step 6; a recording stub proves the step-7/8 seam is invoked with exactly the verified body bytes; **totality pin**: every truncation of a valid file at every length below full surfaces a typed `BackupError`, never a raw `Error`/`Exception`.

## Definition of Done

- [ ] All acceptance criteria met; the three test files were written before the codec and are green under `dart test` in `backup/`; analyzer and `dart format` clean (eng-write-to-coding-standards).
- [ ] **Offline / no-network**: the codec is pure bytes over the T01 dependency wall — no socket, no `dart:io`, no Drift; the E01 banned-import/no-network gate over `backup/` stays green (C1; PRD §17).
- [ ] **No AI / no audio / no microphone**: the codec is a deterministic serialization of stored truth — nothing records, infers, scores, or runs a model (C1, C2).
- [ ] **Text fidelity (R1)**: the container carries an opaque body and no Quran glyph/text/font/layout byte enters the file at this layer; the muṣḥaf `{id, riwayah, name, checksumSha256}` reference is T03's payload concern; nothing here renders or re-typesets sacred text.
- [ ] **Nothing decays silently / never "safe to drop"**: the fail-closed staged parse is the mechanism that keeps a half-copied file from importing as silently-partial history (PRD §7.12; doc 10 §3/§5) — no code path accepts a file that fails any of steps 1–6, and no copy here implies anything about revision state.
- [ ] **No gamification / no shame (R3, C6)**: this task ships no user-facing surface; the `BackupError` members are neutral, user-mappable reasons whose calm localized copy is T08's — no error string is hardcoded here.
- [ ] **RTL + fa/ckb/ar**: nothing user-facing to localize, asserted honestly — the format is locale-independent (no locale, numeral, or calendar leaks into the header bytes); the ARB copy for each `BackupError` lands with T08.
- [ ] **Accessibility**: no UI in this task; the a11y obligations attach to the T08/T09 surfaces that render these errors.
- [ ] **Deterministic tests**: fixed byte fixtures, no `DateTime.now()`, no randomness, no `TZ` sensitivity at this layer (dates exist only inside T03's payload); writer byte-determinism is pinned; all gates stay green.
- [ ] **CLAIMS**: this task introduces no user-facing number or methodology claim — no `docs/science/CLAIMS.md` row is needed (verified: none cited).
