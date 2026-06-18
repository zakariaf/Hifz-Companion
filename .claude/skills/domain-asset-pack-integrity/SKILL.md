---
name: domain-asset-pack-integrity
description: Implement or change the Hifz app's offline asset-pack contract — the one-time GitHub-Releases download, the per-file SHA-256 fail-closed verifier, the pinned manifest, the onboarding core-pack step, and optional reciter/alt-muṣḥaf packs. Use whenever you touch asset download, integrity verification, pack versioning/pinning, the onboarding download screen, audio packs, the `/assets` downloader, or anything that opens the single permitted network socket.
---

# domain-asset-pack-integrity

> **Amendment (2026-06-18) — bundled core.** Tech-decision-log #5/#8 were amended: the **core muṣḥaf is BUNDLED in the signed app binary** (byte-exact Tanzil text + the unmodified KFGQPC QCF V2 per-page fonts + the QUL layout), verified by a **build-time** SHA-256 manifest — there is **no core download**. The downloader, manifest, and runtime fail-closed verifier below now govern **OPTIONAL packs only** (reciter audio, future alt-muṣḥaf); the same SHA-256 primitive re-verifies the bundled core when it is first loaded into the reference DB. Read "the core pack download" below as "the first-launch bundled-core load+verify (no network)", and "the pack download" as "an optional-pack download."

The trust boundary between the untrusted network and the verified local muṣḥaf. This skill governs how Quran assets are proven authentic on the device — the **bundled core** at build time, and **optional** reciter/alt-muṣḥaf packs the one time they are fetched on demand from a public open-source GitHub repo — how every downloaded file (and the bundled core at first load) is re-hashed and compared byte-for-byte against an app-pinned SHA-256 manifest **fail-closed**, and how "offline forever" is held as a build invariant rather than a promise. The core is present and verified from first launch; after any optional download, the app phones home to nothing, ever.

Two outranking rules drive everything here, and they beat any convenience: **the sacred text is never rendered from an unverified byte** (`docs/engineering/09-asset-packs-and-offline-integrity.md` framing rules; `docs/PRD.md` R1, §11.1.1), and **the core is bundled and build-verified — the network is never in the critical path — and the only moment the app extends trust to the network is an optional-pack download** (`docs/PRD.md` C1; `docs/engineering/01-architecture-overview.md` §6).

## When to use

Use when building or changing:
- the `/assets` pack downloader (the single HTTPS-GET module — the only socket in the app)
- the runtime SHA-256 verifier and its fail-closed state machine (match → re-fetch once → refuse to render)
- the pinned pack manifest, exact-tag pinning, or pack versioning
- the first-launch bundled-core setup (load+verify, no network) and any optional-pack download step and its offline / interrupted states
- optional reciter-audio packs or future alt-muṣḥaf packs fetched on demand
- anything that decides trust based on a network response, or that touches the no-network build gate

Do NOT use this skill for → use the named sibling instead:
- what a *verified* asset becomes on screen — glyph-font rendering, overlay painter, layout geometry → use **domain-immutable-quran-rendering**
- the live Drift store the verified reference DB is built into, the single write path → use **eng-persistence-single-write-path**
- the pure scheduling engine and the trust clamp → use **engine-scheduling-trust-clamp**
- the onboarding *flow* sequencing (coverage capture, per-juz confidence, cycle preset) beyond the download step → use **feature-onboarding-coldstart**
- the CI no-network gate, airplane-mode acceptance test, banned-import lint, license/attestation/release plumbing → use **eng-offline-ci-gates**
- the privacy/trust copy and the airplane-mode proof UX → use **ux-privacy-trust-surface**

This skill owns *acquisition and integrity*. The moment bytes are verified and promoted to documents, they belong to the rendering and persistence siblings.

## The canonical pattern

1. **Pin pack identity at compile time — never resolve "latest."** Pack coordinates (`repo`, exact `pinnedTag`, asset base URL) are compile-time constants in `/assets`, baked into the signed binary; there is no code path that resolves the newest release. The app references the **exact pinned tag** on a **GitHub immutable Release**, and treats a 404 as "keep using the verified local copy," never as a trigger to fetch something else. `docs/engineering/09-asset-packs-and-offline-integrity.md` §1 (pinned exact tag, immutable releases, resurrection protection; "we refuse `latest`"); `docs/PRD.md` §11.1.1 (pinned release version + pinned checksums in the binary).

2. **Three packs, one taxonomy.** Core (**bundled in the binary**, build-time SHA-256 verified — no download): Uthmani text (Tanzil, verbatim + attribution), QUL page/line layout, the 604 KFGQPC QCF V2 per-page glyph fonts, the scholar-reviewed mutashābihāt dataset. Reciter-audio (optional, downloaded on demand, large, skippable). Alt-muṣḥaf (optional, future, R2 swappable muṣḥaf). Each pack carries a versioned **manifest** that records, per file, the `sha256` **and** the `source + license` — so one run proves the muṣḥaf is simultaneously *intact* and *lawfully redistributed*, and the riwāyah + attribution can be surfaced in-app (R2). `docs/engineering/09-asset-packs-and-offline-integrity.md` §1 (pack taxonomy + manifest schema); `docs/PRD.md` §11.1 (asset-pack table), R2.

