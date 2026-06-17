// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('engine golden vectors', () {
    // The vector-shaped slot E04's frozen (state, grade, elapsed) ->
    // (D, S, due) rows drop into. Float assertions use closeTo(_, 1e-6),
    // never == on doubles; "today" (when it arrives) is a constructed literal.
    test('frozen stability placeholder matches its golden value', () {
      expect(frozenStabilityPlaceholder(), closeTo(1.0, 1e-6));
    });
  });
}
