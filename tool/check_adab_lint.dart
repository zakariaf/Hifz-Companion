// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// check_adab_lint.dart — the banned-phrase (adab) layer of the localization
// completeness gate (E09-T02; PRD §20 gate 5). Scans every user-facing value in
// the ARB files (app_ar/app_fa/app_ckb + any region-override ARB) for the
// design-system 11 §9 never-ship patterns and fails the build on a match. This
// is a *necessary-not-sufficient* machine layer: the human native + scholar
// review (design 11 §9) still runs per locale and is recorded separately.
//
// The per-locale pattern lists are DATA, deliberately conservative, and flagged
// "extend per native review" — a native reviewer widens them; this file never
// becomes an English-only check a transcreated curt imperative slips past.
//
// Usage: dart run tool/check_adab_lint.dart [arb-dir-or-file ...]
//   (defaults to packages/l10n/lib/src/arb). Exits non-zero on the first match.

import 'dart:convert';
import 'dart:io';

const _defaultRoots = ['packages/l10n/lib/src/arb'];

/// The closed (sealed) set of never-ship classes (design 11 §9). Each value
/// traces to a documented harm, not a style preference.
enum AdabRule {
  exclamationOrEmoji(
    'exclamation mark / emoji (enthusiasm marker, design 11 §2/§9)',
  ),
  mandate('controlling mandate — "you must / should / don\'t" (design 11 §6)'),
  guiltFearLossStreak('guilt / fear / loss / streak framing (design 11 §9)'),
  forbiddenVerdict(
    '"safe to drop" / "mastered" / "done with" (design 11 §5; PRD §7.12)',
  ),
  commercial('commercial-transaction word (design 11 §9; PRD §16)');

  const AdabRule(this.description);

  /// Human-readable reason, printed with each violation.
  final String description;
}

/// One never-ship pattern, optionally scoped to a single [locale] (null = all).
/// [pattern] matches against an ARB value; a hit is a build failure.
class _BannedPattern {
  const _BannedPattern(this.rule, this.pattern, {this.locale});

  final AdabRule rule;
  final RegExp pattern;
  final String? locale;
}

/// A located never-ship match: the offending key, its locale, and the rule —
/// never the full copy (only key + pattern + locale are surfaced).
class AdabViolation {
  const AdabViolation(
    this.file,
    this.key,
    this.locale,
    this.rule,
    this.matched,
  );

  final String file;
  final String key;
  final String locale;
  final AdabRule rule;
  final String matched;

  @override
  String toString() =>
      '$file :: $key [$locale]: ${rule.description} — matched /$matched/';
}

// A banned pattern. `regex` is matched case-insensitively (harmless for the
// Arabic-script locales, which have no case); `locale` null = every locale.
_BannedPattern _p(AdabRule rule, String regex, {String? locale}) =>
    _BannedPattern(rule, RegExp(regex, caseSensitive: false), locale: locale);

// The pattern table. The per-locale (fa/ar/ckb) entries are SEED entries flagged
// "extend per native review" — a native reviewer adds the register-specific
// curt imperatives this can't guess; this never becomes an English-only check.
final List<_BannedPattern> _patterns = <_BannedPattern>[
  // ── Mandate words (controlling language). ──
  _p(AdabRule.mandate, r'\byou must\b'),
  _p(AdabRule.mandate, r'\byou have to\b'),
  _p(AdabRule.mandate, r'\byou should\b'),
  _p(AdabRule.mandate, r'\bmust not\b'),
  _p(AdabRule.mandate, 'باید', locale: 'fa'), // must (extend per native review)
  _p(AdabRule.mandate, 'نباید', locale: 'fa'), // must not
  _p(AdabRule.mandate, 'يجب عليك', locale: 'ar'), // you must
  _p(
    AdabRule.mandate,
    'دەبێت',
    locale: 'ckb',
  ), // must (extend per native review)
  // ── Guilt / fear / loss + streak framing. ──
  _p(AdabRule.guiltFearLossStreak, r'\bstreak\b'),
  _p(AdabRule.guiltFearLossStreak, r'falling behind'),
  _p(AdabRule.guiltFearLossStreak, r'lose your'),
  _p(AdabRule.guiltFearLossStreak, r"haven't opened"),
  _p(AdabRule.guiltFearLossStreak, r"don'?t break"),
  // ── Forbidden verdicts (the engine-invariant copy mirror). ──
  _p(AdabRule.forbiddenVerdict, r'safe to (drop|stop|forget)'),
  _p(AdabRule.forbiddenVerdict, r'\bmastered\b'),
  _p(AdabRule.forbiddenVerdict, r'done with\b'),
  // ── Commercial-transaction words. ──
  _p(AdabRule.commercial, r'\bupgrade\b'),
  _p(AdabRule.commercial, r'\bpremium\b'),
  _p(AdabRule.commercial, r'\bunlock\b'),
  _p(AdabRule.commercial, r'\b(free trial|subscribe|buy now)\b'),
];

