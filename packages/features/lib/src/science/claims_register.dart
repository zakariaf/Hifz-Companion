// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import '../design_system/certainty/evidence_grade.dart';
import 'claim_row.dart';
import 'claims_register_data.dart';

/// Parses the bundled register [source] (the `CLAIMS.md` projection JSON) into
/// typed [ClaimRow]s — pure, synchronous, offline (no network, no AI).
///
/// Every grade is parsed through [EvidenceGrade.parse], so an unknown tag throws
/// [EvidenceGradeFormatException]; a missing field, an unknown group, or an empty
/// grade/source list throws [ClaimRegisterFormatException]. A malformed register
/// is a **release-blocking data defect** surfaced loudly — never a silent default
/// or a rendered fallback (science doc §1; the register-drift risk).
List<ClaimRow> parseClaimsRegister(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (e) {
    throw ClaimRegisterFormatException('register is not valid JSON: ${e.message}');
  }
  if (decoded is! Map<String, dynamic>) {
    throw const ClaimRegisterFormatException('register root must be an object');
  }
  final claims = decoded['claims'];
  if (claims is! List || claims.isEmpty) {
    throw const ClaimRegisterFormatException('register has no claims');
  }

  final rows = <ClaimRow>[];
  final seenIds = <String>{};
  for (final entry in claims) {
    if (entry is! Map<String, dynamic>) {
      throw const ClaimRegisterFormatException('each claim must be an object');
    }
    final id = _requireString(entry, 'id');
    if (!seenIds.add(id)) {
      throw ClaimRegisterFormatException('duplicate claim id "$id"');
    }

    final group = ClaimGroup.parse(_requireString(entry, 'group'));

    final gradeTags = entry['grades'];
    if (gradeTags is! List || gradeTags.isEmpty) {
      throw ClaimRegisterFormatException('claim "$id" has no grades');
    }
    final grades = [
      for (final tag in gradeTags) EvidenceGrade.parse(tag as String),
    ];

    final rawSources = entry['sources'];
    if (rawSources is! List || rawSources.isEmpty) {
      throw ClaimRegisterFormatException('claim "$id" has no sources');
    }
    final sources = [
      for (final s in rawSources)
        if (s is Map<String, dynamic>)
          ClaimSource(label: _requireString(s, 'label'), url: s['url'] as String?)
        else
          throw ClaimRegisterFormatException('claim "$id" has a malformed source'),
    ];

    rows.add(
      ClaimRow(
        id: id,
        group: group,
        grades: grades,
        sources: sources,
        needsScholarlyReview: entry['needsScholarlyReview'] as bool? ?? false,
      ),
    );
  }
  return List.unmodifiable(rows);
}

String _requireString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    throw ClaimRegisterFormatException('missing or empty "$key"');
  }
  return value;
}

List<ClaimRow>? _cached;

/// The bundled register, parsed once and memoized. Read-only; offline.
List<ClaimRow> get claimsRegister => _cached ??= parseClaimsRegister(claimsRegisterJson);

/// The register rows for one [group], in register order.
List<ClaimRow> claimsForGroup(ClaimGroup group) =>
    [for (final row in claimsRegister) if (row.group == group) row];

/// The groups present in the register, in enum (A–J) order.
List<ClaimGroup> get claimGroupsInRegister =>
    [for (final g in ClaimGroup.values) if (claimsForGroup(g).isNotEmpty) g];
