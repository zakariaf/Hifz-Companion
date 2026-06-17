<!--
SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Contributing to Hifz Companion

Hifz Companion is built free, as *ṣadaqah jāriyah*. Contributions are welcome —
and they arrive under the project's own terms, with no paperwork beyond a
sign-off on each commit.

## License & the App Store exception

Inbound code is licensed **GPL-3.0-or-later _with the GPLv3 §7 App Store
additional permission_** (see [`LICENSE`](LICENSE)). The exception must travel
with the license: a contribution that arrives as bare GPL-3.0 — without the
exception — would, once merged, create a co-copyright-holder whose code lacks
the App Store grant, re-opening the hole the exception exists to close. So every
contribution is made under the project's stated license, *including* the
exception.

- **No CLA. No copyright assignment.** You keep your copyright; the project
  holds no power to relicense your work proprietary. That is the structural
  guarantee the *ṣadaqah* gift cannot later be enclosed.
- A contributor who cannot license their code as GPL-3.0-or-later with the §7
  exception cannot contribute that code.

## Developer Certificate of Origin (DCO) 1.1

We use the **Developer Certificate of Origin**, not a CLA. Every commit must
carry a `Signed-off-by:` trailer certifying the text below. By signing off, you
certify the following, **verbatim**:

```text
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

### Signing off

Append the sign-off trailer to every commit:

```bash
# DCO sign-off: appends a verifiable "Signed-off-by" trailer matching your git identity
git commit --signoff -m "engine: clamp due_at to the cycle ceiling"
# trailer added: Signed-off-by: Name <email>
```

A commit missing its sign-off is **rebased to add it**, never waved through
"just this once." (CI enforces this on every commit in a PR.)

## Pull-request rules

- **PR-based workflow, even solo.** Every change lands via a pull request with a
  written intent description; the public PR history is part of the *waqf* audit
  trail.
- **≤ ~400 changed LOC, one concern per PR.** The author self-annotates
  non-obvious hunks before requesting review.
- **100% review on the trust-critical modules** — `engine/`, `data/`, `quran/`,
  and the asset downloader — where a defect is reputation-ending (a wrong glyph,
  a silently-decayed page, a corrupted schedule).
- **No new dependency** without explanation; any `pubspec.lock` change is
  justified in the PR (no analytics, ads, backend, or crash-reporting SDK).

Every PR follows the checklist in
[`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md).
