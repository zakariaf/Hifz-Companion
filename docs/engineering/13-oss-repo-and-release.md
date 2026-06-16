# 13 — OSS Repo & Release

This document specifies how Hifz Companion is licensed, published, and made *auditable* — the trust pack a reader finds when they open this repository on GitHub, the license that keeps a *ṣadaqah jāriyah* project perpetually free in law, the CI/CD that builds and signs releases reproducibly, the privacy declarations and manifests every store still demands even from an app that collects nothing, and the multi-channel release story (F-Droid, Google Play, the Apple App Store, and signed GitHub Releases for Obtainium). It applies the *Decision log: Open-source license & release* entry (README decision 11), leans on the *Decision log: Quran asset distribution & offline integrity* (decision 5) and *Decision log: No networking beyond asset download* (decision 8) entries, and is grounded in the evidence dossier [research/oss-mobile-release-fdroid.md](research/oss-mobile-release-fdroid.md) and [PRD §17, §19.3, §20.6, §21.6](../PRD.md).

The boundaries are deliberate. This doc owns the **app-code repo** and the channels it ships through — the license, the contribution mechanism, the repository trust files, the release workflow, and the per-store privacy declarations. The **data repo** (Quran asset packs, their hosting, their per-file integrity manifest, and reproducible pack builds) is owned by its sibling [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md); where the two meet — the same release tag pins both a signed binary and a frozen asset manifest — this doc references it rather than re-specifying it. The CI *gates* that prove no second network client exists and that the dependency tree stays SDK-free are specified in [11-testing-strategy.md](11-testing-strategy.md) and [03-coding-standards.md](03-coding-standards.md); this doc consumes them as release-blocking checks. This doc owns the trust boundary between "a stranger reading our source" and "a believable claim that the app does exactly what it says."

Two framing facts govern everything below, from [PRD §1](../PRD.md) and the README. First: **the app is built free, as *ṣadaqah jāriyah*; there is no monetization to protect.** The license question is therefore not about revenue but about *trust, auditability, and keeping the gift perpetually free* — which points at copyleft, not permissiveness. Second: **the app is fully offline, account-free, telemetry-free, and contains no proprietary SDKs** ([PRD C1, §17](../PRD.md)). That single architectural fact removes nearly the entire compliance surface that normally makes store releases painful and qualifies the app for the strongest privacy posture every store offers — *and* makes that posture honestly *verifiable*, because the source is open.

## At a glance

