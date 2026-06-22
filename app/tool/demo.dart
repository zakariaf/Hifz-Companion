// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// DEV-ONLY demo entrypoint — NOT shipped (lives in tool/, like gallery.dart).
//
// It runs the real E07 shell (HifzApp) over an in-memory store pre-seeded with a
// small reference fixture, so the whole walking-skeleton spine is explorable on
// a simulator BEFORE E11 loads the real muṣḥaf data: a fresh device → cold-start
// onboarding (mark held juz, rate Solid/Shaky/Rusty) → Today fills with real
// Engine.buildToday-selected pages → grade one (Again/Hard/Good/Easy) and watch
// it reschedule out of today's list → the four inert placeholder tabs.
//
// Run from app/:  flutter run -t tool/demo.dart -d <device>
// Data is in-memory: a hot-restart resets it back to a fresh device.

import 'package:app/app.dart';
import 'package:composition/composition.dart';
import 'package:data/testing.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final handle = inMemoryPersistenceHandle();
  // Four pages per juz across all 30 juz (the real 604-page set is the E11
  // install) so any held juz seeds real page cards.
  await seedReferenceFixture(
    handle,
    pagesByJuz: {
      for (var juz = 1; juz <= 30; juz++)
        juz: [for (var i = 0; i < 4; i++) (juz - 1) * 4 + 1 + i],
    },
  );
  runApp(
    ProviderScope(
      overrides: [persistenceProvider.overrideWithValue(handle)],
      child: const HifzApp(),
    ),
  );
}
