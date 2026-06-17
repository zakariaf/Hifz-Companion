// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// A placeholder data-transfer object proving the `data` barrel resolves and the
/// downward engine/profiles edges link. The real DTOs are authored in E03.
@immutable
class PlaceholderRecord {
  /// Creates a placeholder record.
  const PlaceholderRecord();
}

/// The public repository surface — the single write path. The real
/// CardRepository / ReviewRepository (transactional, persist-before-republish,
/// over an append-only review_log) are authored in E03; the raw DAOs never
/// cross this boundary.
abstract interface class PlaceholderRepository {
  /// Returns the current placeholder record.
  PlaceholderRecord current();
}
