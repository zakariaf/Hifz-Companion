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
    test('enumerates exactly the three co-versioned data files', () {
      // The 604 per-page fonts are NOT installer-manifest entries — they are
      // pinned in EmbeddedManifest.pageFontSha256 and verified one-at-a-time at
      // registration, so the installer never accumulates 200 MB of font bytes.
      expect(core.files.length, 3);
    });

    test('includes the text, layout, and word-glyph entries by name', () {
      final names = core.files.map((e) => e.name).toSet();
      expect(
        names,
        <String>{
          'quran-data.xml',
          'qpc-v2-15-lines.db',
          'qpc-v2.db',
        },
      );
    });

    test('pins every page font QCF_P001 … QCF_P604 with no gaps', () {
      expect(EmbeddedManifest.pageFontSha256.length, 604);
      for (var page = 1; page <= 604; page++) {
        expect(
          EmbeddedManifest.pageFontSha256[page],
          isNotEmpty,
          reason: 'page $page font must be pinned',
        );
        // The sanctioned font file name for that page's verification.
        expect(
          EmbeddedManifest.fontFileName(page),
          'QCF_P${page.toString().padLeft(3, '0')}.ttf',
        );
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

    test('text/layout sources are the authoritative upstreams', () {
      ManifestEntry byName(String name) =>
          core.files.firstWhere((e) => e.name == name);
      expect(byName('quran-data.xml').source, 'tanzil.net');
      expect(byName('qpc-v2-15-lines.db').source, 'qul.tarteel.ai');
      expect(byName('qpc-v2.db').source, 'qul.tarteel.ai');
    });
  });

  group('cross-artifact consistency (no wrong-edition swap)', () {
    test('manifest mushafId matches the default edition', () {
      expect(core.mushafId, kKfgqpcHafsMadaniV2Edition.mushafId);
    });

    test('manifest tag matches the pinned pack coordinates', () {
      expect(core.tag, PackCoordinates.pinnedTag);
    });

    test('buildCoreManifest binds the edition mushafId', () {
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
      // The three data files are edition-independent; only the id binds.
      expect(manifest.files.length, 3);
      expect(manifest.mushafId, 'tiny');
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
