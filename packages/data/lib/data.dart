// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The local single source of truth for Hifz Companion: the Drift/SQLite schema,
/// DAOs, and the repositories that are the only public write path (transactional,
/// persist-before-republish, over an append-only review_log).
///
/// This barrel exports repositories and DTOs only — never the raw DAOs. The
/// schema, migrations, DAOs, and repository bodies (WAL + synchronous=FULL) are
/// authored in E03; it currently exports one compile-proving placeholder.
library;

export 'src/dates/today_for.dart' show todayFor;
export 'src/repositories/placeholder_repository.dart';
