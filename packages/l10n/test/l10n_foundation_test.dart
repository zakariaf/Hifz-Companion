// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

import 'test_setup.dart';

/// E09-T01 — the foundation ARB key set is the build invariant `nullable-getter:
/// false` makes load-bearing: a missing or mistyped key would not COMPILE this
/// file. The runtime cases below add per-locale resolution, the six-category
/// Arabic plural, the placeholder-not-concatenation discipline, the `select`
/// term-set swap shape, and the canonical-ckb smoke (the full lint is E09-T03).
void main() {
  useOfflineTestPolicy();

  // Every foundation getter, referenced once. The file is the standing guard:
  // delete a key from app_ar.arb and this stops compiling (PRD §20 gate 5).
  void touchFoundationKeys(AppLocalizations l10n) {
    <String>[
      l10n.appTitle,
      l10n.navToday,
      l10n.navMushaf,
      l10n.navMutashabihat,
      l10n.navProgress,
      l10n.navSettings,
      l10n.actionSave,
      l10n.actionCancel,
      l10n.actionConfirm,
      l10n.actionUndo,
      l10n.actionRetry,
      l10n.actionClose,
      l10n.actionBack,
      l10n.actionNext,
      l10n.mushafRiwayahLabel,
      l10n.juzLabel('—'),
      l10n.pagesDue(0),
      l10n.trackFar('other'),
    ];
  }

  const Locale ar = Locale('ar');
  const Locale fa = Locale('fa');
  const Locale ckb = Locale('ckb');

  group('foundation key set', () {
    test('every foundation key compiles and resolves non-empty (ar)', () async {
      final l10n = await AppLocalizations.delegate.load(ar);
      touchFoundationKeys(l10n);
      expect(l10n.appTitle, isNotEmpty);
      expect(l10n.mushafRiwayahLabel, isNotEmpty);
    });

    test('per-locale resolution: distinct, no ar/English fallback', () async {
      final arL = await AppLocalizations.delegate.load(ar);
      final faL = await AppLocalizations.delegate.load(fa);
      final ckbL = await AppLocalizations.delegate.load(ckb);

      for (final l10n in <AppLocalizations>[arL, faL, ckbL]) {
        for (final v in <String>[
          l10n.navToday,
          l10n.navSettings,
          l10n.actionSave,
          l10n.actionCancel,
          l10n.mushafRiwayahLabel,
        ]) {
          expect(v, isNotEmpty, reason: '${l10n.localeName}: empty value');
        }
      }

      // fa and ckb are transcreations, not an ar fallback: the everyday nav
      // labels differ in script across all three (a silent fallback to ar would
      // make them identical).
      expect(faL.navToday, isNot(arL.navToday));
      expect(ckbL.navToday, isNot(arL.navToday));
      expect(faL.navToday, isNot(ckbL.navToday));
      expect(faL.actionSave, isNot(arL.actionSave));
      expect(ckbL.actionSave, isNot(arL.actionSave));
    });

    test('mushafRiwayahLabel names the chrome edition, not the Quran', () async {
      // It names the riwāyah (Ḥafṣ ʿan ʿĀṣim) — never "the Quran" in the
      // absolute (design 12 §8). Proper nouns stay in Arabic script in every
      // locale; the surrounding chrome words are transcreated.
      final arL = await AppLocalizations.delegate.load(ar);
      expect(arL.mushafRiwayahLabel, contains('حفص'));
      expect(arL.mushafRiwayahLabel, contains('عاصم'));
    });
  });

  group('ICU plural — Arabic six categories', () {
    test('each count selects its correctly-inflected category (ar)', () async {
      final l10n = await AppLocalizations.delegate.load(ar);

      // zero / one / two carry no count digit; few uses the plural noun
      // (صفحات), many/other use the singular accusative form (صفحة).
      expect(l10n.pagesDue(0), contains('لا صفحات')); // zero
      expect(l10n.pagesDue(1), contains('واحدة')); // one
      expect(l10n.pagesDue(2), contains('صفحتان')); // two
      expect(l10n.pagesDue(3), contains('صفحات')); // few (3–10)
      expect(l10n.pagesDue(11), contains('صفحة')); // many (11–99)
      expect(l10n.pagesDue(11), isNot(contains('صفحات')));
      expect(l10n.pagesDue(100), contains('صفحة')); // other

      // The six categories produce genuinely distinct strings — no silent
      // collapse to a single form.
      final forms = <String>{
        l10n.pagesDue(0),
        l10n.pagesDue(1),
        l10n.pagesDue(2),
        l10n.pagesDue(3),
        l10n.pagesDue(11),
      };
      expect(forms.length, 5);
    });
  });

  group('interpolation is placeholder-shaped, not concatenated', () {
    test('juzLabel injects the passed token intact (ar/fa/ckb)', () async {
      // A sentinel proving the value is "…{juz}…", not a spliced substring: the
      // exact token round-trips inside the rendered label. Built from code
      // points (FSI · Persian ۲۳ · PDI) so no invisible directional glyph sits
      // in source — the run is what numberFormatFor/bidi.dart would hand juzLabel.
      final token = String.fromCharCodes(<int>[0x2068, 0x06F2, 0x06F3, 0x2069]);
      for (final locale in <Locale>[ar, fa, ckb]) {
        final l10n = await AppLocalizations.delegate.load(locale);
        expect(
          l10n.juzLabel(token),
          contains(token),
          reason: l10n.localeName,
        );
      }
    });
  });

  group('select term-set switches the whole vocabulary', () {
    test('trackFar resolves the branch by region key (ar)', () async {
      final l10n = await AppLocalizations.delegate.load(ar);
      expect(l10n.trackFar('subcontinent'), 'دور'); // known branch
      expect(l10n.trackFar('levant'), 'منزل');
      expect(l10n.trackFar('zzz-unknown'), 'منزل'); // falls to `other`
    });
  });

  group('canonical ckb encoding (smoke — full lint is E09-T03)', () {
    test('representative ckb values use U+06D5/U+06A9, no ZWNJ/Teh-Marbuta',
        () async {
      final l10n = await AppLocalizations.delegate.load(ckb);
      const ae = 'ە'; // ە  (the canonical Sorani AE, U+06D5)
      const kaf = 'ک'; // ک  (the canonical Sorani kaf, U+06A9)
      final zwnj = String.fromCharCode(0x200C); // banned: heh+ZWNJ AE hack
      const tehMarbuta = 'ة'; // banned: ة (U+0629) standing for AE

      // actionSave (پاشەکەوت) exercises both canonical letters.
      expect(l10n.actionSave.contains(ae), isTrue);
      expect(l10n.actionSave.contains(kaf), isTrue);

      for (final v in <String>[
        l10n.actionSave,
        l10n.actionCancel,
        l10n.actionConfirm,
        l10n.actionClose,
        l10n.mushafRiwayahLabel,
        l10n.navSettings,
      ]) {
        expect(v.contains(zwnj), isFalse, reason: 'stray ZWNJ in "$v"');
        expect(v.contains(tehMarbuta), isFalse, reason: 'Teh-Marbuta in "$v"');
      }
    });
  });
}
