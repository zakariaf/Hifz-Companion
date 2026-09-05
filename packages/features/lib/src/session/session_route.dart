// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The full-screen revision-session route (plain redesign, 2026-09-05): the
/// day's pages recited one after another — reveal, mark stumbles, grade, next —
/// with a plain factual close. Gated on the verified core like every route that
/// composes the immutable glyph page (R1).
const String kSessionPath = '/session';

/// The optional query parameter naming the page the session starts from (a
/// Today row tap); absent, the session starts at the first page of the day.
const String kSessionStartQuery = 'start';

/// Builds the session location, optionally starting from [startPageId].
String sessionLocation({int? startPageId}) => startPageId == null
    ? kSessionPath
    : '$kSessionPath?$kSessionStartQuery=$startPageId';
