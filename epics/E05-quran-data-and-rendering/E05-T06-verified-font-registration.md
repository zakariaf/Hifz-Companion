# E05-T06 — registerVerifiedPageFonts: load the 604 QPC fonts via FontLoader only after each passes its hash

| | |
|---|---|
| **Epic** | [E05 — Quran Data & Immutable Rendering](EPIC.md) |
| **Size** | S (≈0.5-1 day) |
| **Depends on** | E05-T03 (the chunked SHA-256 verifier + the `AssetVault.readVerified(expectedSha256:)` boundary that throws on mismatch), E05-T05 (the verified core pack is installed and the reference data — including the `MushafEdition` triple with its `fontSha256[1..604]` — is loaded and checksum-governed) |
| **Skills** | domain-mushaf-text-integrity, ui-mushaf-page-view |

## Goal

`registerVerifiedPageFonts(MushafEdition ed, AssetVault vault)` exists in `packages/quran` and registers every one of the 604 per-page KFGQPC QPC glyph fonts with the Flutter engine at runtime — but **only** after each font's bytes are read through `vault.readVerified(expectedSha256: ed.fontSha256[page])`, which throws on any hash mismatch. For each page `1..ed.pageCount` it resolves the family with `qpcFontFamily(page)` (e.g. `QPC_P001`), builds a `FontLoader(qpcFontFamily(page))..addFont(...)` over the verified bytes, and `await`s `loader.load()`. The fonts are registered **byte-for-byte as published** — never sub-set, re-hinted, re-compressed, or renamed (the KFGQPC licence). An unverified font is never registered: the throw from `readVerified` propagates, registration stops, and the reader is left with no `QPC_P###` family to draw — which downstream (E05-T07) becomes a refusal to render Quran text, never a fallback. Fonts arrive from the verified core pack (E05-T05), never the app bundle / `pubspec.yaml`.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 | The verbatim `registerVerifiedPageFonts(MushafEdition ed, AssetVault vault)` shape — loop `page = 1..ed.pageCount`, `vault.readVerified(... expectedSha256: ed.fontSha256[page]!)`, `FontLoader(qpcFontFamily(page))..addFont(Future.value(ByteData.sublistView(bytes)))`, `await loader.load()`; `qpcFontFamily(int) => 'QPC_P${page.padLeft(3,'0')}'`; fonts arrive in the downloaded verified core pack, not the bundle, so they are runtime-loaded via `FontLoader`/`loadFontFromList`, never declared in `pubspec.yaml`; "Refuses to register an unverified font"; one real font file per page → one glyph table per family (Flutter does not simulate missing weights) |
| `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 (pitfalls) | "We refuse to modify the KFGQPC fonts" — no sub-setting, re-hinting, renaming, or re-compression; the licence forbids it ([Open Hub: KFGQPC License]) and modification would also break fidelity; fonts are registered exactly as published and checksummed |
| `docs/engineering/09-asset-packs-and-offline-integrity.md` §3 | The runtime SHA-256 fail-closed contract `readVerified` enforces: match → trust; mismatch/missing/truncated → throw; the app refuses to render Quran text from any unverified asset; this task is a **consumer** of that gate, not a re-implementation of it |
| `docs/PRD.md` §11.1.1, §11.2, §11.3.3 | The app refuses to render Quran text from any unverified asset; each page renders by selecting that page's **dedicated glyph font** (the font *is* the typeset page); runtime re-verifies every downloaded pack's SHA-256 before first use |
| Skill **domain-mushaf-text-integrity** (+ `template.dart`) | Canonical pattern step 4 ("Register the 604 page fonts only after they pass their hash" — `FontLoader(qpcFontFamily(page))..addFont(...)` over `vault.readVerified(expectedSha256: ed.fontSha256[page])`, refuse the unverified, fonts unmodified); the Do/Don't row "Register fonts via `FontLoader` only after `vault.readVerified` passes" / "Bundle/load fonts without re-verifying, or modify/sub-set/rename the KFGQPC fonts"; the checklist line "the 604 per-page fonts are loaded via `FontLoader` only after `vault.readVerified(...)` passes; unverified fonts are refused; fonts are unmodified" |
| Skill **ui-mushaf-page-view** | This task supplies the per-page `QPC_P###` families the page view consumes (canonical step 1 — apply `qpcFontFamily(pageNumber)`); confirms the families this task registers are the *only* thing that lets the page draw glyph-only with `fontFamilyFallback: const []`; the "refuse to render unverified assets" / "fail loudly, never substitute" rule the missing-family case must honour (step 8) |
| `docs/science/CLAIMS.md` C-048 | "Fully offline, never records voice, one-time checksum-verified download" — this task is one half of *checksum-verified*: a font is registered only after its per-file SHA-256 passes. No on-screen number/copy is rendered by this task; C-048 is cited because the runtime verify-before-register behaviour is the data behind that claim |
| Siblings: E05-T01, E05-T03, E05-T05, E05-T07, E05-T11 | T01 defines `MushafEdition` (with `fontSha256[1..604]`) and `qpcFontFamily`'s `QPC_P###` convention; T03 supplies `AssetVault.readVerified(expectedSha256:)` (the throwing gate) and the fail-closed state machine; T05 installs+loads the verified pack so the font bytes exist on disk before this runs; T07's `MushafPageView` draws each line in the `QPC_P###` family **this** task registered (and refuses to render if it is absent); T11's 604-page real-font visual-diff loads the *same* fonts via `FontLoader` to prove pixel-fidelity. This task owns **only** runtime registration behind the verify gate |

