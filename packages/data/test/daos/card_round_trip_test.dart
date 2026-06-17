// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/src/db/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../db/test_database.dart';
import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late HifzDatabase db;
  setUp(() async {
    db = openTestDatabase();
    // Isolate the row↔value mapping from referential integrity (the FK cascade
    // is E03-T03's test); the CHECKs still apply.
    await db.customStatement('PRAGMA foreign_keys = OFF;');
  });
  tearDown(() async => db.close());

  test('a FAR card round-trips value → row → value identically', () async {
    final card = Card(
      profileId: const ProfileId('p'),
      pageId: 42,
      track: ReviewTrack.far,
      difficulty: 6.5,
      stabilityDays: 30.25,
      lastReviewedDay: CalendarDate.ymd(2026, 6, 1),
      dueAt: CalendarDate.ymd(2026, 6, 17),
      reps: 12,
      lapses: 2,
      isWeak: true,
      signoffs: 3,
      hasManualLock: true,
      isPrayerCritical: true,
      isEnabled: false,
    );
    await db.cardDao.upsert(card);

    final read = await db.cardDao.byId(const ProfileId('p'), 42);
    if (read == null) fail('card was not persisted');

    expect(read.profileId, card.profileId);
    expect(read.pageId, 42);
    expect(read.track, ReviewTrack.far);
    expect(read.difficulty, closeTo(6.5, 1e-6));
    expect(read.stabilityDays, closeTo(30.25, 1e-6));
    expect(read.lastReviewedDay, CalendarDate.ymd(2026, 6, 1));
    expect(read.dueAt, CalendarDate.ymd(2026, 6, 17));
    expect(read.reps, 12);
    expect(read.lapses, 2);
    expect(read.isWeak, isTrue);
    expect(read.signoffs, 3);
    expect(read.hasManualLock, isTrue);
    expect(read.isPrayerCritical, isTrue);
    expect(read.isEnabled, isFalse);
  });

  test('due_at is physically stored as the serial-day int, not an instant',
      () async {
    final due = CalendarDate.ymd(2026, 6, 17);
    await db.cardDao.upsert(
      Card(
        profileId: const ProfileId('p'),
        pageId: 7,
        track: ReviewTrack.near,
        difficulty: 5,
        stabilityDays: 10,
        dueAt: due,
      ),
    );
    final row = await db
        .customSelect(
          "SELECT due_at FROM card WHERE profile_id = 'p' AND page_id = 7",
        )
        .getSingle();
    expect(row.read<int>('due_at'), due.epochDay);
  });

  test('an UNMEMORIZED card round-trips dueAt: null', () async {
    await db.cardDao.upsert(
      const Card(
        profileId: ProfileId('p'),
        pageId: 9,
        track: ReviewTrack.unmemorized,
        difficulty: 5,
        stabilityDays: 0,
      ),
    );
    final read = await db.cardDao.byId(const ProfileId('p'), 9);
    if (read == null) fail('card was not persisted');
    expect(read.dueAt, isNull);
    expect(read.lastReviewedDay, isNull);
    expect(read.track, ReviewTrack.unmemorized);
  });

  test('every ReviewTrack round-trips through its wire string', () async {
    for (var i = 0; i < ReviewTrack.values.length; i++) {
      final track = ReviewTrack.values[i];
      final isUnmemorized = track == ReviewTrack.unmemorized;
      await db.cardDao.upsert(
        Card(
          profileId: const ProfileId('p'),
          pageId: 100 + i,
          track: track,
          difficulty: 5,
          stabilityDays: 1,
          dueAt: isUnmemorized ? null : CalendarDate.ymd(2026, 6, 17),
        ),
      );
      final read = await db.cardDao.byId(const ProfileId('p'), 100 + i);
      if (read == null) fail('card $track was not persisted');
      expect(read.track, track);
    }
  });
}
