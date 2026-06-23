// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The discrimination-drill state machine (E14-T08): whole-group, back-to-back,
// hidden → reveal → anchor, no spacing. Provider test over a faked group read
// model (never the Notifier); no pump, runs in milliseconds.

import 'package:features/features.dart'
    show
        BranchPhase,
        DiscriminationDrillState,
        discriminationDrillControllerProvider,
        mutashabihGroupProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import '../test_setup.dart';

MutashabihGroupView _group(int memberCount) => MutashabihGroupView(
      groupId: 'g1',
      type: MutashabihType.nearIdentical,
      noteKey: null,
      members: [
        for (var i = 0; i < memberCount; i++)
          MutashabihMemberView(
            ayahId: '2:${i + 1}',
            pageNumber: i + 1,
            distinguishingWordIndices: const [],
          ),
      ],
    );

ProviderContainer _containerFor(MutashabihGroupView group) {
  final container = ProviderContainer(
    overrides: [
      mutashabihGroupProvider('g1').overrideWith((ref) async => group),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<DiscriminationDrillState> _build(ProviderContainer c) {
  c.listen(discriminationDrillControllerProvider('g1'), (_, __) {});
  return c.read(discriminationDrillControllerProvider('g1').future);
}

void main() {
  useOfflineTestPolicy();

  test('build orders the whole group, starting hidden at index 0', () async {
    final c = _containerFor(_group(3));
    final state = await _build(c);
    expect(state.members.map((m) => m.ayahId), ['2:1', '2:2', '2:3']);
    expect(state.activeIndex, 0);
    expect(state.phases, everyElement(BranchPhase.hidden));
    expect(state.isComplete, isFalse);
  });

  test('reveal then showAnchor advance only the active branch', () async {
    final c = _containerFor(_group(3));
    await _build(c);
    final ctrl = c.read(discriminationDrillControllerProvider('g1').notifier);

    ctrl.reveal();
    var s = c.read(discriminationDrillControllerProvider('g1')).requireValue;
    expect(s.phases[0], BranchPhase.revealed);
    expect(s.phases[1], BranchPhase.hidden); // only the active branch moved

    ctrl.showAnchor();
    s = c.read(discriminationDrillControllerProvider('g1')).requireValue;
    expect(s.phases[0], BranchPhase.anchored);
  });

  test('next advances back-to-back: anchored → next member hidden, no spacing',
      () async {
    final c = _containerFor(_group(3));
    await _build(c);
    final ctrl = c.read(discriminationDrillControllerProvider('g1').notifier);

    ctrl.reveal();
    ctrl.showAnchor();
    ctrl.next();
    final s = c.read(discriminationDrillControllerProvider('g1')).requireValue;
    // Member 0 stays anchored (juxtaposed history), member 1 is hidden now —
    // a direct transition, with no interstitial/spacing state in between.
    expect(s.activeIndex, 1);
    expect(s.phases[0], BranchPhase.anchored);
    expect(s.phases[1], BranchPhase.hidden);
    expect(s.isComplete, isFalse);
  });

  test('the whole group is reachable in order; complete only after the LAST',
      () async {
    final c = _containerFor(_group(3));
    await _build(c);
    final ctrl = c.read(discriminationDrillControllerProvider('g1').notifier);

    for (var i = 0; i < 3; i++) {
      final before =
          c.read(discriminationDrillControllerProvider('g1')).requireValue;
      expect(before.activeIndex, i);
      expect(before.isComplete, isFalse); // never complete before the last next
      ctrl.reveal();
      ctrl.showAnchor();
      ctrl.next();
    }
    final s = c.read(discriminationDrillControllerProvider('g1')).requireValue;
    expect(s.isComplete, isTrue); // only after the last member
  });

  test('transitions are phase-ordered: showAnchor/next no-op out of order',
      () async {
    final c = _containerFor(_group(2));
    await _build(c);
    final ctrl = c.read(discriminationDrillControllerProvider('g1').notifier);

    // No reveal yet → showAnchor and next are no-ops (page never shown early).
    ctrl.showAnchor();
    ctrl.next();
    final s = c.read(discriminationDrillControllerProvider('g1')).requireValue;
    expect(s.phases[0], BranchPhase.hidden);
    expect(s.activeIndex, 0);
  });

  test('a missing group surfaces an error (calm retry), not an exception',
      () async {
    final container = ProviderContainer(
      overrides: [
        mutashabihGroupProvider('g1').overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);
    container.listen(discriminationDrillControllerProvider('g1'), (_, __) {});
    await expectLater(
      container.read(discriminationDrillControllerProvider('g1').future),
      throwsA(isA<StateError>()),
    );
  });
}
