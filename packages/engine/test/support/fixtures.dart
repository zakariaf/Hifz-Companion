// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Shared, clock-free test fixtures for the engine suites: a `today`/`SerialDay`
// literal builder and a `Card` builder with sane defaults. Pure `package:engine`
// + a single `models` symbol for the typed profile id.

import 'package:engine/engine.dart';
import 'package:models/models.dart' show ProfileId;

/// A constructed `CalendarDate` (the spec's `SerialDay`) literal — never a clock.
CalendarDate day(int epochDay) => CalendarDate.fromEpochDay(epochDay);

/// Builds a memorized [Card] with overridable fields and sane defaults. An
/// `unmemorized` track defaults `dueAt` to null; any other track gets a concrete
/// `dueAt` so the memorized-needs-a-ceiling invariant holds.
Card testCard({
  int pageId = 1,
  ReviewTrack track = ReviewTrack.far,
  double difficulty = 5,
  double stabilityDays = 90, // clearly Far, off the kFarMinS boundary
  CalendarDate? lastReviewedDay,
  CalendarDate? dueAt,
  int reps = 0,
  int lapses = 0,
  bool isWeak = false,
  int signoffs = 0,
  bool hasManualLock = false,
  bool isPrayerCritical = false,
}) =>
    Card(
      profileId: const ProfileId('p'),
      pageId: pageId,
      track: track,
      difficulty: difficulty,
      stabilityDays: stabilityDays,
      lastReviewedDay: lastReviewedDay,
      dueAt: dueAt ?? (track == ReviewTrack.unmemorized ? null : day(0)),
      reps: reps,
      lapses: lapses,
      isWeak: isWeak,
      signoffs: signoffs,
      hasManualLock: hasManualLock,
      isPrayerCritical: isPrayerCritical,
    );
