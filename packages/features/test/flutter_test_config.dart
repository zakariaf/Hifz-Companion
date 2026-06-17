// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

// A tiny golden tolerance for the design-system goldens (E06-T11). The pinned
// Linux masters and the Linux CI runner differ by a few sub-pixel anti-aliased
// edge pixels on the off-black Dark/Night frames (~3px / ~0.0002%); anything a
// reviewer cares about — a recolour, an RTL leak, a moved/missing widget, a
// clipped glyph — changes orders of magnitude more, so 0.01% catches every real
// regression while absorbing cross-environment AA noise. macOS renders differ
// far more than this, which is why the goldens stay @Tags(['golden']) and run
// only on the pinned Linux lane.
const double _goldenTolerance = 0.0001; // 0.01% of pixels

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final prior = goldenFileComparator;
  if (prior is LocalFileComparator) {
    goldenFileComparator = _TolerantGoldenComparator(prior.basedir);
  }
  await testMain();
}

class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(Uri baseDir)
      : super(baseDir.resolve('flutter_test_config.dart'));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _goldenTolerance) return true;
    await generateFailureOutput(result, golden, basedir);
    return false;
  }
}
