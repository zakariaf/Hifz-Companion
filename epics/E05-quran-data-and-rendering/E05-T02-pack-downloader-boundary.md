# E05-T02 — Quarantined /assets PackDownloader behind an injectable boundary with a deterministic fake

| | |
|---|---|
| **Epic** | [E05 — Quran Data & Immutable Rendering](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E05-T01 (`PackCoordinates.assetUrl` + the `ManifestEntry`/`EmbeddedManifest` schema this downloader fetches by name) |
| **Skills** | domain-asset-pack-integrity, eng-define-service-boundary, eng-write-dart-test |

## Goal

The app's single whitelisted networking module exists in `packages/assets/`: a `dio` HTTPS GET to the pinned exact-tag GitHub immutable-Release asset URL that carries **no** auth/cookie/identifier/custom User-Agent/query-param/beacon, with a shared `CancelToken` and `connectTimeout`/`receiveTimeout`, streaming to a temporary `.part` file that is never read as Quran. It sits behind an injectable Dart interface (`AssetDownloader`) declared as a Riverpod `Provider` with a throwing placeholder, wired live only at the composition root, and shadowed by a hand-written deterministic fake (`FakeAssetDownloader` serving bytes from an in-memory map) so every other test stays offline. TLS 1.2+/1.3 comes from the platform trust store — no cert/key pinning, no `badCertificateCallback`. This is the only `package:dio`/`dart:io HttpClient` import in the whole app; verification and promotion are not this task (E05-T03/T04).

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §2 (one-time download) | The exact `PackDownloader` shape: `dio` `BaseOptions(connectTimeout: 30s, receiveTimeout: 10m, headers: const {})`, `fetchToTemp(name, {cancel, onProgress})` → temp `.part` via `getTemporaryDirectory()`, `downloadUri(PackCoordinates.assetUrl(name), …, followRedirects: true, receiveDataWhenStatusError: false)`; returns an UNVERIFIED file; the "refuses any networking import outside `/assets`", "attach no identifier", "never render from a `.part`" rules |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §5 (TLS without cert pinning) | Require TLS 1.2+/1.3 via the platform trust store; **no** `badCertificateCallback => true`, **no** custom pinned `SecurityContext`/leaf/intermediate; integrity is the content hash (§3, not this task), never the transport |
| `docs/PRD.md` §11.1.1 (download integrity, guards R1) | HTTPS GET from GitHub Releases / its CDN, "no API we run, no per-user data sent — the request carries only a public asset URL"; one-time, then permanently offline |
| `docs/engineering/01-architecture-overview.md` §3.1, §6 | `assets` is the only module that may open a socket; networking is quarantined to one CI-greppable place; "no global singletons — side effects cross layers as injected dependencies" |
| Skill `domain-asset-pack-integrity` (+ `template.dart`, steps 3, 7, 8) | The download-to-temp scaffold (`PackDownloader.fetchToTemp`), "GET with only the public asset URL", TLS-yes/pinning-no, the socket-quarantine rule and the "never a second network client" foreclosure |
| Skill `eng-define-service-boundary` (+ `template.dart`) | The 5-piece boundary shape: framework-free interface, layer-2 live impl in `assets/`, a thin Riverpod `Provider` with a **throwing placeholder**, the single `main()` `ProviderScope` override, and a plain hand-written fake installed with `overrideWith` — no `get_it`, no mock framework |
| Skill `eng-write-dart-test` (+ `template.dart`, §8) | The throwing-`HttpOverrides` offline bootstrap that this is the **one** test allowed to opt out of (resetting `HttpOverrides.global` to a stub in its own `setUp`); behaviour-asserting cases; REUSE header; no wall clock |
| CLAIMS — C-048 | The "fully offline, never records voice, one-time checksum-verified download" covenant this boundary makes structurally true; **no on-screen number/copy is authored in this task** — onboarding state copy is E05-T04 (this task surfaces typed results only) |
| Sibling E05-T01 | Supplies `PackCoordinates.assetUrl(name)` (the pinned exact-tag URL builder) and the `ManifestEntry` names this downloader is asked to fetch; this task imports those constants, not the other way around |
| Sibling E05-T03 | Consumes the temp `.part` file this returns — the chunked SHA-256 verifier + fail-closed state machine live there, NOT here; this task returns an unverified file and a typed transport failure, nothing more |
| Sibling E05-T04 | The sequenced `installCorePack` (download → verify → promote → build DB → stamp) and the calm RTL `awaitingFirstDownload`/`downloadInterrupted`/`ready` onboarding states; this task exposes the `Provider` + fake that T04 drives, but authors no onboarding flow, no user copy, no Quran-text path |

## Implementation notes

This task is an IO boundary, not correctness-critical arithmetic, so it is not test-first in the engine-vector sense; but the offline guarantee and the no-identifier rule ARE correctness-critical, so write the request-introspection and offline-fake tests below alongside the impl, and keep the boundary a thin plumbing seam.

1. **The interface** → `packages/assets/lib/src/asset_downloader.dart`. A framework-free `abstract interface class AssetDownloader` declaring the one operation, value-typed so it could be named below the boundary:
   ```dart
   abstract interface class AssetDownloader {
     /// Downloads [fileName] from the pinned exact-tag release to a temp `.part`.
     /// Returns the UNVERIFIED temp file; the caller MUST verify (E05-T03) before
     /// any byte is treated as Quran. Throws [AssetDownloadException] on transport failure.
     Future<File> fetchToTemp(
       String fileName, {
       required CancelToken cancel,
       void Function(int received, int total)? onProgress,
     });
   }
   ```
   It references `File`/`CancelToken` (the boundary moves files and is cancellable); keep no manifest/verification/Quran type in the signature.
2. **A typed transport failure** → a small `sealed`/`final class AssetDownloadException` (e.g. `offlineAtFirstRun`, `interrupted`, `httpStatus(int)`, `cancelled`) in the same library. The boundary maps `DioException` to this typed result; it carries **no** user-facing copy — E05-T04 maps it to the calm fa/ckb/ar onboarding states. Do not leak a raw `DioException` across the boundary (it is a `dio` type; keeping it in surfaces `dio` to the feature layer).
3. **The live impl** → `packages/assets/lib/src/live_asset_downloader.dart` (the only file in the app that imports `package:dio` / `dart:io`). Port the §2 spec verbatim:
   - `Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(minutes: 10), headers: const {}))`. **No** `Interceptor` attaching auth/cookies/fingerprint; **no** custom `userAgent`; **no** default query params.
   - `fetchToTemp`: `final tmp = File(p.join((await getTemporaryDirectory()).path, '$fileName.part'));` then `await _dio.downloadUri(PackCoordinates.assetUrl(fileName), tmp.path, cancelToken: cancel, onReceiveProgress: onProgress, options: Options(followRedirects: true, receiveDataWhenStatusError: false));` and `return tmp;` — UNVERIFIED.
   - Wrap the call in a typed `catch (DioException e)` → throw the matching `AssetDownloadException` (`connectionError` ⇒ `offlineAtFirstRun`/`interrupted`; `badResponse` ⇒ `httpStatus`; `cancel` ⇒ `cancelled`). A 404 on a pinned asset is an `httpStatus(404)` the caller treats as "keep the verified local copy" — never a trigger to fetch something else.
   - TLS: rely on the platform default (1.2+/1.3, platform trust store). Construct **no** `SecurityContext`, set **no** `badCertificateCallback`, install **no** `HttpClientAdapter` that disables validation.
4. **The Provider + throwing placeholder** → `packages/assets/lib/src/asset_providers.dart` (or the app composition root per the project's provider home). `final assetDownloaderProvider = Provider<AssetDownloader>((ref) => throw StateError('assetDownloaderProvider must be overridden in main()'));` — a forgotten wiring is a loud startup failure, not a silent socket. The provider is a thin wire: no business logic, no retry policy inside it.
5. **The composition root override** → in `main()`'s `ProviderScope(overrides: [...])`, the **only** place `LiveAssetDownloader` is constructed: `assetDownloaderProvider.overrideWithValue(const LiveAssetDownloader())`. No global mutable singleton; nothing reaches the downloader except via `ref.watch`.
6. **The deterministic fake** → `packages/assets/lib/src/testing/fake_asset_downloader.dart` (a non-`dev` library so widget/integration tests in other packages can import it). A plain `class FakeAssetDownloader implements AssetDownloader` constructed with `Map<String, List<int>> bytesByName` (and optional `Set<String> failWith` / a per-name `AssetDownloadException`), whose `fetchToTemp` writes the bytes to a real temp `.part` and returns it — **no `dio`, no socket**, deterministic and offline. It honours `cancel` (throws `cancelled` if already cancelled) and emits one `onProgress(total,total)` call so progress-driven UIs can be exercised. This is what E05-T04 and every downstream widget test install via `overrideWith`.
7. **Cancellation**: the `CancelToken` is the caller's (E05-T04 owns one shared token across the whole pack); this task only threads it through and maps a cancel to `AssetDownloadException.cancelled`. Do not create a token inside the live impl.
8. **Pitfalls to avoid:**
   - importing `package:dio`/`package:http`/`dart:io HttpClient` anywhere but `live_asset_downloader.dart` (a CI banned-import / allow-list break — the whole point of the quarantine);
   - attaching **any** identifier — an auth header, cookie, custom User-Agent, query param, or analytics beacon (C-048 / §2 "the one network call must leak nothing");
   - adding a "check for a newer pack"/remote-config/crash/analytics client, or resolving `latest` (forecloses the no-second-trust covenant — a 404 means "keep the local copy");
   - setting `badCertificateCallback => true` or pinning GitHub's cert/key (§5 — a rotation outage for zero integrity gain);
   - reading a `.part`/temp file as Quran, or hashing/verifying here (that is E05-T03 — this boundary returns unverified bytes);
   - leaking `DioException` across the interface, or putting user-facing copy / onboarding states in this layer (E05-T04);
   - `readAsBytes`-ing the whole download into memory (the live impl streams to a file via `downloadUri`; verification streams too, in T03);
   - defaulting `assetDownloaderProvider` to a live impl that opens IO at import instead of a throwing placeholder;
   - reaching for a mock framework instead of the hand-written `FakeAssetDownloader`.

## Acceptance criteria

- [ ] `AssetDownloader` exists in `packages/assets/lib/src/asset_downloader.dart` as a framework-free `abstract interface class` with the single `fetchToTemp(name, {cancel, onProgress})` operation and a typed `AssetDownloadException`; the interface file imports no `package:dio`.
- [ ] `LiveAssetDownloader` exists in `packages/assets/lib/src/live_asset_downloader.dart` and is the **only** file in the entire app importing `package:dio` / `dart:io HttpClient` (verifiable by grep / the E01 banned-import + dependency-allow-list gate).
- [ ] The `dio` client sets `connectTimeout: 30s`, `receiveTimeout: 10m`, `headers: const {}`, no interceptors, no custom User-Agent, and no default query params; `fetchToTemp` GETs `PackCoordinates.assetUrl(fileName)` and writes to `<tempDir>/<fileName>.part`, returning the unverified file.
- [ ] The outgoing request carries only the public asset URL — no auth header, cookie, identifier, query param, or beacon (asserted against a capturing fake adapter, see Tests).
- [ ] No `badCertificateCallback`, no custom pinned `SecurityContext`, no validation-disabling `HttpClientAdapter`; TLS is left to the platform default (1.2+/1.3, platform trust store).
- [ ] `DioException` is caught and mapped to the typed `AssetDownloadException`; no raw `DioException` crosses the interface; a 404 surfaces as `httpStatus(404)`, a cancel as `cancelled`.
- [ ] `assetDownloaderProvider` is a `Provider<AssetDownloader>` whose un-overridden body **throws**; `LiveAssetDownloader` is constructed only in `main()`'s `ProviderScope(overrides:)`; no global singleton.
- [ ] `FakeAssetDownloader` (a plain `implements AssetDownloader` class serving bytes from an in-memory map to a temp `.part`, honouring `cancel`/`onProgress`/optional failure) exists in a non-`dev` `testing/` library and uses no networking symbol.
- [ ] Every `public` declaration carries a `///` doc comment; `dart format` + analyzer/lint clean; the REUSE `GPL-3.0-or-later` header is present on every new file.

## Tests

`packages/assets/test/live_asset_downloader_test.dart` and `packages/assets/test/fake_asset_downloader_test.dart` (mirror the source paths), run with `flutter test` (the boundary touches `dart:io`/temp files). This is the **one** suite that opts out of the shared throwing `HttpOverrides`: the live-downloader test installs a capturing in-memory `dio` `HttpClientAdapter` (or `DioAdapter`) in its own `setUp` and resets it in `tearDown`, so it still makes **zero real network calls** while introspecting the request the client *would* send. Every other suite keeps the throwing override untouched. Fixtures use a fixed in-memory byte map — no wall clock, no real socket. Required cases:

- **No-identifier request introspection** (the load-bearing privacy assertion): drive `LiveAssetDownloader.fetchToTemp('QCF_P001.ttf', …)` through the capturing adapter and assert the captured request has the exact pinned URL `https://github.com/hifz-companion/quran-assets/releases/download/core-v1.0.0/QCF_P001.ttf`, an empty/absent `Authorization`, no `Cookie`, no custom `User-Agent` fingerprint, and no query parameters — proving the GET leaks nothing (C-048, §2).
- **Temp `.part` target**: a 200 response writes to `<tempDir>/QCF_P001.ttf.part` and returns that `File`; the bytes match the served body; the file is in temp, not app-documents (never promoted here).
- **Timeouts & options**: the constructed `Dio` carries `connectTimeout == 30s`, `receiveTimeout == 10m`, and `headers` empty; `downloadUri` is called with `followRedirects: true`, `receiveDataWhenStatusError: false`.
- **No TLS weakening**: the client installs no `badCertificateCallback`/custom `SecurityContext` (assert the boundary never sets one — e.g. via a constructed-client introspection or a code-review-backed grep test that `badCertificateCallback`/`SecurityContext(` appear in no `assets` source).
- **Transport-failure mapping**: a simulated `connectionError` ⇒ `AssetDownloadException.offlineAtFirstRun`/`interrupted`; a 404 ⇒ `httpStatus(404)`; an already-cancelled `CancelToken` ⇒ `cancelled`; no `DioException` escapes the interface.
- **Provider wiring**: reading `assetDownloaderProvider` un-overridden throws `StateError`; overriding it with `FakeAssetDownloader` makes `ref.watch(assetDownloaderProvider).fetchToTemp(...)` resolve from the in-memory map.
- **Fake fidelity** (`fake_asset_downloader_test.dart`): `FakeAssetDownloader` writes the mapped bytes to a temp `.part`, emits one `onProgress(total,total)`, throws the configured `AssetDownloadException` for a `failWith` name, throws `cancelled` for an already-cancelled token, and imports no networking package — so downstream tests stay offline by construction.

No golden, no widget, no integration test in this task (nothing is rendered or persisted). The chunked-hash / single-byte-flip / truncation rejections are E05-T03; the sequenced install + onboarding states are E05-T04; the airplane-mode acceptance run is an E01 gate this boundary must simply not trip.

## Definition of Done

- [ ] All acceptance criteria met; both suites green under `flutter test` locally and in CI.
- [ ] **Offline / no-network (existential):** `LiveAssetDownloader` is the only `package:dio`/`dart:io HttpClient` import in the whole app; the E01 banned-import + dependency-allow-list gates stay green; every other suite keeps the throwing `HttpOverrides`, and this suite makes zero real network calls (capturing in-memory adapter only); the outgoing GET carries only the public pinned URL with no identifier (C-048).
- [ ] **No AI / no microphone:** nothing in the download path uses AI, ASR, or audio; the boundary moves opaque bytes and decides nothing about them.
- [ ] **Quran text fidelity (existential):** the downloader returns an **unverified** temp `.part`; nothing here hashes, promotes, or reads it as Quran; a `.part`/temp file is never treated as muṣḥaf (verification is E05-T03, the fail-closed gate that guards R1).
- [ ] **Fail-closed boundary discipline:** transport errors surface as a typed `AssetDownloadException`, never a swallowed error or a degraded render; a 404 is "keep the verified local copy", never a re-fetch of something else; no second network client, no `latest` resolution.
- [ ] **TLS, no pinning:** TLS 1.2+/1.3 via the platform trust store; no `badCertificateCallback`, no pinned `SecurityContext`/cert/key (§5).
- [ ] **Sect-neutral adab:** no user-facing copy is authored in this task; the boundary names no riwāyah and makes no religious claim — it moves bytes only; onboarding tone/states are E05-T04.
- [ ] **RTL + fa/ckb/ar:** N/A by construction — this boundary emits typed values, not strings; all calm, RTL, FSI/PDI-isolated, locale-numeral onboarding copy for `awaitingFirstDownload`/`downloadInterrupted`/`ready`/`integrityFailure` is authored at the feature layer (E05-T04) via `gen_l10n`.
- [ ] **Accessibility:** N/A — no widget, no `Semantics`; the download screen and its retry affordance (with labels and thumb-zone/contrast norms) are E05-T04.
- [ ] **Nothing safe to drop:** the boundary fetches whatever file it is asked for and marks no asset optional or skippable; the core pack covers the whole muṣḥaf (the manifest is E05-T01).
- [ ] **Deterministic tests:** suites use a fixed in-memory byte map and a capturing adapter — no real socket, no wall clock, no randomness; `FakeAssetDownloader` is the offline double every downstream test installs via `overrideWith`; every new file carries the REUSE header and is `dart format` + analyzer/lint clean with `///` docs on public members.
