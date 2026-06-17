// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  // A FAR card with every field set to a non-default value, so a copyWith()
  // that silently dropped a field would revert it to its default and fail the
  // identity assertion below.
  final farCard = Card(
    profileId: const ProfileId('profile-1'),
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

  group('Card construction', () {
    test('an UNMEMORIZED card has a null dueAt', () {
      const card = Card(
        profileId: ProfileId('profile-1'),
        pageId: 1,
        track: ReviewTrack.unmemorized,
        difficulty: 5,
        stabilityDays: 0,
      );
      expect(card.dueAt, isNull);
      expect(card.lastReviewedDay, isNull);
      expect(card.track, ReviewTrack.unmemorized);
    });

    test('a FAR card carries a concrete CalendarDate dueAt', () {
      expect(farCard.dueAt, CalendarDate.ymd(2026, 6, 17));
      expect(farCard.track, ReviewTrack.far);
    });

    test('counters and flags default to the schema column defaults', () {
      const card = Card(
        profileId: ProfileId('p'),
        pageId: 1,
        track: ReviewTrack.unmemorized,
        difficulty: 5,
        stabilityDays: 0,
      );
      expect(card.reps, 0);
      expect(card.lapses, 0);
      expect(card.signoffs, 0);
      expect(card.isWeak, isFalse);
      expect(card.hasManualLock, isFalse);
      expect(card.isPrayerCritical, isFalse);
      expect(card.isEnabled, isTrue);
    });
  });

  group('Card scheduling-day and stability are typed, not instants', () {
    test('dueAt / lastReviewedDay are CalendarDate (compile-time pin)', () {
      // A static-type assignment: if a future edit retyped these as DateTime,
      // this would fail to compile — the DST off-by-one this epic removes.
      final CalendarDate? due = farCard.dueAt;
      final CalendarDate? last = farCard.lastReviewedDay;
      expect(due, isA<CalendarDate>());
      expect(last, isA<CalendarDate>());
    });

    test('stabilityDays / difficulty are double (compile-time pin)', () {
      final double stability = farCard.stabilityDays;
      final double difficulty = farCard.difficulty;
      expect(stability, 30.25);
      expect(difficulty, 6.5);
    });
  });

  group('Card.copyWith', () {
    test('copyWith() with no args preserves every field', () {
      expect(farCard.copyWith(), farCard);
    });

    test('copyWith(dueAt:) changes only dueAt', () {
      final moved = farCard.copyWith(dueAt: CalendarDate.ymd(2026, 7, 1));
      expect(moved.dueAt, CalendarDate.ymd(2026, 7, 1));
      // every other field is preserved
      expect(moved.profileId, farCard.profileId);
      expect(moved.pageId, farCard.pageId);
      expect(moved.track, farCard.track);
      expect(moved.difficulty, farCard.difficulty);
      expect(moved.stabilityDays, farCard.stabilityDays);
      expect(moved.lastReviewedDay, farCard.lastReviewedDay);
      expect(moved.reps, farCard.reps);
      expect(moved.lapses, farCard.lapses);
      expect(moved.isWeak, farCard.isWeak);
      expect(moved.signoffs, farCard.signoffs);
      expect(moved.hasManualLock, farCard.hasManualLock);
      expect(moved.isPrayerCritical, farCard.isPrayerCritical);
      expect(moved.isEnabled, farCard.isEnabled);
    });

    test('two cards with equal fields are value-equal', () {
      final twin = Card(
        profileId: const ProfileId('profile-1'),
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
      expect(twin, farCard);
      expect(twin.hashCode, farCard.hashCode);
    });
  });
}
