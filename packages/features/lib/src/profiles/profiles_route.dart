// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The location of the Profiles management screen — a child route under the
/// Settings tab's `ShellRoute`, so the Settings tab stays selected and the
/// router's redirect guard still applies. One source of truth for the path,
/// referenced by the router and the Settings Profiles row.
const String kProfilesPath = '/settings/profiles';
