// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// check_ckb_canonical.dart — the canonical-Sorani encoding layer of the
// localization gate (E09-T03; design 12 §7; PRD §20 gate 5). Scans every value
// in app_ckb.arb codepoint-by-codepoint and fails the build on a non-canonical
// Sorani encoding: a stray U+200C (ZWNJ, bad-conversion noise / the heh+ZWNJ AE
// hack), a U+0629 (ة, Teh-Marbuta) or U+06C0 (ۀ) standing for AE where U+06D5
// (ە) belongs, or a U+0643 (ك, Arabic kaf) where U+06A9 (ک) belongs. Pure Dart,
// no Flutter import — runs in CI. The canonical AE (ە) and kaf (ک) are required
// positively by these substitution bans, never re-encoded here.
//
// Usage: dart run tool/check_ckb_canonical.dart [app_ckb.arb]
//   (defaults to packages/l10n/lib/src/arb/app_ckb.arb). Exits 1 on any hit.

import 'dart:convert';
import 'dart:io';

const String _defaultArb = 'packages/l10n/lib/src/arb/app_ckb.arb';

/// Forbidden code points in a Sorani (`ckb`) value, each with why it is banned.
/// The canonical letters they displace — U+06D5 (ە) for AE, U+06A9 (ک) for kaf —
/// are what a value MUST use instead.
const Map<int, String> forbiddenCodePoints = <int, String>{
  0x200C: 'U+200C ZWNJ — bad-conversion noise / the heh+ZWNJ AE hack',
  0x0629: 'U+0629 (ة, Teh-Marbuta) standing for AE — use U+06D5 (ە)',
  0x06C0: 'U+06C0 (ۀ, heh-with-hamza) standing for AE — use U+06D5 (ە)',
  0x0643: 'U+0643 (ك, Arabic kaf) — Sorani kaf is U+06A9 (ک)',
};

/// A non-canonical code point located in one ARB value.
class CkbViolation {
  const CkbViolation(this.key, this.offset, this.codePoint, this.reason);

  final String key;

  /// Rune (code-point) index within the value.
  final int offset;
  final int codePoint;
  final String reason;

  @override
  String toString() {
    final hex = codePoint.toRadixString(16).toUpperCase().padLeft(4, '0');
    return 'key "$key": forbidden U+$hex at offset $offset — $reason';
  }
}

/// Scans one Sorani [value] (the copy for [key]) for non-canonical code points.
List<CkbViolation> scanValue(String key, String value) {
  final out = <CkbViolation>[];
  final runes = value.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final reason = forbiddenCodePoints[runes[i]];
    if (reason != null) out.add(CkbViolation(key, i, runes[i], reason));
  }
  return out;
}

/// Scans every non-`@` string value in a decoded ARB map.
List<CkbViolation> scanArb(Map<String, dynamic> arb) {
  final out = <CkbViolation>[];
  for (final entry in arb.entries) {
    if (entry.key.startsWith('@')) continue; // @@locale / @metadata
    final value = entry.value;
    if (value is String) out.addAll(scanValue(entry.key, value));
  }
  return out;
}

/// Scans the `app_ckb.arb` at [path]; exits 1 on any non-canonical code point.
void main(List<String> args) {
  final path = args.isEmpty ? _defaultArb : args.first;
  final arb = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final violations = scanArb(arb);

  if (violations.isNotEmpty) {
    stderr.writeln(
      '::error::check_ckb_canonical: non-canonical Sorani encoding in $path '
      '(design 12 §7; PRD §20 gate 5):',
    );
    for (final v in violations) {
      stderr.writeln('$path: $v');
    }
    exit(1);
  }
}
