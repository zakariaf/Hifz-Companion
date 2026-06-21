// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The single bidi-isolation helper for all of Hifz Companion's CHROME (design
/// 12 §3; engineering 12 §4). Every mixed-script chrome run — a page number,
/// "Juz N", a surah name beside RTL copy, a date, a percentage, a user-typed
/// profile name, a version string — is wrapped through one of these functions so
/// it cannot reorder its line ("page 7 of 30" must never render "30 of 7", which
/// is a visual *and* a screen-reader-order bug).
///
/// Uses Unicode *isolates* (FSI/LRI/RLI … PDI per UAX #9), never the legacy
/// embeddings/overrides (LRE/RLE/LRO/RLO), which do not isolate the run from its
/// surroundings. Each function only prepends one initiator and appends one PDI;
/// the inner run is preserved byte-for-byte and the localized sentence stays a
/// single `Text`/`TextSpan` (fragmenting an Arabic-script word clips diacritics).
///
/// CHROME-ONLY: muṣḥaf glyph runs come pre-shaped from the immutable glyph layer
/// (E05 / domain-mushaf-text-integrity) and are NEVER passed through this helper
/// — no bidi control ever reaches a glyph of the page (design 12 §8). There is
/// no muṣḥaf import reachable from this package, so the refusal is structural.
library;

import 'package:flutter/foundation.dart' show Unicode;
import 'package:intl/intl.dart' show Bidi;

/// Wraps a run of *unknown* direction in a First-Strong Isolate (FSI … PDI).
///
/// Prefer [isolateLtr]/[isolateRtl] when the direction is known: FSI guesses
/// direction from the first strong character, so a run that opens with the
/// "wrong" script — an Arabic string led by an ASCII quote — is mis-detected.
String isolate(String run) => '${Unicode.FSI}$run${Unicode.PDI}';

/// Wraps a known left-to-right run in a Left-to-Right Isolate (LRI … PDI) — for
/// a Latin technical token or a locale-numeral string meant to read LTR inside
/// RTL copy. Preferred over [isolate] because it does not depend on first-strong
/// detection.
String isolateLtr(String run) => '${Unicode.LRI}$run${Unicode.PDI}';

/// Wraps a known right-to-left run in a Right-to-Left Isolate (RLI … PDI).
/// Preferred over [isolate] because it does not depend on first-strong detection.
String isolateRtl(String run) => '${Unicode.RLI}$run${Unicode.PDI}';

/// Isolates a run whose direction must be DETECTED at runtime (e.g. a user-typed
/// profile name or a backup filename that may be either script), choosing the
/// known-direction isolate from the run's content via [Bidi.hasAnyRtl] — more
/// robust than [isolate]'s first-strong guess on a run with leading punctuation.
String isolateAuto(String run) =>
    _isRtl(run) ? isolateRtl(run) : isolateLtr(run);

/// Whether [s] contains any right-to-left character — the seam [isolateAuto]
/// uses to choose [isolateRtl] vs [isolateLtr]. Private: direction detection is
/// not exposed; call sites choose an explicit isolate or [isolateAuto].
bool _isRtl(String s) => Bidi.hasAnyRtl(s);
