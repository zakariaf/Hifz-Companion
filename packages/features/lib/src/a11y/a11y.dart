// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The shared accessibility chrome conventions (E08): the `Semantics`
/// label/role/merge/exclude wrappers, the RTL announce path, the never-color-
/// alone redundant-encoding convention, and the reduce-motion substitution.
///
/// Downward-only — these helpers depend on the widget layer, the design-system
/// tokens, and l10n only; never on the engine, persistence, the network, or the
/// muṣḥaf glyph layer. The shell and (later) the component library apply them so
/// accessibility is Definition-of-Done, not a retrofit.
library;

export 'announce.dart';
export 'reduce_motion_substitution.dart';
export 'semantics.dart';
