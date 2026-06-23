// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The recite/grade route's path under the E07 `ShellRoute`. The full route
/// (`ReciteGradeScreen` + its `GoRoute`) is registered in E12-T07; this constant
/// is the single source of the location both the Today row tap (E12-T03) and the
/// route registration use, so they can never drift.
const String kRecitePathPrefix = '/recite';

/// The typed deep-link location for reciting one muṣḥaf [pageId].
String reciteLocation(int pageId) => '$kRecitePathPrefix/$pageId';
