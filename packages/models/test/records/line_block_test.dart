// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  const block = LineBlock(
    blockId: BlockId('block-1'),
    profileId: ProfileId('profile-1'),
    pageId: 42,
    lineStart: 4,
    lineEnd: 9,
    errorCount: 3,
  );

  group('LineBlock fields', () {
    test('it stores only line numbers and a stumble count (no Quran text)', () {
      expect(block.lineStart, 4);
      expect(block.lineEnd, 9);
      expect(block.errorCount, 3);
      expect(block.pageId, 42);
    });

    test('errorCount defaults to 0', () {
      const fresh = LineBlock(
        blockId: BlockId('b'),
        profileId: ProfileId('p'),
        pageId: 1,
        lineStart: 1,
        lineEnd: 15,
      );
      expect(fresh.errorCount, 0);
    });
  });

  group('LineBlock.copyWith', () {
    test('copyWith() with no args preserves every field', () {
      expect(block.copyWith(), block);
    });

    test('copyWith(errorCount:) changes only the count', () {
      final bumped = block.copyWith(errorCount: 4);
      expect(bumped.errorCount, 4);
      expect(bumped.blockId, block.blockId);
      expect(bumped.lineStart, block.lineStart);
      expect(bumped.lineEnd, block.lineEnd);
    });

    test('two blocks with equal fields are value-equal', () {
      const twin = LineBlock(
        blockId: BlockId('block-1'),
        profileId: ProfileId('profile-1'),
        pageId: 42,
        lineStart: 4,
        lineEnd: 9,
        errorCount: 3,
      );
      expect(twin, block);
      expect(twin.hashCode, block.hashCode);
    });
  });
}