## Implementation notes

TEST-FIRST (correctness-critical): the refuse-unverified path is the reason this task exists. Write the "a mismatched `fontSha256` throws and registers nothing past the bad page" case and the "every page goes through `readVerified` before any `addFont`" ordering case **before** the implementation body; both must exist and fail before `registerVerifiedPageFonts` is written.

1. **File** → `packages/quran/lib/src/fonts/register_verified_page_fonts.dart` (barrel-exported from `lib/quran.dart`). Font registration is QPC-font/glyph-handling and is therefore allowed **only** in `packages/quran` (enforced by `tool/check_quran_isolation.sh`, engineering 02 §). `qpcFontFamily` lives alongside it (or is imported from the `quran` glyph module if T07 already placed it) — keep exactly one definition of the `QPC_P${page.padLeft(3,'0')}` convention.

2. **Signature** → `Future<void> registerVerifiedPageFonts(MushafEdition ed, AssetVault vault)`. Pure orchestration over two injected collaborators: the `MushafEdition` value type (E05-T01, from `models`) and the `AssetVault` boundary (E05-T03, the injectable service interface with a deterministic fake). This function reads no clock, opens no socket, and parses no manifest — it consumes the already-installed verified pack.

3. **The loop body**, exactly per engineering 08 §2:
   ```dart
   for (var page = 1; page <= ed.pageCount; page++) {
     final bytes = await vault.readVerified(        // throws if hash != fontSha256[page]
       kind: AssetKind.pageFont,
       page: page,
       expectedSha256: ed.fontSha256[page]!,
     );
     final loader = FontLoader(qpcFontFamily(page))
       ..addFont(Future.value(ByteData.sublistView(bytes)));
     await loader.load();
   }
   ```
   - `readVerified` is `await`ed **before** the `FontLoader` for that page is constructed — verify-then-register, never register-then-verify. The throw from a bad hash must abort registration; do **not** wrap the body in a `try`/`catch` that swallows it and continues to the next page (a partial, silently-degraded muṣḥaf is exactly the failure this gate exists to prevent).
   - `qpcFontFamily(page)` is the family name passed to `FontLoader` *and* the name `MushafPageView` (T07) later resolves — one shared function, one `QPC_P###` form (zero-padded to 3 digits).
   - `ByteData.sublistView(bytes)` wraps the verified `Uint8List` without copying; `addFont` takes a `Future<ByteData>`, hence `Future.value(...)`.

4. **Bytes are registered unmodified.** Pass the verified bytes straight to `addFont`. Do **not** sub-set, re-hint, re-compress, transcode, or rename the font; do not strip tables or "optimise" it — the KFGQPC licence forbids modification and any change breaks the byte-for-byte fidelity the verifier just proved (engineering 08 §1 pitfalls). The family *name* (`QPC_P###`) is the engine-side handle, not a rename of the file.

5. **Composition / when it runs.** Expose this as the registration step the onboarding/install sequence calls **after** E05-T05's verified load completes and **before** the reader can present a page (it is a one-time post-install step, re-run on launch only if the engine's registered families do not survive a cold start — registration is process-local, the verified bytes on disk are the durable source of trust). The Riverpod wiring that invokes it lives at the reader's composition root (E05-T07 / the reader feature), not in this pure function; this task ships the function and its boundary contract, not the provider.