3. **Download to temp, never render in flight.** The downloader is a plain HTTPS GET with **no auth, cookies, identifiers, custom User-Agent, query params, or beacon** — only the public asset URL. Use `dio` with a shared `CancelToken` and `connectTimeout`/`receiveTimeout`; write to `getTemporaryDirectory()` as a `.part` file. A `.part` or any unverified temp file is **never** read as Quran, even transiently. `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 (download-to-temp-then-promote, no identifiers, `dio` controls); `docs/PRD.md` §11.1.1 (request carries only a public asset URL).

4. **Verify with chunked SHA-256, fail-closed.** Re-hash every downloaded file with the Dart-team `crypto` package via `startChunkedConversion` (streamed, bounded memory — **never** `readAsBytes` on a hundreds-of-MB reciter pack). Compare byte-for-byte against the manifest digest in the **signed binary** (the independent trust channel — never a sidecar `SHA256SUMS`). The state machine is total: match → promote; mismatch → delete + re-fetch **exactly once**; still mismatch → **refuse to render Quran text** + calm honest error + Retry; missing/truncated → treated as mismatch. No soft path, no MD5/SHA-1, no unbounded retry. `docs/engineering/09-asset-packs-and-offline-integrity.md` §3 (chunked hash, fail-closed table, what we refuse); `docs/PRD.md` §11.1.1 (reject + re-fetch unless hash matches; refuse unverified assets).

5. **Build the reference DB only from fully-verified bytes.** For the **bundled core** the sequence is load-bundled → verify-each-against-the-embedded-manifest → build-DB → stamp, entirely offline; a mismatch cannot be re-fetched, so it fails closed immediately (and the build-time gate makes such a mismatch a build failure first). For an **optional** pack the sequence is download → verify → promote (move verified files from temp into `getApplicationDocumentsDirectory()`) → use. Either way no partially-trusted state is ever observable, and the build then stamps `text_checksum_verified_at`. The build/promote hand-off crosses into **eng-persistence-single-write-path**; this skill stops at "verified bytes ready for the DB." `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 (sequenced `installCorePack` over bundled assets; optional-pack promote-then-use); `docs/engineering/01-architecture-overview.md` §3.1 (`assets` is the only socket; `data` builds the reference DB).