// Emoji / pictograph code-point ranges (NOT the em-dash U+2014 or locale digits,
// which fall outside every range below). Variation selectors and the main emoji
// planes are covered.
bool _hasEmoji(String value) {
  for (final rune in value.runes) {
    if ((rune >= 0x2600 && rune <= 0x27BF) || // Misc symbols + Dingbats (✨❤)
        (rune >= 0x2B00 && rune <= 0x2BFF) || // Misc symbols & arrows (⭐)
        (rune >= 0xFE00 && rune <= 0xFE0F) || // Variation selectors
        (rune >= 0x1F000 && rune <= 0x1FAFF)) {
      return true;
    }
  }
  return false;
}

/// Returns the locale tag for an ARB [file] — its `@@locale`, else the
/// `app_<tag>.arb` filename stem.
String _localeOf(File file, Map<String, dynamic> json) {
  final declared = json['@@locale'];
  if (declared is String && declared.isNotEmpty) return declared;
  final name = file.uri.pathSegments.last;
  final m = RegExp(r'app_([A-Za-z]+)\.arb').firstMatch(name);
  return m?.group(1) ?? name;
}

List<AdabViolation> _scanFile(File file) {
  final violations = <AdabViolation>[];
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final locale = _localeOf(file, json);

  for (final entry in json.entries) {
    final key = entry.key;
    if (key.startsWith('@')) continue; // @@locale / @metadata, not user copy
    final value = entry.value;
    if (value is! String) continue;

    void flag(AdabRule rule, String matched) =>
        violations.add(AdabViolation(file.path, key, locale, rule, matched));

    if (value.contains('!') || value.contains('！')) {
      flag(AdabRule.exclamationOrEmoji, '!');
    }
    if (_hasEmoji(value)) flag(AdabRule.exclamationOrEmoji, 'emoji');
    for (final p in _patterns) {
      if (p.locale != null && p.locale != locale) continue;
      if (p.pattern.hasMatch(value)) flag(p.rule, p.pattern.pattern);
    }
  }
  return violations;
}

Iterable<File> _arbFiles(String root) {
  final asFile = File(root);
  if (asFile.existsSync() && root.endsWith('.arb')) return <File>[asFile];
  final dir = Directory(root);
  if (!dir.existsSync()) return const <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'));
}

/// Scans every `.arb` file under [roots] (a dir or a single `.arb` path) and
/// returns the never-ship matches. Pure (no exit, no stdout) so the unit suite
/// can assert each pattern class against crafted fixtures.
List<AdabViolation> lintRoots(List<String> roots) {
  final violations = <AdabViolation>[];
  for (final root in roots) {
    for (final file in _arbFiles(root)) {
      violations.addAll(_scanFile(file));
    }
  }
  return violations;
}

/// Scans the ARB roots for never-ship adab patterns; exits 1 on any match,
/// printing the offending key, pattern, and locale (never the full copy).
void main(List<String> args) {
  final violations = lintRoots(args.isEmpty ? _defaultRoots : args);

  if (violations.isNotEmpty) {
    stderr.writeln(
      '::error::check_adab_lint: never-ship copy found (design 11 §9; PRD §20 '
      'gate 5). A native + scholar review still runs per locale.',
    );
    violations.map((v) => v.toString()).forEach(stderr.writeln);
    exit(1);
  }
}
