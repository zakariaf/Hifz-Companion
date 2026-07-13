// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E21-T08: the page-detail prayer-critical toggle command. It writes the flag for
// the active profile through the single write path; no profile is a no-op.

import 'package:data/data.dart' show PrayerCriticalRepository;
import 'package:features/features.dart' show PrayerCriticalController;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

class _FakeRepo implements PrayerCriticalRepository {
  final List<(ProfileId, int, bool)> calls = [];

  @override
  Future<void> setPrayerCritical(
    ProfileId profileId,
    int pageId, {
    required bool value,
  }) async {
    calls.add((profileId, pageId, value));
  }
}

void main() {
  PrayerCriticalController controller(
    _FakeRepo repo, {
    ProfileId? profile = const ProfileId('p1'),
  }) =>
      PrayerCriticalController(
        repository: repo,
        readActiveProfileId: () => profile,
      );

  test('sets the flag for the active profile', () async {
    final repo = _FakeRepo();
    await controller(repo).setPrayerCritical(3, value: true);
    expect(repo.calls, [(const ProfileId('p1'), 3, true)]);
  });

  test('no active profile is a calm no-op', () async {
    final repo = _FakeRepo();
    await controller(repo, profile: null).setPrayerCritical(3, value: true);
    expect(repo.calls, isEmpty);
  });
}
