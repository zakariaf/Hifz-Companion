// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Thin, zero-cost typed wrappers over the UUID `String` primary keys, so a
/// `profileId` can never be passed where a `logId` is expected at a call site.
///
/// These are Dart `extension type`s: at runtime each *is* its [String] value
/// (no allocation, no boxing), so equality, `hashCode`, and use as a map key
/// are exactly `String`'s — two ids with the same text are equal. The DAO
/// (E03-T06) wraps a stored TEXT key on read and unwraps `.value` on write.
/// `pageId`/`ayahA`/`ayahB` are deliberately **not** wrapped: they key into the
/// read-only reference tables (E03-T02) and stay their schema types
/// (`int`/`String`).
library;

/// A profile's UUID primary key (`profile.profile_id`).
extension type const ProfileId(String value) {}

/// A review-log row's UUID primary key (`review_log.log_id`).
extension type const LogId(String value) {}

/// A line-block's UUID primary key (`line_block.block_id`).
extension type const BlockId(String value) {}
