// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The framework-free repository interfaces the [PersistenceHandle] exposes —
/// the public seam the shell reaches persistence through (01 §2, §4).
///
/// They reference `models` value types only — no `package:drift`/`sqlite3`
/// symbol appears here, so the boundary cannot leak a Drift type into the
/// engine/features/quran layers. The read/append method signatures are added in
/// E03-T06 (DAOs + mappers) and the single-write-path `commitReview` in E03-T07;
/// this task ships the seam, not the implementation.
library;

/// Reads and (through the single write path) writes `card` rows as `models`
/// value types. Methods: E03-T06 / E03-T07.
abstract interface class CardRepository {}

/// Reads and **appends** `review_log` rows — never updates or deletes one (the
/// append-only *sanad* audit trail). Methods: E03-T06 / E03-T07.
abstract interface class ReviewLogRepository {}

/// Reads and writes `profile` rows as `models` value types. Methods: E03-T06.
abstract interface class ProfileRepository {}
