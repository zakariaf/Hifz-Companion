// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Well-known keys in the app-level `app_meta` (key, value) store (05 §2).
///
/// The store is generic `String`/`String`; these constants name the keys whose
/// semantics cross a layer boundary, so the writer (the core installer's
/// verified stamp) and the reader (the app-ready gate) agree on one literal
/// rather than two.
library;

/// The key stamped once the bundled core muṣḥaf has been verified (every file's
/// SHA-256 matched the binary-baked manifest) and its reference DB built — the
/// durable "the muṣḥaf is whole and ready" signal (engineering 09 §2).
///
/// Absent until a successful first-launch core install (written via the
/// installer's `CoreVerifiedStamp`, wired in E11). The app-ready gate reads it
/// to refuse any Quran-rendering route on an unverified install (PRD R1).
const String kAppMetaKeyTextChecksumVerifiedAt = 'text_checksum_verified_at';
