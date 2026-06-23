// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Shared recite test harness: a fixed card, a stub card repository, a recording
// review repository, and override builders so the recite flow runs with no DB,
// no network, and an injected clock.

import 'package:composition/composition.dart';
import 'package:data/data.dart' show CardRepository, ReviewRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart' show ReviewRecorder, reviewRecorderProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ProfileId, ReviewOutcome;

/// The fixed test profile + page.
const ProfileId kProfile = ProfileId('p1');

/// The fixed "today" injected into the recite flow.
final CalendarDate kReciteToday = CalendarDate.ymd(2026, 6, 19);

/// A due Far card for the recited page.
Card reciteCard({int pageId = 42}) => Card(
      profileId: kProfile,
      pageId: pageId,
      track: ReviewTrack.far,
      difficulty: 5,
      stabilityDays: 30,
      lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
      dueAt: CalendarDate.ymd(2026, 6, 19),
      reps: 4,
    );

/// A stub card repository returning [card] for its page id.
class StubCards implements CardRepository {
  StubCards(this.card);

  /// The single card this repository serves.
  final Card card;

  @override
  Future<Card?> byId(ProfileId profile, int pageId) async =>
      pageId == card.pageId ? card : null;
  @override
  Future<List<Card>> forProfile(ProfileId profile) async => [card];
  @override
  Stream<List<Card>> watchForProfile(ProfileId profile) => Stream.value([card]);
}

/// A review repository that records every committed outcome.
class RecordingReviews implements ReviewRepository {
  /// Every committed outcome, in order.
  final List<ReviewOutcome> outcomes = <ReviewOutcome>[];

  @override
  Future<void> commitReview(ReviewOutcome outcome) async =>
      outcomes.add(outcome);
}

/// A `ProviderContainer` wiring a recording recorder + stub card repo + injected
/// clock/profile, for driving the recite controller in tests (wrap it in an
/// `UncontrolledProviderScope` for widget tests).
ProviderContainer reciteContainer({
  required StubCards cards,
  required RecordingReviews reviews,
}) =>
    ProviderContainer(
      overrides: [
        initialActiveProfileProvider.overrideWithValue(kProfile),
        todayProvider.overrideWithValue(kReciteToday),
        cardRepositoryProvider.overrideWithValue(cards),
        reviewRecorderProvider.overrideWithValue(
          ReviewRecorder(
            cards: cards,
            reviews: reviews,
            engine: SchedulingEngine(EngineConfig.defaults()),
            newId: () => 'recite-log',
          ),
        ),
      ],
    );
