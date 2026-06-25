// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E16-T10: the teacher / halaqa loop. Switching the active profile to a student
// (T09) before signing off through E12's recite teacher toggle attributes the
// review to THAT student's append-only review_log — there is no new sign-off
// path and no remote dashboard. Each write lands in the switched student's own
// log, device-local. Faked card + review paths; offline guard (no socket).

import 'package:composition/composition.dart'
    show
        activeProfileProvider,
        cardRepositoryProvider,
        initialActiveProfileProvider,
        todayProvider;
import 'package:data/data.dart' show CardRepository;
import 'package:engine/engine.dart';
import 'package:features/features.dart'
    show ReviewRecorder, reciteControllerProvider, reviewRecorderProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../recite/recite_test_harness.dart' show RecordingReviews;
import '../test_setup.dart';

/// A card repo whose returned card's `profileId` matches the requested profile,
/// so a sign-off's review_log row is attributed to whoever is active.
class _PerProfileCards implements CardRepository {
  Card _card(ProfileId profile, int pageId) => Card(
        profileId: profile,
        pageId: pageId,
        track: ReviewTrack.far,
        difficulty: 5,
        stabilityDays: 30,
        lastReviewedDay: CalendarDate.ymd(2026, 5, 1),
        dueAt: CalendarDate.ymd(2026, 6, 19),
        reps: 4,
      );

  @override
  Future<Card?> byId(ProfileId profile, int pageId) async =>
      _card(profile, pageId);
  @override
  Future<List<Card>> forProfile(ProfileId profile) async =>
      [_card(profile, 42)];
  @override
  Stream<List<Card>> watchForProfile(ProfileId profile) =>
      Stream.value([_card(profile, 42)]);
}

void main() {
  useOfflineTestPolicy();

  test('a teacher sign-off lands in the switched student review_log', () async {
    final reviews = RecordingReviews();
    final cards = _PerProfileCards();
    final container = ProviderContainer(
      overrides: [
        initialActiveProfileProvider
            .overrideWithValue(const ProfileId('student-a')),
        todayProvider.overrideWithValue(CalendarDate.ymd(2026, 6, 19)),
        cardRepositoryProvider.overrideWithValue(cards),
        reviewRecorderProvider.overrideWithValue(
          ReviewRecorder(
            cards: cards,
            reviews: reviews,
            engine: SchedulingEngine(EngineConfig.defaults()),
            newId: () => 'log',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Keep the page-42 recite controller alive across the profile switch.
    final sub = container.listen(reciteControllerProvider(42), (_, __) {});
    addTearDown(sub.close);

    // Student A is active → reveal → teacher present → sign off.
    final a = container.read(reciteControllerProvider(42).notifier);
    a.revealNextLine();
    a.setTeacherPresent(present: true);
    await a.submitGrade(ReviewGrade.good);

    // Switch to Student B → reveal → teacher present → sign off.
    container
        .read(activeProfileProvider.notifier)
        .select(const ProfileId('student-b'));
    final b = container.read(reciteControllerProvider(42).notifier);
    b.revealNextLine();
    b.setTeacherPresent(present: true);
    await b.submitGrade(ReviewGrade.good);

    // Two teacher-sourced sign-offs, each attributed to its own student.
    expect(reviews.outcomes.length, 2);
    expect(reviews.outcomes[0].logRow.profileId, const ProfileId('student-a'));
    expect(reviews.outcomes[0].logRow.source, GradeSource.teacher);
    expect(reviews.outcomes[1].logRow.profileId, const ProfileId('student-b'));
    expect(reviews.outcomes[1].logRow.source, GradeSource.teacher);
  });
}
