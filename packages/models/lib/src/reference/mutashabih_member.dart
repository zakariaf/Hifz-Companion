// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// One āyah's membership in a mutashābihāt group (05 §2 `mutashabih_member`;
/// PRD R4).
///
/// Read-only reference data. [distinguishingWordIndexJson] carries small
/// structural indices of the word(s) that distinguish this member from its
/// siblings — drawn as a coordinate overlay on the glyph layer, never
/// reconstructed text (R1).
@immutable
class MutashabihMember {
  /// The group this member belongs to (FK into `mutashabih_group`).
  final String groupId;

  /// The member āyah's `'s:a'` id (FK into `ayah`).
  final String ayahId;

  /// The raw `distinguishing_word_index_json` payload — structural word indices
  /// only, or null.
  final String? distinguishingWordIndexJson;

  /// Creates a mutashābihāt member descriptor.
  const MutashabihMember({
    required this.groupId,
    required this.ayahId,
    this.distinguishingWordIndexJson,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  MutashabihMember copyWith({
    String? groupId,
    String? ayahId,
    String? distinguishingWordIndexJson,
  }) {
    return MutashabihMember(
      groupId: groupId ?? this.groupId,
      ayahId: ayahId ?? this.ayahId,
      distinguishingWordIndexJson:
          distinguishingWordIndexJson ?? this.distinguishingWordIndexJson,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MutashabihMember &&
      other.groupId == groupId &&
      other.ayahId == ayahId &&
      other.distinguishingWordIndexJson == distinguishingWordIndexJson;

  @override
  int get hashCode => Object.hash(groupId, ayahId, distinguishingWordIndexJson);
}
