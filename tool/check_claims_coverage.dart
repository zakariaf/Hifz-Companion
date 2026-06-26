// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// check_claims_coverage.dart — the grade-coverage / no-orphan-claim release gate
// (E19-T02; docs/science/11-the-in-app-science-screen.md §1; PRD §20). The
// "The science we follow" screen renders a BUNDLED projection of the CLAIMS
// register; this gate proves that projection stays faithful to the single source
// of authorship, docs/science/CLAIMS.md, so no orphan or mis-graded claim ever
// reaches a ḥāfiẓ:
//
//   1. ID parity — every C-NNN row in CLAIMS.md is in the bundled register and
//      vice-versa (no orphan rendered claim, no silently-dropped row).
//   2. Grade fidelity — for every claim, the bundled grades exactly match the
//      standard grade tags in the doc's Grade column (no invented, no dropped
//      grade). C-048's "[TRAD-equivalent project rule]" reduces to {TRAD}.
//   3. Structural integrity — every bundled claim carries ≥1 source and ≥1
//      known grade (MA/RCT/EXP/CS/OBS/TEXT/TRAD), never an unknown tag.
//
// A violation is a release-blocking defect, not a copy nit. Dependency-free
// (dart:convert + dart:io). Usage: dart run tool/check_claims_coverage.dart.

import 'dart:convert';
import 'dart:io';

const String _defaultClaimsMd = 'docs/science/CLAIMS.md';
const String _defaultRegisterDart =
    'packages/features/lib/src/science/claims_register_data.dart';

/// The seven evidence-grade names (lower-case), mirroring `EvidenceGrade`.
const Set<String> gradeNames = <String>{
  'ma',
  'rct',
  'exp',
  'cs',
  'obs',
  'text',
  'trad',
};

/// Extracts the bundled register JSON from its Dart raw-string literal. The data
/// file holds exactly one `r'''…'''` block.
String extractRegisterJson(String dartSource) {
  const open = "r'''";
  final start = dartSource.indexOf(open);
  if (start < 0) {
    throw const FormatException('no r\'\'\' register literal found');
  }
  final from = start + open.length;
  final end = dartSource.indexOf("'''", from);
  if (end < 0) throw const FormatException('unterminated register literal');
  return dartSource.substring(from, end);
}

/// id → its set of grade names, parsed from the bundled register JSON.
Map<String, Set<String>> bundledGrades(String registerJson) {
  final decoded = jsonDecode(registerJson) as Map<String, dynamic>;
  final claims = decoded['claims'] as List<dynamic>;
  return {
    for (final c in claims.cast<Map<String, dynamic>>())
      c['id'] as String: {
        for (final g in (c['grades'] as List<dynamic>).cast<String>())
          g.toLowerCase(),
      },
  };
}

/// id → number of bundled sources, for the ≥1-source structural check.
Map<String, int> bundledSourceCounts(String registerJson) {
  final decoded = jsonDecode(registerJson) as Map<String, dynamic>;
  final claims = decoded['claims'] as List<dynamic>;
  return {
    for (final c in claims.cast<Map<String, dynamic>>())
      c['id'] as String: (c['sources'] as List<dynamic>).length,
  };
}

/// id → its set of standard grade names, parsed from the CLAIMS.md Grade column.
///
/// Only table rows (`| C-NNN | … |`) are read; inline `(C-016)` prose references
/// and the References list are ignored. Bracketed grade tags are taken from the
/// fifth column only — `[link](url)` markdown elsewhere in the row never leaks in.
Map<String, Set<String>> docGrades(String claimsMarkdown) {
  final rowId = RegExp(r'^\s*\|\s*(C-\d{3})\s*\|');
  final result = <String, Set<String>>{};
  for (final line in const LineSplitter().convert(claimsMarkdown)) {
    final match = rowId.firstMatch(line);
    if (match == null) continue;
    final id = match.group(1)!;
    final cells = line.split('|');
    if (cells.length < 7) continue; // malformed; reported as missing grades
    final gradeCell = cells[5];
    final tags = <String>{};
    for (final bracket in RegExp(r'\[([^\]]+)\]').allMatches(gradeCell)) {
      // Leading alpha token of the bracket content, e.g. "TRAD-equivalent" → trad.
      final leading = RegExp(r'^[A-Za-z]+').firstMatch(bracket.group(1)!.trim());
      final name = leading?.group(0)?.toLowerCase();
      if (name != null && gradeNames.contains(name)) tags.add(name);
    }
    result[id] = tags;
  }
  return result;
}

/// Returns every coverage violation between the doc and the bundled register;
/// an empty list means the gate passes.
List<String> checkClaimsCoverage({
  required String claimsMarkdown,
  required String registerJson,
}) {
  final violations = <String>[];

  final doc = docGrades(claimsMarkdown);
  final bundled = bundledGrades(registerJson);
  final sources = bundledSourceCounts(registerJson);

  // 1. ID parity.
  for (final id in doc.keys) {
    if (!bundled.containsKey(id)) {
      violations.add('CLAIMS.md row $id has no bundled register row (orphan).');
    }
  }
  for (final id in bundled.keys) {
    if (!doc.containsKey(id)) {
      violations.add('bundled register row $id is not in CLAIMS.md (unsourced).');
    }
  }

  // 2 + 3. Per-claim grade fidelity and structural integrity.
  for (final id in bundled.keys) {
    final bundledSet = bundled[id]!;
    if (bundledSet.isEmpty) {
      violations.add('$id has no grade.');
    }
    for (final g in bundledSet) {
      if (!gradeNames.contains(g)) {
        violations.add('$id has unknown grade "$g".');
      }
    }
    if ((sources[id] ?? 0) < 1) {
      violations.add('$id has no source.');
    }
    final docSet = doc[id];
    if (docSet != null) {
      final invented = bundledSet.difference(docSet);
      if (invented.isNotEmpty) {
        violations.add('$id bundles grade(s) ${_sorted(invented)} absent from '
            'CLAIMS.md ${_sorted(docSet)}.');
      }
      final dropped = docSet.difference(bundledSet);
      if (dropped.isNotEmpty) {
        violations.add('$id drops CLAIMS.md grade(s) ${_sorted(dropped)} '
            '(bundled ${_sorted(bundledSet)}).');
      }
    }
  }
  return violations;
}

List<String> _sorted(Set<String> s) => s.toList()..sort();

void main(List<String> args) {
  final mdPath = args.isNotEmpty ? args[0] : _defaultClaimsMd;
  final dartPath = args.length > 1 ? args[1] : _defaultRegisterDart;

  final registerJson = extractRegisterJson(File(dartPath).readAsStringSync());
  final violations = checkClaimsCoverage(
    claimsMarkdown: File(mdPath).readAsStringSync(),
    registerJson: registerJson,
  );

  if (violations.isNotEmpty) {
    stderr.writeln(
      '::error::check_claims_coverage: the bundled science register has drifted '
      'from docs/science/CLAIMS.md (E19; PRD §20). Every rendered claim must '
      'resolve to a sourced, correctly-graded register row:',
    );
    for (final v in violations) {
      stderr.writeln('  - $v');
    }
    exit(1);
  }
  stdout.writeln(
    'check_claims_coverage: OK — ${bundledGrades(registerJson).length} bundled '
    'claims, all sourced and graded faithfully to CLAIMS.md.',
  );
}