6. **Setup/download states are honest, never blaming.** The bundled core needs no network: first launch loads+verifies it (`preparingMushaf` → `ready`; a corrupted bundled byte → `coreIntegrityFailure` with calm reinstall guidance — never a degraded render). An **optional** pack requested while offline → `awaitingDownload` with a calm "needs a connection once" message + Retry; interrupted → `downloadInterrupted`, the `.part` discarded. Copy is calm, RTL-correct for fa/ckb/ar, localized via `gen_l10n` (`l10n` package), uses `type.body` / `color.text.secondary`, no exclamation marks, no scolding. Surface the airplane-mode proof here. `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 (state table, "offline when an optional pack is requested is not a failure to scold"); `docs/PRD.md` §12.1, R3; design tokens per `docs/design-system/10-privacy-and-trust-ux.md` (airplane-mode proof, `type.body`/`color.text.secondary`).

7. **TLS yes, certificate pinning no.** Require TLS 1.2+/1.3 and the platform trust store; **never** pin GitHub's certificate/public key, and **never** install a `badCertificateCallback => true` or a custom pinned `SecurityContext`. End-to-end integrity is carried by the content hash (step 4), not the transport — a pinned GitHub cert that rotates would strand new installs for no integrity gain. `docs/engineering/09-asset-packs-and-offline-integrity.md` §5 (TLS without cert pinning; OWASP anti-pattern); `docs/engineering/01-architecture-overview.md` §6 (content-hash pinning, not cert pinning).

8. **Keep the socket quarantined to `/assets`.** No networking symbol (`package:dio`, `package:http`, `dart:io HttpClient`/`Socket`) may appear anywhere except this downloader module; the banned-import lint and dependency allow-list fail the build otherwise, and tests install an `HttpOverrides` that throws. Adding a second network client — remote config, "check for newer pack," crash reporter, analytics — is forbidden. Provenance/attestation (`attest-build-provenance`, minisign) is CI/audit only and never parsed in the app. The enforcement *gates* live in **eng-offline-ci-gates**; this skill must simply not give them anything to catch. `docs/engineering/09-asset-packs-and-offline-integrity.md` §6 (offline-forever as a build invariant) + §4 (attestation is CI/audit, not runtime); `docs/engineering/01-architecture-overview.md` §6 (network quarantined to one module).

## Do / Don't

| Do | Don't |
|---|---|
| Pin an **exact release tag** + base URL as compile-time constants in `/assets` | Resolve `latest`, add a "newer pack available" check, or follow a moving pointer |
| Treat a 404 on a pinned asset as "keep the verified local copy" | Treat a 404 as a trigger to fetch some other file or a mirror by default |
| GET with only the public asset URL — no auth, cookie, identifier, or custom User-Agent | Attach any header/query param/beacon, or run a first-party server, API, or default mirror |
| Download to a temp `.part`, verify, **then** promote to app-documents | Read a `.part` or any unverified temp file as Quran, even transiently |
| Hash with `crypto` `startChunkedConversion` (streamed, bounded memory) | `readAsBytes` a multi-hundred-MB pack into memory |
| Compare against the digest **baked into the signed binary** | Trust a sidecar `SHA256SUMS` the attacker could replace alongside the pack |
| Fail-closed: mismatch → re-fetch once → **refuse to render Quran text** | Log-and-continue, render-anyway-flag-later, or render a partial pack |
| Use SHA-256 only | Use MD5 / SHA-1, or loop re-fetch unboundedly |
| Require TLS 1.2+/1.3 via the platform trust store | Pin GitHub's cert/public key, or set `badCertificateCallback => true` |
| Keep every networking import inside `/assets` | Import `dio`/`http`/`HttpClient` anywhere else, or add a second network client |
| Show calm, RTL, localized states (core: `preparingMushaf`/`ready`/`coreIntegrityFailure`; optional pack: `awaitingDownload`/`downloadInterrupted`) | Blame the user for being offline, or use exclamation marks / shame copy |
| Record `source + license` per file and surface riwāyah + attribution (R2) | Ship an asset without its source/license metadata |

## Checklist

Before this asset-pack work is done:

- [ ] Pack coordinates are compile-time constants in `/assets`: `repo`, **exact** `pinnedTag` (never `latest`), and the GitHub immutable-Release asset base URL — baked into the binary.
- [ ] The pinned **SHA-256 manifest** lives in the signed binary; the manifest records `sha256` + `source` + `license` per file (core text, QUL layout, mutashābihāt, all 604 QPC fonts).
- [ ] The downloader GET carries **only** the public asset URL — no auth, cookie, identifier, custom User-Agent, query param, or analytics beacon; `dio` has `CancelToken` + `connectTimeout`/`receiveTimeout`.
- [ ] Files download to a temp `.part`; nothing in a `.part`/temp path is ever read as Quran.
- [ ] Verification hashes with `crypto` `startChunkedConversion` (bounded memory, never `readAsBytes`) and compares against the binary's digest — not a sidecar checksum.
- [ ] The fail-closed state machine is total: match → promote; mismatch → delete + re-fetch **once**; still mismatch → refuse to render Quran text + calm error + Retry; missing/truncated → mismatch. No soft path; SHA-256 only; exactly one re-fetch.
- [ ] Sequence for the **bundled core** is load-bundled → verify-each → build reference DB → stamp `text_checksum_verified_at` (no network); for an **optional** pack it is download → verify → promote (app-documents) → use; no partially-trusted state observable; hand-off to **eng-persistence-single-write-path** is clean.
- [ ] States are present, calm, non-blaming — core: `preparingMushaf` / `ready` / `coreIntegrityFailure`; optional pack: `awaitingDownload` / `downloadInterrupted`; copy is `gen_l10n`-localized for **fa/ckb/ar**, RTL-correct, `type.body` / `color.text.secondary`, no exclamation marks; airplane-mode proof surfaced (per **ux-privacy-trust-surface**).
- [ ] TLS 1.2+/1.3 enforced via the platform trust store; **no** cert/public-key pinning, **no** `badCertificateCallback => true`.
- [ ] No networking import outside `/assets`; no second network client (no remote config / "check for update" / crash / analytics); attestation/minisign stays CI-only, never parsed in-app.
- [ ] No AI, no ASR, no audio recognition anywhere in the download/verify path (C2); reciter packs are inert audio bytes, fetched only on demand.
- [ ] Adab/integrity: a single altered diacritic is caught by the avalanche property; a single-byte-flipped and a truncated copy are golden-rejected in tests (per **eng-offline-ci-gates**); when in doubt, refuse — never degrade.

A wrong diacritic ends the project, and a second silent network call ends the trust. Both are foreclosed here by structure, not by hope: an exact-pinned hash that refuses to degrade, and a single quarantined socket that never speaks again.

## Files

- `template.dart` — copy-paste scaffold: `PackCoordinates` (pinned tag), the quarantined `PackDownloader` (`dio`, temp `.part`, no identifiers), the chunked `sha256OfFile` + fail-closed `verifyAndPromote` state machine, the sequenced `installCorePack`, and a Riverpod onboarding `download` controller with the calm RTL state enum. Fill the `// TODO` markers.
- `references.md` — the precise governing doc sections, each with the one thing to take from it.

Related skills: **domain-immutable-quran-rendering** (what a verified asset becomes on screen), **eng-persistence-single-write-path** (the Drift reference DB built from verified bytes), **engine-scheduling-trust-clamp** (the pure engine the verified data feeds), **feature-onboarding-coldstart** (the onboarding flow the download step sits inside), **eng-offline-ci-gates** (the no-network build invariant and airplane-mode acceptance test), **ux-privacy-trust-surface** (the privacy copy and airplane-mode proof).
