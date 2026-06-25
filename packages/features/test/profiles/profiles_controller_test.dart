// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T08: the ProfilesController write path — create (seeds a profile from a
// typed name + role, with a default cycle and no cards, no PII), rename (the
// display name only), delete. The cold-start + profile write paths are faked;
// offline guard installed.

import 'package:data/data.dart' show ColdStartRepository;
import 'package:features/features.dart' show ProfilesController;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../settings/fake_profiles.dart';
import '../test_setup.dart';

/// Records the cold-start seed and mirrors the new profile into [profiles] (as
/// the real handle does — both write paths share one store).
class _FakeColdStart implements ColdStartRepository {
  _FakeColdStart(this.profiles);

  final FakeProfileRepository profiles;
  Profile? seededProfile;
  CycleConfig? seededConfig;
  List<CardSeed>? seededCards;

  @override
  Future<void> seedColdStart(
    Profile profile,
    CycleConfig config,
    List<CardSeed> cards,
  ) async {
    seededProfile = profile;
    seededConfig = config;
    seededCards = cards;
    await profiles.upsert(profile);
  }
}

void main() {
  useOfflineTestPolicy();

  ProfilesController controller(
    FakeProfileRepository profiles,
    _FakeColdStart coldStart,
  ) =>
      ProfilesController(
        profiles: profiles,
        coldStart: coldStart,
        today: () => CalendarDate.ymd(2026, 6, 25),
        newId: () => 'new-id',
      );

  test('create seeds a profile (typed name + role, default cycle, no cards)',
      () async {
    final profiles = FakeProfileRepository([]);
    final coldStart = _FakeColdStart(profiles);

    final id = await controller(profiles, coldStart).createProfile(
      displayName: 'Aisha',
      role: ProfileRole.student,
    );

    expect(id, const ProfileId('new-id'));
    expect(coldStart.seededProfile?.displayName, 'Aisha');
    expect(coldStart.seededProfile?.role, ProfileRole.student);
    expect(coldStart.seededProfile?.locale, ProfileLocale.fa);
    expect(coldStart.seededCards, isEmpty); // bare profile — placement fills it
    expect(coldStart.seededConfig?.cycleCeilingDays, 30);
  });

  test('rename changes the display name only', () async {
    final profiles = FakeProfileRepository([fakeProfile('p1')]);
    final coldStart = _FakeColdStart(profiles);
    final before = profiles.store['p1']!;

    await controller(profiles, coldStart)
        .renameProfile(const ProfileId('p1'), 'Yusuf');

    final after = profiles.store['p1']!;
    expect(after.displayName, 'Yusuf');
    expect(after.copyWith(displayName: before.displayName), before);
  });

  test('delete removes the profile, leaving the others', () async {
    final profiles =
        FakeProfileRepository([fakeProfile('p1'), fakeProfile('p2')]);
    final coldStart = _FakeColdStart(profiles);

    await controller(profiles, coldStart).deleteProfile(const ProfileId('p1'));

    expect(profiles.store.containsKey('p1'), isFalse);
    expect(profiles.store.containsKey('p2'), isTrue);
  });
}
