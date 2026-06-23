// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// The silent welcome-back (ui-empty-state §1; CLAIMS C-042/C-043): after a gap
/// with **nothing to catch up on**, the app resumes straight into the ordinary
/// day and **greets nothing**. This wrapper is the explicit *absence* of a
/// greeting — it renders [child] (the ordinary all-done or populated body)
/// unchanged and adds no "Welcome back, N days" / streak-reset / "you're behind"
/// chrome. (The gap-with-a-backlog case is the catch-up banner, E12-T05.)
class TodaySilentResume extends StatelessWidget {
  /// Wraps the ordinary day [child] with no welcome-back chrome.
  const TodaySilentResume({required this.child, super.key});

  /// The ordinary day body to resume into, unchanged.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
