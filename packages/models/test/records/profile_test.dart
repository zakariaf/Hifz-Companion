// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  final profile = Profile(
    profileId: const ProfileId('profile-1'),
    displayName: 'Aisha',
    role: ProfileRole.student,
    locale: ProfileLocale.ckb,
    mushafId: 'hafs_madani_15',
    createdAtInstant: DateTime.utc(2026, 1, 5, 8),
    settings: const {'reminderHour': 20, 'theme': 'sepia'},
  );

  group('Profile construction', () {
    test('displayName is the only PII; settings is schema-shaped data', () {
      expect(profile.displayName, 'Aisha');
      expect(profile.settings, {'reminderHour': 20, 'theme': 'sepia'});
    });

    test('createdAtInstant is a UTC DateTime', () {
      final DateTime created = profile.createdAtInstant;
      expect(created.isUtc, isTrue);
    });

    test('settings is a Map<String, Object?>?', () {
      final Map<String, Object?>? settings = profile.settings;
      expect(settings, isA<Map<String, Object?>>());
    });
  });

  group('Profile role/locale match the schema CHECK wire tokens', () {
    test('ProfileRole wire tokens are exactly self/student/child', () {
      expect(
        ProfileRole.values.map((r) => r.wireValue).toSet(),
        {'self', 'student', 'child'},
      );
    });

    test('ProfileLocale wire codes are exactly ar/fa/ckb', () {
      expect(
        ProfileLocale.values.map((l) => l.wireValue).toSet(),
        {'ar', 'fa', 'ckb'},
      );
    });
  });

  group('Profile.copyWith', () {
    test('copyWith() with no args preserves every field', () {
      expect(profile.copyWith(), profile);
    });

    test('copyWith(displayName:) changes only the name', () {
      final renamed = profile.copyWith(displayName: 'Aisha Rahman');
      expect(renamed.displayName, 'Aisha Rahman');
      expect(renamed.profileId, profile.profileId);
      expect(renamed.role, profile.role);
      expect(renamed.locale, profile.locale);
      expect(renamed.mushafId, profile.mushafId);
      expect(renamed.createdAtInstant, profile.createdAtInstant);
      expect(renamed.settings, profile.settings);
    });

    test('two profiles with equal fields are value-equal', () {
      final twin = Profile(
        profileId: const ProfileId('profile-1'),
        displayName: 'Aisha',
        role: ProfileRole.student,
        locale: ProfileLocale.ckb,
        mushafId: 'hafs_madani_15',
        createdAtInstant: DateTime.utc(2026, 1, 5, 8),
        settings: const {'reminderHour': 20, 'theme': 'sepia'},
      );
      expect(twin, profile);
      expect(twin.hashCode, profile.hashCode);
    });
  });
}
