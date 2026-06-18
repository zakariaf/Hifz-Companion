# 09 — Asset Packs & Offline Integrity

> **Amendment (2026-06-18) — bundled core.** Tech-decision-log #5/#8 were amended: the **core muṣḥaf is now BUNDLED in the signed app binary** (byte-exact Tanzil Uthmani text, the unmodified KFGQPC QCF V2 per-page fonts, and the QUL layout), verified by a **build-time** SHA-256 manifest — there is **no core download**, so the app is fully usable offline from first launch. The downloader, manifest, and runtime fail-closed verifier described below now govern **OPTIONAL packs only** (reciter audio, future alt-muṣḥaf); the same SHA-256 primitive is reused to re-verify the bundled core when it is first loaded into the reference DB. Read "the pack" below as "an optional pack" except where it explicitly says *bundled core*.

This document specifies how Hifz Companion proves the Quran bytes on the device are exactly the authoritative muṣḥaf — the **bundled core** at build time, and any **optional pack** the one time it is fetched, and then never again. It covers where optional packs are hosted (GitHub immutable Releases, pinned by exact tag), how an on-demand download works (the only network event in the product's life), how every downloaded file — and the bundled core at first load — is verified against a SHA-256 manifest baked into the signed app binary (fail-closed — a mismatch refuses to render Quran text), how the packs are built reproducibly so the community can re-derive our hashes, and how "offline forever" is enforced as a build invariant rather than a promise. It applies the *Decision log: Quran asset distribution & offline integrity* entry (README decision 5, amended) and the *Decision log: No networking beyond asset download* entry (README decision 8, amended), and is grounded in the evidence dossier [research/asset-integrity-and-distribution.md](research/asset-integrity-and-distribution.md) and [PRD §11.1, §11.1.1, §17, §19.3, §20](../PRD.md).

The boundaries are deliberate. This doc owns the *acquisition and integrity* of the asset packs — the bundled-core manifest, the optional-pack downloader, the verifier, the local cache, and the offline guarantee. What the *verified* assets then become — the immutable glyph-font rendering, the overlay painter, the layout geometry — is owned by [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md). The live Drift store the reference DB is built into is owned by [05-persistence-and-encryption.md](05-persistence-and-encryption.md). The CI gates that prove no second network client exists are shared with [11-testing-strategy.md](11-testing-strategy.md), and the license/attestation/release-channel mechanics that publish the packs are shared with [13-oss-repo-and-release.md](13-oss-repo-and-release.md). This doc owns the trust boundary between "untrusted network" and "verified local muṣḥaf."

Two framing rules from the README's outranking rules and [PRD R1, C1](../PRD.md) govern everything below. First: **the sacred text is never rendered from an unverified byte.** A single altered diacritic ends the project, so the integrity gate is fail-closed — when in doubt, refuse, never degrade. Second: **the core is bundled and build-verified, so the network is never in the critical path; the only moment the app extends trust to the network is an optional-pack download, and after it the app phones home to nothing, ever.** The verified local muṣḥaf — bundled at build time — is the root of trust for the lifetime of the install; there is no remote config, no silent re-fetch, no "latest" check, and no first-party server to receive anything.

## At a glance

| Concern | Decision |
|---|---|
| Core delivery | **Bundled in the signed app binary** (Tanzil text + unmodified KFGQPC QCF V2 fonts + QUL layout), verified by a **build-time** SHA-256 manifest — no download, present and verified at first launch |
| Optional-pack hosting | **GitHub immutable Releases** (GA 28 Oct 2025), referenced by **exact tag** baked into the binary — never `latest` ([GitHub: Immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases)) |
| Runtime integrity primitive | **SHA-256** (FIPS 180-4), per-file, compared against a manifest in the **signed app binary** ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)) |
| Verification semantics | **Fail-closed** (the SRI model): mismatch ⇒ reject, re-fetch once, then **refuse to render Quran text** ([MDN: Subresource Integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity)) |
| Trust channel | The app binary (got from a trusted store), **never** a sidecar checksum next to the pack ([bitkode: verify file integrity](https://bitkode.com/how-to-verify-file-integrity-with-sha-256-windows-mac-linux/)) |
| Hashing | Dart-team **`crypto`** package; chunked `startChunkedConversion` for large files ([pub.dev: crypto](https://pub.dev/packages/crypto)) |
| Download client (optional packs only) | One HTTPS GET, no auth/cookies/identifiers; `dio` with `CancelToken` + timeouts ([pub.dev: dio](https://pub.dev/packages/dio)) |
| TLS | Enforce TLS 1.2+/1.3; **no certificate pinning** against GitHub (rotation-outage anti-pattern) ([OWASP: Cert pinning](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)) |
| Storage | Download to **temp**, verify, then move into `getApplicationDocumentsDirectory()` as the canonical offline copy ([DhiWise: app documents dir](https://www.dhiwise.com/post/a-deep-dive-into-getapplicationdocumentsdirectory)) |
| Provenance (CI/audit only) | `actions/attest-build-provenance` + reproducible builds; **not** a mobile runtime dependency ([Reproducible Builds](https://reproducible-builds.org/)) |
| Offline guarantee | A **build invariant**, now stronger: the core is bundled, so the app is fully functional with the network **permanently off** from first launch (only optional reciter audio is unavailable); CI bans all networking outside the one optional-pack downloader module; airplane-mode acceptance test ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)) |

---

## 1. Pack hosting: GitHub immutable Releases, pinned by exact tag

### Decision

The **core muṣḥaf is bundled in the signed app binary** (verified by a build-time SHA-256 manifest — §3), so it is never published-and-downloaded. **Optional** packs — **reciter-audio** and future **alt-muṣḥaf** — ship as **versioned packs** published to **GitHub immutable Releases** on the public, open-source data repository, and referenced by an **exact release tag baked into the app binary, never `latest`** (*Decision log: Quran asset distribution & offline integrity*). The app treats a 404 on a pinned optional-asset URL as "keep using the verified local copy," never as a trigger to fetch something else. No first-party server, API, or CDN we operate exists anywhere in this picture.

### Rationale

- **The repo is itself a form of *waqf*.** Hosting the muṣḥaf as open, community-correctable data on a public repo matches the README's "open-source & auditable" value and [PRD §11.1](../PRD.md) (the data repo "itself a form of *waqf* — auditable, community-correctable open data"). GitHub Releases serves each asset from a clean, predictable, unauthenticated HTTPS URL for public repos ([w3tutorials: GitHub release download links](https://www.w3tutorials.net/blog/is-there-a-link-to-github-for-downloading-a-file-in-the-latest-release-of-a-repository/)), fronted by GitHub's asset CDN — so there is literally nothing of ours for the app to phone home to (research note, Finding 1).
- **Immutable releases tamper-lock the bytes and the tag.** As of the 28 October 2025 GA, "assets can't be added, modified, or deleted" and "Tags for new immutable releases are protected and can't be deleted or moved" ([GitHub Changelog, 2025-10-28](https://github.blog/changelog/2025-10-28-immutable-releases-are-now-generally-available/)). The tag "is locked to a specific commit, cannot be changed, and cannot be deleted while the release exists" ([GitHub: Immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases)). For the muṣḥaf this is the strongest available hosting-layer guarantee that the bytes a pinned URL points at can never quietly become different bytes.
- **Resurrection protection closes the repo-recreate attack.** "Even if you delete a repository and create a new one with the same name, you cannot reuse tags that were associated with immutable releases" ([GitHub: Immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases)). For a project meant to outlive its first maintainer, this forecloses the attack where someone re-creates the repo to re-bind a trusted tag to malicious assets (research note, Finding 2).
- **`latest` is a moving pointer; an exact tag is a fixed contract.** The established SRI best practice is to pin to a specific version, "not a 'latest' tag, as if the file changes, the hash won't match" ([andrewlock: SRI](https://andrewlock.net/avoiding-cdn-supply-chain-attacks-with-subresource-integrity/)). Because the app also carries a frozen SHA-256 manifest (§3), the tag and the manifest move together, atomically, only when the app binary is updated.

### Specification

Pack identity is a compile-time constant, not a runtime lookup. The binary embeds the exact tag and the asset base URL; there is no code path that resolves "the newest release."

```dart
// /assets — pack coordinates are compile-time constants, never resolved at runtime.
class PackCoordinates {
  static const repo = 'hifz-companion/quran-assets';
  static const pinnedTag = 'core-v1.0.0';   // EXACT tag — never 'latest'

  // GitHub immutable-release asset URL: github.com/<repo>/releases/download/<tag>/<file>
  static Uri assetUrl(String fileName) => Uri.parse(
        'https://github.com/$repo/releases/download/$pinnedTag/$fileName',
      );
}
```

The pack taxonomy, taken from [PRD §11.1](../PRD.md):

| Pack | Contents | Delivery | Source / license |
|---|---|---|---|
| **Core (bundled)** | Uthmani text (Tanzil, verbatim + attribution); QUL page/line layout; 604 KFGQPC QCF V2 glyph fonts; scholar-reviewed mutashābihāt dataset | **Bundled in the app binary** — build-time SHA-256 verified, no download | Tanzil (verbatim copy + link); QUL/KFGQPC (per-resource terms) ([Tanzil: Terms](https://tanzil.net/download/); [QUL: QPC font](https://qul.tarteel.ai/resources/font/249)) |
| **Reciter audio (optional)** | One reciter's ayah-level audio | On demand, per reciter; large; skippable | open / attributed |
| **Alt-muṣḥaf (optional, future)** | Other riwāyāt / layouts | On demand (R2 — swappable muṣḥaf) | open |

A versioned **pack manifest** declares every file in a pack. For the **bundled core** it is committed in-repo and embedded in the binary, asserted at **build time** (§3, [PRD §11.3](../PRD.md)); for an **optional** pack it is also an asset in the release, with its expected hash baked into the binary and checked at runtime. The schema is the same:

```jsonc
// core.manifest.json  (one entry per file; the binary pins THIS file's hash too)
{
  "pack": "core",
  "tag": "core-v1.0.0",
  "mushaf": "hafs_madani_15line",
  "files": [
    { "name": "quran-uthmani.db",   "sha256": "9f86d0…",  "bytes": 3211264,
      "source": "tanzil.net", "license": "verbatim+attribution" },
    { "name": "layout-qul.json",    "sha256": "2c26b4…",  "bytes": 1884160,
      "source": "qul.tarteel.ai", "license": "QUL" },
    { "name": "mutashabihat.json",  "sha256": "fcde2b…",  "bytes": 204800,
      "source": "repo", "license": "CC-BY (scholar-reviewed)" },
    { "name": "QCF_P001.ttf",       "sha256": "486ea4…",  "bytes": 40960,
      "source": "kfgqpc", "license": "KFGQPC" }
    // … one entry per font through QCF_P604.ttf (604 fonts) …
  ]
}
```

The manifest records, per asset, both the **SHA-256** and the **source + license**, so a single CI run proves the muṣḥaf is simultaneously *intact* and *lawfully redistributed* (research note, Finding 12; [PRD §11.3, §20.7](../PRD.md)). Surfacing the riwāyah + source attribution in-app satisfies [PRD R2](../PRD.md).

### Pitfalls / what we refuse

- **We refuse `latest` or any moving release pointer.** The only release the app ever references is the exact pinned tag; a "newer pack available" check would reintroduce a network trust the design exists to remove.
- **We refuse to treat a 404 as "go find another file."** If a pinned asset stops resolving (e.g. a maintainer deleted the release), the app keeps using the already-verified local copy and never silently substitutes anything; a pre-download 404 surfaces a calm retry, not a fallback fetch (research note, Finding 2).
- **We refuse a first-party host, mirror-as-default, or API.** Optional public CDN mirrors over GitHub (jsDelivr, Statically) exist only as a documented *manual* fallback host; they change nothing about integrity because the content hash carries end-to-end (§3). We never run a server.

---

## 2. First-launch core setup (bundled, no network) and the optional-pack download

### Decision

The **bundled core** needs no download: at first launch its bundled bytes are loaded, re-verified against the embedded manifest (§3), and built into the reference DB — entirely offline. **Optional** packs (reciter audio, alt-muṣḥaf) are downloaded **on demand** by a **single whitelisted downloader module** in `/assets` — a plain HTTPS GET that carries **no authentication, cookies, or identifiers**, only the public asset URL. Optional downloads go to the **temporary directory**, are verified there (§3), and only a verified pack is moved into app-documents. The download is cancellable, resumable on retry, and — if the device is offline when an optional pack is requested — surfaces a calm, honest "needs a connection once" state with a retry, after which that pack too is permanently local (*Decision log: No networking beyond asset download*; [PRD §11.1.1, §12.1](../PRD.md)).

### Rationale

- **The one network call must leak nothing.** A public, unauthenticated GET to a CDN asset URL carries only that URL — no body, no identifiers — so even the single permitted request reveals nothing about the user (research note, Finding 11; [PRD §17](../PRD.md)). This is what makes "no per-user data ever leaves the device" literally true rather than aspirational.
- **`dio` gives the three controls a one-shot mobile download needs.** It downloads to a file path with `onReceiveProgress`, supports cancellation via a shared `CancelToken`, and enforces `connectTimeout`/`receiveTimeout` ([pub.dev: dio](https://pub.dev/packages/dio)). A multi-hundred-megabyte reciter pack on a flaky connection must be cancellable and time-bounded, not a hung spinner.
- **Download-to-temp-then-promote prevents rendering from an in-flight file.** The convention is durable, hard-to-re-download data in documents and cheap re-downloadable in-flight data in temp ([DhiWise: app documents dir](https://www.dhiwise.com/post/a-deep-dive-into-getapplicationdocumentsdirectory)). The bundled core is the irreplaceable muṣḥaf and lives in the binary; a verified optional pack lives in documents; an unverified download is temp and is never read as Quran (research note, Finding 9).

### Specification

The downloader is the **only** code in the entire app permitted to import a networking package — enforced by the same banned-import CI gate that confines Drift to `/data` (*Decision log: No networking beyond asset download*; [03-coding-standards.md](03-coding-standards.md)).

```dart
// /assets — THE ONLY module allowed to import a networking package (CI-enforced).
class PackDownloader {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),   // large reciter packs over slow links
    // No interceptors that attach auth, cookies, or identifiers. No User-Agent fingerprint.
    headers: const {},
  ));

  /// Downloads one file to a temp path. Returns the temp File on a 200; the caller
  /// must then VERIFY (§3) before the file is ever treated as Quran.
  Future<File> fetchToTemp(
    String fileName, {
    required CancelToken cancel,
    void Function(int received, int total)? onProgress,
  }) async {
    final tmpDir = await getTemporaryDirectory();
    final tmp = File(p.join(tmpDir.path, '$fileName.part'));

    await _dio.downloadUri(
      PackCoordinates.assetUrl(fileName),   // pinned exact-tag public URL
      tmp.path,
      cancelToken: cancel,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true,              // GitHub → objects.githubusercontent.com
        receiveDataWhenStatusError: false,
      ),
    );
    return tmp;   // UNVERIFIED — not yet trusted. §3 decides.
  }
}
```

The first-launch core setup ([PRD §12.1](../PRD.md)) sequences load-bundled → verify → build-DB, with **no network**, so that no partially-trusted state is ever observable:

```dart
// Bundled core: NO network. Load bundled bytes → verify against the embedded
// manifest → build the reference DB. Sequenced so no partially-trusted state shows.
Future<CorePackResult> installCorePack() async {
  final manifest = EmbeddedManifest.core;         // committed in-repo, baked into the binary
  for (final entry in manifest.files) {           // text, layout, mutashābihāt, 604 fonts
    final actual = await sha256OfBundledAsset(entry.name);   // §3 — chunked over the bundled asset
    if (actual != entry.sha256) {
      // A bundled byte cannot be "re-fetched"; a mismatch means a corrupted install.
      return CorePackResult.integrityFailure(entry.name);    // FAIL-CLOSED (§3)
    }
  }
  // Only now, with EVERY bundled file verified, build the DB from the bundled assets.
  await _buildReferenceDb(manifest);              // → /data reference tables (05)
  await _appMeta.set('text_checksum_verified_at', DateTime.now().toUtc());
  return CorePackResult.ready();
}
```

An **optional** pack reuses the download path, with the fail-closed re-fetch-once of §3 (download to temp → `sha256OfFile` → on mismatch delete + re-fetch once → promote to documents). The first-launch core setup yields distinct, honest states; an optional pack requested offline yields its own — never an error that blames the user:

| Condition | App state | Copy posture |
|---|---|---|
| Core being loaded/verified at first launch | `preparingMushaf` | Brief, silent — bundled, no network |
| Bundled core fails its hash (corrupted install) | `coreIntegrityFailure` | Calm honest error + reinstall guidance — never a degraded render |
| Core ready | `ready` | The muṣḥaf is available offline from first launch |
| Optional pack requested while offline | `awaitingDownload` | "This reciter needs a one-time download. You can do this on any connection, once." + Retry |
| Optional-pack download interrupted | `downloadInterrupted` | Resume/retry; the partial `.part` file is discarded, never read |

### Pitfalls / what we refuse

- **We refuse any networking import outside `/assets`.** The CI banned-import gate (`import_rules` / DCM `avoid-banned-imports`) fails the build on a networking import anywhere except this one module; tests additionally install an `HttpOverrides` that throws, weaponizing the test binding's default network block ([Flutter API: TestWidgetsFlutterBinding](https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html); *Decision log: No networking beyond asset download*).
- **We refuse to attach any identifier to the request.** No auth header, cookie, custom User-Agent fingerprint, query parameter, or analytics beacon — the GET carries the public URL and nothing else (research note, Finding 11).
- **We refuse to render from a `.part` or temp file.** An in-flight or unverified download is never read as Quran, even transiently; only a hash-verified file promoted to documents is muṣḥaf.
- **We refuse to treat "offline when an optional pack is requested" as a failure to scold.** The core never needs a connection (it is bundled); when an *optional* pack does, the honest message is that one download is needed once for that pack; the tone is calm and non-blaming ([PRD §12.1](../PRD.md), R3).

---

## 3. Runtime SHA-256 verification (fail-closed)

### Decision

Every downloaded file — **and the bundled core at first load** — is re-hashed with **SHA-256** and compared, byte-for-byte, against the expected digest in the **manifest baked into the signed app binary**. The verification is **fail-closed, exactly like Subresource Integrity**: a match loads the asset; a *downloaded* mismatch is rejected and re-fetched **once**, and if it still mismatches the app **refuses to render Quran text** and surfaces a calm, honest error. A *bundled-core* mismatch cannot be re-fetched (it indicates a corrupted install), so it refuses immediately — the build-time manifest gate (§4, [PRD §11.3](../PRD.md)) is what makes such a mismatch a build failure long before ship. The expected digest is the *independent trust channel* — it comes from the app the user installed from a trusted store, **never** from a checksum file sitting next to the pack (*Decision log: Quran asset distribution & offline integrity*; [PRD §11.1.1](../PRD.md)).

### Rationale

- **SHA-256 is the correct integrity primitive, and a single flipped byte changes everything.** SHA-256 is specified in NIST **FIPS 180-4**, whose digests are intended "to detect whether messages have been changed since the digests were generated" ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)); it has ~128-bit collision resistance with no known collisions ([Wikipedia: SHA-2](https://en.wikipedia.org/wiki/SHA-2)). The avalanche property is exactly what R1 needs: a one-character change to a single diacritic in the Uthmani text yields a totally different digest, so a tampered or truncated pack can never silently pass (research note, Finding 4). The web SRI spec accepts only `sha256`/`sha384`/`sha512` and forbids the broken MD5/SHA-1 ([MDN: SRI](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity)) — we use SHA-256.
- **Fail-closed is the SRI model translated to the muṣḥaf.** SRI tells the browser to compare the computed hash against the expected value; if they match "it will load the resource, otherwise it will refuse to load the resource, and return a network error" ([MDN: SRI](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity)). [PRD §11.1.1](../PRD.md) is precisely this: a pack is "rejected and re-fetched unless its hash matches exactly," and the app "refuses to render Quran text from any unverified asset." Degrading to a best-effort render on mismatch would violate the README's first outranking rule.
- **The expected hash must come from a channel independent of the download.** A checksum hosted next to the file gives only corruption detection: an attacker who can replace the pack can replace its sidecar checksum too ([bitkode: verify file integrity](https://bitkode.com/how-to-verify-file-integrity-with-sha-256-windows-mac-linux/)). The defense is to bake the expected digest into the signed app binary; the app store's app signing is our "second trusted channel," upgrading the check from corruption-detection to tamper-resistance (research note, Finding 6).
- **Flutter has the primitive natively.** The Dart-team **`crypto`** package implements SHA-256 and a chunked-conversion API ([pub.dev: crypto](https://pub.dev/packages/crypto)); large packs (multi-megabyte fonts, hundreds-of-MB audio) are hashed incrementally so the whole file is never held in memory (research note, Finding 9).

### Specification

Large files are hashed by streaming through `startChunkedConversion`, never `readAsBytes` (which would load a whole reciter pack into memory):

```dart
// /assets — chunked SHA-256 so multi-hundred-MB packs never load fully into memory.
Future<String> sha256OfFile(File file) async {
  final output = AccumulatorSink<Digest>();
  final input = sha256.startChunkedConversion(output);
  await for (final chunk in file.openRead()) {   // streamed, bounded memory
    input.add(chunk);
  }
  input.close();
  return output.events.single.toString();        // lowercase hex digest
}

/// Constant-time-ish compare is unnecessary (this is integrity, not a secret),
/// but the comparison is exact string equality on the canonical hex form.
bool digestMatches(String actual, String expected) => actual == expected;
```

The verification decision is a small, total state machine — every branch is enumerated, with no "soft" path:

| Outcome of `sha256OfFile` vs manifest | Action | User-visible result |
|---|---|---|
| Match (first attempt) | Promote to documents | Silent success |
| Mismatch (first attempt) | Delete; re-fetch **once** | Brief "re-checking" state |
| Match (after one re-fetch) | Promote to documents | Silent success |
| Mismatch (after one re-fetch) | Delete; **refuse to render Quran text** | Calm honest error + Retry; never a degraded render |
| File missing / truncated read | Treated as mismatch | Same as mismatch path |

Test vectors anchor the implementation and the goldens ([11-testing-strategy.md](11-testing-strategy.md)). SHA-256 of the empty input and of `"abc"` are fixed, publishable constants that any auditor can confirm:

```
sha256("")    = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
sha256("abc") = ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
```

Beyond these standard anchors, the pack-integrity tests assert three behaviors: (a) the real verified core files hash to their manifest digests; (b) a **single-byte-flipped** copy of `quran-uthmani.db` is **rejected** (the avalanche guarantee, proven, not assumed); (c) a truncated download is rejected. These are golden assertions in CI, so a regression in the verifier fails the build (research note, Finding 4; [PRD §20.1](../PRD.md)).

### Pitfalls / what we refuse

- **We refuse a "soft" mismatch path.** There is no log-and-continue, no "render anyway, flag later," no partial-pack rendering. Mismatch after one re-fetch ⇒ refuse to render Quran text, full stop ([PRD §11.1.1](../PRD.md)).
- **We refuse to trust a sidecar checksum.** The expected digest lives only in the signed binary; a `SHA256SUMS` file in the release is, at most, a *convenience for human auditors*, never an input the app reads to decide trust (research note, Finding 6).
- **We refuse MD5/SHA-1.** Both are cryptographically broken for integrity and excluded by the SRI spec; only SHA-256 (or stronger) gates the muṣḥaf ([MDN: SRI](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity)).
- **We refuse to hash by reading the whole file into memory.** A reciter pack can be hundreds of MB; `readAsBytes` invites OOM crashes on low-end Android — chunked conversion is mandatory ([pub.dev: crypto](https://pub.dev/packages/crypto)).
- **We refuse to re-fetch in an unbounded loop.** Exactly one re-fetch on mismatch, then fail-closed; a tampering CDN edge must not become an infinite-retry battery drain.

---

## 4. Reproducible pack builds and provenance (CI / audit, not mobile runtime)

### Decision

The pack-build pipeline (Tanzil text → normalized DB, QUL layout → tables, font manifest, mutashābihāt dataset) is **reproducible** — deterministic enough that any third party can re-run it and re-derive our published SHA-256 digests bit-for-bit. Each immutable release additionally carries a **build-provenance attestation** (`actions/attest-build-provenance`, free with immutable releases). These are **CI- and audit-time controls only**; the **mobile app verifies nothing but the pinned digest** — no PKI, no Sigstore client, no attestation parsing in the app (*Decision log: Quran asset distribution & offline integrity*; research note, Findings 3, 7, 8).

### Rationale

- **Reproducibility turns "trust us" into "verify yourself."** "A build is reproducible if given the same source code, build environment and build instructions, any party can recreate bit-by-bit identical copies of all specified artifacts," giving "an independently-verifiable path from source to binary code" ([Reproducible Builds](https://reproducible-builds.org/)). For an open *waqf*-style data repo this is the concrete meaning of "open-source & auditable": the community can re-derive every pinned hash from the open source data and confirm we shipped exactly what the source produces (research note, Finding 8).
- **Immutable releases give provenance nearly for free.** Publishing an immutable release "automatically generates a release attestation … containing the release tag, commit SHA, and release assets," in the **Sigstore bundle format**, so anyone can "verify releases and assets using the GitHub CLI or integrate with any Sigstore-compatible tooling" ([GitHub Changelog, 2025-10-28](https://github.blog/changelog/2025-10-28-immutable-releases-are-now-generally-available/); [GitHub: Immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases)). An auditor or F-Droid reviewer runs `gh attestation verify` to confirm the pack was built from our source on our workflow.
- **An attestation is provenance evidence, not a runtime safety check.** GitHub is explicit that "artifact attestations are not a guarantee that an artifact is secure" — they are claims to evaluate against a policy ([GitHub: Artifact attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)). So the attestation belongs in CI/audit, while the *mobile* integrity guarantee stays the simple, offline, PKI-free pinned-digest check (research note, Finding 3) — the right tool in each place.

### Specification

The build is made deterministic by the standard reproducible-builds levers, documented as an exact, re-runnable command:

| Determinism lever | Rule |
|---|---|
| Sorted inputs | Files enumerated in a fixed, sorted order before hashing/packing — never filesystem iteration order |
| Fixed timestamps | Archive/DB build stamps set to a fixed `SOURCE_DATE_EPOCH`, not "now" |
| Pinned toolchain | The pack-builder script, its interpreter, and dependency versions are pinned and recorded |
| No locale leakage | Byte-exact text transforms; `LC_ALL=C`; no locale-dependent sorting or number formatting |
| Documented command | `make packs` (or equivalent) reproduces every artifact and prints each file's SHA-256 |

CI then asserts the chain end-to-end (the build-time analogue of the app's runtime gate):

```yaml
# .github/workflows/release-packs.yml  (sketch — full version in 13-oss-repo-and-release.md)
- name: Build packs reproducibly
  run: make packs SOURCE_DATE_EPOCH=1700000000

- name: Assert pinned hashes match the freshly-built artifacts
  run: |
    sha256sum -c core.SHA256SUMS         # fails the build on any drift
    # and assert each asset's source/license metadata is present (PRD §20.7)

- name: Attest build provenance (free with immutable releases)
  uses: actions/attest-build-provenance@v1
  with:
    subject-path: 'dist/*'
```

A separate CI step verifies the app's **embedded** manifest matches the **bundled core assets** committed in the app repo (and any **optional** pack's pinned checksums against its published release), and that the bundled text matches the authoritative Tanzil hash — mismatch fails the *app* build ([PRD §11.3 step 1, §20.1](../PRD.md)). Optionally, a tiny **minisign** (Ed25519) signature + public key may be published in the repo for a PKI-free, fully-offline-verifiable provenance path ([jedisct1/minisign](https://github.com/jedisct1/minisign/blob/master/README.md); research note, Finding 7).

### Pitfalls / what we refuse

- **We refuse to put Sigstore/attestation verification in the app.** It would add PKI, a transparency-log client, and network dependence to a runtime whose whole point is offline simplicity; the pinned digest is the app's only check (research note, Finding 3).
- **We refuse a non-reproducible pack build.** "It built on my machine" is not auditable; if a third party cannot re-derive our hashes, the "verify yourself" claim is hollow ([Reproducible Builds](https://reproducible-builds.org/)).
- **We refuse to treat an attestation as a security guarantee.** It is provenance evidence evaluated against policy, not proof the bytes are safe; the content hash (§3) is what protects R1 ([GitHub: Artifact attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)).

---

## 5. Transport: TLS without certificate pinning

### Decision

The optional-pack download enforces **modern TLS (1.2+/1.3)** and relies on the platform trust store, but **does not pin GitHub's TLS certificate or public key**. End-to-end integrity is carried by the **content hash** (§3), not the transport (*Decision log: Quran asset distribution & offline integrity*; research note, Finding 10).

### Rationale

- **Cert pinning third-party hosts is an OWASP anti-pattern.** OWASP guidance is that pinning "should only be done when the client and server sides are both controlled by the same party," and "major platform maintainers and industry experts now discourage the use of SSL pinning except in very special cases" ([OWASP: Cert pinning](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning); [OWASP MASTG: testing cert pinning](https://mas.owasp.org/MASTG/tests/android/MASVS-NETWORK/MASTG-TEST-0022/)). We do not control GitHub's certificates, and they rotate.
- **Pinning here would be a self-inflicted outage, for no integrity gain.** A pinned GitHub cert that rotates would break the optional-pack download for new installs until an app update ships — a real availability risk — while buying nothing, because the content digest already protects integrity regardless of which CDN edge served the bytes (research note, Finding 10). Transport security here protects confidentiality and in-flight tampering; the SHA-256 protects integrity end to end.

### Specification

- Require TLS 1.2 or 1.3 for the fetch (platform default on current iOS/Android); do not disable certificate validation, ever.
- Do **not** install a `badCertificateCallback` that returns `true`, and do **not** ship a custom `SecurityContext` that pins a leaf/intermediate.
- The content-hash gate (§3) runs regardless of transport outcome; a successful TLS handshake is necessary but never sufficient to treat bytes as muṣḥaf.

### Pitfalls / what we refuse

- **We refuse certificate/public-key pinning against GitHub.** Rotation would strand new users for no integrity benefit (research note, Finding 10).
- **We refuse to weaken TLS validation.** No `badCertificateCallback => true`, no disabled hostname checks — the download still benefits from transport security even though the content hash is the real guarantee.

---

## 6. Proving "offline forever"

### Decision

"Fully offline" is enforced as a **build invariant and a release gate**, not asserted in prose — and it is now **stronger**: because the core is bundled, the app is fully functional with the network **permanently off from first launch**. A **two-layer CI gate** proves the only network client is the optional-pack downloader: (a) a dependency allow-list step fails on any analytics/ads/backend/crash SDK in the resolved graph; (b) a banned-import rule forbids networking imports everywhere except the single `/assets` downloader module. A **manual airplane-mode acceptance test** confirms every core Quran feature works indefinitely with the radio off from first launch — only optional reciter audio requires the one-time on-demand download (*Decision log: No networking beyond asset download*; [PRD §19.3, §20.6](../PRD.md)).

### Rationale

- **"Offline" must be demonstrable, given the population's privacy stakes.** The Muslim Pro location-data scandal (precise location of 98M+ users reaching brokers via "prayer-time" SDKs) shows that for this user base, surveillance is an existential trust risk, not a cosmetic one (RESEARCH-FINDINGS §4). A no-network *guarantee* the user can verify is a structural answer to that risk, which is why it is a CI gate.
- **The constraints are verbatim F-Droid's entry ticket.** F-Droid's Inclusion Policy bans non-free Play Services/Firebase/Crashlytics, ad, and tracking SDKs ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)); enforcing the same allow-list in our own CI makes the offline/no-telemetry posture a build invariant and makes F-Droid distribution natural ([13-oss-repo-and-release.md](13-oss-repo-and-release.md)).
- **The test binding already blocks the network; we weaponize it.** Flutter's test binding overrides `HttpClient` to return 400, blocking real network in tests ([Flutter API: TestWidgetsFlutterBinding](https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html)); adding an `HttpOverrides` that *throws* makes any accidental network call in a non-download path fail loudly rather than silently succeed.

### Specification

| Gate | Mechanism | Fails the build when |
|---|---|---|
| Dependency allow-list | CI step parsing the resolved dependency graph | Any analytics/ads/backend/crash SDK appears ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)) |
| Banned networking imports | `import_rules` / DCM `avoid-banned-imports` | A networking import appears outside `/assets` (*Decision log: No networking*) |
| Test-time network block | `HttpOverrides` that throws + default test binding | Any code path other than the downloader attempts a connection |
| Airplane-mode acceptance | Manual + scripted journey | Install → enable airplane mode (no core download) → any core Quran feature fails ([PRD §20.6](../PRD.md)) |
| Privacy declaration | Store-listing gate | The "no data collected" declaration is contradicted by a linked SDK ([13-oss-repo-and-release.md](13-oss-repo-and-release.md)) |

The airplane-mode journey is the human-facing proof of the whole chapter: from first launch, with the radio off, the muṣḥaf reader, the Today scheduler, grading, the heat-map, mutashābihāt drills, notifications, and backup all work — because the bundled, build-verified muṣḥaf is the root of trust and nothing else is ever fetched; only optional reciter audio requires a one-time on-demand download.

### Pitfalls / what we refuse

- **We refuse any second network client.** No remote config, no feature flags, no "check for asset update," no crash reporter, no analytics — the downloader is the *only* outbound path, and CI proves it (research note, Finding 11; [PRD §17, §19.3](../PRD.md)).
- **We refuse to extend network trust a second time.** After onboarding, the app never again decides anything based on a network response; the pinned local muṣḥaf is authoritative for the life of the install.
- **We refuse to ship a tracking/ads/backend SDK to "improve" the product.** Such an SDK would void the no-telemetry covenant and F-Droid eligibility simultaneously; the dependency allow-list makes it a hard build failure, not a code-review hope.

---

## References

- GitHub Docs. *Immutable releases* (tag locked to a commit; assets cannot be modified/deleted; repository-resurrection protection; auto-generated release attestation binding tag + commit SHA + assets). https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases
- GitHub Changelog. *Immutable releases are now generally available* (GA 28 Oct 2025; assets/tags immutable; Sigstore bundle format; verify with GitHub CLI / Sigstore tooling). https://github.blog/changelog/2025-10-28-immutable-releases-are-now-generally-available/
- GitHub Docs. *Artifact attestations* (an attestation is provenance evidence, "not a guarantee that an artifact is secure"). https://docs.github.com/en/actions/concepts/security/artifact-attestations
- actions/attest-build-provenance. *Generate build provenance attestations for workflow artifacts.* https://github.com/actions/attest-build-provenance
- National Institute of Standards and Technology. *FIPS 180-4: Secure Hash Standard (SHS)* (SHA-256; digests detect message change). https://csrc.nist.gov/pubs/fips/180-4/upd1/final
- Wikipedia. *SHA-2* (256-bit digest; ~128-bit collision resistance; no known collisions). https://en.wikipedia.org/wiki/SHA-2
- Mozilla Developer Network. *Subresource Integrity* (fail-closed: match ⇒ load, otherwise refuse to load; only sha256/sha384/sha512; defense against supply-chain attacks). https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Subresource_Integrity
- Lock, Andrew. *Avoiding CDN supply-chain attacks with Subresource Integrity* (pin a specific version, never `latest`). https://andrewlock.net/avoiding-cdn-supply-chain-attacks-with-subresource-integrity/
- bitkode. *How to Verify File Integrity with SHA-256* (single-byte change → completely different hash; confirm the expected hash through a second trusted channel; never the sidecar). https://bitkode.com/how-to-verify-file-integrity-with-sha-256-windows-mac-linux/
- pub.dev. *crypto* (Dart team; SHA-256 `convert` + `startChunkedConversion`; SHA-1/224/256/384/512, MD5, HMAC). https://pub.dev/packages/crypto
- pub.dev. *dio* (HTTP client; `download`/`downloadUri` with `onReceiveProgress`; `CancelToken`; `connectTimeout`/`receiveTimeout`; MIT). https://pub.dev/packages/dio
- DhiWise. *A Deep Dive into getApplicationDocumentsDirectory* (documents = durable offline data; temp = re-downloadable in-flight data). https://www.dhiwise.com/post/a-deep-dive-into-getapplicationdocumentsdirectory
- OWASP Foundation. *Certificate and Public Key Pinning* (pin only when both sides are controlled by the same party; experts discourage it otherwise). https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning
- OWASP Mobile Application Security. *MASTG-TEST-0022: Testing certificate pinning.* https://mas.owasp.org/MASTG/tests/android/MASVS-NETWORK/MASTG-TEST-0022/
- Reproducible Builds. *An independently-verifiable path from source to binary code* (bit-by-bit identical artifacts from the same source). https://reproducible-builds.org/
- jedisct1/minisign. *README* (Ed25519 signatures; tiny base64 keys; no PKI). https://github.com/jedisct1/minisign/blob/master/README.md
- F-Droid. *Inclusion Policy* (bans Play Services/Firebase/Crashlytics/ad/tracking SDKs — verbatim the offline/no-telemetry constraint). https://f-droid.org/en/docs/Inclusion_Policy/
- Flutter API. *TestWidgetsFlutterBinding class* (overrides HttpClient to return 400, blocking network in tests). https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html
- Tanzil Project. *Download Quran Text / Terms of Use* (verbatim copies; attribution + link). https://tanzil.net/download/
- Quranic Universal Library (QUL). *QPC V2 Font — 604 per-page glyph fonts.* https://qul.tarteel.ai/resources/font/249
- w3tutorials. *Static link to download a file from a GitHub release* (unauthenticated public-repo asset URL form). https://www.w3tutorials.net/blog/is-there-a-link-to-github-for-downloading-a-file-in-the-latest-release-of-a-repository/
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Asset integrity & distribution research note.* [research/asset-integrity-and-distribution.md](research/asset-integrity-and-distribution.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
