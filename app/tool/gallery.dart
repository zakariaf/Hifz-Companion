// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// The dev-only "Mihrab gallery": every design token and every component on one
// scrolling screen, with live appearance × locale switching, so the look can be
// tuned on-device. It is NOT a shipped screen — run it explicitly from app/:
//
//     flutter run -t tool/gallery.dart
//
// It lives outside lib/ on purpose: it is developer tooling, so its inline
// English labels are exempt from the l10n gate and its raw swatch sizes are
// exempt from the token-discipline gate (both scope to lib/). Colours, spacing,
// type and motion are all READ from the Mihrab tokens — nothing is hardcoded.

import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

void main() => runApp(const GalleryApp());

String _hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

/// The dev gallery shell: holds the live appearance + locale and forces RTL
/// (every supported locale is RTL), exactly like the real app shell.
class GalleryApp extends StatefulWidget {
  /// Creates the gallery app.
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  MihrabAppearance _appearance = MihrabAppearance.light;
  Locale _locale = const Locale('fa');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mihrabThemeFor(_appearance),
      locale: _locale,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: _Home(
        appearance: _appearance,
        locale: _locale,
        onAppearance: (a) => setState(() => _appearance = a),
        onLocale: (l) => setState(() => _locale = l),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.appearance,
    required this.locale,
    required this.onAppearance,
    required this.onLocale,
  });

  final MihrabAppearance appearance;
  final Locale locale;
  final ValueChanged<MihrabAppearance> onAppearance;
  final ValueChanged<Locale> onLocale;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Mihrab gallery')),
      body: ListView(
        padding: EdgeInsets.all(space.space4),
        children: [
          _Switchers(
            appearance: appearance,
            locale: locale,
            onAppearance: onAppearance,
            onLocale: onLocale,
          ),
          SizedBox(height: space.space5),
          _Section(title: 'Colours', child: _Colours(appearance: appearance)),
          const _Section(title: 'Spacing scale', child: _Spacing()),
          const _Section(title: 'Type ramp', child: _TypeRamp()),
          const _Section(title: 'Components', child: _Components()),
          const _Section(
            title: 'Motion — tap to turn the page',
            child: _MotionDemo(),
          ),
        ],
      ),
    );
  }
}

/// Two chip rows: pick the appearance and the locale, live.
class _Switchers extends StatelessWidget {
  const _Switchers({
    required this.appearance,
    required this.locale,
    required this.onAppearance,
    required this.onLocale,
  });

  final MihrabAppearance appearance;
  final Locale locale;
  final ValueChanged<MihrabAppearance> onAppearance;
  final ValueChanged<Locale> onLocale;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: space.space2,
          children: [
            for (final a in MihrabAppearance.values)
              ChoiceChip(
                label: Text(a.name),
                selected: a == appearance,
                onSelected: (_) => onAppearance(a),
              ),
          ],
        ),
        SizedBox(height: space.space2),
        Wrap(
          spacing: space.space2,
          children: [
            for (final code in const ['fa', 'ckb', 'ar'])
              ChoiceChip(
                label: Text(code),
                selected: code == locale.languageCode,
                onSelected: (_) => onLocale(Locale(code)),
              ),
          ],
        ),
      ],
    );
  }
}

/// A titled block with a divider, used for every gallery section.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: space.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: space.space4),
          Text(title, style: text.titleSmall),
          SizedBox(height: space.space3),
          child,
        ],
      ),
    );
  }
}

/// Swatches for the ColorScheme roles and the Mihrab semantic colours.
class _Colours extends StatelessWidget {
  const _Colours({required this.appearance});

