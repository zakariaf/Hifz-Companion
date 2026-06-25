// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:models/models.dart';

import 'backup_error.dart';
import 'snapshot.dart';

// The truth-only versioned JSON payload (domain-backup-format §4). A complete,
// value-typed export of the per-profile user model and NOTHING else — no derived
// state (health %, forecast, Today list, notification cache) and no Quran bytes.
//
// Encoding rules (§4): scheduling days (`dueAt`, `lastReviewAt`, `lastConfusedAt`)
// are floating `"YYYY-MM-DD"` strings (a cross-timezone restore is byte-identical);
// true event instants (`reviewedAt`, `createdAt`) are UTC ISO-8601; `profileId` is
// the ProfileExport-level merge key, so child rows omit it (it is injected on
// decode); keys are sorted before encoding so the body bytes — and the integrity
// hash and golden tests — are deterministic.

/// The payload `schemaVersion` this app writes (== the Drift schemaVersion).
const int kCurrentSchemaVersion = 2;

/// Encodes a payload map to canonical (sorted-key) UTF-8 JSON bytes — the
/// deterministic body the §5 SHA-256 covers (§4).
Uint8List encodeCanonicalJson(Map<String, Object?> payload) =>
    Uint8List.fromList(utf8.encode(jsonEncode(_sortKeysDeep(payload))));

/// Decodes UTF-8 JSON bytes to a string-keyed map, or throws [BackupError.malformedPayload].
Map<String, Object?> decodeJsonObject(Uint8List bytes) {
  final Object? decoded;
  try {
    decoded = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const BackupException(BackupError.malformedPayload);
  }
  if (decoded is Map<String, dynamic>) return decoded;
  throw const BackupException(BackupError.malformedPayload);
}

Object? _sortKeysDeep(Object? v) {
  if (v is Map) {
    final sorted = <String, Object?>{};
    for (final k in v.keys.map((k) => k.toString()).toList()..sort()) {
      sorted[k] = _sortKeysDeep(v[k]);
    }
    return sorted;
  }
  if (v is List) return v.map(_sortKeysDeep).toList();
  return v;
}

// ── Snapshot ⇄ JSON ───────────────────────────────────────────────────────────

/// The truth-only top-level payload map for [snapshot] (§4).
Map<String, Object?> snapshotToJson(BackupSnapshot snapshot) =>
    <String, Object?>{
      'schemaVersion': snapshot.schemaVersion,
      'appVersion': snapshot.appVersion,
      'exportedAt': snapshot.exportedAt,
      'mushaf': _mushafToJson(snapshot.mushaf),
      'profiles': snapshot.profiles.map(_profileExportToJson).toList(),
    };

/// Decodes a payload map, refusing a newer `schemaVersion` ([BackupError.newerFormat])
/// and migrating older ones forward (§4) before reading the current shape.
BackupSnapshot snapshotFromJson(Map<String, Object?> json) {
  final version = _readInt(json, 'schemaVersion');
  if (version > kCurrentSchemaVersion) {
    throw const BackupException(BackupError.newerFormat);
  }
  final migrated = _migrateForward(json, version);
  return BackupSnapshot(
    // The data is now mapped onto the current schema.
    schemaVersion: kCurrentSchemaVersion,
    appVersion: _readString(migrated, 'appVersion'),
    exportedAt: _readString(migrated, 'exportedAt'),
    mushaf: _mushafFromJson(_readMap(migrated, 'mushaf')),
    profiles: _readList(migrated, 'profiles')
        .map((e) => _profileExportFromJson(_asMap(e)))
        .toList(),
  );
}

/// Maps a payload of [from] forward to [kCurrentSchemaVersion] through explicit,
/// per-version functions (§4), mirroring the DB migration discipline. v2 is the
/// first shipped format, so there is no older version to migrate yet — this is
/// the registered seam each future bump adds a step to.
Map<String, Object?> _migrateForward(Map<String, Object?> json, int from) {
  // for (var v = from; v < kCurrentSchemaVersion; v++) json = _migrations[v]!(json);
  return json;
}

// ── Per-entity codecs ─────────────────────────────────────────────────────────

