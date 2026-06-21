// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../theme/mihrab_color_schemes.dart';

// Below this compact width five segments would clip the longer ckb labels, so
// the control reflows to a labelled radio group (reflow-not-truncate, 05 §3).
const double _compactWidthThreshold = 380;

/// The appearance preference control (design-system 02 §5) — a dumb View over
/// [AppearanceSetting] (`followSystem · light · sepia · dark · night`).
///
/// It sets no theme and reads no store: it reflects [selected] and emits
/// [onChanged]. A `SegmentedButton` when there is room, falling back to a
/// labelled radio group (same callback) when the ckb labels would overflow.
/// Labels resolve through `l10n.*`.
class AppearanceSwitcher extends StatelessWidget {
  /// Creates the switcher reflecting [selected].
  const AppearanceSwitcher({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The currently selected appearance setting.
  final AppearanceSetting selected;

  /// Called with the newly chosen setting. The widget mutates no theme/state.
  final ValueChanged<AppearanceSetting> onChanged;

  Map<AppearanceSetting, String> _labels(AppLocalizations l10n) => {
        AppearanceSetting.followSystem: l10n.appearanceFollowSystem,
        AppearanceSetting.light: l10n.appearanceLight,
        AppearanceSetting.sepia: l10n.appearanceSepia,
        AppearanceSetting.dark: l10n.appearanceDark,
        AppearanceSetting.night: l10n.appearanceNight,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = _labels(l10n);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _compactWidthThreshold) {
          return _radioGroup(context, labels);
        }
        return SegmentedButton<AppearanceSetting>(
          showSelectedIcon: false,
          segments: [
            for (final entry in labels.entries)
              ButtonSegment(value: entry.key, label: Text(entry.value)),
          ],
          selected: {selected},
          onSelectionChanged: (s) => onChanged(s.first),
        );
      },
    );
  }

  Widget _radioGroup(
    BuildContext context,
    Map<AppearanceSetting, String> labels,
  ) {
    return RadioGroup<AppearanceSetting>(
      groupValue: selected,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in labels.entries)
            RadioListTile<AppearanceSetting>(
              value: entry.key,
              title: Text(entry.value),
            ),
        ],
      ),
    );
  }
}
