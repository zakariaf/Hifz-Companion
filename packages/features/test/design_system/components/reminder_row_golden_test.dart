// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T09 — the reminder row across fa/ckb/ar × the four appearances + 200%
// reflow: off (the off-by-default artifact — switch off, no time picker), on, and
// on+catch-up-note. Linux lane only.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

const _callbacks = ReminderRowCallbacks(
  onEnabledChanged: _ignoreBool,
  onTimeChanged: _ignoreTime,
  onCatchUpNoteChanged: _ignoreBool,
);

void _ignoreBool(bool _) {}
void _ignoreTime(TimeOfDay _) {}

ComponentSpecimen _spec(String name, ReminderRowState state) =>
    ComponentSpecimen(
      name: name,
      build: (context) => ReminderRow(state: state, callbacks: _callbacks),
    );

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'reminder_row',
      specimens: [
        _spec('off', const ReminderRowState()),
        _spec('on', const ReminderRowState(enabled: true)),
        _spec(
          'on_catch_up',
          const ReminderRowState(enabled: true, catchUpNote: true),
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('reminder row across locale × appearance', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
