// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../shell/section_placeholder.dart';

/// The Today tab. An inert placeholder for the walking skeleton — replaced
/// wholesale by the real `buildToday` queue (View + `AsyncNotifier`) in
/// E07-T07/T08.
class TodayScreen extends StatelessWidget {
  /// Creates the Today placeholder.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) => SectionPlaceholder(
        title: AppLocalizations.of(context)!.navToday,
        identifier: 'screen.today',
      );
}
