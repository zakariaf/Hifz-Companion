// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E18-T10: every reminder string passes the calm voice gate in ALL three locales —
// non-empty, no exclamation, no emoji, no ASCII digit (locale numerals only). The
// full per-locale never-ship scan (mandate / guilt-fear-loss / safe-to-drop /
// commercial, incl. fa باید · ar يجب عليك · ckb دەبێت) runs over every ARB value in
// CI via tool/check_adab_lint.dart; this locks the reminder surface explicitly,
// including the notification bodies (daily + catch-up) that no widget renders.

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart' show AppLocalizations;

// The check_adab_lint emoji ranges (variation selectors + symbols + pictographs);
// em-dash (U+2014) and locale digits sit deliberately outside them.
bool _hasEmoji(String s) => s.runes.any(
      (r) =>
          (r >= 0x2600 && r <= 0x27BF) ||
          (r >= 0x2B00 && r <= 0x2BFF) ||
          (r >= 0xFE00 && r <= 0xFE0F) ||
          (r >= 0x1F000 && r <= 0x1FAFF),
    );

void main() {
  for (final code in const ['ar', 'fa', 'ckb']) {
    test('reminder copy is calm in $code', () async {
      final l = await AppLocalizations.delegate.load(Locale(code));
      final strings = <String, String>{
        'settingsSectionReminders': l.settingsSectionReminders,
        'reminderToggleLabel': l.reminderToggleLabel,
        'reminderTimeLabel': l.reminderTimeLabel,
        'reminderCatchUpNoteLabel': l.reminderCatchUpNoteLabel,
        'reminderHonestLine': l.reminderHonestLine,
        'reminderNotificationBody': l.reminderNotificationBody,
        'reminderCatchUpBody': l.reminderCatchUpBody,
        'reminderPermissionDeniedNote': l.reminderPermissionDeniedNote,
      };
      strings.forEach((key, s) {
        expect(s.trim(), isNotEmpty, reason: '$code/$key is empty');
        expect(
          s.contains('!') || s.contains('！'),
          isFalse,
          reason: '$code/$key carries an exclamation',
        );
        expect(_hasEmoji(s), isFalse, reason: '$code/$key carries an emoji');
        expect(
          RegExp(r'[0-9]').hasMatch(s),
          isFalse,
          reason: '$code/$key carries an ASCII digit (use locale numerals)',
        );
      });
    });
  }
}
