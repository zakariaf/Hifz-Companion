// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ProfileId;

/// The profile id the device starts on, read once from disk in `main()` and
/// supplied via `overrideWithValue` (04 §1.2).
///
/// `null` on a fresh install (no profile exists yet → onboarding). It is a plain
/// constant the composition root computes from `profiles.all()`; tests override
/// it directly. Separated from [activeProfileProvider] so the mutable in-session
/// notifier has a deterministic, injectable initial value.
final initialActiveProfileProvider = Provider<ProfileId?>((ref) => null);

/// The profile the shell is currently acting for — self, a student, or a child
/// (PRD §12; local multi-profile, device-only, no account).
///
/// `null` until a profile exists and is selected: the redirect guard (E07-T03)
/// sends a null-profile device to onboarding before any Quran screen resolves
/// (PRD R1). The minimal cold-start seed (E07-T06) calls [ActiveProfile.select]
/// after the seed is durably committed — never optimistically before.
class ActiveProfile extends Notifier<ProfileId?> {
  @override
  ProfileId? build() => ref.read(initialActiveProfileProvider);

  /// Makes [id] the active profile (after cold-start seeding or a halaqa switch).
  void select(ProfileId id) => state = id;

  /// Clears the active profile (e.g. after the profile is erased).
  void clear() => state = null;
}

/// The active-profile notifier provider (04 §1.2 — the only profile gate).
final activeProfileProvider = NotifierProvider<ActiveProfile, ProfileId?>(
  ActiveProfile.new,
);
