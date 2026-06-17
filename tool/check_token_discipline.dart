// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later
//
// check_token_discipline.dart — every value in a Mihrab *consumer* widget must
// resolve to a named token (a ColorScheme role, the TextTheme, or a
// ThemeExtension); no widget inlines a value the design system owns
// (design-system 02 §9; 05 §3; 04 §6). Scans packages/features/lib/src/** and
// flags the five anti-patterns below, skipping generated files and the
// token-DEFINITION subtree (design_system/theme/**), which is the one place
// each family is allowed to name raw hex/dp/Duration.
//
// Usage: dart run tool/check_token_discipline.dart [dir ...]
// (defaults to packages/features/lib/src). Exits non-zero on the first hit.

import 'dart:io';

const _defaultRoots = ['packages/features/lib/src'];

final Map<String, RegExp> _rules = {
  'raw hex colour (use a ColorScheme role / MihrabColors)':
      RegExp(r'Color\(0x|Color\.fromARGB\('),
  'Colors.* literal (use a role; only Colors.transparent is exempt)':
      RegExp(r'\bColors\.(?!transparent\b)[a-zA-Z]'),
  'off-scale dp (use SpacingTokens.space*)': RegExp(
    r'(EdgeInsets[A-Za-z]*\.[a-zA-Z]+\(|SizedBox\(\s*(width|height):|'
    r'BorderRadius\.circular\(|Gap\()\s*-?[0-9]',
  ),
  'bare Duration/Curve (use MotionTokens)': RegExp(r'\bDuration\(|\bCurves\.'),
  'physical-side inset (use the directional variant)': RegExp(
    r'EdgeInsets\.only\(\s*(left|right):|Alignment\.center(Left|Right)|'
    r'Positioned\(\s*(left|right):',
  ),
  'non-zero letterSpacing on a UI run (Arabic joins — keep 0)':
      RegExp(r'letterSpacing:\s*-?[1-9]'),
};

final RegExp _fullLineComment = RegExp(r'^\s*(//|/\*|\*)');

bool _skip(String path) =>
    path.contains('/design_system/theme/') || // token-definition allowlist
    path.contains('/generated/') ||
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.endsWith('.drift.dart');

void main(List<String> args) {
  final roots = args.isEmpty ? _defaultRoots : args;
  final violations = <String>[];

  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (_skip(entity.path)) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_fullLineComment.hasMatch(line)) continue;
        for (final rule in _rules.entries) {
          if (rule.value.hasMatch(line)) {
            violations.add('${entity.path}:${i + 1}: ${rule.key}');
          }
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln(
      'check_token_discipline: a widget inlines a value the design system owns '
      '(02 §9):',
    );
    violations.forEach(stderr.writeln);
    exit(1);
  }
}
