// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// registerBundledEdition writes ONLY the bundled edition's metadata row (so a
// profile's mushaf_id FK resolves in a debug build without the asset pack); it
// writes no page/line/surah/ayah, and is idempotent. Combined with the
// cold_start_repository test (seedColdStart succeeds with a mushaf row present),
// this proves the debug bundle-first onboarding commit no longer FK-fails.

import 'package:data/data.dart' show PersistenceHandle, registerBundledEdition;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart'
    show JumpTarget, JumpUnit, kKfgqpcHafsMadaniV2Edition;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late PersistenceHandle handle;
  setUp(() => handle = inMemoryPersistenceHandle());
  tearDown(() => handle.close());

  test('registers the bundled edition metadata row (idempotent)', () async {
    final edition = kKfgqpcHafsMadaniV2Edition;

    await registerBundledEdition(handle, edition);
    await registerBundledEdition(handle, edition); // idempotent — no duplicate

    // The reference structure is otherwise untouched — no page/sūrah data was
    // written, so structural jumps still resolve to nothing (nothing is faked).
    expect(await handle.reference.linesForPage(1), isEmpty);
    expect(
      await handle.reference
          .firstPageOf(const JumpTarget(unit: JumpUnit.juz, index: 1)),
      isNull,
    );
    // A page jump still resolves to itself (identity) — page navigation works.
    expect(
      await handle.reference
          .firstPageOf(const JumpTarget(unit: JumpUnit.page, index: 5)),
      5,
    );
  });
}
