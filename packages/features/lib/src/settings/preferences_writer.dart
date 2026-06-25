// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ProfileRepository;
import 'package:models/models.dart' show Profile, ProfileId;

import 'display_preferences.dart';
import 'reminder_preferences.dart';

/// The single write path for a profile's display preferences (eng-create-
/// riverpod-store §3): a calm command object that reads the active profile,
/// applies an immutable change, and **persists transactionally before** the
/// reactive `activeProfileRecordProvider` stream republishes.
///
/// It holds no state, reads no clock, opens no socket, and never re-derives a
/// `due_at`. With no active profile (e.g. before onboarding completes) every
/// mutation is a safe no-op rather than a throw.
class PreferencesWriter {
  /// Creates a writer over the [profiles] repository, reading the current active
  /// profile id through [readActiveProfileId] at write time (so a halaqa switch
  /// writes to whichever student is active *now*).
  PreferencesWriter({
    required ProfileRepository profiles,
    required ProfileId? Function() readActiveProfileId,
  })  : _profiles = profiles,
        _readActiveProfileId = readActiveProfileId;

  final ProfileRepository _profiles;
  final ProfileId? Function() _readActiveProfileId;

  /// Reads the active profile, applies [update], and upserts the result — the
  /// generic persist-before-republish profile mutation the concrete preference
  /// setters build on. A no-op when no profile is active or the row is absent.
  Future<void> mutateActiveProfile(
    Profile Function(Profile current) update,
  ) async {
    final id = _readActiveProfileId();
    if (id == null) return;
    final current = await _profiles.byProfileId(id);
    if (current == null) return;
    await _profiles.upsert(update(current));
  }

  /// Applies [update] to the active profile's [DisplayPreferences] and persists
  /// the result back into its `settings_json`, preserving unknown keys.
  Future<void> updateDisplayPreferences(
    DisplayPreferences Function(DisplayPreferences current) update,
  ) =>
      mutateActiveProfile((profile) {
        final next = update(DisplayPreferences.fromSettings(profile.settings));
        return profile.copyWith(settings: next.toSettings(profile.settings));
      });

  /// Applies [update] to the active profile's [ReminderPreferences] and persists
  /// the result back into its `settings_json`, preserving unknown keys (E18-T02).
  /// The OS reschedule (E18-T03/T05) runs only *after* this commit, never from a
  /// view — the schedule is a derived cache over the persisted truth.
  Future<void> updateReminderPreferences(
    ReminderPreferences Function(ReminderPreferences current) update,
  ) =>
      mutateActiveProfile((profile) {
        final next = update(ReminderPreferences.fromSettings(profile.settings));
        return profile.copyWith(settings: next.toSettings(profile.settings));
      });
}
