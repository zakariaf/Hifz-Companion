// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The WCAG 2.2 AA contrast audit (design-system 03 §7), re-derived from the LIVE
// ColorSchemes + MihrabColors E06-T03 ships — never the printed numbers. Fails
// closed: any audited pair below its floor, or an appearance missing an audited
// cell, fails the build. Sepia/Night are measured from their own values, never
// inherited. `flutter_test`, fast lane, no pixels (this is not a golden).

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_setup.dart';

const _textFloor = 4.5; // SC 1.4.3 normal text / accent
const _graphicalFloor = 3.0; // SC 1.4.11 graphical anchor

enum _Kind { textAccent, anchor, atmosphere, ornament }

typedef _Resolve = Color Function(ColorScheme scheme, MihrabColors colors);

class _Case {
  const _Case(this.appearance, this.label, this.fg, this.bg, this.kind);
  final MihrabAppearance appearance;
  final String label;
  final _Resolve fg;
  final _Resolve bg;
  final _Kind kind;

  double get ratio {
    final scheme = colorSchemeFor(appearance);
    final colors = mihrabColorsFor(appearance);
    return contrastRatio(fg(scheme, colors), bg(scheme, colors));
  }
}

// Resolvers read the live tokens through the typed API — no re-typed hex.
Color _surface(ColorScheme s, MihrabColors c) => s.surface;
Color _container(ColorScheme s, MihrabColors c) => s.surfaceContainer;
Color _onSurface(ColorScheme s, MihrabColors c) => s.onSurface;
Color _onSurfaceVariant(ColorScheme s, MihrabColors c) => s.onSurfaceVariant;
Color _primary(ColorScheme s, MihrabColors c) => s.primary;
Color _onPrimary(ColorScheme s, MihrabColors c) => s.onPrimary;
Color _tertiary(ColorScheme s, MihrabColors c) => c.textTertiary;
Color _warning(ColorScheme s, MihrabColors c) => c.semanticWarning;
Color _gold(ColorScheme s, MihrabColors c) => c.accentGold;
Color _strong(ColorScheme s, MihrabColors c) => c.heatmapStrong;

const _all = MihrabAppearance.values;
const _lightDark = [MihrabAppearance.light, MihrabAppearance.dark];

final List<_Case> _registry = [
  // text/accent ≥ 4.5:1 (03 §7 Core table).
  for (final a in _all)
    _Case(a, 'text.primary/bg', _onSurface, _surface, _Kind.textAccent),
  for (final a in _lightDark)
    _Case(a, 'primary/container', _onSurface, _container, _Kind.textAccent),
  for (final a in _all)
    _Case(a, 'secondary/bg', _onSurfaceVariant, _surface, _Kind.textAccent),
  for (final a in _lightDark)
    _Case(a, 'text.tertiary/bg', _tertiary, _surface, _Kind.textAccent),
  for (final a in _all)
    _Case(a, 'accent.green/bg', _primary, _surface, _Kind.textAccent),
  for (final a in _lightDark)
    _Case(a, 'text.on-accent/accent', _onPrimary, _primary, _Kind.textAccent),
  for (final a in _lightDark)
    _Case(a, 'semantic.warning/bg', _warning, _surface, _Kind.textAccent),
  // heat-map anchor ≥ 3:1 in every appearance.
  for (final a in _all)
    _Case(a, 'heatmap.strong/bg', _strong, _surface, _Kind.anchor),
  // heat-map atmosphere steps — below the anchor by design (number+label carry
  // the value; colour is never the sole channel). Asserted < the strong anchor,
  // not a blanket <3 (Dark `good` legitimately clears 3:1 on the off-black bg).
  for (final a in _lightDark)
    for (final entry in <(String, _Resolve)>[
      ('heatmap.good', (s, c) => c.heatmapGood),
      ('heatmap.fair', (s, c) => c.heatmapFair),
      ('heatmap.weak', (s, c) => c.heatmapWeak),
      ('heatmap.faded', (s, c) => c.heatmapFaded),
    ])
      _Case(a, '${entry.$1}/bg', entry.$2, _surface, _Kind.atmosphere),
  // the muted gold ornament accent (Mihrab amendment) — a visible graphical
  // mark, audited ≥3:1 against the surface in every appearance.
  for (final a in _all)
    _Case(a, 'accent.gold/bg', _gold, _surface, _Kind.ornament),
];

