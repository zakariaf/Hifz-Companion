// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:models/models.dart';

import 'test_setup.dart';

void main() {
  // The manifest is a binary-baked constant; nothing here touches the network.
  useOfflineTestPolicy();

  final core = EmbeddedManifest.core;

  group('core manifest coverage', () {
    test('enumerates text + layout + mutashābihāt + 604 fonts = 607 files', () {
      expect(core.files.length, 607);
    });

    test('includes the text, layout, and mutashābihāt entries by name', () {
      final names = core.files.map((e) => e.name).toSet();
      expect(
        names,
        containsAll(<String>{
          'quran-uthmani.db',
          'layout-qul.json',
          'mutashabihat.json',
        }),
      );
    });

    test('covers fonts QCF_P001.ttf … QCF_P604.ttf with no gaps or dupes', () {
      final fontNames = core.files
          .map((e) => e.name)
          .where((n) => n.startsWith('QCF_P'))
          .toList();
      expect(fontNames.length, 604);
      expect(fontNames.toSet().length, 604, reason: 'no duplicates');
      expect(fontNames.first, 'QCF_P001.ttf');
      expect(fontNames.last, 'QCF_P604.ttf');
      // No gaps: every page 1..604 is present exactly once.
      for (var page = 1; page <= 604; page++) {
        final expected = 'QCF_P${page.toString().padLeft(3, '0')}.ttf';
        expect(fontNames, contains(expected));
      }
    });
  });

  group('core manifest attribution invariant (R2 lawful redistribution)', () {
    test('every entry records a non-empty source and license', () {
      for (final entry in core.files) {
        expect(entry.source, isNotEmpty, reason: 'source for ${entry.name}');
        expect(entry.license, isNotEmpty, reason: 'license for ${entry.name}');
      }
    });

    test('text/layout/font sources are the authoritative upstreams', () {
      ManifestEntry byName(String name) =>
          core.files.firstWhere((e) => e.name == name);
      expect(byName('quran-uthmani.db').source, 'tanzil.net');
      expect(byName('layout-qul.json').source, 'qul.tarteel.ai');
      expect(byName('QCF_P001.ttf').source, 'kfgqpc');
    });
  });

  group('cross-artifact consistency (no wrong-edition swap)', () {
    test('manifest mushafId matches the default edition', () {
      expect(core.mushafId, kKfgqpcHafsMadaniV2Edition.mushafId);
    });

    test('manifest tag matches the pinned pack coordinates', () {
      expect(core.tag, PackCoordinates.pinnedTag);
    });

    test('buildCoreManifest tracks the edition pageCount (no hardcoded 604)',
        () {
      final small = MushafEdition(
        mushafId: 'tiny',
        riwayah: 'r',
        displayName: 'd',
        pageCount: 2,
        lineCount: 15,
        textSha256: '',
        layoutSha256: '',
        fontSha256: const {1: '', 2: ''},
      );
      final manifest = buildCoreManifest(small);
      // text + layout + mutashābihāt + 2 fonts.
      expect(manifest.files.length, 5);
      expect(manifest.mushafId, 'tiny');
      expect(
        manifest.files.where((e) => e.name.startsWith('QCF_P')).length,
        2,
      );
    });
  });

  group('core manifest immutability', () {
    test('the files list cannot be mutated', () {
      expect(
        () => core.files.add(
          const ManifestEntry(
            name: 'x',
            sha256: '',
            bytes: 0,
            source: 's',
            license: 'l',
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
