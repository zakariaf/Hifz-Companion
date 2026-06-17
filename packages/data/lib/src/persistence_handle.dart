// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'repositories/cold_start_repository.dart';
import 'repositories/repositories.dart';
import 'repositories/review_repository.dart';

/// The single injectable seam to the local store — the framework-free interface
/// the rest of the app reaches persistence through (01 §2, §4; 05 §1).
///
/// It exposes the value-type repositories and nothing else: **no**
/// `package:drift`/`sqlite3` symbol crosses this surface, so the engine,
/// features, and quran layers never see a Drift type and the determinism
/// boundary holds. The live implementation wraps the Drift `HifzDatabase`
/// ([LivePersistenceHandle]); tests inject the in-memory double. It moves bytes
/// and returns values — it computes no schedule and renders no Quran text.
abstract interface class PersistenceHandle {
  /// The `card` repository.
  CardRepository get cards;

  /// The append-only `review_log` repository.
  ReviewLogRepository get reviewLog;

  /// The `profile` repository.
  ProfileRepository get profiles;

  /// The single write path for one review (one transaction, persist before
  /// republish).
  ReviewRepository get reviews;

  /// The cold-start provisioning write path (one all-or-nothing outer
  /// transaction).
  ColdStartRepository get coldStart;

  /// Closes the underlying store; resolves once it is durably released.
  Future<void> close();
}
