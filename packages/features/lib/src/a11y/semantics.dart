// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The Hifz `Semantics` convention layer (design-system 09 §7): thin, documented
/// wrappers over Flutter's `Semantics`/`MergeSemantics`/`ExcludeSemantics` that
/// the shell and the component library apply so every surface has a known-good
/// name-role-value tree (WCAG 4.1.2). Chrome only — these helpers receive
/// already-localized strings and import nothing below the widget layer (no
/// engine, no drift, no http, no glyph layer), so they stay pure and testable.
library;

import 'package:flutter/widgets.dart';

/// Wraps [child] in a `Semantics` node with an **already-localized** [label]
/// (and optional [hint]) and a role flag, collapsing the subtree into one spoken
/// node via `MergeSemantics`.
///
/// The [label]/[hint] are always passed in already localized (`l10n.*`) — this
/// helper never performs an ARB lookup, which keeps it l10n-package-free and
/// pure. Role mapping (design-system 09 §7): a tappable control → [button] true;
/// a section title → [header] true; a static value carrier → a plain [label]
/// (Flutter's `value` is reserved for genuine value controls like a slider and
/// is not modelled here). Every icon-only control (the nav glyphs, a future
/// track chip, the teacher sign-off toggle) must be wrapped so it is never an
/// unlabeled control.
///
/// `MergeSemantics` folds the explicit label/role together with the child's own
/// gesture node (e.g. a `GestureDetector`'s tap action), so the result is a
/// single labeled, tappable node — `labeledTapTargetGuideline` passes. When the
/// visual child itself carries a `Text` whose label would duplicate [label],
/// wrap that child in [decoration] so only [label] reaches the reader.
Widget labeled({
  required String label,
  required Widget child,
  String? hint,
  bool button = false,
  bool header = false,
}) {
  return MergeSemantics(
    child: Semantics(
      label: label,
      hint: hint,
      button: button,
      header: header,
      child: child,
    ),
  );
}

/// Collapses a multi-part item — a card's title + body, a Today page-card's
/// page-number + track + decay — into **one** spoken semantics node, so a screen
/// reader reads it as a single localized phrase rather than three fragments
/// (design-system 09 §7).
///
/// The merged node's label is the composed run of the [child]'s own already-
/// localized `Text` nodes; format any number/page-reference run through
/// `numberFormatFor(locale)` and the bidi `isolate` helper before composing it,
/// so the reader voices it in order. Do not pass an explicit label here — the
/// children supply it; for a single labeled control use [labeled] instead.
Widget mergedItem({required Widget child}) => MergeSemantics(child: child);

/// Marks [child] as pure decoration the screen reader must skip — a divider, an
/// ornament, or a visual whose meaning is already carried by a sibling label
/// (design-system 09 §7). Use only for elements that carry no meaning; never
/// hide a meaningful control behind it.
Widget decoration({required Widget child}) => ExcludeSemantics(child: child);
