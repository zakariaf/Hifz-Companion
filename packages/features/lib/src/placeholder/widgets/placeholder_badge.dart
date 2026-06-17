// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// A leaf presentation widget for the placeholder feature, reserving the
/// `widgets/` folder in the feature anatomy. Presentation only — no state, no
/// logic. Real leaf widgets are authored in the feature epics.
class PlaceholderBadge extends StatelessWidget {
  /// Creates the placeholder badge.
  const PlaceholderBadge({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
