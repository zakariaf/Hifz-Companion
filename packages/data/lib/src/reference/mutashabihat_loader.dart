// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:models/models.dart' show MutashabihType;
import 'package:sqlite3/common.dart' show SqliteException;

import '../db/database.dart';

/// Parses and loads the scholar-reviewed mutashābihāt confusables dataset into
/// E03's **read-only** `mutashabih_group` / `mutashabih_member` reference tables
/// (PRD §9.1, §10.1; science 05 §3, §7).
///
/// The dataset is objective wording only — scoped to `identical |
/// near_identical | structural` (R4) — and carries **no** reconstructed verse
/// text, tafsīr, or translation: a member holds an `ayah_id` reference, a list
/// of structural word **indices** (the anchor-overlay handle, E14-T09 draws
/// from them; this layer only validates and stores them), and the group carries
/// a `type` and a localizable `note_key` resource key, never a gloss (R2).
///
/// Like [loadCoreReference], this is a one-shot install path called only from
/// the post-verification reference-DB build: the dataset file is one
/// checksum-pinned `manifest.files` entry verified by the assets layer **before**
/// the bytes reach this parser (doc 09 §3). This layer opens no socket and
/// re-implements no hashing. No DAO exposes a runtime write to either table —
/// the read-only invariant is the first outranking rule (05 §2).

/// A failure of the mutashābihāt dataset load, confined to the `/data`
/// boundary — typed, never swallowed, never carrying Quran text or glyph codes.
///
/// Every variant names the offending `groupId`/`ayahId` and the failed rule so a
/// bad dataset fails the build with an actionable message (and so the CI dataset
/// gate, E01, can assert on it).
sealed class MutashabihatDatasetException implements Exception {
  /// Const base constructor for the sealed hierarchy.
  const MutashabihatDatasetException();

  /// The bytes could not be decoded into the expected `{ "groups": [...] }`
  /// shape (a non-object root, a missing/!-list `groups`, a malformed row).
  const factory MutashabihatDatasetException.malformed(String detail) =
      _MalformedDataset;

  /// A `group.type` was not one of `identical | near_identical | structural`
  /// (a thematic/interpretive label is refused — objective wording only, R4).
  const factory MutashabihatDatasetException.unknownType({
    required String groupId,
    required String type,
  }) = _UnknownType;

  /// A group declared fewer than two members — a confusion is a property of a
  /// pair/group, never a lone node (science 05 §4).
  const factory MutashabihatDatasetException.singletonGroup(String groupId) =
      _SingletonGroup;

  /// The same `group_id` appeared twice in the dataset.
  const factory MutashabihatDatasetException.duplicateGroup(String groupId) =
      _DuplicateGroup;

  /// A `distinguishing_word_index_json` entry was not a list of non-negative
  /// integers (the overlay handles must be storable, in-range indices, never
  /// text). The upper bound (against the ayah's word count) lands with the
  /// bundled per-word geometry (E14-T09) — this layer enforces the integer/
  /// non-negative shape.
  const factory MutashabihatDatasetException.invalidWordIndex({
    required String groupId,
    required String ayahId,
    required String detail,
  }) = _InvalidWordIndex;

  /// A `member.ayah_id` did not resolve to a loaded `ayah` reference row (a
  /// dangling reference — the `ayah` FK is the storage backstop, this names it).
  const factory MutashabihatDatasetException.danglingAyah({
    required String groupId,
    required String ayahId,
  }) = _DanglingAyah;

  /// A row violated a table `CHECK`/FK — the whole load rolled back.
  const factory MutashabihatDatasetException.constraintViolation(
    String detail,
  ) = _ConstraintViolation;
}

class _MalformedDataset extends MutashabihatDatasetException {
  const _MalformedDataset(this.detail);
  final String detail;
  @override
  String toString() => 'MutashabihatDatasetException.malformed: $detail';
}

class _UnknownType extends MutashabihatDatasetException {
  const _UnknownType({required this.groupId, required this.type});
  final String groupId;
  final String type;
  @override
  String toString() => 'MutashabihatDatasetException.unknownType: group '
      '"$groupId" has non-conforming type "$type" (expected identical | '
      'near_identical | structural).';
}

class _SingletonGroup extends MutashabihatDatasetException {
  const _SingletonGroup(this.groupId);
  final String groupId;
  @override
  String toString() => 'MutashabihatDatasetException.singletonGroup: group '
      '"$groupId" has fewer than two members (a confusion is a pair).';
}

class _DuplicateGroup extends MutashabihatDatasetException {
  const _DuplicateGroup(this.groupId);
  final String groupId;
  @override
  String toString() =>
      'MutashabihatDatasetException.duplicateGroup: group "$groupId" '
      'is declared more than once.';
}

