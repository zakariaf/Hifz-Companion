// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E08-T03 convention guard: no user-facing chrome disables OS text scaling
// (TextScaler.noScaling), reaches for the deprecated textScaleFactor, or inlines
// an ad-hoc withClampedTextScaling — the one sanctioned ceiling is the
// ClampedTextScaling helper. A pure source scan, fast lane.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../test_setup.dart';

Directory _featuresLibSrc() {
  for (final base in const [
    'lib/src',
    'packages/features/lib/src',
  ]) {
    final dir = Directory(base);
    if (dir.existsSync()) return dir;
  }
  throw StateError('features lib/src not found from ${Directory.current.path}');
}

void main() {
  useOfflineTestPolicy();

  test('no TextScaler.noScaling / textScaleFactor on user-facing chrome', () {
    final offenders = <String>[];
    for (final entity in _featuresLibSrc().listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // The clamp helper's own `///` names the banned terms to document the ban.
      if (entity.path.endsWith('clamped_text_scaling.dart')) continue;
      final text = entity.readAsStringSync();
      if (text.contains('TextScaler.noScaling')) {
        offenders.add('${entity.path}: TextScaler.noScaling');
      }
      if (text.contains('textScaleFactor')) {
        offenders.add('${entity.path}: deprecated textScaleFactor');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('withClampedTextScaling lives only in the ClampedTextScaling helper', () {
    final offenders = <String>[];
    for (final entity in _featuresLibSrc().listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('clamped_text_scaling.dart')) continue;
      if (entity.readAsStringSync().contains('withClampedTextScaling')) {
        offenders.add(entity.path);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'use the ClampedTextScaling helper, not an inline clamp:\n'
          '${offenders.join('\n')}',
    );
  });
}
