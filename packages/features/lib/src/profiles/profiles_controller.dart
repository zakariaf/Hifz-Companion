// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show ColdStartRepository, ProfileRepository;
import 'package:models/models.dart';

import '../ids/uuid_v4.dart';

/// The single write path for the device's profile set (E16-T08): create a new
/// profile from a typed display name + role (the only PII is the name — no
/// account, no login, PRD §17), rename one, or delete one. Each mutation persists
/// transactionally **before** the reactive `profilesListProvider` stream
/// republishes.
///
/// A new profile is seeded with a default cycle config (and no cards — its
/// placement, or an imported `.hifzbackup`, fills them later) so it is
/// immediately functional. It holds no state and reads no wall clock — the
/// creation instant comes from the injected `CalendarDate` day.
class ProfilesController {
  /// Creates the controller over the profile + cold-start write paths, reading
  /// "today" from the injected clock and the new id from [newId] (a v4 UUID).
  ProfilesController({
    required ProfileRepository profiles,
    required ColdStartRepository coldStart,
    required CalendarDate Function() today,
    String Function() newId = uuidV4,
  })  : _profiles = profiles,
        _coldStart = coldStart,
        _today = today,
        _newId = newId;

  final ProfileRepository _profiles;
  final ColdStartRepository _coldStart;
  final CalendarDate Function() _today;
  final String Function() _newId;

  /// Creates a profile from a typed [displayName] and [role] (defaulting to the
  /// primary locale and the bundled muṣḥaf), seeded with a default cycle and no
  /// cards. Returns the durable new id. The caller activates it only after this
  /// resolves (never optimistically).
  Future<ProfileId> createProfile({
    required String displayName,
    required ProfileRole role,
  }) async {
    final id = ProfileId(_newId());
    final day = _today();
    final profile = Profile(
      profileId: id,
      displayName: displayName,
      role: role,
      locale: ProfileLocale.fa,
      mushafId: kKfgqpcHafsMadaniV2Edition.mushafId,
      // The creation instant from the injected scheduling day — no wall clock.
      createdAtInstant: DateTime.utc(day.year, day.month, day.day),
    );
    await _coldStart.seedColdStart(profile, _defaultCycle(id), const []);
    return id;
  }

  /// Renames [profileId] to [displayName] (the only mutable PII). A no-op if the
  /// profile is absent.
  Future<void> renameProfile(ProfileId profileId, String displayName) async {
    final current = await _profiles.byProfileId(profileId);
    if (current == null) return;
    await _profiles.upsert(current.copyWith(displayName: displayName));
  }

  /// Permanently deletes [profileId] and all its scoped rows (FK cascade). Other
  /// profiles are untouched.
  Future<void> deleteProfile(ProfileId profileId) =>
      _profiles.delete(profileId);

  CycleConfig _defaultCycle(ProfileId id) => CycleConfig(
        profileId: id,
        cycleType: '1_juz_day',
        nearWindowJuz: 3,
        farTargetPerDay: (kKfgqpcHafsMadaniV2Edition.pageCount / 30).ceil(),
        cycleCeilingDays: 30,
        dailyBudgetMinutes: 30,
        termLabelSet: 'classical',
      );
}
