// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart';
import 'package:data/data.dart' show PrayerCriticalRepository;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ProfileId;

/// The command behind the page-detail "prayer-critical" toggle (E21-T08) — a user
/// preference that raises a page's retention floor (PRD §7.2/§7.5). It reads the
/// active profile and writes the flag through the single write path; a no-op when
/// no profile is active. Holds no state, reads no clock, opens no socket, and
/// issues no fiqh ruling.
class PrayerCriticalController {
  /// Creates the controller over the toggle write path, reading the active
  /// profile id at write time.
  PrayerCriticalController({
    required PrayerCriticalRepository repository,
    required ProfileId? Function() readActiveProfileId,
  })  : _repository = repository,
        _readActiveProfileId = readActiveProfileId;

  final PrayerCriticalRepository _repository;
  final ProfileId? Function() _readActiveProfileId;

  /// Sets whether [pageId] is prayer-critical for the active profile.
  Future<void> setPrayerCritical(int pageId, {required bool value}) async {
    final id = _readActiveProfileId();
    if (id == null) return;
    await _repository.setPrayerCritical(id, pageId, value: value);
  }
}

/// The prayer-critical toggle command, wired from the composition seams. App-scope
/// (no `autoDispose`): it holds no per-screen state.
final prayerCriticalControllerProvider =
    Provider<PrayerCriticalController>((ref) {
  return PrayerCriticalController(
    repository: ref.watch(persistenceProvider).prayerCritical,
    readActiveProfileId: () => ref.read(activeProfileProvider),
  );
});