class _InvalidWordIndex extends MutashabihatDatasetException {
  const _InvalidWordIndex({
    required this.groupId,
    required this.ayahId,
    required this.detail,
  });
  final String groupId;
  final String ayahId;
  final String detail;
  @override
  String toString() =>
      'MutashabihatDatasetException.invalidWordIndex: group "$groupId", '
      'ayah "$ayahId": $detail';
}

class _DanglingAyah extends MutashabihatDatasetException {
  const _DanglingAyah({required this.groupId, required this.ayahId});
  final String groupId;
  final String ayahId;
  @override
  String toString() =>
      'MutashabihatDatasetException.danglingAyah: group "$groupId" references '
      'ayah "$ayahId", which is not a loaded reference row.';
}

class _ConstraintViolation extends MutashabihatDatasetException {
  const _ConstraintViolation(this.detail);
  final String detail;
  @override
  String toString() =>
      'MutashabihatDatasetException.constraintViolation: $detail';
}

/// One parsed, validated member of a mutashābihāt group — an `ayah_id`
/// reference plus its structural distinguishing-word indices (never text).
class MutashabihMemberData {
  /// Bundles a validated member row.
  const MutashabihMemberData({
    required this.ayahId,
    required this.distinguishingWordIndices,
  });

  /// The member āyah's `'s:a'` id (a FK into the read-only `ayah` table).
  final String ayahId;

  /// The validated, non-negative structural word indices for the anchor overlay
  /// (E14-T09); an empty list means "no distinguishing word recorded".
  final List<int> distinguishingWordIndices;
}

/// One parsed, validated mutashābihāt group — its `type`, optional localizable
/// `note_key`, and its full member set (always ≥ 2 — group-not-node).
class MutashabihGroupData {
  /// Bundles a validated group row and its members.
  const MutashabihGroupData({
    required this.groupId,
    required this.type,
    required this.noteKey,
    required this.members,
  });

  /// The group's stable id (the `mutashabih_group` PK).
  final String groupId;

  /// The objective-wording similarity type (`identical | near_identical |
  /// structural`).
  final MutashabihType type;

  /// An optional `l10n` resource key for the group's note — never prose/tafsīr.
  final String? noteKey;

  /// The group's members, in stable dataset order (≥ 2).
  final List<MutashabihMemberData> members;
}

/// The fully-parsed, ready-to-load mutashābihāt dataset — the value bundle the
/// JSON parse produces and [loadMutashabihatInto] inserts.
class MutashabihatDataset {
  /// Bundles the parsed groups, in stable dataset order.
  const MutashabihatDataset(this.groups);

  /// The dataset's groups.
  final List<MutashabihGroupData> groups;
}

/// Parses the verified mutashābihāt dataset [jsonText] into a validated
/// [MutashabihatDataset], rejecting any non-conforming row with a named
/// [MutashabihatDatasetException] **before** any DB write is attempted.
///
/// Validates structure only (no DB): the closed `type` enum, a ≥ 2 member count
/// per group (group-not-node), distinct `group_id`s, and that every
/// distinguishing-word index is a non-negative integer. Unknown JSON keys (e.g.
/// any stray translation/commentary field) are **ignored** — the parser has no
/// text/translation field and persists none. Order-stable: the same input
/// yields byte-identical output.
MutashabihatDataset parseMutashabihatDataset(String jsonText) {
  final Object? root;
  try {
    root = jsonDecode(jsonText);
  } on FormatException catch (e) {
    throw MutashabihatDatasetException.malformed('invalid JSON: ${e.message}');
  }
  if (root is! Map) {
    throw const MutashabihatDatasetException.malformed(
      'expected a JSON object root with a "groups" array',
    );
  }
  final rawGroups = root['groups'];
  if (rawGroups is! List) {
    throw const MutashabihatDatasetException.malformed(
      'expected a "groups" array',
    );
  }

  final seenGroupIds = <String>{};
  final groups = <MutashabihGroupData>[];
  for (final rawGroup in rawGroups) {
    if (rawGroup is! Map) {
      throw const MutashabihatDatasetException.malformed(
        'a group entry was not an object',
      );
    }
    final groupId = rawGroup['groupId'];
    if (groupId is! String || groupId.isEmpty) {
      throw const MutashabihatDatasetException.malformed(
        'a group is missing a non-empty "groupId"',
      );
    }
    if (!seenGroupIds.add(groupId)) {
      throw MutashabihatDatasetException.duplicateGroup(groupId);
    }

    final type = _parseType(groupId, rawGroup['type']);
    final noteKey = rawGroup['noteKey'];
    if (noteKey != null && noteKey is! String) {
      throw MutashabihatDatasetException.malformed(
        'group "$groupId" has a non-string "noteKey"',
      );
    }

    final rawMembers = rawGroup['members'];
    if (rawMembers is! List) {
      throw MutashabihatDatasetException.malformed(
        'group "$groupId" is missing a "members" array',
      );
    }
    final members = <MutashabihMemberData>[
      for (final rawMember in rawMembers) _parseMember(groupId, rawMember),
    ];
    if (members.length < 2) {
      throw MutashabihatDatasetException.singletonGroup(groupId);
    }

    groups.add(
      MutashabihGroupData(
        groupId: groupId,
        type: type,
        noteKey: noteKey as String?,
        members: members,
      ),
    );
  }
  return MutashabihatDataset(groups);
}

