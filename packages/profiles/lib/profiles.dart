// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The local multi-profile model for Hifz Companion (self / students / child),
/// device-local with no cloud and no account.
///
/// The real [Profile] fields — display name, role, locale, muṣḥaf id — are
/// fleshed out by the profiles/settings feature epic; this barrel currently
/// exports only a compile-proving stub.
library;

export 'src/profile.dart';