void main() {
  useOfflineTestPolicy();

  group('relativeLuminance / contrastRatio match WCAG worked examples', () {
    test('white=1, black=0, grey≈0.2158, white:black≈21', () {
      expect(relativeLuminance(const Color(0xFFFFFFFF)), closeTo(1.0, 1e-6));
      expect(relativeLuminance(const Color(0xFF000000)), closeTo(0.0, 1e-6));
      expect(relativeLuminance(const Color(0xFF808080)), closeTo(0.2159, 2e-3));
      expect(
        contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF000000)),
        closeTo(21.0, 1e-3),
      );
    });
  });

  group('text/accent pairs clear 4.5:1 in every appearance', () {
    for (final c in _registry.where((c) => c.kind == _Kind.textAccent)) {
      test('${c.appearance.name}: ${c.label}', () {
        expect(
          c.ratio,
          greaterThanOrEqualTo(_textFloor),
          reason: '${c.appearance.name} ${c.label} = ${c.ratio}',
        );
      });
    }
  });

  group('heat-map anchor clears 3:1; atmosphere stays below the anchor', () {
    for (final c in _registry.where((c) => c.kind == _Kind.anchor)) {
      test('${c.appearance.name}: ${c.label} ≥ 3:1', () {
        expect(c.ratio, greaterThanOrEqualTo(_graphicalFloor));
      });
    }
    for (final a in _lightDark) {
      final anchor = _registry
          .firstWhere((c) => c.appearance == a && c.kind == _Kind.anchor)
          .ratio;
      for (final c in _registry
          .where((c) => c.appearance == a && c.kind == _Kind.atmosphere)) {
        test('${a.name}: ${c.label} stays below the strong anchor', () {
          expect(c.ratio, lessThan(anchor));
        });
      }
    }
  });

  group('the gold ornament mark clears the 3:1 graphical floor', () {
    for (final c in _registry.where((c) => c.kind == _Kind.ornament)) {
      test('${c.appearance.name}: ${c.label}', () {
        expect(c.ratio, greaterThanOrEqualTo(_graphicalFloor));
      });
    }
  });

  group('Sepia/Night are measured independently (not inherited)', () {
    test('Sepia bg.primary differs from Light, so its ratios are its own', () {
      expect(
        colorSchemeFor(MihrabAppearance.sepia).surface,
        isNot(colorSchemeFor(MihrabAppearance.light).surface),
      );
    });
    test('Night bg.primary differs from Dark', () {
      expect(
        colorSchemeFor(MihrabAppearance.night).surface,
        isNot(colorSchemeFor(MihrabAppearance.dark).surface),
      );
    });
  });

  group('cross-check vs 03 §7 quoted ratios (sanity, non-gating)', () {
    double ratioOf(MihrabAppearance a, _Resolve fg, _Resolve bg) {
      final s = colorSchemeFor(a);
      final c = mihrabColorsFor(a);
      return contrastRatio(fg(s, c), bg(s, c));
    }

    test('representative cells track the prose within ±0.1', () {
      const light = MihrabAppearance.light;
      const dark = MihrabAppearance.dark;
      final cells = <(MihrabAppearance, _Resolve, _Resolve, double)>[
        (light, _onSurface, _surface, 15.05),
        (light, _primary, _surface, 5.61),
        (dark, _primary, _surface, 8.77),
        (light, _strong, _surface, 4.59),
      ];
      for (final cell in cells) {
        expect(ratioOf(cell.$1, cell.$2, cell.$3), closeTo(cell.$4, 0.1));
      }
    });
  });

  group('registry completeness — no audited cell missing, no role unaudited',
      () {
    test('each appearance carries its expected audited-cell count', () {
      int countFor(MihrabAppearance a) =>
          _registry.where((c) => c.appearance == a).length;
      // Light/Dark: 7 text/accent + 1 anchor + 4 atmosphere + 1 gold = 13.
      // Sepia/Night: 3 text/accent (primary, secondary, accent.green) + 1
      // anchor + 1 gold = 5 (§7 lists no container/tertiary/on-accent/warning
      // /atmosphere rows for them).
      expect(countFor(MihrabAppearance.light), 13);
      expect(countFor(MihrabAppearance.dark), 13);
      expect(countFor(MihrabAppearance.sepia), 5);
      expect(countFor(MihrabAppearance.night), 5);
    });

    test('every pinned text/accent role is audited in Light and Dark', () {
      for (final a in _lightDark) {
        final fgs = _registry
            .where((c) => c.appearance == a && c.kind == _Kind.textAccent)
            .map((c) => c.fg(colorSchemeFor(a), mihrabColorsFor(a)))
            .toSet();
        final s = colorSchemeFor(a);
        final roles = [s.onSurface, s.onSurfaceVariant, s.primary, s.onPrimary];
        for (final role in roles) {
          expect(fgs, contains(role), reason: '${a.name} role unaudited');
        }
      }
    });
  });
}
