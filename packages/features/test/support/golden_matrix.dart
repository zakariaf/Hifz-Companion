// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T02 — the ONE reusable golden + accessibility scaffold T03–T10 call. A
// per-component test re-implementing this locale×appearance loop is a review
// reject. Goldens land at `goldens/<component>/<component>__<locale>__<appearance>.png`
// relative to the CALLING test file, so component golden suites live under
// `packages/features/test/design_system/`. Pinned-OS (Linux) golden lane only;
// masters regenerate via local `--update-goldens`, never blessed by CI.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l10n/l10n.dart';

/// The three RTL locales every component matrix renders under, each in its own
/// script (ckb is the longest transcreation — the reflow stress case).
const List<Locale> mihrabMatrixLocales = [
  Locale('fa'),
  Locale('ckb'),
  Locale('ar'),
];

/// Wraps [matrix]'s [ComponentGallery] in a host-less themed, localized, RTL
/// `MaterialApp` for [appearance]/[locale] — the single composed surface both
/// the golden scaffold and a developer preview render. [textScaler] applies a
/// reflow pass (e.g. 200%) below `MaterialApp`'s own `MediaQuery`.
Widget mihrabGalleryApp({
  required ComponentStateMatrix matrix,
  required MihrabAppearance appearance,
  required Locale locale,
  TextScaler? textScaler,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    localizationsDelegates: hifzLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mihrabThemeFor(appearance),
    builder: textScaler == null
        ? null
        : (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            ),
    home: ComponentGallery(matrix: matrix),
  );
}

Future<void> _pumpSurface(
  WidgetTester tester,
  Widget app,
  Size surfaceSize,
) async {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = surfaceSize * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(app);
  await tester.pump(const Duration(milliseconds: 50));
}

/// Pumps [matrix] and screenshots its full state set across fa/ckb/ar × the four
/// appearances (Light/Sepia/Dark/Night) under `Directionality.rtl` on the real
/// bundled UI fonts, plus one 200%-text-scale reflow pass per locale. Pins
/// DPR/physicalSize/theme; disables animations by settling one frame. Call
/// `loadMihrabUiFonts()` + `useOfflineTestPolicy()` first (in `setUpAll`).
Future<void> pumpComponentMatrix(
  WidgetTester tester, {
  required ComponentStateMatrix matrix,
  Size surfaceSize = const Size(390, 920),
}) async {
  for (final appearance in MihrabAppearance.values) {
    for (final locale in mihrabMatrixLocales) {
      await _pumpSurface(
        tester,
        mihrabGalleryApp(
          matrix: matrix,
          appearance: appearance,
          locale: locale,
        ),
        surfaceSize,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          'goldens/${matrix.component}/'
          '${matrix.component}__${locale.languageCode}__${appearance.name}.png',
        ),
      );
    }
  }
  // The 200% reflow-not-clip pass — one (Light) appearance per locale is enough
  // to prove the longest transcreation reflows without clipping.
  for (final locale in mihrabMatrixLocales) {
    await _pumpSurface(
      tester,
      mihrabGalleryApp(
        matrix: matrix,
        appearance: MihrabAppearance.light,
        locale: locale,
        textScaler: const TextScaler.linear(2),
      ),
      surfaceSize,
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        'goldens/${matrix.component}/'
        '${matrix.component}__${locale.languageCode}__x2.png',
      ),
    );
  }
}

/// Runs the WCAG 2.2 release-gate guideline set (design-system 09 §10) over the
/// pumped tree — the single helper T03–T10 and T10's aggregate gate call instead
/// of re-deriving per task. Enable semantics first (`tester.ensureSemantics()`).
Future<void> meetsLibraryGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

/// A color-independence check (WCAG 1.4.1): asserts every signal in [labels] and
/// every glyph in [icons] is present, so the component's meaning survives a
/// grayscale/deuteranope render — carried by the redundant text + shape
/// encoding, never color alone. T03/T04 pass their decay/track labels + glyphs.
void assertColorIndependent(
  WidgetTester tester, {
  List<String> labels = const [],
  List<IconData> icons = const [],
}) {
  for (final label in labels) {
    expect(
      find.text(label),
      findsWidgets,
      reason:
          'color-independent label "$label" must be present, not color-only',
    );
  }
  for (final icon in icons) {
    expect(
      find.byIcon(icon),
      findsWidgets,
      reason: 'color-independent glyph must be present, not color-only',
    );
  }
}
