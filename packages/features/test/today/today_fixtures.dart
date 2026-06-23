// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Shared Today test fixtures: due cards whose stability lands them
// deterministically in each phase (phaseOf: S < 9 → New, < 60 → Near, else Far).

import 'package:engine/engine.dart' show CalendarDate, Card, ReviewTrack;
import 'package:models/models.dart' show ProfileId;

/// The fixed test profile.
const ProfileId kTestProfile = ProfileId('p1');

/// The fixed "today" the suites inject.
final CalendarDate kToday = CalendarDate.ymd(2026, 6, 19);

/// A due Far (manzil) card: large stability (`S ≥ 60`).
Card dueFar(int pageId, {bool isWeak = false, bool isPrayerCritical = false}) =>
    Card(
      profileId: kTestProfile,
      pageId: pageId,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 200,
      lastReviewedDay: CalendarDate.ymd(2026, 4, 1),
      dueAt: kToday,
      isWeak: isWeak,
      isPrayerCritical: isPrayerCritical,
    );

/// A due Near (sabqi) card: mid stability (`9 ≤ S < 60`).
Card dueNear(int pageId) => Card(
      profileId: kTestProfile,
      pageId: pageId,
      track: ReviewTrack.near,
      difficulty: 5,
      stabilityDays: 20,
      lastReviewedDay: CalendarDate.ymd(2026, 6, 5),
      dueAt: kToday,
    );

/// A due New (sabaq) card: small stability (`S < 9`).
Card dueNew(int pageId) => Card(
      profileId: kTestProfile,
      pageId: pageId,
      track: ReviewTrack.newPage,
      difficulty: 5,
      stabilityDays: 3,
      lastReviewedDay: CalendarDate.ymd(2026, 6, 18),
      dueAt: kToday,
    );