6. **Idempotence / re-registration.** Registering the same `QPC_P###` family twice (e.g. a second cold-start pass) must be harmless — `FontLoader.load()` for an already-registered family is additive and safe; do not add bespoke "already registered?" bookkeeping or a global mutable registry. Keep the function stateless.

7. **Failure surfaces as absence, never as fallback.** If `readVerified` throws for page *N*, families `QPC_P001..QPC_P(N-1)` are registered and `QPC_P(N)..` are not; let the error propagate to the install/reader orchestrator (E05-T04/T07), which renders the calm "refuse to render Quran text" state. This function must **never** register a placeholder, substitute, system, or fallback font for a page whose bytes did not verify — a missing `QPC_P###` family makes T07's `fontFamilyFallback: const []` line surface as visible tofu / refusal, which is the intended fail-loud behaviour.

8. **Pitfalls to avoid:** a `try`/`catch` (or `await Future.wait` with `eagerError: false`) that swallows a single page's verification failure and registers the other 603 (a corrupt-but-rendered muṣḥaf); modifying/sub-setting/renaming the font bytes; reading the font from `rootBundle`/`pubspec.yaml` assets instead of the verified vault (the fonts are *not* bundled); hardcoding `604`/`'QPC_P604'` instead of looping `1..ed.pageCount` and zero-padding via `qpcFontFamily` (breaks swappability — R2); importing `dio`/`http`/`HttpClient` (this file touches no network — `packages/quran` is outside the networking-allowed `packages/assets`); calling `vault.readVerified` after `addFont` (verify must precede register); defining a second copy of `qpcFontFamily`/`QPC_P###`.

## Acceptance criteria

- [ ] `registerVerifiedPageFonts(MushafEdition ed, AssetVault vault)` exists in `packages/quran/lib/src/fonts/register_verified_page_fonts.dart`, is barrel-exported, and is the only place per-page QPC fonts are registered; the file imports no networking symbol (`dio`/`http`/`dart:io HttpClient`) and passes `tool/check_quran_isolation.sh`.
- [ ] For every page `1..ed.pageCount` the function reads bytes through `vault.readVerified(expectedSha256: ed.fontSha256[page]!)` **before** constructing that page's `FontLoader`, then registers the family `qpcFontFamily(page)` (`QPC_P###`, zero-padded to 3 digits) via `FontLoader(...)..addFont(Future.value(ByteData.sublistView(bytes)))` and `await loader.load()`.
- [ ] A single mismatched/missing/truncated `fontSha256[page]` causes `readVerified` to throw; the throw propagates (it is **not** caught-and-continued); pages at and after the failing one are left unregistered; no fallback/substitute/system font is registered for any page.
- [ ] The verified bytes are passed to `addFont` **unmodified** — no sub-set, re-hint, re-compress, transcode, or rename; the only thing chosen by this task is the engine-side family name `QPC_P###`.
- [ ] The function reads no clock, opens no socket, parses no manifest, and loads no font from `rootBundle`/`pubspec.yaml`; it consumes only the injected `MushafEdition` and `AssetVault`.
- [ ] Re-invoking the function (cold-start re-registration) is harmless — no duplicate-registration error and no global mutable registry is introduced; the function is stateless.
- [ ] `pageCount` drives the loop bound and `qpcFontFamily` derives the family from the page number; no `604`/literal `'QPC_P###'` is hardcoded in the loop or its bound.
- [ ] Every `public` declaration carries a `///` doc comment; `dart format` + analyzer/lint clean; the REUSE license header is present.

## Tests

