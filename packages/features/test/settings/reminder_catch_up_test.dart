// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T09: the optional catch-up note. When the catch-up toggle is ON and a
// missed-gap backlog exists (hasCatchUpBacklogProvider — the E12 read model, read
// not computed), the daily reminder body becomes the help-framed catch-up line;
// with no backlog OR the toggle off, it stays the calm daily line. Offline guard.

import 'package:composition/composition.dart'
    show
        initialActiveProfileProvider,
        notificationSchedulerProvider,
        profileRepositoryProvider;
import 'package:composition/testing.dart' show FakeNotificationScheduler;
import 'package:features/features.dart'
    show
        hasCatchUpBacklogProvider,
        reminderControllerProvider,
        reminderPreferencesProvider;
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart' show AppLocalizations;
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';
import 'fake_profiles.dart';

const _onWithCatchUp = <String, Object?>{
  'reminderEnabled': true,
  'reminderCatchUpNote': true,
};
const _onCatchUpOff = <String, Object?>{'reminderEnabled': true};

void main() {
  useOfflineTestPolicy();

  Future<AppLocalizations> faL10n() =>
      AppLocalizations.delegate.load(const Locale('fa'));

  ProviderContainer makeContainer(
    FakeNotificationScheduler scheduler,
    FakeProfileRepository profiles, {
    required bool backlog,
  }) {
    final c = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profiles),
        initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
        notificationSchedulerProvider.overrideWithValue(scheduler),
        hasCatchUpBacklogProvider.overrideWithValue(backlog),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> settle(ProviderContainer c) async {
    final sub = c.listen(reminderPreferencesProvider, (_, __) {});
    addTearDown(sub.close);
    await pumpEventQueue();
  }

  test('catch-up on + a backlog -> the daily reminder uses the catch-up body',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: _onWithCatchUp),
    ]);
    final c = makeContainer(scheduler, profiles, backlog: true);
    await settle(c);

    await c.read(reminderControllerProvider).reconcile();

    expect(scheduler.scheduled.last.body, (await faL10n()).reminderCatchUpBody);
  });

  test('catch-up on + NO backlog -> the calm daily body', () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: _onWithCatchUp),
    ]);
    final c = makeContainer(scheduler, profiles, backlog: false);
    await settle(c);

    await c.read(reminderControllerProvider).reconcile();

    expect(
      scheduler.scheduled.last.body,
      (await faL10n()).reminderNotificationBody,
    );
  });

  test('catch-up OFF + a backlog -> still the calm daily body (note is opt-in)',
      () async {
    final scheduler = FakeNotificationScheduler();
    final profiles = FakeProfileRepository([
      fakeProfile('p1', settings: _onCatchUpOff),
    ]);
    final c = makeContainer(scheduler, profiles, backlog: true);
    await settle(c);

    await c.read(reminderControllerProvider).reconcile();

    expect(
      scheduler.scheduled.last.body,
      (await faL10n()).reminderNotificationBody,
    );
  });
}
