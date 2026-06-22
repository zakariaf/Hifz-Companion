// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

@Tags(['golden'])
library;

// E10-T07 — the generic SettingsPicker across fa/ckb/ar × the four appearances +
// 200% reflow: a calendar specimen with a T01-rendered date and a muṣḥaf-riwāyah
// specimen, proving the neutral selected styling + locale numerals. Linux lane.

import 'package:engine/engine.dart' show CalendarDate;
import 'package:features/features.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import '../../support/golden_matrix.dart';
import '../../support/offline_test_bootstrap.dart';

ComponentStateMatrix _matrix() => ComponentStateMatrix(
      component: 'settings_picker',
      specimens: [
        ComponentSpecimen(
          name: 'calendar',
          build: (context) {
            final locale = Localizations.localeOf(context);
            final date = CalendarDate.ymd(2026, 6, 16);
            return SettingsPicker<CalendarSystem>(
              selected: CalendarSystem.jalali,
              onSelected: (_) {},
              options: [
                SettingsOption(
                  value: CalendarSystem.jalali,
                  label: CalendarPresenter(CalendarSystem.jalali, locale)
                      .format(date),
                ),
                SettingsOption(
                  value: CalendarSystem.hijriUmmAlQura,
                  label:
                      CalendarPresenter(CalendarSystem.hijriUmmAlQura, locale)
                          .format(date),
                ),
                SettingsOption(
                  value: CalendarSystem.gregorian,
                  label: CalendarPresenter(CalendarSystem.gregorian, locale)
                      .format(date),
                ),
              ],
            );
          },
        ),
        ComponentSpecimen(
          name: 'mushaf_riwayah',
          build: (context) {
            final l10n = AppLocalizations.of(context);
            return SettingsPicker<String>(
              selected: 'hafs',
              onSelected: (_) {},
              options: [
                SettingsOption(value: 'hafs', label: l10n.mushafRiwayahLabel),
              ],
            );
          },
        ),
      ],
    );

void main() {
  useOfflineTestPolicy();
  setUpAll(loadMihrabUiFonts);

  testWidgets('settings picker across locale × appearance', (tester) async {
    await pumpComponentMatrix(tester, matrix: _matrix());
  });
}
