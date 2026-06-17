// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// Placeholder muṣḥaf page geometry — the line/word rectangles a page is drawn
/// from, received as a plain value type so the renderer needs no local package
/// dependency. The real geometry (from the fixed QUL layout dataset, never
/// recomputed) is authored in E05.
@immutable
class PageGeometry {
  /// Creates page geometry for the given 1-based muṣḥaf [pageNumber].
  const PageGeometry({required this.pageNumber});

  /// The 1-based muṣḥaf page number this geometry describes.
  final int pageNumber;
}
