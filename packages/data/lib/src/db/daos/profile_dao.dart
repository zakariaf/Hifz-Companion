// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:drift/drift.dart';
import 'package:models/models.dart';

import '../database.dart';
import '../tables/user/profiles.dart';
import 'mappers.dart';

part 'profile_dao.g.dart';

/// Reads and upserts `profile` rows as `models.Profile` value types (05 §2).
@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<HifzDatabase> with _$ProfileDaoMixin {
  /// Creates the DAO over [db].
  ProfileDao(super.db);

  /// Inserts or replaces a profile.
  Future<void> upsert(Profile profile) =>
      into(profiles).insertOnConflictUpdate(_toCompanion(profile));

  /// The profile for [profileId], or null if none.
  Future<Profile?> byId(ProfileId profileId) async {
    final query = select(profiles)
      ..where((p) => p.profileId.equals(profileId.value));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// All profiles on the device.
  Future<List<Profile>> all() async {
    final rows = await select(profiles).get();
    return rows.map(_toModel).toList();
  }

  Profile _toModel(ProfileRow row) {
    return Profile(
      profileId: ProfileId(row.profileId),
      displayName: row.displayName,
      role: enumFromWire(
        ProfileRole.values,
        (r) => r.wireValue,
        row.role,
        'ProfileRole',
      ),
      locale: enumFromWire(
        ProfileLocale.values,
        (l) => l.wireValue,
        row.locale,
        'ProfileLocale',
      ),
      mushafId: row.mushafId,
      createdAtInstant: instantFromWire(row.createdAt),
      settings: settingsFromJson(row.settingsJson),
    );
  }

  ProfilesCompanion _toCompanion(Profile profile) {
    return ProfilesCompanion(
      profileId: Value(profile.profileId.value),
      displayName: Value(profile.displayName),
      role: Value(profile.role.wireValue),
      locale: Value(profile.locale.wireValue),
      mushafId: Value(profile.mushafId),
      createdAt: Value(instantToWire(profile.createdAtInstant)),
      settingsJson: Value(settingsToJson(profile.settings)),
    );
  }
}
