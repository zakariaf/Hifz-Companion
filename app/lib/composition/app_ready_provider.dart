// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show kAppMetaKeyTextChecksumVerifiedAt;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_profile_provider.dart';
import 'persistence_provider.dart';

/// Whether the bundled core muṣḥaf has been verified and its reference DB built
/// — read from the `app_meta` verified-text stamp through the persistence
/// boundary, never a socket (engineering 09 §2; PRD C-048).
///
/// `false` until a successful first-launch core install writes the stamp (the
/// installer + its `CoreVerifiedStamp` are wired in E11). This boundary only
/// *reports* readiness — it downloads nothing, verifies no bytes, renders no
/// glyph.
final coreVerifiedProvider = FutureProvider<bool>((ref) async {
  final handle = ref.watch(persistenceProvider);
  final stamp = await handle.meta.read(kAppMetaKeyTextChecksumVerifiedAt);
  return stamp != null;
});

/// The structural precondition for rendering Quran text: the core pack is
/// verified **and** a profile exists (PRD R1; engineering 01 §6).
///
/// The redirect guard (E07-T03) refuses any Quran-rendering route until this is
/// `true`. The shell itself (Today + the inert placeholder tabs, which render no
/// glyphs) is reachable as soon as a profile exists — gated on
/// [activeProfileProvider], not on the verified half — so a returning ḥāfiẓ
/// lands on Today after seeding even before E11 wires the core install. Until
/// [coreVerifiedProvider] resolves it reads `false` (fail-closed).
final appReadyProvider = Provider<bool>((ref) {
  final hasProfile = ref.watch(activeProfileProvider) != null;
  final verified = ref.watch(coreVerifiedProvider).asData?.value ?? false;
  return hasProfile && verified;
});
