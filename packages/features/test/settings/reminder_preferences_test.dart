// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T02: the reminder-preference write path + total decode. ReminderPreferences
// is OFF by default; decoding is total (out-of-range / malformed → calm default,
// never a throw); updateReminderPreferences persists to settings_json BEFORE the
// reminderPreferencesProvider republishes; it coexists with the display
// preferences (unknown keys preserved); a null active profile is a safe no-op.
// Offline guard installed — the write path opens no socket.

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, profileRepositoryProvider;
import 'package:features/features.dart'
    show
        ReminderPreferences,
        preferencesWriterProvider,
        reminderPreferencesProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';
import 'fake_profiles.dart';

void main() {
  useOfflineTestPolicy();

  group('ReminderPreferences decode (E18-T02)', () {
    test('is off by default at a calm 07:00, from null or empty settings', () {
      const fromNull = ReminderPreferences();
      expect(fromNull.enabled, isFalse);
      expect(fromNull.hour, 7);
      expect(fromNull.minute, 0);
      expect(fromNull.catchUpNoteEnabled, isFalse);

      expect(ReminderPreferences.fromSettings(null), const ReminderPreferences());
      expect(
        ReminderPreferences.fromSettings(const {}),
        const ReminderPreferences(),
      );
    });

    test('decode is total — out-of-range / malformed values fall back', () {
      final decoded = ReminderPreferences.fromSettings(const {
        'reminderEnabled': 'yes', // not a bool true → off
        'reminderHour': 47, // out of 0..23 → default 7
        'reminderMinute': -3, // out of 0..59 → default 0
        'reminderCatchUpNote': 1, // not a bool true → off
      });
      expect(decoded, const ReminderPreferences());
    });

    test('round-trips explicit values and preserves unknown keys', () {
      const prefs = ReminderPreferences(
        enabled: true,
        hour: 6,
        minute: 30,
        catchUpNoteEnabled: true,
      );
      // A display preference shares the same settings_json map and is untouched.
      final wire = prefs.toSettings(const {'appearance': 'dark'});
      expect(wire['appearance'], 'dark');
      expect(ReminderPreferences.fromSettings(wire), prefs);
    });
  });

  test('updateReminderPreferences persists, then the provider republishes',
      () async {
    final fake = FakeProfileRepository(
      [fakeProfile('p1', settings: {'appearance': 'dark'})],
    );
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(fake),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(reminderPreferencesProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();

    // Off until an explicit opt-in (off-by-default DoD).
    expect(container.read(reminderPreferencesProvider).enabled, isFalse);

    await container.read(preferencesWriterProvider).updateReminderPreferences(
          (p) => p.copyWith(enabled: true, hour: 6, minute: 5),
        );
    await pumpEventQueue();

    // Persisted into settings_json AND republished; the display pref is untouched.
    expect(fake.store['p1']!.settings!['reminderEnabled'], true);
    expect(fake.store['p1']!.settings!['reminderHour'], 6);
    expect(fake.store['p1']!.settings!['reminderMinute'], 5);
    expect(fake.store['p1']!.settings!['appearance'], 'dark');
    final republished = container.read(reminderPreferencesProvider);
    expect(republished.enabled, isTrue);
    expect(republished.hour, 6);
    expect(republished.minute, 5);
  });

  test('no active profile makes a reminder write a safe no-op', () async {
    final fake = FakeProfileRepository([fakeProfile('p1')]);
    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(preferencesWriterProvider).updateReminderPreferences(
          (p) => p.copyWith(enabled: true),
        );

    expect(fake.store['p1']!.settings, isNull);
  });
}
