// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'reference_enums.dart';

/// One scholar-reviewed mutashābihāt group — a set of near-identical passages
/// (05 §2 `mutashabih_group`; PRD R4).
///
/// Read-only reference data, scoped to objective near-identical wording only.
/// [noteKey] is a **localizable resource key**, never inline commentary — the
/// note text lives in `l10n` and carries no tafsīr/ruling.
@immutable
class MutashabihGroup {
  /// The group's stable id.
  final String groupId;

  /// The kind of similarity binding the group.
  final MutashabihType type;

  /// An optional localizable note resource key (a key into `l10n`), or null.
  final String? noteKey;

  /// Creates a mutashābihāt group descriptor.
  const MutashabihGroup({
    required this.groupId,
    required this.type,
    this.noteKey,
  });

  /// Returns a copy with the given fields replaced; omitted fields preserved.
  MutashabihGroup copyWith({
    String? groupId,
    MutashabihType? type,
    String? noteKey,
  }) {
    return MutashabihGroup(
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      noteKey: noteKey ?? this.noteKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MutashabihGroup &&
      other.groupId == groupId &&
      other.type == type &&
      other.noteKey == noteKey;

  @override
  int get hashCode => Object.hash(groupId, type, noteKey);
}
