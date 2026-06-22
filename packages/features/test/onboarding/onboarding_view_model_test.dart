// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The resume-safe onboarding capture controller (E11-T01): a pure in-memory
// capture surface. It reaches no repository/DAO (the container overrides no
// persistence, so any data write would throw the un-overridden placeholder),
// invents no (D, S), reads "today" only from the injected todayProvider, and
// never navigates. The cursor advances only behind its preconditions; back()
// never drops a captured value; the family key isolates one profile's capture
// from another's. The placement commit + persist-before-republish proof are
// E11-T09's (packages/data cold_start_repository_test.dart).

import 'dart:ui' show Locale;

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:features/features.dart'
    show
        CoreSetupPhase,
        OnboardingController,
        OnboardingState,
        OnboardingStep,
        onboardingControllerProvider;
import 'package:features/src/design_system/pickers/cycle_preset_picker.dart'
    show CyclePreset;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart' show ProfileId;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  final fixedToday = CalendarDate.ymd(2026, 6, 22);

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [todayProvider.overrideWithValue(fixedToday)],
    );
    addTearDown(container.dispose);
    return container;
  }

  // Short reads on the first-run (null-scoped) controller.
  OnboardingState read(ProviderContainer c) =>
      c.read(onboardingControllerProvider(null));
  OnboardingController ctrl(ProviderContainer c) =>
      c.read(onboardingControllerProvider(null).notifier);

  // Drives the cursor from welcomePrivacy down to [target], satisfying each
  // step's precondition along the way (no persistence touched).
  void advanceTo(ProviderContainer c, OnboardingStep target) {
    final k = ctrl(c)..next(); // welcomePrivacy → language
    k.setLocale(const Locale('ar'));
    if (target == OnboardingStep.language) return;
    k.next(); // language → riwayahConfirm
    k.confirmMushaf('kfgqpc_hafs_madani_v2');
    if (target == OnboardingStep.riwayahConfirm) return;
    k.next(); // riwayahConfirm → coreSetup
    if (target == OnboardingStep.coreSetup) return;
    k
      ..setCoreSetupPhase(CoreSetupPhase.ready)
      ..next(); // coreSetup → coverage
    if (target == OnboardingStep.coverage) return;
    k
      ..toggleJuz(1)
      ..toggleJuz(2)
      ..next(); // coverage → confidence
  }

  group('capture round-trips', () {
    test('a fresh controller starts empty at welcomePrivacy (clean restart)',
        () {
      final c = makeContainer();
      final s = read(c);
      expect(s.cursor, OnboardingStep.welcomePrivacy);
      expect(s.locale, isNull);
      expect(s.coverage, isEmpty);
      expect(s.confidence, isEmpty);
      expect(s.memorizedOn, isEmpty);
      expect(s.cyclePreset, isNull);
      expect(s.dailyBudgetMinutes, isNull);
    });

    test('capture commands round-trip exactly', () {
      final c = makeContainer();
      ctrl(c)
        ..setLocale(const Locale('fa'))
        ..confirmMushaf('kfgqpc_hafs_madani_v2')
        ..toggleJuz(3)
        ..toggleJuz(7)
        ..setJuzConfidence(3, JuzConfidence.solid)
        ..setJuzConfidence(7, JuzConfidence.rusty)
        ..setMemorizedOn(3, CalendarDate.ymd(2020, 1, 1))
        ..setCyclePreset(CyclePreset.oneJuzPerDay)
        ..setDailyBudget(20);
      final s = read(c);
      expect(s.locale, const Locale('fa'));
      expect(s.mushafEditionId, 'kfgqpc_hafs_madani_v2');
      expect(s.coverage, {3, 7});
      expect(s.confidence, {3: JuzConfidence.solid, 7: JuzConfidence.rusty});
      expect(s.memorizedOn[3], CalendarDate.ymd(2020, 1, 1));
      expect(s.cyclePreset, CyclePreset.oneJuzPerDay);
      expect(s.dailyBudgetMinutes, 20);
    });
  });

  group('cursor + guards', () {
    test('next() from language does not advance without a locale', () {
      final c = makeContainer();
      final k = ctrl(c)..next();
      expect(read(c).cursor, OnboardingStep.language);
      k.next(); // blocked: no locale
      expect(read(c).cursor, OnboardingStep.language);
      k
        ..setLocale(const Locale('ckb'))
        ..next();
      expect(read(c).cursor, OnboardingStep.riwayahConfirm);
    });

    test('coreSetup is fail-closed: next() blocks until phase == ready', () {
      final c = makeContainer();
      advanceTo(c, OnboardingStep.coreSetup);
      final k = ctrl(c)..next(); // blocked: not verified
      expect(read(c).cursor, OnboardingStep.coreSetup);
      k
        ..setCoreSetupPhase(CoreSetupPhase.ready)
        ..next();
      expect(read(c).cursor, OnboardingStep.coverage);
    });

    test('back() never drops a captured value', () {
      final c = makeContainer();
      advanceTo(c, OnboardingStep.confidence);
      final k = ctrl(c)
        ..setJuzConfidence(1, JuzConfidence.solid)
        ..setJuzConfidence(2, JuzConfidence.shaky);
      final ratedBefore = Map<int, JuzConfidence>.of(read(c).confidence);
      k.back(); // → coverage
      expect(read(c).cursor, OnboardingStep.coverage);
      k.next(); // → confidence again
      expect(read(c).confidence, ratedBefore);
    });
  });

  group('coverage absence semantics', () {
    test('un-toggling removes a juz (absence, never a 0/missing value)', () {
      final c = makeContainer();
      ctrl(c)
        ..toggleJuz(5)
        ..setJuzConfidence(5, JuzConfidence.shaky)
        ..setMemorizedOn(5, CalendarDate.ymd(2019, 5, 5))
        ..toggleJuz(5); // un-hold
      final s = read(c);
      expect(s.coverage, isEmpty);
      // Un-holding also drops the orphaned confidence + date — never a sentinel.
      expect(s.confidence.containsKey(5), isFalse);
      expect(s.memorizedOn.containsKey(5), isFalse);
    });

    test('toggling one juz does not disturb another', () {
      final c = makeContainer();
      ctrl(c)
        ..toggleJuz(1)
        ..toggleJuz(2)
        ..setJuzConfidence(1, JuzConfidence.solid)
        ..setJuzConfidence(2, JuzConfidence.rusty)
        ..toggleJuz(1); // un-hold juz 1 only
      final s = read(c);
      expect(s.coverage, {2});
      expect(s.confidence, {2: JuzConfidence.rusty});
    });

    test('an un-held juz cannot be rated or dated', () {
      final c = makeContainer();
      ctrl(c)
        ..setJuzConfidence(9, JuzConfidence.solid)
        ..setMemorizedOn(9, CalendarDate.ymd(2018, 1, 1));
      final s = read(c);
      expect(s.confidence, isEmpty);
      expect(s.memorizedOn, isEmpty);
    });
  });

  test('no data write is reachable: capture runs with no persistence override',
      () {
    // persistenceProvider/coldStartSeederProvider are not overridden here, so
    // they throw on first read. The capture commands complete without touching
    // them — proof the controller reaches no data write (E11-T09 owns the
    // single write path).
    final c = makeContainer();
    expect(
      () => ctrl(c)
        ..setLocale(const Locale('ar'))
        ..toggleJuz(1)
        ..setJuzConfidence(1, JuzConfidence.solid)
        ..setCyclePreset(CyclePreset.weeklyKhatm)
        ..setDailyBudget(30),
      returnsNormally,
    );
  });

  test('memorizedOn uses the injected today, never a wall clock', () {
    final c = makeContainer();
    final k = ctrl(c);
    expect(k.today, fixedToday);
    k
      ..toggleJuz(4)
      ..setMemorizedOn(4, k.today);
    expect(read(c).memorizedOn[4], fixedToday);
  });

  test('family isolation: two profile scopes hold independent captures', () {
    final c = makeContainer();
    const a = ProfileId('a');
    const b = ProfileId('b');
    c.read(onboardingControllerProvider(a).notifier).toggleJuz(1);
    c.read(onboardingControllerProvider(b).notifier).toggleJuz(2);
    expect(c.read(onboardingControllerProvider(a)).coverage, {1});
    expect(c.read(onboardingControllerProvider(b)).coverage, {2});
  });
}
