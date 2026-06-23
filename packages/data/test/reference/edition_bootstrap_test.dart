// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// registerBundledEdition writes ONLY the bundled edition's metadata row so a
// profile's mushaf_id FK resolves in a debug build without the asset pack; it
// writes no page/line/surah/ayah, and is idempotent. The load-bearing proof is
// that a profile referencing the registered edition now COMMITS (the exact FK
// that fails on an empty reference) — via the public ColdStartRepository.

import 'package:data/data.dart' show PersistenceHandle, registerBundledEdition;
import 'package:data/testing.dart' show inMemoryPersistenceHandle;
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart'
    show
        CardSeed,
        CycleConfig,
        JumpTarget,
        JumpUnit,
        Profile,
        ProfileId,
        ProfileLocale,
        ProfileRole,
        kKfgqpcHafsMadaniV2Edition;

import '../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  late PersistenceHandle handle;
  setUp(() => handle = inMemoryPersistenceHandle());
  tearDown(() => handle.close());

  final edition = kKfgqpcHafsMadaniV2Edition;
  const profileId = ProfileId('p1');

  Profile profileOnEdition() => Profile(
        profileId: profileId,
        displayName: 'self',
        role: ProfileRole.self,
        locale: ProfileLocale.fa,
        mushafId: edition.mushafId,
        createdAtInstant: DateTime.utc(2026, 6, 17),
      );

  const cycleConfig = CycleConfig(
    profileId: profileId,
    cycleType: '7_manzil',
    nearWindowJuz: 3,
    farTargetPerDay: 4,
    cycleCeilingDays: 7,
    dailyBudgetMinutes: 45,
    termLabelSet: 'classical',
  );

  test('a profile referencing the registered edition commits (FK resolves)',
      () async {
    // Without the metadata row the cold-start commit FK-fails (the reported bug);
    // after registering it, the same commit (0 cards, empty reference) succeeds.
    await registerBundledEdition(handle, edition);
    await registerBundledEdition(handle, edition); // idempotent — no duplicate

    await handle.coldStart
        .seedColdStart(profileOnEdition(), cycleConfig, const <CardSeed>[]);

    final profiles = await handle.profiles.all();
    expect(profiles.map((p) => p.mushafId), contains(edition.mushafId));
  });

  test('it writes only the edition metadata — no faked page/sūrah structure',
      () async {
    await registerBundledEdition(handle, edition);

    expect(await handle.reference.linesForPage(1), isEmpty);
    // A structural jump still resolves to nothing — nothing is faked on the page.
    expect(
      await handle.reference
          .firstPageOf(const JumpTarget(unit: JumpUnit.juz, index: 1)),
      isNull,
    );
    // A page jump resolves to itself (identity) — page navigation still works.
    expect(
      await handle.reference
          .firstPageOf(const JumpTarget(unit: JumpUnit.page, index: 5)),
      5,
    );
  });
}
