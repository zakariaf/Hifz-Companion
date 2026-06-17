// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// Unicode First-Strong Isolate code point.
const int firstStrongIsolate = 0x2068;

/// Unicode Pop Directional Isolate code point.
const int popDirectionalIsolate = 0x2069;

/// Wraps [text] in a Unicode First-Strong Isolate (U+2068) … Pop Directional
/// Isolate (U+2069) pair so a mixed-script run renders inside RTL chrome without
/// reordering.
///
/// Stub: E09 finalizes the bidi policy (FSI/PDI placement for numerals, dates,
/// and free-text runs).
String isolate(String text) => '${String.fromCharCode(firstStrongIsolate)}$text'
    '${String.fromCharCode(popDirectionalIsolate)}';
