// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import '../reference/reference_enums.dart';

/// One member of a mutashābihāt group as the trainer reads it (E14-T06): the
/// member āyah's id, the muṣḥaf **page** it falls on (so the drill can render
/// it), and the validated structural distinguishing-word indices for the anchor
/// overlay (E14-T09).
///
/// Carries `ayah_id` + page + word **indices** only — **no** reconstructed verse
/// text, glyph codes, tafsīr, or translation (R1, R2).
@immutable
class MutashabihMemberView {
  /// Assembles one read-model member.
  const MutashabihMemberView({
    required this.ayahId,
    required this.pageNumber,
    required this.distinguishingWordIndices,
  });

  /// The member āyah's `'s:a'` id.
  final String ayahId;

  /// The muṣḥaf page (1–604) this member falls on — the recited/rendered unit.
  final int pageNumber;

  /// The structural word indices that distinguish this member from its siblings;
  /// empty if none recorded. Coordinate handles for the overlay, never text.
  final List<int> distinguishingWordIndices;

  @override
  bool operator ==(Object other) =>
      other is MutashabihMemberView &&
      other.ayahId == ayahId &&
      other.pageNumber == pageNumber &&
      _intListEquals(
        other.distinguishingWordIndices,
        distinguishingWordIndices,
      );

  @override
  int get hashCode => Object.hash(
        ayahId,
        pageNumber,
        Object.hashAll(distinguishingWordIndices),
      );
}

/// A whole mutashābihāt group as the trainer reads it (E14-T06): its objective
/// similarity [type], an optional localizable [noteKey] (a key into `l10n`, never
/// prose/tafsīr), and the **full** member set in stable order — group-not-node,
/// so a drill always has the contrasting pair, never a lone sibling.
@immutable
class MutashabihGroupView {
  /// Assembles one read-model group.
  const MutashabihGroupView({
    required this.groupId,
    required this.type,
    required this.noteKey,
    required this.members,
  });

  /// The group's stable id.
  final String groupId;

  /// The objective-wording similarity type (`identical | near_identical |
  /// structural`).
  final MutashabihType type;

  /// An optional `l10n` resource key for the group's note — never a gloss.
  final String? noteKey;

  /// The group's members, in stable order (≥ 2).
  final List<MutashabihMemberView> members;

  @override
  bool operator ==(Object other) =>
      other is MutashabihGroupView &&
      other.groupId == groupId &&
      other.type == type &&
      other.noteKey == noteKey &&
      _listEquals(other.members, members);

  @override
  int get hashCode =>
      Object.hash(groupId, type, noteKey, Object.hashAll(members));
}

bool _intListEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _listEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
