// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// One of the two sanctioned manual-`Directionality` islands (engineering 12
/// §2): a pure-Latin technical token — a version string, a backup file's
/// SHA-256 hex, an asset-pack id — forced LTR *as a whole island* so it does not
/// visually scramble inside the app's RTL chrome.
///
/// This is NOT bidi isolation: the token stands alone and is Latin-only, so it
/// is wrapped wholesale in `Directionality(TextDirection.ltr)`. A mixed run (a
/// number beside RTL words) is the bidi helper's job (`bidi.dart`), never this.
class ForcedLtrText extends StatelessWidget {
  /// Wraps a pure-Latin technical [token] in a forced-LTR island.
  const ForcedLtrText(this.token, {this.style, this.textAlign, super.key});

  /// The pure-Latin technical token (e.g. `1.2.0+build`, a SHA-256 hex).
  final String token;

  /// Optional text style, passed through to the inner [Text].
  final TextStyle? style;

  /// Optional alignment, passed through to the inner [Text].
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text(token, style: style, textAlign: textAlign),
      );
}
