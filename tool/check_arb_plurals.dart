// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// check_arb_plurals.dart — the Arabic six-category ICU-plural completeness layer
// of the localization gate (E09-T07; engineering 12 §6; PRD §20 gate 5). Every
// ICU `plural` message in app_ar.arb (the base content language) MUST define all
// six Arabic CLDR categories (zero/one/two/few/many/other) — a missing few/many
// is a grammatical defect, not a cosmetic gap, and fails the build rather than
// the eye of a native reader. Arabic only: fa/ckb use their own CLDR categories
// (asserted elsewhere is wrong — only `ar` carries the six-category contract).
//
// Plurals are detected STRUCTURALLY (by the `{arg, plural,` selector), never by
// key name, so a future count-key cannot slip the gate. `=N` exact-match forms
// are additive — they never substitute a category. Dependency-free (dart:convert
// JSON read only). Usage: dart run tool/check_arb_plurals.dart [app_ar.arb].

import 'dart:convert';
import 'dart:io';

const String _defaultArb = 'packages/l10n/lib/src/arb/app_ar.arb';

/// The six Arabic CLDR plural categories every `plural` in app_ar.arb must define.
const Set<String> requiredArabicCategories = <String>{
  'zero',
  'one',
  'two',
  'few',
  'many',
  'other',
};

/// A `plural` message missing one or more required Arabic CLDR categories.
final class PluralCompletenessViolation {
  const PluralCompletenessViolation(
    this.offendingKey,
    this.localeTag,
    this.missingCategories,
  );

  final String offendingKey;
  final String localeTag;
  final Set<String> missingCategories;

  @override
  String toString() => 'key "$offendingKey" [$localeTag]: missing CLDR plural '
      'category(ies) ${missingCategories.toList()..sort()}';
}

/// The top-level CLDR category labels of [message] if it is an ICU `plural`
/// message, else the empty set (the value is not a plural). Brace-depth aware,
/// so a nested `{count}` placeholder is never mistaken for a category label.
Set<String> pluralCategories(String message) {
  final selector = RegExp(r'\{\s*\w+\s*,\s*plural\s*,').firstMatch(message);
  if (selector == null) return const <String>{};

  final categories = <String>{};
  final label = RegExp(r'^\s*(=\d+|zero|one|two|few|many|other)\s*\{');
  var depth = 1; // inside the outer plural block
  var i = selector.end;
  while (i < message.length && depth > 0) {
    final char = message[i];
    if (char == '}') {
      depth--;
      i++;
      continue;
    }
    if (char == '{') {
      depth++;
      i++;
      continue;
    }
    if (depth == 1) {
      final match = label.firstMatch(message.substring(i));
      if (match != null) {
        categories.add(match.group(1)!);
        i += match.end - 1; // land on the '{' so depth increments next loop
        continue;
      }
    }
    i++;
  }
  return categories;
}

/// Scans every non-`@` value of [arb] (locale [localeTag]) for incomplete
/// Arabic plurals.
List<PluralCompletenessViolation> lintArbPlurals(
  Map<String, dynamic> arb,
  String localeTag,
) {
  final violations = <PluralCompletenessViolation>[];
  for (final entry in arb.entries) {
    if (entry.key.startsWith('@')) continue;
    final value = entry.value;
    if (value is! String) continue;
    final categories = pluralCategories(value);
    if (categories.isEmpty) continue; // not a plural
    final missing = requiredArabicCategories.difference(categories);
    if (missing.isNotEmpty) {
      violations.add(
        PluralCompletenessViolation(entry.key, localeTag, missing),
      );
    }
  }
  return violations;
}

/// Reads app_ar.arb and fails (exit 1) on any incomplete Arabic plural.
void main(List<String> args) {
  final path = args.isEmpty ? _defaultArb : args.first;
  final arb = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final localeTag = (arb['@@locale'] as String?) ?? 'ar';
  final violations = lintArbPlurals(arb, localeTag);

  if (violations.isNotEmpty) {
    stderr.writeln(
      '::error::check_arb_plurals: incomplete Arabic ICU plural in $path '
      '(engineering 12 §6; PRD §20 gate 5):',
    );
    for (final v in violations) {
      stderr.writeln('$path: $v');
    }
    exit(1);
  }
}
