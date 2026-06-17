// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'enums.dart';
import 'ids.dart';

/// One local profile — self, a student, or a child — on this device (05 §2
/// `profile`; PRD §10.2, §15).
///
/// Device-local only: there is no account, no server identity, and nothing
/// leaves the device. [displayName] is the **only** "PII" the app holds — a
/// user-typed name (PRD §17). Sharing between profiles is by file
/// export/import, never a network sync.
@immutable
class Profile {
  /// This profile's UUID primary key (`profile.profile_id`).
  final ProfileId profileId;

  /// The user-typed display name — the only PII the app stores (PRD §17).
  final String displayName;

  /// Whether this is the device owner, a tracked student, or a child profile.
  final ProfileRole role;

  /// The profile's UI/content locale (`ar`/`fa`/`ckb`).
  final ProfileLocale locale;

  /// The selected muṣḥaf descriptor's id (FK into the read-only `mushaf`
  /// table; the riwāyah is named there, no cascade — the muṣḥaf is immutable).
  final String mushafId;

  /// When the profile was created, stored **UTC** (a true instant).
  final DateTime createdAtInstant;

  /// The decoded, schema-shaped `settings_json` payload, or null.
  ///
  /// Small, decode-validated preference data only — **never** health roll-ups
  /// or Quran facts (05 §2).
  final Map<String, Object?>? settings;

  /// Creates a local profile.
  const Profile({
    required this.profileId,
    required this.displayName,
    required this.role,
    required this.locale,
    required this.mushafId,
    required this.createdAtInstant,
    this.settings,
  });

  /// Returns a copy with the given fields replaced; every omitted field is
  /// preserved unchanged.
  Profile copyWith({
    ProfileId? profileId,
    String? displayName,
    ProfileRole? role,
    ProfileLocale? locale,
    String? mushafId,
    DateTime? createdAtInstant,
    Map<String, Object?>? settings,
  }) {
    return Profile(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      locale: locale ?? this.locale,
      mushafId: mushafId ?? this.mushafId,
      createdAtInstant: createdAtInstant ?? this.createdAtInstant,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.profileId == profileId &&
      other.displayName == displayName &&
      other.role == role &&
      other.locale == locale &&
      other.mushafId == mushafId &&
      other.createdAtInstant == createdAtInstant &&
      _mapEquals(other.settings, settings);

  @override
  int get hashCode {
    final map = settings;
    return Object.hash(
      profileId,
      displayName,
      role,
      locale,
      mushafId,
      createdAtInstant,
      map == null
          ? null
          : Object.hashAllUnordered(
              map.entries.map((e) => Object.hash(e.key, e.value)),
            ),
    );
  }
}

/// Shallow value equality for the nullable `settings` maps (no
/// `package:collection` dependency at Layer 0; settings is small, flat data).
bool _mapEquals(Map<String, Object?>? a, Map<String, Object?>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
