// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

import 'page_geometry.dart';

/// A placeholder muṣḥaf page widget. It renders no Quran glyph yet — the
/// immutable per-page KFGQPC glyph rendering (PRD R1) is authored in E05. It
/// takes its [geometry] as a plain value type, keeping `quran` free of any local
/// package dependency.
class QuranPagePlaceholder extends StatelessWidget {
  /// Creates the placeholder page for the given [geometry].
  const QuranPagePlaceholder({required this.geometry, super.key});

  /// The page geometry this placeholder would render.
  final PageGeometry geometry;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