Map<String, Object?> _mushafToJson(MushafRef m) => <String, Object?>{
      'id': m.id,
      'riwayah': m.riwayah,
      'name': m.name,
      'checksumSha256': m.checksumSha256,
    };

MushafRef _mushafFromJson(Map<String, Object?> j) => MushafRef(
      id: _readString(j, 'id'),
      riwayah: _readString(j, 'riwayah'),
      name: _readString(j, 'name'),
      checksumSha256: _readString(j, 'checksumSha256'),
    );

Map<String, Object?> _profileExportToJson(ProfileExport p) => <String, Object?>{
      // The stable merge key (§4/§7); child rows below omit it.
      'profileId': p.profile.profileId.value,
      'profile': _profileToJson(p.profile),
      'cycleConfig': _cycleConfigToJson(p.cycleConfig),
      'cards': p.cards.map(_cardToJson).toList(),
      'lineBlocks': p.lineBlocks.map(_lineBlockToJson).toList(),
      'reviewLog': p.reviewLog.map(_reviewLogToJson).toList(),
      'confusionEdges': p.confusionEdges.map(_confusionEdgeToJson).toList(),
    };

ProfileExport _profileExportFromJson(Map<String, Object?> j) {
  final profileId = ProfileId(_readString(j, 'profileId'));
  return ProfileExport(
    profile: _profileFromJson(profileId, _readMap(j, 'profile')),
    cycleConfig: _cycleConfigFromJson(profileId, _readMap(j, 'cycleConfig')),
    cards: _readList(j, 'cards')
        .map((e) => _cardFromJson(profileId, _asMap(e)))
        .toList(),
    lineBlocks: _readList(j, 'lineBlocks')
        .map((e) => _lineBlockFromJson(profileId, _asMap(e)))
        .toList(),
    reviewLog: _readList(j, 'reviewLog')
        .map((e) => _reviewLogFromJson(profileId, _asMap(e)))
        .toList(),
    confusionEdges: _readList(j, 'confusionEdges')
        .map((e) => _confusionEdgeFromJson(profileId, _asMap(e)))
        .toList(),
  );
}

Map<String, Object?> _profileToJson(Profile p) => <String, Object?>{
      'displayName': p.displayName,
      'role': p.role.wireValue,
      'locale': p.locale.wireValue,
      'mushafId': p.mushafId,
      'createdAt': _instantToString(p.createdAtInstant),
      'settingsJson': p.settings,
    };

Profile _profileFromJson(ProfileId profileId, Map<String, Object?> j) =>
    Profile(
      profileId: profileId,
      displayName: _readString(j, 'displayName'),
      role: _enumFromWire(ProfileRole.values, (e) => e.wireValue, j['role']),
      locale:
          _enumFromWire(ProfileLocale.values, (e) => e.wireValue, j['locale']),
      mushafId: _readString(j, 'mushafId'),
      createdAtInstant: _instantFromString(_readString(j, 'createdAt')),
      settings: _readNullableMap(j, 'settingsJson'),
    );

Map<String, Object?> _cycleConfigToJson(CycleConfig c) => <String, Object?>{
      'cycleType': c.cycleType,
      'newLinesPerDay': c.newLinesPerDay,
      'nearWindowJuz': c.nearWindowJuz,
      'farTargetPerDay': c.farTargetPerDay,
      'farCycleDays': c.cycleCeilingDays,
      'dailyBudgetMinutes': c.dailyBudgetMinutes,
      'pureCycleMode': c.isPureCycleMode,
      'termLabelSet': c.termLabelSet,
      'regionPreset': c.regionPreset,
    };

CycleConfig _cycleConfigFromJson(ProfileId profileId, Map<String, Object?> j) =>
    CycleConfig(
      profileId: profileId,
      cycleType: _readString(j, 'cycleType'),
      newLinesPerDay: _readInt(j, 'newLinesPerDay'),
      nearWindowJuz: _readInt(j, 'nearWindowJuz'),
      farTargetPerDay: _readInt(j, 'farTargetPerDay'),
      cycleCeilingDays: _readInt(j, 'farCycleDays'),
      dailyBudgetMinutes: _readInt(j, 'dailyBudgetMinutes'),
      isPureCycleMode: _readBool(j, 'pureCycleMode'),
      termLabelSet: _readString(j, 'termLabelSet'),
      regionPreset: _readNullableString(j, 'regionPreset'),
    );

