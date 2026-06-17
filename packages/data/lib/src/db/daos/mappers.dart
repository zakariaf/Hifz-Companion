// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:models/models.dart';

import '../../persistence_exception.dart';

/// Shared, total row↔value mappers used by the DAOs — the only place where a
/// stored wire token, serial day, UTC instant, or `*_json` payload is converted
/// to/from a `models` value type (05 §2). They hold no Drift symbol.

/// Decodes a stored wire token to its enum member.
///
/// Throws [MappingException] on an unknown token (schema/enum drift; a column
/// `CHECK` normally makes this unreachable).
T enumFromWire<T extends Enum>(
  Iterable<T> values,
  String Function(T) wireOf,
  String stored,
  String enumName,
) {
  for (final value in values) {
    if (wireOf(value) == stored) return value;
  }
  throw MappingException('unknown $enumName wire token: "$stored"');
}

/// Maps a nullable serial-day INTEGER column to a [CalendarDate] (07 §1).
///
/// Never reads a column into a `DateTime`: a scheduling day is a serial integer,
/// not an instant.
CalendarDate? calendarDateFromSerial(int? serialDay) =>
    serialDay == null ? null : CalendarDate.fromEpochDay(serialDay);

/// Maps a [CalendarDate] to its serial-day INTEGER (the stored representation).
int? serialFromCalendarDate(CalendarDate? day) => day?.epochDay;

/// Encodes a true instant as a UTC ISO-8601 string (the stored representation).
String instantToWire(DateTime instant) => instant.toUtc().toIso8601String();

/// Decodes a stored ISO-8601 instant string to a UTC [DateTime].
DateTime instantFromWire(String stored) => DateTime.parse(stored).toUtc();

/// Encodes a list of stumble line indices as a JSON array string, or null.
String? lineIndicesToJson(List<int>? indices) =>
    indices == null ? null : jsonEncode(indices);

/// Decodes the `error_lines_json` payload to a list of line indices, or null.
///
/// Maps any malformed payload to [MappingException] — eagerly: a non-array
/// shape or a non-int element is materialised inside the `try` (never a lazy
/// `cast` whose `TypeError` would leak past the boundary to the caller). Holds
/// line indices only — never Quran text (R1). The message names the column, not
/// the payload bytes (§17).
List<int>? lineIndicesFromJson(String? json) {
  if (json == null) return null;
  try {
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw const FormatException('expected a JSON array');
    }
    return List<int>.from(decoded); // eager — throws here on a bad element
  } on Object {
    throw const MappingException('malformed error_lines_json');
  }
}

/// Encodes the schema-shaped settings map as a JSON object string, or null.
String? settingsToJson(Map<String, Object?>? settings) =>
    settings == null ? null : jsonEncode(settings);

/// Decodes the `settings_json` payload to a schema-shaped map, or null.
///
/// Maps any malformed payload to [MappingException] — eagerly: a non-object
/// shape is rejected inside the `try` (never a lazy `cast`/`as` whose
/// `TypeError` would leak past the boundary). Never health roll-ups or Quran
/// facts (05 §2). The message names the column, not the payload bytes (§17).
Map<String, Object?>? settingsFromJson(String? json) {
  if (json == null) return null;
  try {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('expected a JSON object');
    }
    return Map<String, Object?>.from(decoded);
  } on Object {
    throw const MappingException('malformed settings_json');
  }
}
