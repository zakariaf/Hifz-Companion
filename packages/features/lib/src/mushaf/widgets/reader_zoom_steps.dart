// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../mushaf_reader_state.dart';

/// The discrete zoom band the reader's `−`/`+` control steps through — each step
/// a named, repeatable choice (never a continuous "fit to width" slider). The
/// band stays within `[kReaderMinZoom, kReaderMaxZoom]` (E13-T02); `1.0` fits the
/// page. Zoom is the muṣḥaf's own uniform scale, independent of OS text-scale.
const List<double> kReaderZoomSteps = <double>[
  kReaderMinZoom, // 1.0 — the page fits
  1.25,
  1.5,
  2.0,
  2.5,
  3.0,
];

/// The band value at or just above [zoom] stepped one notch toward [zoomIn]
/// (`+`) or away (`−`); returns the same value at the band's end (a no-op step).
double steppedZoom(double zoom, {required bool zoomIn}) {
  final index = _nearestIndex(zoom);
  final next = zoomIn ? index + 1 : index - 1;
  if (next < 0 || next >= kReaderZoomSteps.length) return kReaderZoomSteps[index];
  return kReaderZoomSteps[next];
}

/// Whether [zoom] is already at the band's maximum (so `+` is a no-op).
bool isMaxZoom(double zoom) =>
    _nearestIndex(zoom) == kReaderZoomSteps.length - 1;

/// Whether [zoom] is already at the band's minimum (so `−` is a no-op).
bool isMinZoom(double zoom) => _nearestIndex(zoom) == 0;

int _nearestIndex(double zoom) {
  var best = 0;
  var bestDelta = (kReaderZoomSteps[0] - zoom).abs();
  for (var i = 1; i < kReaderZoomSteps.length; i++) {
    final delta = (kReaderZoomSteps[i] - zoom).abs();
    if (delta < bestDelta) {
      best = i;
      bestDelta = delta;
    }
  }
  return best;
}
