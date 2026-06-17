// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

void main() {
  useOfflineTestPolicy();

  testWidgets('motionReduced tracks MediaQuery.disableAnimations', (
    tester,
  ) async {
    Future<bool> read({required bool disabled}) async {
      late bool value;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disabled),
          child: Builder(
            builder: (context) {
              value = motionReduced(context);
              return const SizedBox();
            },
          ),
        ),
      );
      return value;
    }

    expect(await read(disabled: true), isTrue);
    expect(await read(disabled: false), isFalse);
  });
}