  final MihrabAppearance appearance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mc = mihrabColorsFor(appearance);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final swatches = <(String, Color)>[
      ('primary', scheme.primary),
      ('secondary', scheme.secondary),
      ('surface', scheme.surface),
      ('surfaceLow', scheme.surfaceContainerLow),
      ('onSurface', scheme.onSurface),
      ('onSurfaceVar', scheme.onSurfaceVariant),
      ('error', scheme.error),
      ('accentGold', mc.accentGold),
      ('warning', mc.semanticWarning),
      ('heat·strong', mc.heatmapStrong),
      ('heat·good', mc.heatmapGood),
      ('heat·fair', mc.heatmapFair),
      ('heat·weak', mc.heatmapWeak),
      ('heat·faded', mc.heatmapFaded),
      ('trackChip', mc.trackChipSurface),
      ('decayCalm', mc.decayCalm),
      ('textTertiary', mc.textTertiary),
    ];
    return Wrap(
      spacing: space.space2,
      runSpacing: space.space2,
      children: [
        for (final s in swatches) _Swatch(name: s.$1, color: s.$2),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ink = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      width: 104,
      height: 60,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: ink, fontSize: 11)),
          Text(_hex(color), style: TextStyle(color: ink, fontSize: 9)),
        ],
      ),
    );
  }
}

/// The space1…space8 ramp drawn to scale with its resolved dp value.
class _Spacing extends StatelessWidget {
  const _Spacing();

  @override
  Widget build(BuildContext context) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final steps = <(String, double)>[
      ('space1', space.space1),
      ('space2', space.space2),
      ('space3', space.space3),
      ('space4', space.space4),
      ('space5', space.space5),
      ('space6', space.space6),
      ('space7', space.space7),
      ('space8', space.space8),
    ];
    return Column(
      children: [
        for (final s in steps)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(width: 64, child: Text(s.$1)),
                Container(width: s.$2, height: 14, color: scheme.primary),
                const SizedBox(width: 8),
                Text('${s.$2.toStringAsFixed(0)}dp'),
              ],
            ),
          ),
      ],
    );
  }
}

/// One line per text-theme role, rendered in that role's own style.
class _TypeRamp extends StatelessWidget {
  const _TypeRamp();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final samples = <(String, TextStyle?)>[
      ('titleLarge — سرفصل', t.titleLarge),
      ('titleMedium — عنوان', t.titleMedium),
      ('bodyLarge — متن', t.bodyLarge),
      ('bodyMedium — متن', t.bodyMedium),
      ('bodySmall — یادداشت', t.bodySmall),
      ('labelLarge — برچسب', t.labelLarge),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in samples)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(s.$1, style: s.$2),
          ),
      ],
    );
  }
}

/// Live instances of the shipped components, fed real localized strings.
class _Components extends StatelessWidget {
  const _Components();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MihrabCard(
          title: l10n.navToday,
          subtitle: l10n.navProgress,
          leading: Icons.menu_book_outlined,
          onTap: () {},
        ),
        SizedBox(height: space.space3),
        MihrabCard(title: l10n.navSettings),
        SizedBox(height: space.space4),
        Wrap(
          spacing: space.space2,
          runSpacing: space.space2,
          children: [
            FilledButton(onPressed: () {}, child: Text(l10n.navMushaf)),
            OutlinedButton(onPressed: () {}, child: Text(l10n.navProgress)),
            TextButton(onPressed: () {}, child: Text(l10n.navSettings)),
          ],
        ),
        SizedBox(height: space.space4),
        AppearanceSwitcher(
          selected: AppearanceSetting.followSystem,
          onChanged: (_) {},
        ),
        SizedBox(height: space.space4),
        MihrabNavigationBar(selectedIndex: 0, onDestinationSelected: (_) {}),
      ],
    );
  }
}

/// Tap to swap two keyed surfaces through the directional page-turn.
class _MotionDemo extends StatefulWidget {
  const _MotionDemo();

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final fills = [scheme.primary, scheme.secondary, scheme.tertiary];
    final fill = fills[_page % fills.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: PageTurnTransition(
            child: Container(
              key: ValueKey(_page),
              alignment: Alignment.center,
              color: fill,
              child: Text(
                'page $_page',
                style: TextStyle(color: scheme.onPrimary),
              ),
            ),
          ),
        ),
        SizedBox(height: space.space3),
        FilledButton(
          onPressed: () => setState(() => _page++),
          child: const Text('Turn the page'),
        ),
      ],
    );
  }
}
