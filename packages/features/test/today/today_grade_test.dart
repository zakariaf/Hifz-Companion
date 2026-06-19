// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Tapping a grade on a Today row routes through the single write path: the
// ReviewRecorder reads the card, runs the engine, and commits one outcome —
// proven by faking the repositories behind the recorder.

import 'package:composition/composition.dart';
import 'package:data/data.dart' show CardRepository, ReviewRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart'
    show
        MihrabAppearance,
        ReviewRecorder,
        TodayScreen,
        mihrabThemeFor,
        reviewRecorderProvider,
        todayQueueProvider;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show ProfileId, ReviewOutcome;

import '../test_setup.dart';

class _StubCards implements CardRepository {
  _StubCards(this._card);
  final Card _card;

  @override
  Future<Card?> byId(ProfileId profile, int pageId) async =>
      pageId == _card.pageId ? _card : null;
  @override
  Future<List<Card>> forProfile(ProfileId profile) async => [_card];
  @override
  Stream<List<Card>> watchForProfile(ProfileId profile) =>
      Stream.value([_card]);
}

class _RecordingReviews implements ReviewRepository {
  ReviewOutcome? committed;

  @override
  Future<void> commitReview(ReviewOutcome outcome) async => committed = outcome;
}

void main() {
  useOfflineTestPolicy();

  final engine = SchedulingEngine(EngineConfig.defaults());
  final card = Card(
    profileId: const ProfileId('p1'),
    pageId: 42,
    track: ReviewTrack.far,
    difficulty: 5,
    stabilityDays: 30,
    lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
    dueAt: CalendarDate.ymd(2026, 6, 19),
  );

  testWidgets('tapping a grade commits one review through the write path',
      (t) async {
    final reviews = _RecordingReviews();
    final recorder = ReviewRecorder(
      cards: _StubCards(card),
      reviews: reviews,
      engine: engine,
      newId: () => 'log1',
    );

    await t.pumpWidget(
      ProviderScope(
        overrides: [
          todayQueueProvider.overrideWith((ref) => Stream.value([card])),
          reviewRecorderProvider.overrideWithValue(recorder),
          initialActiveProfileProvider.overrideWithValue(const ProfileId('p1')),
          todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 19)),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: hifzLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: mihrabThemeFor(MihrabAppearance.light),
          home: const Scaffold(body: TodayScreen()),
        ),
      ),
    );
    await t.pumpAndSettle();

    await t.tap(find.byKey(const ValueKey('grade.good')));
    await t.pumpAndSettle();

    expect(reviews.committed, isNotNull);
    expect(reviews.committed!.logRow.grade, ReviewGrade.good);
    expect(reviews.committed!.cardUpdate.pageId, 42);
  });
}