| Concern | Decision |
|---|---|
| App-code license | **GPL-3.0-or-later** + explicit GPLv3 §7 **App Store additional permission** (Signal's 2016 precedent) ([GNU: GPL-3.0 §7](https://www.gnu.org/licenses/gpl-3.0.html); [Signal: License update](https://signal.org/blog/license-update/)) |
| Why copyleft | A *waqf* must stay perpetually free; GPL forecloses a closed, paywalled, telemetry-laden fork — copyleft encodes the *ṣadaqah* intent in law ([quran/quran_android (GPL-3.0)](https://github.com/quran/quran_android)) |
| Why not AGPL | AGPL's only distinguishing clause (§13) is a no-op for an app with no network service ([AboutCode: GPL-3.0 compliance](https://aboutcode.org/2021/gpl-3-0-license-compliance/)) |
| Contributions | **DCO 1.1** (`Signed-off-by`), no CLA — outside work arrives under the project license *including the exception* ([Developer Certificate of Origin](https://developercertificate.org/)) |
| License clarity | **REUSE 3.x**: per-file `SPDX-License-Identifier` + `SPDX-FileCopyrightText`, full texts in `LICENSES/`, `reuse lint` in CI ([REUSE: Tutorial](https://reuse.software/tutorial/)) |
| Trust pack | `LICENSE` (+ exception), `CONTRIBUTING.md` + DCO, `SECURITY.md`, `PRIVACY.md`, a **"verify us yourself"** doc, `fastlane/metadata/` |
| Android build | **Reproducible**, signed with **our own key** → F-Droid ships *our* APK, an auditor rebuilds the exact bytes ([F-Droid: Reproducible builds](https://f-droid.org/2023/09/03/reproducible-builds-signing-keys-and-binary-repos.html)) |
| CI/CD | GitHub Actions: pinned `subosito/flutter-action`; `reuse lint` + dependency/import/network gates + goldens; tag → signed build + SLSA provenance ([actions/attest-build-provenance](https://github.com/marketplace/actions/attest-build-provenance)) |
| Apple privacy manifest | App-level **`PrivacyInfo.xcprivacy`**: `NSPrivacyTracking=false`, empty collected types, accurate required-reason codes ([Apple via Sentry: Privacy Manifest for Flutter](https://docs.sentry.io/platforms/dart/guides/flutter/data-management/apple-privacy-manifest/)) |
| Store privacy declaration | Apple **"Data Not Collected"** + mandatory privacy policy; Play **"No data collected"** (unskippable form) ([Apple: App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/); [Google Play: Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)) |
| Channels | **F-Droid** (primary), **Google Play**, **Apple App Store**, **signed GitHub Releases** for Obtainium ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)) |
| Distribution-policy risk | Track Google's 2025 developer-registration decree; multi-channel posture is the hedge ([F-Droid: Registration decree](https://f-droid.org/en/2025/09/29/google-developer-registration-decree.html)) |

---

## 1. License: GPL-3.0-or-later, with an App Store additional permission

### Decision

The app code is licensed **GPL-3.0-or-later** with one explicit GPLv3 §7 **additional permission** authorizing distribution through application stores whose terms impose usage restrictions (the App Store, Google Play), modeled on Signal's June 2016 grant (*Decision log: Open-source license & release*). The Quran-data repo keeps its assets under their own source licenses (Tanzil verbatim + attribution, KFGQPC font terms, the CC-BY mutashābihāt dataset) — owned by [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md), not relicensed here. We deliberately do **not** choose AGPL, and we deliberately do **not** choose a permissive license (MIT/Apache-2.0).

### Rationale

- **For a *ṣadaqah jāriyah* project the license trade-off is freedom-preservation vs. permissiveness, not revenue.** Because nothing is sold, the only question copyleft answers is whether the gift *stays* a gift. GPL-3.0 "structurally prevents a third party from taking the work proprietary, paywalling it, or bolting ads/telemetry onto a closed fork" — it encodes the *waqf* (perpetual public benefit) intent in law (research note, Finding 6). Permissive licensing maximizes reuse but explicitly permits the closed, monetized, telemetry-laden derivative this project's values reject ([PRD §4, §17](../PRD.md)).
- **The strongest free-Quran-app precedent is copyleft.** `quran/quran_android` (Quran.com / Quran Foundation) is **GPL-3.0** — "modifications to this code [must] be open sourced as well" ([quran/quran_android](https://github.com/quran/quran_android)) — and the Quranic Arabic Corpus is GNU GPL ([corpus.quran.com license](https://corpus.quran.com/license.jsp)). The *ṣadaqah*-software convention is live: Open Waqf builds "privacy-focused, ad-free, and open-source software … Built as Sadaqah Jariyah for everyone" and invokes *waqf* for the code itself ([Open Waqf](https://open-waqf.org/)).
- **AGPL buys this app nothing.** AGPL differs from GPL only in §13, which treats network deployment as distribution — but "running unmodified AGPL software over a network doesn't automatically trigger the disclosure requirement" and only fires when the *network-service provider* modifies the code ([AboutCode: GPL-3.0 compliance](https://aboutcode.org/2021/gpl-3-0-license-compliance/)). Hifz Companion has **no network service** ([PRD C1](../PRD.md)), so §13 never fires; AGPL would add the same App-Store friction as GPL while delivering no extra protection (research note, Finding 7).
- **The App Store exception cures the one real, narrow GPL conflict.** GPLv3 §10 forbids imposing "any further restrictions on the exercise of the rights granted" ([GNU: GPL-3.0 §10](https://www.gnu.org/licenses/gpl-3.0.html)), which collides with app-store Usage Rules that *do* restrict recipients. §7 expressly lets the copyright holder "supplement the terms of this License with terms" ([GNU: GPL-3.0 §7](https://www.gnu.org/licenses/gpl-3.0.html)); an "App Store exception" is exactly that — it "allows distribution of software through an app store, even if that store has restrictive terms … provided that the source is also available through a channel without those restrictive terms" ([wger: app store exception #10](https://github.com/wger-project/flutter/issues/10)). Signal's 2016 relicensing is the canonical precedent, "explicitly authorizing GPL-compliant applications to be distributed through the Apple App Store" ([Signal: License update](https://signal.org/blog/license-update/)) (research note, Finding 5).

### Specification

The repository root carries a `LICENSE` file containing the unmodified GPL-3.0 text, immediately followed by the additional-permission grant. The exception text is the load-bearing artifact — it must be present *before* any outside copyright enters the tree:

```text
This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

  --- Additional permission under GNU GPL version 3 section 7 ---

As an additional permission under section 7 of the GNU General Public
License version 3, the copyright holders of Hifz Companion give you
permission to convey the resulting work via the Apple App Store, Google
Play, or any comparable application store whose terms of service impose
usage restrictions on recipients, notwithstanding the prohibition in
section 10 of the GPL on imposing further restrictions, provided that:

  (1) the Corresponding Source for the same version remains available,
      under this License (GPL-3.0-or-later with this exception), through
      a channel that does not impose those restrictions (this public
      repository and its signed GitHub Releases); and

  (2) you do not remove or alter this additional permission.

If you modify this program, you may extend this permission to your version,
but you are not obligated to do so.
```

The repository declares the license machine-readably with **REUSE** (§2). The top-level SPDX expression is:

```text
SPDX-License-Identifier: GPL-3.0-or-later
```

A short `LICENSING.md` records the deliberate split so an auditor sees it at a glance:

| Component | Repo | License | Notes |
|---|---|---|---|
| App code | this repo | **GPL-3.0-or-later** + §7 App Store exception | copyleft = *waqf* in law |
| Quran text | data repo | Tanzil verbatim + attribution | never relicensed ([09](09-asset-packs-and-offline-integrity.md)) |
| Page glyph fonts | data repo | KFGQPC font terms (verify redistribution) | NonFreeAssets risk if restrictive (§7 below) |
| Mutashābihāt dataset | data repo | CC-BY (scholar-reviewed) | open so it can be audited/corrected ([PRD R4](../PRD.md)) |

### Pitfalls / what we refuse

- **We refuse to merge any outside contribution before the App Store exception text is in `LICENSE`.** Once a second copyright holder exists, retrofitting the exception requires *their* consent — the literal VLC / GNU-Go failure mode that pulled GPL apps from the App Store (research note, Finding 5). The exception ships in the first commit.
- **We refuse a CLA.** A Contributor License Agreement draws justified suspicion in this community (it lets a steward relicense proprietary later, the opposite of our intent); we use a DCO instead (§3).
- **We refuse permissive relicensing "for reach."** Wider adoption via MIT/Apache is real, but it is the freedom to make exactly the closed, ad-supported fork the *ṣadaqah* intent forbids. The reach we want — anyone may run, study, share, and improve — GPL already grants.
- **We refuse to relicense the Quran assets.** The text stays Tanzil-verbatim under its own terms; the app's GPL covers *code*, never the muṣḥaf bytes (R1 fidelity is a data-repo concern — [09](09-asset-packs-and-offline-integrity.md)).

---

## 2. Repository trust pack and machine-readable license clarity (REUSE)

### Decision

The repository ships a complete, conventional **trust pack** at its root — `LICENSE` (+ exception), `LICENSING.md`, `CONTRIBUTING.md` (with the DCO), `SECURITY.md`, `PRIVACY.md`, a **"Verify us yourself"** document (§8), and `fastlane/metadata/` for store listings — and is **REUSE-compliant** (REUSE 3.x): every file carries an `SPDX-License-Identifier` and `SPDX-FileCopyrightText` header, full license texts live in a `LICENSES/` directory, and `reuse lint` runs in CI (*Decision log: Open-source license & release*).

### Rationale

- **For an offline, no-AI app, the repo *is* the audit.** The product's central promise — "no data leaves the device" ([PRD §17](../PRD.md)) — is only believable because the source is open and the single network code path is readable. The trust pack is what turns the promise into a *checkable* claim rather than marketing (research note, Finding 9, Implication 9).
- **REUSE makes licensing "easily, comprehensively, and unambiguously" machine-readable.** The convention requires a `LICENSES/` directory "which will contain all the licenses that you use," and that "each file must always contain" both `SPDX-FileCopyrightText` (publication years + copyright holder) and `SPDX-License-Identifier` (a valid SPDX expression) ([REUSE: Tutorial](https://reuse.software/tutorial/)). For a project that may outlive its first maintainer, per-file provenance forecloses the "is *this* file actually GPL?" ambiguity an auditor would otherwise have to resolve by hand.
- **A `SECURITY.md` is the honest channel for an app with no bug-bounty budget.** Because there is no server to attack, the realistic security surface is the asset-integrity gate ([09](09-asset-packs-and-offline-integrity.md)) and the dependency tree; a documented private-disclosure address is the minimum responsible posture.

### Specification

Repository layout (trust pack only; full package layout is [02-project-structure.md](02-project-structure.md)):

```text
/
├── LICENSE                     # GPL-3.0 text + §7 App Store exception (§1)
├── LICENSING.md                # the code-vs-assets license split table
├── CONTRIBUTING.md             # DCO text + "Signed-off-by" instructions (§3)
├── SECURITY.md                 # private disclosure contact; scope = integrity gate + deps
├── PRIVACY.md                  # the in-repo privacy policy (also linked from both stores, §6)
├── docs/verify-yourself.md     # reproducible-build + airplane-mode + "Data Not Collected" walkthrough (§8)
├── LICENSES/
│   ├── GPL-3.0-or-later.txt     # required by REUSE — full license text by SPDX id
│   └── CC-BY-4.0.txt            # for any CC-BY docs/data vendored into the code repo
├── .reuse/dep5                  # bulk SPDX info for files that can't carry a header (binaries, fonts)
├── fastlane/metadata/android/<locale>/
│   ├── short_description.txt    # ≤ 80 chars, mandatory
│   ├── full_description.txt     # ≤ 4000 chars, mandatory
│   └── images/                  # icon + screenshots, per locale (ar/fa/ckb)
└── .github/workflows/           # CI/CD (§4, §5)
```

Per-file header convention (REUSE), e.g. atop a Dart source file:

```dart
// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
```

`reuse lint` is a release-blocking CI step; a missing or malformed header fails the build, the same fail-loud discipline the network-restraint and golden gates use ([11](11-testing-strategy.md)):

```yaml
# .github/workflows/ci.yml (excerpt) — license clarity as a build invariant
- name: REUSE compliance
  uses: fsfe/reuse-action@v6   # runs `reuse lint`; non-zero exit fails the job
```

F-Droid sources the store listing **directly from this repo's `fastlane/metadata/`** — "the application's metadata is under direct control of the repository owners" and "automatically syncs to F-Droid without requiring merge requests" ([F-Droid: Descriptions, Graphics & Screenshots](https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/)). The same `fastlane/metadata/` tree feeds Play (via `fastlane supply`) and is the single localized source of truth for all three stores, in `ar`/`fa`/`ckb` ([PRD §13](../PRD.md)).

### Pitfalls / what we refuse

- **We refuse a repo whose license is "in the README only."** A stated MIT/GPL in prose with no SPDX file and no per-file headers is exactly the ambiguity REUSE exists to kill; one Quran-app precedent (a MIT-in-README project with "no SPDX license file detected via API") shows the failure mode (research note, Finding 6).
- **We refuse store descriptions that drift from the repo.** Listings live in `fastlane/metadata/` and are reviewed in PRs like code; we never hand-edit a store console as the source of truth, or the three stores silently diverge.
- **We refuse a `SECURITY.md` that promises a bounty we cannot fund.** It states the truth: private disclosure, best-effort timeline, and that the highest-value report is one against the asset-integrity gate or a dependency.

---

## 3. Contributions: DCO, not CLA

### Decision

Outside contributions are accepted under the **Developer Certificate of Origin (DCO) 1.1**: every commit carries a `Signed-off-by:` line, and `CONTRIBUTING.md` reproduces the DCO text verbatim. There is **no CLA**. The DCO certification means contributed work arrives under the project license **including the §7 App Store exception**, with no transfer of copyright (*Decision log: Open-source license & release*).

### Rationale

- **The DCO is the lightweight, copyright-holder-preserving attestation a copyleft project wants.** By signing off, a contributor certifies the contribution "was created in whole or in part by me and I have the right to submit it under the open source license indicated," or is appropriately-licensed prior work, and that "this project and the contribution are public and that a record of the contribution … is maintained indefinitely" ([Developer Certificate of Origin](https://developercertificate.org/)). Critically the contributor keeps their copyright — there is no relicensing power for a steward to abuse, which is exactly why a DCO does not draw the suspicion a CLA does in this community (research note, Implication 1).
- **The exception must propagate with the inbound license.** Because the project is GPL-3.0 *plus the App Store exception*, a contribution that arrives as bare GPL-3.0 without the exception would, once merged, create a co-copyright-holder whose code lacks the App Store grant — re-opening the very hole §1 closes. The DCO flow (contribute *under the project's stated license*, which includes the exception) keeps every commit App-Store-distributable (research note, Finding 5).

### Specification

`CONTRIBUTING.md` reproduces the DCO 1.1 text and instructs contributors to sign each commit:

```bash
# DCO sign-off: appends a verifiable "Signed-off-by" trailer matching your git identity
git commit --signoff -m "engine: clamp due_at to the cycle ceiling"
# trailer added: Signed-off-by: Name <email>
```

A CI check enforces the sign-off on every commit in a PR:

```yaml
# .github/workflows/dco.yml — every commit must carry a valid Signed-off-by trailer
- uses: tim-actions/dco@v1.1.0   # fails the PR if any commit is missing sign-off
```

The four DCO clauses (a)/(b)/(c)/(d) are quoted in full in `CONTRIBUTING.md` so a contributor reads exactly what they certify ([Developer Certificate of Origin](https://developercertificate.org/)).

### Pitfalls / what we refuse

- **We refuse unsigned commits in `main`.** The DCO check is required; an unsigned commit is rebased to add sign-off, never waved through "just this once."
- **We refuse to accept a contribution under a *different* license "for convenience."** All inbound code is GPL-3.0-or-later with the exception; a contributor who cannot license that way cannot contribute that code.
- **We refuse copyright assignment.** Contributors keep their copyright; the project holds no power to relicense the work proprietary — the structural guarantee that the *ṣadaqah* gift cannot be later enclosed.

---

## 4. CI/CD: reproducible, signed, provenance-attested builds

### Decision

Continuous integration runs on **GitHub Actions** using a **pinned** `subosito/flutter-action` Flutter version (matching the README baseline), and a tagged release triggers a **reproducible Android build signed with our own key**, plus a **SLSA build-provenance attestation** binding the artifact to the exact source and workflow. The release CI runs the full release-gate suite ([PRD §20](../PRD.md)) — REUSE lint, the dependency/import/network-restraint gates ([03](03-coding-standards.md), [11](11-testing-strategy.md)), pinned-OS goldens, the engine property tests, and the asset-manifest check ([09](09-asset-packs-and-offline-integrity.md)) — and refuses to publish if any fail (*Decision log: Open-source license & release*).

### Rationale

- **Reproducible Android builds turn "trust us" into "verify the bytes."** Reproducibility is "considered best practice" for F-Droid, and its payoff is provenance: "with reproducible builds, F-Droid ships APKs signed by the upstream developer(s), rather than by F-Droid itself," validating that the published APK "was built from the very code the developer provided" ([F-Droid: Reproducible builds](https://f-droid.org/2023/09/03/reproducible-builds-signing-keys-and-binary-repos.html)). Android (unlike iOS) is genuinely reproducible, so for a Flutter app this is achievable and is the single strongest auditability claim available on any platform (research note, Finding 4).
- **A pinned toolchain is a precondition for reproducibility *and* for stable goldens.** `subosito/flutter-action` with an explicit `flutter-version` is the README's CI choice precisely because goldens are documented to be OS/font/Flutter-version sensitive ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)); a floating toolchain would make both the muṣḥaf goldens and the rebuild-the-bytes claim non-deterministic ([11](11-testing-strategy.md)).
- **SLSA provenance links a binary to its build.** `actions/attest-build-provenance` "generates signed build provenance attestations for workflow artifacts," binding a named artifact + digest to a SLSA provenance predicate, signed with short-lived Sigstore certificates, verifiable with `gh attestation verify` ([actions/attest-build-provenance](https://github.com/marketplace/actions/attest-build-provenance)). For a project meant to outlive its maintainer, this is a durable, cryptographic answer to "did *this* repo at *this* commit produce *this* APK?" — the code-side analogue of the asset-pack provenance in [09](09-asset-packs-and-offline-integrity.md).
- **The release fees are negligible; the cost is discipline.** Google Play is "a one-time $25 USD payment — there is no annual renewal" ([Google Play Console: Get started](https://support.google.com/googleplay/android-developer/answer/6112435)), F-Droid is free to publish to, and Apple's is its standard annual fee — so the real release cost is the engineering gates above, not money (research note, Finding 13).

### Specification

Two workflows: a fast PR/`push` CI, and a tag-triggered release. The release job signs with our own keystore (secrets), produces a reproducible AAB/APK, and attests it.

```yaml
# .github/workflows/release.yml (excerpt) — tag → gated, signed, attested build
on:
  push:
    tags: ['v*.*.*']            # an exact, immutable version tag — never a moving ref

permissions:
  contents: write               # create the GitHub Release
  id-token: write               # Sigstore signing for provenance
  attestations: write           # upload the SLSA attestation

jobs:
  release:
    runs-on: ubuntu-latest      # pinned Linux runner for golden + build stability
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.0'   # PINNED — matches README baseline; reproducibility precondition
          channel: stable
      - run: flutter pub get
      - name: Release gates (all must pass — PRD §20)
        run: |
          flutter analyze --fatal-infos        # includes banned-import / network-restraint lints (03, 11)
          flutter pub run dependency_validator  # no analytics/ads/backend SDK in the resolved graph
          dart test packages/engine             # pure-engine + glados invariant property tests
          flutter test --tags golden            # pinned-OS, real-font muṣḥaf goldens
      - name: REUSE compliance
        uses: fsfe/reuse-action@v6
      - name: Build signed Android release
        run: flutter build appbundle --release   # signed via android/key.properties from secrets
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
      - name: Attest build provenance
        uses: actions/attest-build-provenance@v1
        with:
          subject-path: build/app/outputs/bundle/release/app-release.aab
```

| Gate | Tool | Blocks release on | Specified in |
|---|---|---|---|
| License clarity | `reuse lint` | missing SPDX header / license text | this doc §2 |
| DCO sign-off | DCO action | any unsigned commit | this doc §3 |
| Network restraint | banned-import lint + dep allow-list | a 2nd network client or any analytics/ads/backend SDK | [03](03-coding-standards.md), [11](11-testing-strategy.md) |
| Determinism | engine property tests | non-deterministic schedule / clamp violation | [06](06-scheduling-engine.md), [11](11-testing-strategy.md) |
| Muṣḥaf fidelity | pinned-OS real-font goldens | any rendered-page pixel drift | [08](08-quran-data-and-immutable-rendering.md), [11](11-testing-strategy.md) |
| Asset integrity | manifest hash check | pinned SHA-256 ≠ published pack | [09](09-asset-packs-and-offline-integrity.md) |
| Privacy posture | declaration checklist | any code path that transmits user data | this doc §6 |

### Pitfalls / what we refuse

- **We refuse a floating Flutter version in CI.** The toolchain is pinned; an unpinned `flutter-action` silently breaks reproducibility and thrashes goldens.
- **We refuse to publish a release with a red gate.** All of [PRD §20](../PRD.md)'s release-blocking gates run in the release job; a failing privacy, integrity, network, or fidelity check stops the release — these are not advisory.
- **We refuse to let CI fetch the Quran assets at *app* build time.** The binary ships *lean* and embeds only the pinned tag + manifest hashes; baking the muṣḥaf into the APK would couple the code and data release cycles the design keeps separate ([09](09-asset-packs-and-offline-integrity.md)).
- **We refuse to store the signing key in the repo.** It lives only in encrypted CI secrets and an offline backup; losing the upstream key would forfeit the reproducible-build signature provenance.

---

## 5. F-Droid as the primary channel and the entry-ticket constraints

### Decision

**F-Droid is the primary, first-class distribution channel**, and F-Droid eligibility is treated as a **release gate**: the whole dependency tree and build toolchain stay 100% FLOSS, no proprietary tracking/ads/analytics SDK is ever linked, and the build earns **no Anti-Feature** flag — in particular not **NonFreeNet** or **NonFreeAssets** (*Decision log: Open-source license & release*; *Decision log: No networking beyond asset download*).

### Rationale

- **F-Droid's bar is the strictest of the three channels — clearing it guarantees the others.** Its Inclusion Policy requires apps be "Free, Libre and Open Source Software (FLOSS)," that "the software in its entirety must be so - including all libraries and dependencies used, and it must be buildable with only FLOSS tools," and that the build use "a 100% FLOSS toolchain" ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)). GPL-3.0 is explicitly acceptable; the gate is not *which* free license but that the *entire tree and toolchain* is free (research note, Finding 1).
- **The PRD's offline/no-SDK constraints *are* the F-Droid entry ticket.** F-Droid's prohibition — "proprietary tracking or advertising libraries and analytics tools such as Google Play Services and Firebase and Crashlytics and proprietary ad/tracking SDKs are strictly forbidden" ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)) — is verbatim [PRD C1, §19.3](../PRD.md). The app does not need to *strip* anything to qualify; it must merely *stay clean*, which is already a release gate ([PRD §20.6](../PRD.md)) (research note, Finding 2).
- **Our architecture earns no Anti-Feature, but two are live risks to watch.** Anti-Features are "warning indicators about user freedom, privacy or etc." and **Tracking**-flagged apps are "hidden by default" in the client ([F-Droid: Anti-Features](https://f-droid.org/en/docs/Anti-Features/)). **NonFreeNet** ("depend entirely on a proprietary network service") does *not* apply — the one-time GitHub download fetches static public data and the app then runs fully offline forever ([PRD C1](../PRD.md)). **NonFreeAssets** ("Non-Free assets … under a license that restricts commercial usage or making derivative works") *is* a real risk if the KFGQPC font terms forbid redistribution/derivatives — a concrete reason to verify font terms (research note, Finding 3; [09](09-asset-packs-and-offline-integrity.md), [PRD §11.1, §21.6](../PRD.md)).

### Specification

The F-Droid eligibility checklist, run as part of the release gates:

| F-Droid requirement | How we satisfy it | Evidence |
|---|---|---|
| App + all deps + toolchain FLOSS | GPL-3.0 app; `reuse lint` proves per-file licensing; dep allow-list rejects non-FLOSS | [F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/) |
| No Play Services / Firebase / Crashlytics / ad/tracking SDK | banned-import + dep allow-list CI gates ([03](03-coding-standards.md), [11](11-testing-strategy.md)) | [F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/) |
| No **NonFreeNet** | one-time static-data download; airplane-mode acceptance test ([09](09-asset-packs-and-offline-integrity.md)) | [F-Droid: Anti-Features](https://f-droid.org/en/docs/Anti-Features/) |
| No **NonFreeAssets** | verify font/audio licenses permit redistribution + derivatives before shipping a pack | [F-Droid: Anti-Features](https://f-droid.org/en/docs/Anti-Features/) |
| No **Tracking** / **Ads** | "Data Not Collected" posture (§6); no ad SDK | [F-Droid: Anti-Features](https://f-droid.org/en/docs/Anti-Features/) |
| Reproducible build (ship our key) | reproducible AAB/APK from pinned toolchain (§4) | [F-Droid: Reproducible builds](https://f-droid.org/2023/09/03/reproducible-builds-signing-keys-and-binary-repos.html) |
| Localized listing | `fastlane/metadata/android/{ar,fa,ckb}/` in-repo (§2) | [F-Droid: Descriptions](https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/) |

Flutter is an explicitly trusted prebuilt-binary source in F-Droid's toolchain rules, so the framework itself is not an obstacle ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)).

### Pitfalls / what we refuse

- **We refuse any dependency that drags in Play Services, Firebase, or an ad/tracking SDK.** A single such transitive dependency would forfeit F-Droid eligibility and break [PRD §20.6](../PRD.md); the dep allow-list catches it at PR time.
- **We refuse to ship a font or audio pack whose license forbids redistribution or derivatives.** That would earn a **NonFreeAssets** flag; font/audio terms are verified before a pack is published ([09](09-asset-packs-and-offline-integrity.md), [PRD §21.6](../PRD.md)).
- **We refuse to let the one-time download be framed (or coded) as a runtime *dependency on a service*.** The app must work fully offline forever after the download, or it risks the **NonFreeNet** flag and contradicts C1.

---

## 6. Privacy declarations: "Data Not Collected," truthfully, on every store

### Decision

The app declares the **strongest truthful privacy posture** on every store and gates it: Apple **"Data Not Collected"** nutrition label plus the still-mandatory in-app and App Store Connect **privacy policy**; Google Play **"No data collected"** in the unskippable Data safety form; an app-level Apple **`PrivacyInfo.xcprivacy`** with `NSPrivacyTracking=false`, empty collected-data types, and accurate required-reason API codes. "Declaration stays at zero collection" is a **release-checklist gate** — any future feature that transmits anything breaks it (*Decision log: Open-source license & release*; [PRD §17, §20.6](../PRD.md)).

### Rationale

- **Zero collection is not zero paperwork — but our architecture earns the strongest answer honestly.** Apple's controlling definition is generous to local-first apps: "'Collect' refers to transmitting data off the device … Data that is processed only on device is not 'collected' and does not need to be disclosed" ([Apple: App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)). An app that never transmits qualifies *truthfully* for "Data Not Collected." On Google's side the logic is the same but the form is unskippable: "If your app doesn't collect data, you still declare 'no data collected'" ([Google Play: Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)) (research note, Finding 9).
- **A privacy policy is mandatory even for a no-data app.** "All apps must include a link to their privacy policy in the App Store Connect metadata field and within the app" (Guideline 5.1.1(i)) ([Apple: App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)). We satisfy it with `PRIVACY.md` in the repo (§2), linked from both stores and from in-app Settings — the open-repo version doubles as an auditable artifact.
- **Apple privacy manifests are mandatory since spring 2024 and now first-class in Flutter.** Apple requires an "approved reason in the app's privacy manifest which accurately reflects how your app uses the API" for required-reason APIs ([Apple via Sentry: Privacy Manifest for Flutter](https://docs.sentry.io/platforms/dart/guides/flutter/data-management/apple-privacy-manifest/)), and Flutter supports it natively ([flutter/flutter #140013](https://github.com/flutter/flutter/issues/140013)). Realistically the app touches at least **UserDefaults** (settings) and possibly **file timestamp / disk space** (handling downloaded packs and backup files), so an app-level manifest with correct reason codes is required, not optional (research note, Finding 11).
- **Google Play's 2025 automated binary scan is our ally.** Play "now runs automated checks against your APK/AAB before you can submit. If your binary accesses data types you didn't declare, you'll get flagged before human review" ([Respectlytics: Data safety guide](https://respectlytics.com/blog/google-play-data-safety-guide/)). For a no-SDK app this scan finds nothing — itself corroborating evidence for the claim — and catches a careless future dependency that quietly reads a device ID, reinforcing the dependency-minimalism gate (research note, Finding 10).
- **The account-free design removes the riskiest store duties entirely.** Apple "let[s] people use it without a login … Apps may not require users to enter personal information to function" (5.1.1(v)) ([Apple: App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)); the app has no accounts, so the account-deletion duty never arises, and 3.1.1 in-app-purchase rules never apply because nothing is sold (research note, Finding 8).

### Specification

The app-level `ios/Runner/PrivacyInfo.xcprivacy` (collected types empty; tracking false; reason codes for the APIs actually used):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>                                    <!-- no tracking, ever -->
  <key>NSPrivacyTrackingDomains</key>
  <array/>                                    <!-- empty: no tracking domains -->
  <key>NSPrivacyCollectedDataTypes</key>
  <array/>                                    <!-- empty: Data Not Collected -->
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>   <!-- settings -->
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>  <!-- access info only this app wrote -->
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryDiskSpace</string>      <!-- pack download / backup -->
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>E174.1</string></array>  <!-- write/delete files for the user -->
    </dict>
  </array>
</dict>
</plist>
```

The cross-store declaration matrix:

| Store | Declaration | Value | Mandatory artifact |
|---|---|---|---|
| Apple App Store | Privacy nutrition label | **Data Not Collected** | `PrivacyInfo.xcprivacy` + privacy policy link (5.1.1(i)) |
| Google Play | Data safety form | **No data collected** (unskippable) | covers third-party SDKs too |
| F-Droid | Anti-Features | none (no Tracking/Ads) | — (the open source *is* the disclosure) |

### Pitfalls / what we refuse

- **We refuse any feature that would force a "yes" in either store's collection form.** Even an opt-in diagnostic that transmits would break "Data Not Collected" / "No data collected"; the gate is binary and ties to [PRD §20.6](../PRD.md). Diagnostic logs stay local and are never transmitted ([PRD §17](../PRD.md)).
- **We refuse an inaccurate or stale manifest.** Apple makes the developer "responsible for keeping your responses accurate and up to date" ([Apple: App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)); a new required-reason API use without a matching reason code is a release blocker, and we audit bundled plugins for *their own* manifests.
- **We refuse to add an account "for backup."** Backup is a user-initiated local file ([10-backup-format.md](10-backup-format.md)); an account would resurrect the account-deletion duty and the collection surface the design exists to avoid.

---

## 7. Multi-channel distribution and the policy-risk hedge

### Decision

The app ships through **four channels**: **F-Droid** (primary, §5), **Google Play**, the **Apple App Store**, and **signed GitHub Releases** consumable by **Obtainium** (install + auto-update straight from the releases page). We **track** Google's 2025 developer-registration decree as a live threat to free/open distribution, and treat the multi-channel posture as the hedge against any single gatekeeper narrowing access (*Decision log: Open-source license & release*).

### Rationale

- **A *ṣadaqah* app should maximize reach and resilience.** Signed GitHub Releases let Obtainium users "install … apps directly from their releases pages" and "receive notifications when new releases are made available," independent of any store's gatekeeping; Accrescent offers a hardened alternative store ([AlternativeTo: Accrescent / Obtainium](https://www.alternativeto.net/software/accrescent/)) (research note, Finding 12). Because the same reproducible build is signed with our key (§4), a GitHub-Releases install is as verifiable as the F-Droid one.
- **The Android open-distribution landscape is under active threat.** F-Droid warns Google's August 2025 decree, "if it were to be put into effect … will end the F-Droid project and other free/open-source app distribution sources as we know them today," requiring central registration, fees, government-ID verification, and enumeration of "all the unique application identifiers" ([F-Droid: Registration decree](https://f-droid.org/en/2025/09/29/google-developer-registration-decree.html)). A free app whose natural home is sideloading and F-Droid must watch this and keep the signed-GitHub-Releases path alive as insurance (research note, Finding 12).
- **The App Store accepts a free app cleanly.** Apple's guidelines do not require pricing; the only metadata duty is that "if your business model isn't obvious, make sure to explain in its metadata and App Review notes" ([Apple: App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)) — which we do (free, *ṣadaqah*, no IAP, no account). Guideline 2.5.2 (no downloaded/executed code) is satisfied because the one-time download is *static data*, not code, and the engine is plain compiled Dart arithmetic with no AI model ([PRD C2](../PRD.md)) (research note, Finding 8).

### Specification

| Channel | Artifact | Signing / trust | Update mechanism |
|---|---|---|---|
| **F-Droid** | reproducible APK | **our** key (reproducible) | F-Droid client; metadata from `fastlane/` |
| **Google Play** | signed AAB | our key + Play signing | Play; Data safety = no data collected |
| **Apple App Store** | IPA | Apple signing | App Store; `PrivacyInfo.xcprivacy` + policy |
| **GitHub Releases (Obtainium)** | reproducible APK + SLSA attestation | **our** key; `gh attestation verify` | Obtainium watches the releases page |

The "business model" App Review note states plainly: *free, built as ongoing charity (ṣadaqah jāriyah); no in-app purchase, no subscription, no account, no ads, no data collection; one-time download of static public Quran assets, then fully offline.*

### Pitfalls / what we refuse

- **We refuse single-channel dependence.** No one store may become the only way to get the app; the signed-GitHub-Releases / Obtainium path is maintained precisely so a hostile policy change at Google or Apple cannot orphan users (research note, Finding 12).
- **We refuse to monetize through any channel.** No IAP, no subscription, no ads, no paid tier — so the App Store's 3.1.1 IAP machinery and Play's billing rules never apply ([PRD §1](../PRD.md); research note, Finding 8).
- **We refuse to phone home after install.** Store trust is extended exactly once — at install — and from then on the app extends *zero* further trust to any network or remote-config service (research note, Implication 10; [09](09-asset-packs-and-offline-integrity.md)).

---

## 8. Auditability: "verify us yourself"

### Decision

The repository ships a **"Verify us yourself"** document (`docs/verify-yourself.md`) that converts every trust claim into a step a reader can independently check: rebuild the exact Android bytes from source (reproducible build + SLSA attestation), confirm the empty Data-safety / "Data Not Collected" declarations against the open source, observe airplane-mode operation, and re-derive the asset hashes. Auditability is treated as a **deliverable**, not a slogan (*Decision log: Open-source license & release*; [PRD §19.3](../PRD.md)).

### Rationale

- **An offline, no-AI, no-telemetry app's whole value proposition is checkability.** The open repo is "what upgrades the declaration from *aspirational* to *auditable* — anyone can read the source and confirm the single network code path" (research note, Finding 9). The reproducible build is the strongest claim available: an auditor "can independently rebuild the exact bytes from source" (research note, Finding 4).
- **It mirrors the asset-side trust story.** The release story is the code-side analogue of the asset story ([09](09-asset-packs-and-offline-integrity.md)): the user trusts a signed binary once, then the app phones home to nothing. Documenting *how to verify both* — code provenance here, asset hashes there — is the concrete meaning of the engineering pillar "open-source & auditable" (README pillar 7; research note, Implication 4).

### Specification

`docs/verify-yourself.md` walks a reader through four independent checks:

```text
1. Verify the binary matches the source (Android)
   - gh attestation verify app-release.aab --repo hifz-companion/app
   - or: rebuild from the pinned tag with the pinned Flutter version (§4) and
     compare the APK hash to the published release.

2. Verify "no data collected"
   - Read the single networking module in /assets (the ONLY code allowed a
     network import — CI-enforced, §4). Confirm it does one HTTPS GET of a
     public asset URL with no auth, cookies, or identifiers.
   - Cross-check against the Play "No data collected" and Apple "Data Not
     Collected" declarations and PrivacyInfo.xcprivacy (§6).

3. Verify "offline forever"
   - Complete the one-time core-pack download, enable airplane mode, and use
     the full app — Today, Muṣḥaf, Mutashābihāt, Progress — with no network.

4. Verify the muṣḥaf bytes (data repo)
   - Re-derive each asset's SHA-256 and compare to the manifest baked into the
     binary; see 09-asset-packs-and-offline-integrity.md.
```

### Pitfalls / what we refuse

- **We refuse claims a reader cannot check.** Every privacy/offline/integrity assertion in the README or store listing maps to a step in this doc; an unverifiable claim is removed or rewritten.
- **We refuse to let the verify-doc rot.** It is reviewed whenever the build, the networking module, or the manifest format changes — a stale verification walkthrough is worse than none.
- **We refuse to treat auditability as marketing.** It is a release artifact with its own gate; "open-source & auditable" (README pillar 7) is a build invariant, not a tagline.

---

## References

- GNU Project. *GNU General Public License, version 3* (§7 additional permissions; §10 "no further restrictions"). https://www.gnu.org/licenses/gpl-3.0.html
- Signal Messenger. *License update* (June 2016 App Store additional permission for GPL-compliant apps). https://signal.org/blog/license-update/
- wger Project. *Add app store exception to license — Issue #10, wger-project/flutter* (what an App Store exception is and why a Flutter project adds one). https://github.com/wger-project/flutter/issues/10
- quran (Quran.com / Quran Foundation). *quran_android* (GPL-3.0 precedent). https://github.com/quran/quran_android
- The Quranic Arabic Corpus. *License* (GNU GPL). https://corpus.quran.com/license.jsp
- Open Waqf. *Digital Sadaqah Jariyah — privacy-focused, ad-free, open-source software.* https://open-waqf.org/
- AboutCode (nexB). *On GPL 3.0 and Related License Compliance Issues* (AGPL §13 network clause fires only on provider modification). https://aboutcode.org/2021/gpl-3-0-license-compliance/
- Developer Certificate of Origin. *DCO 1.1* (certification clauses a/b/c/d; Signed-off-by; indefinite public record). https://developercertificate.org/
- REUSE Software (FSFE). *Tutorial* (LICENSES/ directory; per-file SPDX-FileCopyrightText + SPDX-License-Identifier; reuse lint). https://reuse.software/tutorial/
- F-Droid. *Inclusion Policy* (FLOSS-everything; 100% FLOSS toolchain; banned Play Services/Firebase/Crashlytics/ad/tracking SDKs; Flutter allowed; reproducible builds best practice). https://f-droid.org/en/docs/Inclusion_Policy/
- F-Droid. *Anti-Features* (NonFreeNet, NonFreeDep, NonFreeAssets, Tracking, Ads definitions; tracking apps hidden by default). https://f-droid.org/en/docs/Anti-Features/
- F-Droid. *Reproducible builds, signing keys, and binary repos* (upstream-signed APKs when reproducible; the two-party guarantee). https://f-droid.org/2023/09/03/reproducible-builds-signing-keys-and-binary-repos.html
- F-Droid. *All About Descriptions, Graphics & Screenshots* (fastlane/metadata/android/<locale>/; short/full description; metadata under repo owner control). https://f-droid.org/en/docs/All_About_Descriptions_Graphics_and_Screenshots/
- F-Droid. *F-Droid and Google's Developer Registration Decree* (Aug 2025 decree; existential threat to F-Droid and sideloading). https://f-droid.org/en/2025/09/29/google-developer-registration-decree.html
- Apple. *App Review Guidelines* (3.1.1 IAP; 2.5.2 no downloaded code; 5.1.1(i) mandatory privacy policy; 5.1.1(v) optional login; business-model metadata note). https://developer.apple.com/app-store/review/guidelines/
- Apple. *App Privacy Details* (definition of "Collect"; on-device processing is not collection; developer responsible for accuracy). https://developer.apple.com/app-store/app-privacy-details/
- Apple via Sentry. *Apple Privacy Manifest for Flutter* (spring-2024 required-reason API + manifest enforcement; PrivacyInfo.xcprivacy). https://docs.sentry.io/platforms/dart/guides/flutter/data-management/apple-privacy-manifest/
- flutter/flutter. *Add blank Required Reason API xcprivacy manifest to plugin template — Issue #140013* (Flutter's native privacy-manifest support). https://github.com/flutter/flutter/issues/140013
- Google Play. *Provide information for Google Play's Data safety section* (mandatory; "no data collected" still required; covers third-party SDKs). https://support.google.com/googleplay/android-developer/answer/10787469
- Respectlytics. *Google Play Data Safety Section: Step-by-Step Guide* (2025 automated pre-submission binary checks). https://respectlytics.com/blog/google-play-data-safety-guide/
- Google Play. *Get started with Play Console* (US$25 one-time registration fee). https://support.google.com/googleplay/android-developer/answer/6112435
- GitHub. *actions/attest-build-provenance* (signed SLSA build-provenance attestations; id-token/attestations permissions; gh attestation verify). https://github.com/marketplace/actions/attest-build-provenance
- Flutter API. *matchesGoldenFile function* (goldens are OS/font/Flutter-version sensitive). https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
- AlternativeTo. *Accrescent / Obtainium* (Obtainium installs/updates from releases pages; Accrescent as security-focused F-Droid alternative). https://www.alternativeto.net/software/accrescent/
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Asset Packs & Offline Integrity.* [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)
- Hifz Companion. *OSS Mobile Release, Licensing & F-Droid Distribution — Research Note.* [research/oss-mobile-release-fdroid.md](research/oss-mobile-release-fdroid.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