Map<String, Object?> _cardToJson(Card c) => <String, Object?>{
      'pageId': c.pageId,
      'track': c.track.wireValue,
      'd': c.difficulty,
      's': c.stabilityDays,
      'lastReviewAt': _dateToNullableString(c.lastReviewedDay),
      'dueAt': _dateToNullableString(c.dueAt),
      'reps': c.reps,
      'lapses': c.lapses,
      'weakFlag': c.isWeak,
      'signoffs': c.signoffs,
      'manualLock': c.hasManualLock,
      'prayerCritical': c.isPrayerCritical,
      'enabled': c.isEnabled,
    };

Card _cardFromJson(ProfileId profileId, Map<String, Object?> j) => Card(
      profileId: profileId,
      pageId: _readInt(j, 'pageId'),
      track: _enumFromWire(ReviewTrack.values, (e) => e.wireValue, j['track']),
      difficulty: _readDouble(j, 'd'),
      stabilityDays: _readDouble(j, 's'),
      lastReviewedDay: _readNullableDate(j, 'lastReviewAt'),
      dueAt: _readNullableDate(j, 'dueAt'),
      reps: _readInt(j, 'reps'),
      lapses: _readInt(j, 'lapses'),
      isWeak: _readBool(j, 'weakFlag'),
      signoffs: _readInt(j, 'signoffs'),
      hasManualLock: _readBool(j, 'manualLock'),
      isPrayerCritical: _readBool(j, 'prayerCritical'),
      isEnabled: _readBool(j, 'enabled'),
    );

Map<String, Object?> _lineBlockToJson(LineBlock b) => <String, Object?>{
      'blockId': b.blockId.value,
      'pageId': b.pageId,
      'lineStart': b.lineStart,
      'lineEnd': b.lineEnd,
      'errorCount': b.errorCount,
    };

LineBlock _lineBlockFromJson(ProfileId profileId, Map<String, Object?> j) =>
    LineBlock(
      blockId: BlockId(_readString(j, 'blockId')),
      profileId: profileId,
      pageId: _readInt(j, 'pageId'),
      lineStart: _readInt(j, 'lineStart'),
      lineEnd: _readInt(j, 'lineEnd'),
      errorCount: _readInt(j, 'errorCount'),
    );

Map<String, Object?> _reviewLogToJson(ReviewLog r) => <String, Object?>{
      'logId': r.logId.value,
      'pageId': r.pageId,
      'reviewedAt': _instantToString(r.reviewedAtInstant),
      'trackAtReview': r.trackAtReview.wireValue,
      'grade': r.grade.wireValue,
      'errorLinesJson': r.errorLineIndices,
      'elapsedDays': r.elapsedDays,
      'rPredicted': r.predictedRetrievability,
      'sBefore': r.stabilityDaysBefore,
      'sAfter': r.stabilityDaysAfter,
      'dBefore': r.difficultyBefore,
      'dAfter': r.difficultyAfter,
      'source': r.source.wireValue,
      'teacherLabel': r.teacherLabel,
    };

ReviewLog _reviewLogFromJson(ProfileId profileId, Map<String, Object?> j) =>
    ReviewLog(
      logId: LogId(_readString(j, 'logId')),
      profileId: profileId,
      pageId: _readInt(j, 'pageId'),
      reviewedAtInstant: _instantFromString(_readString(j, 'reviewedAt')),
      trackAtReview: _enumFromWire(
        ReviewTrack.values,
        (e) => e.wireValue,
        j['trackAtReview'],
      ),
      grade: _enumFromWire(ReviewGrade.values, (e) => e.wireValue, j['grade']),
      errorLineIndices: _readNullableIntList(j, 'errorLinesJson'),
      elapsedDays: _readInt(j, 'elapsedDays'),
      predictedRetrievability: _readNullableDouble(j, 'rPredicted'),
      stabilityDaysBefore: _readNullableDouble(j, 'sBefore'),
      stabilityDaysAfter: _readNullableDouble(j, 'sAfter'),
      difficultyBefore: _readNullableDouble(j, 'dBefore'),
      difficultyAfter: _readNullableDouble(j, 'dAfter'),
      source:
          _enumFromWire(GradeSource.values, (e) => e.wireValue, j['source']),
      teacherLabel: _readNullableString(j, 'teacherLabel'),
    );