`packages/quran/test/fonts/register_verified_page_fonts_test.dart` (mirrors the source path), `flutter_test` (the test bootstrap installs E01's throwing `HttpOverrides`; this suite must never trip it — registration is offline). Drive the function with a **recording fake `AssetVault`** (the deterministic double from E05-T03) over a small synthetic edition (`pageCount: 3`, `fontSha256: {1: shaA, 2: shaB, 3: shaC}`) so cases stay fast and exhaustive; `qpcFontFamily` resolution is unit-tested directly. Required cases, the first two written FIRST:

- **Refuse-unverified (the central case)**: a fake vault whose `readVerified` throws the verifier's mismatch error on page 2; assert `registerVerifiedPageFonts` rethrows that exact error, that the vault recorded a `readVerified` call for pages 1 and 2 but **not** page 3 (registration stopped at the failure), and that no `addFont`/family registration happened for page 2+. Repeat for a missing-bytes and a truncated-bytes vault response — all three must abort, none must fall back.
- **Verify-before-register ordering**: a recording vault whose `readVerified` asserts, at call time for page *p*, that no `FontLoader` for `qpcFontFamily(p)` has yet been built (e.g. via a recorded event log the test inspects), proving every page is verified strictly before it is registered, for all pages.
- **All-pages-verified happy path**: with a vault that returns valid bytes for all 3 pages, exactly 3 `readVerified` calls are made (pages 1,2,3, each with the matching `expectedSha256` from `fontSha256`), exactly 3 families `QPC_P001`/`QPC_P002`/`QPC_P003` are loaded, and the call completes without throwing.
- **`qpcFontFamily` convention**: `qpcFontFamily(1) == 'QPC_P001'`, `qpcFontFamily(42) == 'QPC_P042'`, `qpcFontFamily(604) == 'QPC_P604'` (zero-padded to 3 digits); the same function name is the one T07 uses (one definition, asserted by reference).
- **Unmodified bytes**: the bytes handed to `addFont` are byte-equal to the bytes returned by `readVerified` (a recording `FontLoader` seam / injected loader captures them) — proving no sub-set/transcode/rehint happens in this layer.
- **Idempotent re-registration**: calling the function twice over the same valid vault does not throw and makes a second full pass of `readVerified` calls (re-verify on re-register), with no duplicate-registration error.
- **`pageCount` drives the loop**: an edition with `pageCount: 5` makes exactly 5 verify+register cycles; an edition with `pageCount: 2` makes exactly 2 — proving no `604` is baked in (swappability, R2).
- **Offline guard**: the suite runs with the throwing `HttpOverrides` installed and never trips it; no real network, no `rootBundle` font load.

No 604-page real-font golden in this task — that is the E05-T11 visual-diff gate (which loads these same fonts via `FontLoader` on min-OS iOS+Android); here the `FontLoader`/`AssetVault` seams are faked so the unit suite is fast and deterministic.

## Definition of Done

- [ ] All acceptance criteria met; the unit suite green under `flutter test` locally and in CI; the refuse-unverified and verify-before-register cases were written test-first.
- [ ] **Offline / no-network:** the file imports no networking symbol and lives in `packages/quran` (outside the networking-allowed `packages/assets`); fonts come from the verified vault, never `rootBundle`/`pubspec.yaml` or the wire; tests run under the throwing `HttpOverrides` and never trip it; E01's banned-import + dependency-allow-list gates stay green.
- [ ] **No AI / no microphone:** nothing here touches AI, ASR, or audio; it registers glyph fonts only.
- [ ] **Quran text fidelity (existential):** a font is registered **only** after its per-file SHA-256 passes `readVerified`; an unverified/missing/truncated font is refused (the throw propagates, registration aborts, nothing falls back); the bytes are registered byte-for-byte unmodified (no sub-set/re-hint/rename — KFGQPC licence + fidelity); a missing `QPC_P###` family surfaces as tofu/refusal in T07, never a substituted font (R1).
- [ ] **Fail-closed:** the function is a faithful consumer of E05-T03's fail-closed `readVerified` gate — no soft path, no swallowed verification error, no per-page fallback; verify strictly precedes register for every page.
- [ ] **Sect-neutral adab:** this task registers fonts only; it renders no copy, no riwāyah label, no decoration, and gates nothing behind piety/wuḍūʾ; the muṣḥaf edition stays swappable (the loop is driven by `pageCount`/`fontSha256`, not a hardcoded 604).
- [ ] **RTL + fa/ckb/ar:** N/A by construction — this task ships a pure registration function with no user-facing string; the registered families are identical across all three locales (the muṣḥaf is locale-independent; only chrome localizes), and any refuse-to-render/retry copy is owned by E05-T04/T07's `l10n`.
- [ ] **Accessibility:** N/A — no widget, no `Semantics`; the reader's accessible chrome around the page is E05-T07/T09.
- [ ] **Nothing safe to drop:** every page `1..pageCount` is registered behind its own hash gate; no page is marked optional, skippable, or droppable, and a failure never degrades to "render the rest anyway".
- [ ] **Deterministic tests:** the suite is fast and deterministic over a small synthetic edition with faked `AssetVault`/`FontLoader` seams — no real network, no real font I/O, no clock, no randomness; every `public` member has a `///` doc comment and the file carries its REUSE header; `dart format` + analyzer/lint clean.
