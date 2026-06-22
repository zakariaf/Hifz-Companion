// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// E10-T02 — the shared M3 interaction-state model: state-layer overlays over the
// role color (never an ad-hoc opacity/hue), a visible focus ring (SC 2.4.7)
// that follows the component, disabled = dimmed-not-error, the Semantics flags,
// and the load-bearing adab guard that NO pressed/selected path is a reward.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/offline_test_bootstrap.dart';

const _onColor = Color(0xFF1A2B3C); // a known role on-color for the assertions

Widget _host({required Widget child, TextDirection dir = TextDirection.ltr}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: mihrabThemeFor(MihrabAppearance.light),
    home: Directionality(
      textDirection: dir,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  useOfflineTestPolicy();

  group('MihrabStateLayer overlays — M3 state layer over the role on-color',
      () {
    test('enabled and disabled add no overlay (transparent)', () {
      expect(
        MihrabStateLayer.overlayFor(MihrabInteractionState.enabled, _onColor),
        Colors.transparent,
      );
      expect(
        MihrabStateLayer.overlayFor(MihrabInteractionState.disabled, _onColor),
        Colors.transparent,
      );
    });

    test('pressed/focused/selected are the on-color at the calm M3 opacity',
        () {
      for (final (state, opacity) in const [
        (MihrabInteractionState.pressed, 0.10),
        (MihrabInteractionState.focused, 0.10),
        (MihrabInteractionState.selected, 0.10),
      ]) {
        final overlay = MihrabStateLayer.overlayFor(state, _onColor);
        // Same hue as the role's on-color — never a bespoke bright tint.
        expect(overlay.r, _onColor.r);
        expect(overlay.g, _onColor.g);
        expect(overlay.b, _onColor.b);
        // …only translucent at the M3 opacity (calm, never opaque).
        expect(overlay.a, closeTo(opacity, 1e-6));
      }
    });

    test('the WidgetStateProperty resolves the same M3 model for M3 plumbing',
        () {
      final prop = MihrabStateLayer.overlayColor(_onColor);
      expect(prop.resolve({WidgetState.pressed})!.a, closeTo(0.10, 1e-6));
      expect(prop.resolve({WidgetState.hovered})!.a, closeTo(0.08, 1e-6));
      expect(prop.resolve({WidgetState.disabled}), Colors.transparent);
      expect(prop.resolve(<WidgetState>{}), Colors.transparent);
    });

    test('disabled dims the role (waiting, not error) — no warning recolor',
        () {
      const role = Color(0xFF205030);
      final dimmed = MihrabStateLayer.dimmedRole(role);
      expect(dimmed.a, closeTo(0.38, 1e-6));
      expect(dimmed.r, role.r); // same hue, just faded
      expect(dimmed.g, role.g);
      expect(dimmed.b, role.b);
    });
  });

  group('adab guard — no pressed/selected reward tier', () {
    test('every overlay is a translucent on-color layer ≤ 0.12 alpha', () {
      // A reward surface would be an opaque/bright fill or a non-role hue; the
      // whole model is calm translucent state layers. Asserting this here means
      // a future "celebration" recolour fails a test, not just review.
      for (final state in MihrabInteractionState.values) {
        final overlay = MihrabStateLayer.overlayFor(state, _onColor);
        expect(overlay.a, lessThanOrEqualTo(0.12));
      }
    });

    testWidgets(
        'the focus ring adds no scale/transform (no celebratory motion)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          child: const MihrabFocusRing(
            child:
                Focus(autofocus: true, child: SizedBox(width: 80, height: 48)),
          ),
        ),
      );
      await tester.pump();
      // No scale/pop on focus — the ring is a flat outline, nothing animates up.
      expect(
        find.descendant(
          of: find.byType(MihrabFocusRing),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
    });
  });

  group('MihrabFocusRing — SC 2.4.7 visible ring, follows the component', () {
    testWidgets('shows a color.outline ring at the focus width when focused',
        (tester) async {
      await tester.pumpWidget(
        _host(
          child: const MihrabFocusRing(
            child:
                Focus(autofocus: true, child: SizedBox(width: 80, height: 48)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(MihrabFocusRing), findsOneWidget);
      final scheme =
          Theme.of(tester.element(find.byType(MihrabFocusRing))).colorScheme;
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(MihrabFocusRing),
          matching: find.byType(DecoratedBox),
        ),
      );
      final shape =
          (box.decoration as ShapeDecoration).shape as RoundedRectangleBorder;
      // The ring is drawn in color.outline at the WCAG focus width…
      expect(shape.side.color, scheme.outline);
      expect(shape.side.width, kMihrabFocusRingWidth);
      // …as a uniform outline (a RoundedRectangleBorder applies one side to all
      // four edges), so it follows the component and favors no physical side.
      expect(shape.side.width, greaterThanOrEqualTo(2));
    });

    testWidgets('no ring when unfocused', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const MihrabFocusRing(
            child: SizedBox(width: 80, height: 48),
          ),
        ),
      );
      await tester.pump();
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(MihrabFocusRing),
          matching: find.byType(DecoratedBox),
        ),
      );
      final shape =
          (box.decoration as ShapeDecoration).shape as RoundedRectangleBorder;
      expect(shape.side, BorderSide.none);
    });

    testWidgets('the ring is symmetric in RTL too (not pinned to a side)',
        (tester) async {
      await tester.pumpWidget(
        _host(
          dir: TextDirection.rtl,
          child: const MihrabFocusRing(
            child:
                Focus(autofocus: true, child: SizedBox(width: 80, height: 48)),
          ),
        ),
      );
      await tester.pump();
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(MihrabFocusRing),
          matching: find.byType(DecoratedBox),
        ),
      );
      // A RoundedRectangleBorder (uniform side) — not a one-sided/physical Border.
      expect(
        (box.decoration as ShapeDecoration).shape,
        isA<RoundedRectangleBorder>(),
      );
    });
  });

  group('mihrabStateSemantics — state announced non-visually (SC 4.1.2)', () {
    testWidgets('disabled clears the enabled flag', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          child: mihrabStateSemantics(
            states: const {MihrabInteractionState.disabled},
            child: const Text('x'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('x')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('selected sets the selected flag, enabled otherwise',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          child: mihrabStateSemantics(
            states: const {MihrabInteractionState.selected},
            child: const Text('y'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('y')),
        isSemantics(isSelected: true, isEnabled: true),
      );
      handle.dispose();
    });
  });

  // The offline guarantee is enforced structurally, not by a behavioral network
  // call: `useOfflineTestPolicy()` installs the throwing override and the
  // `check_no_network` gate bans every network-client / socket symbol outside
  // `packages/assets/` (and `test_setup.dart`) — so no component can open a
  // connection and a test attempting one would itself fail that gate.
}
