// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T02 — the library-wide test bootstrap every E10 widget/golden suite calls:
// the throwing-HttpOverrides offline guard (a stray socket is a loud, named
// failure, not a silent 400) and the real bundled UI font loader (never Ahem —
// the epic exercises Sorani extra letters and the locale digit blocks). Building
// the themes and loading the bundled fonts is the only IO any E10 suite does.

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;

export '../test_setup.dart' show useOfflineTestPolicy;

File _vazirmatnFile(String weight) {
  // flutter test's CWD is the repo root or the package dir depending on the
  // invocation; try both anchors for the bundled face.
  for (final base in const ['app/assets/fonts', '../../app/assets/fonts']) {
    final file = File('$base/Vazirmatn-$weight.ttf');
    if (file.existsSync()) return file;
  }
  throw StateError('Vazirmatn-$weight.ttf not found from ${Directory.current}');
}

/// Loads the real bundled Vazirmatn UI face (Regular/Medium/SemiBold/Bold) and
/// MaterialIcons so the fa/ckb/ar goldens shape genuinely (Sorani extra letters
/// پ چ ژ ڤ ک گ ڕ ڵ ۆ ێ ە ھ and the Persian/Arabic digit blocks) and the
/// affordance icons draw as real glyphs — never Ahem (epic DoD). The single font
/// entry point every E10 golden suite calls in `setUpAll`.
Future<void> loadMihrabUiFonts() async {
  final loader = FontLoader('Vazirmatn');
  for (final weight in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = await _vazirmatnFile(weight).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();

  // MaterialIcons is not auto-bundled by flutter_test; load it from the Flutter
  // cache beside the running Dart SDK (works locally and on CI).
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    final font = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (font.existsSync()) {
      final bytes = await font.readAsBytes();
      await (FontLoader('MaterialIcons')
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
      return;
    }
    dir = dir.parent;
  }
}
