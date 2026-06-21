// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// The RTL languages whose script direction is right-to-left. Used only to give
/// the [LanguagePreview] island the *previewed* locale's direction; app-wide
/// direction is never computed from this list (it comes from the active locale
/// via `GlobalWidgetsLocalizations`).
const Set<String> _rtlLanguageCodes = <String>{
  'ar',
  'fa',
  'ckb',
  'he',
  'iw',
  'ur',
  'ps',
  'sd',
  'ug',
  'yi',
};

/// The text direction of [locale], from its language subtag.
TextDirection directionForLocale(Locale locale) =>
    _rtlLanguageCodes.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;

/// The second sanctioned manual-`Directionality` island (engineering 12 §2): a
/// Settings language-picker preview that renders [sampleText] in the
/// *previewed* locale's direction ([previewLocale]) — NOT the ambient app
/// direction — so previewing a (hypothetical) LTR locale shows LTR even while
/// the app itself is RTL. The hosting Settings screen is E16's; this is the
/// reusable island.
class LanguagePreview extends StatelessWidget {
  /// Previews [sampleText] in [previewLocale]'s own script direction.
  const LanguagePreview({
    required this.sampleText,
    required this.previewLocale,
    this.style,
    super.key,
  });

  /// The sample copy shown in the previewed locale.
  final String sampleText;

  /// The locale being previewed — its direction governs this island, not the
  /// ambient one.
  final Locale previewLocale;

  /// Optional text style, passed through to the inner [Text].
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: directionForLocale(previewLocale),
        child: Text(sampleText, style: style),
      );
}
