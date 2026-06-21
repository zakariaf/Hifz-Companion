// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T09 sync-guard (NOT the A9 pass — A9 is a human, on-device, not-automatable
// gate). This only keeps the recorded procedure from rotting: its journey ids
// must match the integration_test journey spine, and every announcement /
// control label it tells the operator to listen for must resolve to non-empty
// text in all three locales — so no one is asked to listen for text that does
// not exist localized.

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

const _procedurePaths = [
  'docs/engineering/manual-a9-screenreader-procedure.md',
  '../../docs/engineering/manual-a9-screenreader-procedure.md',
];

// The canonical four-journey spine (engineering 11 §6 J1–J4).
const _canonicalJourneyIds = {
  'j1ColdStart',
  'j2FirstDay',
  'j3Review',
  'j4Catchup',
};

String _readProcedure() {
  for (final path in _procedurePaths) {
    final file = File(path);
    if (file.existsSync()) return file.readAsStringSync();
  }
  throw StateError(
    'manual-a9 procedure not found from ${Directory.current.path}',
  );
}

void main() {
  useOfflineTestPolicy();

  test('procedure journey ids match the integration_test journey spine', () {
    final text = _readProcedure();
    final ids = RegExp('journey-id:\\s*(\\w+)')
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toSet();
    expect(
      ids,
      _canonicalJourneyIds,
      reason: 'the recorded A9 journeys must mirror J1–J4 exactly',
    );
  });

  test('every announcement + named control resolves non-empty in fa/ckb/ar',
      () async {
    for (final locale in const [Locale('fa'), Locale('ckb'), Locale('ar')]) {
      final l10n = await AppLocalizations.delegate.load(locale);
      // Announcements the operator is told to listen for.
      final strings = <String>[
        l10n.a11yAnnounceCatchUpReady,
        l10n.a11yAnnouncePageGraded,
        l10n.a11yAnnounceSignOffRecorded,
        // Named controls the J1–J4 steps reference.
        l10n.gradeAgain,
        l10n.gradeHard,
        l10n.gradeGood,
        l10n.gradeEasy,
        l10n.trackNewLabel,
        l10n.trackNearLabel,
        l10n.trackFarLabel,
        l10n.stateSignedOff,
        l10n.stateWeak,
      ];
      for (final s in strings) {
        expect(
          s.trim(),
          isNotEmpty,
          reason: 'a procedure-named string is empty in ${locale.languageCode}',
        );
      }
    }
  });
}
