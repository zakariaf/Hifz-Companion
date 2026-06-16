# references — domain-asset-pack-integrity

The exact governing doc sections for this skill. Only real sections are listed; each line states the one thing to take from it.

## Primary

- `docs/engineering/09-asset-packs-and-offline-integrity.md` §1 (Pack hosting) — **Pin an exact GitHub immutable-Release tag baked into the binary, never `latest`.** A 404 on a pinned asset means "keep using the verified local copy," never "go fetch something else"; no first-party server/API/CDN exists; the pack taxonomy (core / reciter-audio / alt-muṣḥaf) and the per-file manifest (`sha256` + `source` + `license`) live here.
- `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 (The one-time download) — **One whitelisted `/assets` downloader, a plain HTTPS GET with no auth/cookies/identifiers, download-to-temp-then-promote.** The sequenced `installCorePack` (download → verify → promote → build-DB), the `dio` controls (`CancelToken`, timeouts), and the honest offline/interrupted/ready state table; "offline at first run is not a failure to scold."
- `docs/engineering/09-asset-packs-and-offline-integrity.md` §3 (Runtime SHA-256 verification) — **The fail-closed state machine, exactly like Subresource Integrity.** Chunked `startChunkedConversion` (never `readAsBytes`); the expected digest comes from the signed binary, never a sidecar; match → re-fetch once → refuse to render Quran text; SHA-256 only, no MD5/SHA-1, no soft path, no unbounded retry; the avalanche property catches a single altered diacritic.
- `docs/PRD.md` §11.1 + §11.1.1 (Asset source + Download integrity) — **The binary ships pinned SHA-256 + pinned release version; a pack is rejected and re-fetched unless its hash matches exactly, and the app refuses to render Quran text from any unverified asset.** Downloads are HTTPS GET from GitHub Releases / CDN carrying only a public asset URL; the asset-pack table (core/reciter/alt-muṣḥaf, sources, when downloaded).
- `docs/PRD.md` §1 / C1 (Hard Constraints) — **Offline after setup; the only network use is fetching static, public, checksum-verified open data — no backend, accounts, sync, telemetry, remote config, or API we run.** This is the outranking rule the whole skill serves.

## Supporting

- `docs/engineering/01-architecture-overview.md` §3.1 (Packages and allowed imports) — **`assets` is the only module that opens a socket** (`package:http` / `dart:io HttpClient`), quarantined and holding no user data; the verified bytes build the `data` reference DB; `engine`/`models` import no Flutter and no I/O.
- `docs/engineering/01-architecture-overview.md` §6 (The offline guarantee, made auditable) — **"Fully offline" is a build invariant, not a promise:** network quarantined to one module, dependency allow-list, banned-import lint, test-time `HttpOverrides` that throws; content-hash pinning over GitHub immutable releases, **not** TLS cert pinning; no push (server-required), no `url_launcher`/WebView.
- `docs/engineering/09-asset-packs-and-offline-integrity.md` §4 (Reproducible builds & provenance) — **Attestation / `attest-build-provenance` / minisign are CI- and audit-time controls only; the mobile app verifies nothing but the pinned digest** — no PKI, no Sigstore client, no attestation parsing in the app.
- `docs/engineering/09-asset-packs-and-offline-integrity.md` §5 (Transport: TLS without cert pinning) — **Require TLS 1.2+/1.3 via the platform trust store; never pin GitHub's cert/public key, never `badCertificateCallback => true`.** Integrity is the content hash, not the transport; pinning a third-party cert is an OWASP anti-pattern and a rotation-outage risk.
- `docs/engineering/09-asset-packs-and-offline-integrity.md` §6 (Proving "offline forever") — **The two-layer CI gate + airplane-mode acceptance test;** after the one verified download every Quran feature works with the radio off, permanently — the downloader is the only outbound path.
- `docs/PRD.md` §12.1 (Onboarding / Cold-start) — **The one-time core-pack download sits inside onboarding** (welcome/privacy → language + muṣḥaf confirmation → **download + integrity check** → coverage → confidence → cycle preset); the download step is this skill's, the rest is the onboarding sibling's.
- `docs/PRD.md` R1 / R3 / R2 / C2 (Religious integrity + constraints) — **R1:** text fidelity is existential (one wrong diacritic ends the project) → fail-closed. **R3/§12.1:** offline-at-first-run is explained calmly, never scolded. **R2:** state the riwāyah + attribution (manifest `source`/`license`). **C2:** no AI/ASR — reciter packs are inert audio bytes.
- `docs/design-system/10-privacy-and-trust-ux.md` (Privacy & trust UX) — **The download/onboarding copy is a checkable fact, calm and felt:** the airplane-mode proof, `type.body` + `color.text.secondary`, no exclamation marks; a guarantee the user cannot perceive is one they do not trust.

## Sibling skills

- **domain-immutable-quran-rendering** — what a *verified* asset becomes: glyph-font rendering, overlay painter, layout geometry (`docs/PRD.md` §11.2; `docs/engineering/08-quran-data-and-immutable-rendering.md`).
- **eng-persistence-single-write-path** — the live Drift store / reference DB the verified bytes are built into, the single write path (`docs/engineering/05-persistence-and-encryption.md`).
- **engine-scheduling-trust-clamp** — the pure-Dart scheduling engine and the trust clamp the verified data ultimately feeds (`docs/engineering/06-scheduling-engine.md`).
- **feature-onboarding-coldstart** — the onboarding flow the download step is embedded in, beyond the download itself (`docs/PRD.md` §12.1, §7.10).
- **eng-offline-ci-gates** — the no-network build invariant: dependency allow-list, banned-import lint, `HttpOverrides`, airplane-mode acceptance, and the single-byte-flip / truncation golden tests (`docs/engineering/09-asset-packs-and-offline-integrity.md` §6; `docs/engineering/11-testing-strategy.md`; `docs/engineering/13-oss-repo-and-release.md`).
- **ux-privacy-trust-surface** — the privacy copy and the airplane-mode proof the download step surfaces (`docs/design-system/10-privacy-and-trust-ux.md`).
