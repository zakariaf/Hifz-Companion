// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The reader's covenant (C-048; PRD §17/§19.3): it couples to NO microphone and
// NO audio/AI, and it is display-only — it imports no audio/ASR package and no
// single-write-path symbol, and assembling + interacting with the chrome writes
// nothing to persistence. (The resolution, overlay-gating, control, and a11y
// units are authored across E13-T04..T09; this consolidates the covenant.)

import 'dart:io';

import 'package:composition/composition.dart'
    show initialActiveProfileProvider, persistenceProvider;
import 'package:data/data.dart' show PersistenceHandle;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:features/features.dart'
    show
        MihrabAppearance,
        MushafChrome,
        mihrabThemeFor,
        mushafReaderStateProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show MushafEdition, ProfileId;

import '../test_setup.dart';

// The mushaf feature's source root (CWD-robust across the fast/full CI lanes).
Directory mushafLib() => [
      Directory('lib/src/mushaf'),
      Directory('packages/features/lib/src/mushaf'),
    ].firstWhere((d) => d.existsSync());

Iterable<String> importLines(Directory dir) sync* {
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    for (final line in entity.readAsLinesSync()) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('import ') || trimmed.startsWith('export ')) {
        yield '${entity.path}: $trimmed';
      }
    }
  }
}

MushafEdition fakeEdition() => MushafEdition(
      mushafId: 'kfgqpc_hafs_madani_v2',
      riwayah: 'Ḥafṣ ʿan ʿĀṣim',
      displayName: 'Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf',
      pageCount: 604,
      lineCount: 15,
      textSha256: '',
      layoutSha256: '',
      fontSha256: const <int, String>{},
    );

void main() {
  useOfflineTestPolicy();

  group('no microphone / no AI (C-048) — by construction', () {
    test('the reader imports no audio / ASR / AI / mic package', () {
      final banned = RegExp(
        r'audioplayers|just_audio|flutter_sound|mic_stream|record/'
        r'|speech_to_text|speech_recognition|tflite|ml_?kit|dart:ffi'
        r'|microphone|recogni[sz]er',
        caseSensitive: false,
      );
      final offenders =
          importLines(mushafLib()).where(banned.hasMatch).toList();
      expect(
        offenders,
        isEmpty,
        reason: 'reader couples to audio/AI: $offenders',
      );
    });
  });

  group('display-only (single write path) — by construction', () {
    test('the reader imports no single-write-path / engine-write symbol', () {
      // The reader reads `persistenceProvider` (reference reads only) but pulls
      // in NO write recorder, no engine, and no card-write repository.
      final banned = RegExp(
        r"review_recorder\.dart|ReviewRecorder|package:engine"
        r"|cardRepositoryProvider|commitReview",
      );
      final offenders =
          importLines(mushafLib()).where(banned.hasMatch).toList();
      expect(
        offenders,
        isEmpty,
        reason: 'reader reaches a write path: $offenders',
      );
    });

    testWidgets('assembling + interacting with the reader writes no card',
        (tester) async {
      final handle = inMemoryPersistenceHandle();
      addTearDown(handle.close);
      const profile = ProfileId('p1');
      final container = ProviderContainer(
        overrides: [
          persistenceProvider.overrideWithValue(handle),
          initialActiveProfileProvider.overrideWithValue(profile),
        ],
      );
      addTearDown(container.dispose);
      container.listen(mushafReaderStateProvider(1), (_, __) {});
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: hifzLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: mihrabThemeFor(MihrabAppearance.light),
            home: Scaffold(body: MushafChrome(edition: fakeEdition(), page: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drive some reader-state changes (display-only).
      container.read(mushafReaderStateProvider(1).notifier)
        ..setZoom(2.0)
        ..toggleWeakLineOverlay()
        ..setPage(42);
      await tester.pumpAndSettle();

      // The reader created/mutated no card — it wrote nothing to persistence.
      final PersistenceHandle h = handle;
      expect(await h.cards.forProfile(profile), isEmpty);
    });
  });
}
