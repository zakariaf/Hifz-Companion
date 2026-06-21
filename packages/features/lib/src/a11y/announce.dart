// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/semantics.dart' show SemanticsService;
import 'package:flutter/widgets.dart';

/// Announces a background state change to the screen reader in the active
/// locale's reading direction (design-system 09 §7) — the one place the app
/// fires `SemanticsService.announce` for state the reader would otherwise miss
/// ("catch-up plan ready", "page graded", "sign-off recorded").
///
/// [message] is **always** an already-localized `l10n.*` string, and the
/// direction is read from context (`Directionality.of`) — which resolves to
/// `TextDirection.rtl` for fa/ckb/ar — never a hardcoded `TextDirection`
/// constant. Fire it **once** per real state change (from the View after the
/// controller's future completes), never chattily and never on a timer. The
/// announce path is local OS output only: it records nothing, opens no socket,
/// and adds no microphone — the no-AI/no-audio guarantee is preserved.
///
/// (Flutter 3.35+ supersedes `SemanticsService.announce` with
/// `sendAnnouncement`; keeping the call behind this single function makes that
/// migration a one-site change.)
Future<void> announceState(BuildContext context, String message) {
  // `announce` is the single-window API; `sendAnnouncement` is the multi-window
  // successor. Hifz is single-window, and keeping the call behind this one
  // function makes the future migration a one-site change (design-system 09 §7).
  // ignore: deprecated_member_use
  return SemanticsService.announce(message, Directionality.of(context));
}