MutashabihType _parseType(String groupId, Object? rawType) {
  for (final value in MutashabihType.values) {
    if (value.wireValue == rawType) return value;
  }
  throw MutashabihatDatasetException.unknownType(
    groupId: groupId,
    type: '$rawType',
  );
}

MutashabihMemberData _parseMember(String groupId, Object? rawMember) {
  if (rawMember is! Map) {
    throw MutashabihatDatasetException.malformed(
      'group "$groupId" has a member that is not an object',
    );
  }
  final ayahId = rawMember['ayahId'];
  if (ayahId is! String || ayahId.isEmpty) {
    throw MutashabihatDatasetException.malformed(
      'group "$groupId" has a member missing a non-empty "ayahId"',
    );
  }
  final indices = _parseWordIndices(groupId, ayahId, rawMember['indices']);
  return MutashabihMemberData(
    ayahId: ayahId,
    distinguishingWordIndices: indices,
  );
}

List<int> _parseWordIndices(String groupId, String ayahId, Object? raw) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw MutashabihatDatasetException.invalidWordIndex(
      groupId: groupId,
      ayahId: ayahId,
      detail: '"indices" must be a list of non-negative integers',
    );
  }
  return [
    for (final element in raw)
      if (element is int && element >= 0)
        element
      else
        throw MutashabihatDatasetException.invalidWordIndex(
          groupId: groupId,
          ayahId: ayahId,
          detail: 'index "$element" is not a non-negative integer',
        ),
  ];
}

/// Loads the parsed [data] into the read-only `mutashabih_group` /
/// `mutashabih_member` tables in **one** `db.transaction` — the only sanctioned
/// writer of those tables, mirroring [loadCoreReference] (05 §2).
///
/// Validate-all-then-write: every `member.ayah_id` is checked against the loaded
/// `ayah` rows **before** the first insert, so a dangling reference leaves both
/// tables empty rather than half-populated (fail-closed). A `CHECK`/FK violation
/// rolls the **whole** load back and surfaces as
/// [MutashabihatDatasetException.constraintViolation]. The structural facts are
/// inserted as given — `distinguishing_word_index_json` is stored as a JSON
/// index array, never text (R1).
Future<void> loadMutashabihatInto(
  HifzDatabase db,
  MutashabihatDataset data,
) async {
  try {
    await db.transaction(() async {
      // FK pre-check: every referenced ayah must already be a loaded reference
      // row. Named here so a dangling ref fails with the offending pair, not a
      // bare SqliteException (the ayah FK is the on-disk backstop).
      final referenced = <String>{
        for (final group in data.groups)
          for (final member in group.members) member.ayahId,
      };
      if (referenced.isNotEmpty) {
        // Chunk the `IN (...)` lookup: a full-muṣḥaf dataset can reference more
        // distinct āyāt than SQLite's ~999 bound variables (Gemini E14 #1).
        const chunkSize = 500;
        final referencedList = referenced.toList();
        final existing = <String>{};
        for (var i = 0; i < referencedList.length; i += chunkSize) {
          final end = i + chunkSize < referencedList.length
              ? i + chunkSize
              : referencedList.length;
          final rows = await (db.select(db.ayat)
                ..where((a) => a.ayahId.isIn(referencedList.sublist(i, end))))
              .get();
          existing.addAll(rows.map((row) => row.ayahId));
        }
        for (final group in data.groups) {
          for (final member in group.members) {
            if (!existing.contains(member.ayahId)) {
              throw MutashabihatDatasetException.danglingAyah(
                groupId: group.groupId,
                ayahId: member.ayahId,
              );
            }
          }
        }
      }

      await db.batch((b) {
        b.insertAll(db.mutashabihGroups, [
          for (final group in data.groups)
            MutashabihGroupsCompanion(
              groupId: Value(group.groupId),
              type: Value(group.type.wireValue),
              noteKey: Value(group.noteKey),
            ),
        ]);
        b.insertAll(db.mutashabihMembers, [
          for (final group in data.groups)
            for (final member in group.members)
              MutashabihMembersCompanion(
                groupId: Value(group.groupId),
                ayahId: Value(member.ayahId),
                distinguishingWordIndexJson: Value(
                  jsonEncode(member.distinguishingWordIndices),
                ),
              ),
        ]);
      });
    });
  } on SqliteException catch (e) {
    throw MutashabihatDatasetException.constraintViolation(e.message);
  }
}