Map<String, Object?> _confusionEdgeToJson(ConfusionEdge e) => <String, Object?>{
      'ayahA': e.ayahA,
      'ayahB': e.ayahB,
      'weight': e.weight,
      // A CalendarDate serial day (post-E14 v2), so a floating date — NOT a UTC
      // instant (the §4 prose still says "UTC"; the model is authoritative).
      'lastConfusedAt': _dateToNullableString(e.lastConfusedAt),
    };

ConfusionEdge _confusionEdgeFromJson(
  ProfileId profileId,
  Map<String, Object?> j,
) =>
    ConfusionEdge(
      profileId: profileId,
      ayahA: _readString(j, 'ayahA'),
      ayahB: _readString(j, 'ayahB'),
      weight: _readDouble(j, 'weight'),
      lastConfusedAt: _readNullableDate(j, 'lastConfusedAt'),
    );

// ── Scalar helpers ────────────────────────────────────────────────────────────

String _dateToString(CalendarDate d) =>
    d.toString(); // "YYYY-MM-DD" (§4 floating)
String? _dateToNullableString(CalendarDate? d) =>
    d == null ? null : _dateToString(d);

CalendarDate _dateFromString(String s) {
  final parts = s.split('-');
  if (parts.length != 3) _malformed();
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) _malformed();
  return CalendarDate.ymd(y, m, d);
}

String _instantToString(DateTime t) => t.toUtc().toIso8601String();

DateTime _instantFromString(String s) {
  final t = DateTime.tryParse(s);
  if (t == null) _malformed();
  return t.toUtc();
}

T _enumFromWire<T>(List<T> values, String Function(T) wireOf, Object? raw) {
  if (raw is String) {
    for (final v in values) {
      if (wireOf(v) == raw) return v;
    }
  }
  _malformed();
}

// ── Read helpers — a missing/invalid field is malformedPayload (§4) ───────────

Never _malformed() => throw const BackupException(BackupError.malformedPayload);

Map<String, Object?> _asMap(Object? v) =>
    v is Map ? v.cast<String, Object?>() : _malformed();

String _readString(Map<String, Object?> j, String k) {
  final v = j[k];
  return v is String ? v : _malformed();
}

int _readInt(Map<String, Object?> j, String k) {
  final v = j[k];
  return v is int ? v : _malformed();
}

double _readDouble(Map<String, Object?> j, String k) {
  final v = j[k];
  return v is num ? v.toDouble() : _malformed();
}

bool _readBool(Map<String, Object?> j, String k) {
  final v = j[k];
  return v is bool ? v : _malformed();
}

Map<String, Object?> _readMap(Map<String, Object?> j, String k) => _asMap(j[k]);

List<Object?> _readList(Map<String, Object?> j, String k) {
  final v = j[k];
  return v is List ? v : _malformed();
}

String? _readNullableString(Map<String, Object?> j, String k) {
  final v = j[k];
  if (v == null) return null;
  return v is String ? v : _malformed();
}

double? _readNullableDouble(Map<String, Object?> j, String k) {
  final v = j[k];
  if (v == null) return null;
  return v is num ? v.toDouble() : _malformed();
}

CalendarDate? _readNullableDate(Map<String, Object?> j, String k) {
  final s = _readNullableString(j, k);
  return s == null ? null : _dateFromString(s);
}

Map<String, Object?>? _readNullableMap(Map<String, Object?> j, String k) {
  final v = j[k];
  if (v == null) return null;
  return v is Map ? v.cast<String, Object?>() : _malformed();
}

List<int>? _readNullableIntList(Map<String, Object?> j, String k) {
  final v = j[k];
  if (v == null) return null;
  if (v is! List) _malformed();
  return v
      .map((e) => e is int ? e : (e is num ? e.toInt() : _malformed()))
      .toList();
}
