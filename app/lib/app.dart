// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart'
    show
        activeProfileRecordProvider,
        displayPreferencesProvider,
        mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import 'composition/router.dart';

/// The root widget of the Hifz Companion shell.
///
/// It builds [MaterialApp.router] over the injected [routerProvider] and
/// declares the fa/ckb/ar supported-locale set (all right-to-left). The active
/// locale and theme follow the active profile's display preferences (E16): the
/// chosen language drives `locale:`, the chosen appearance drives the theme. RTL
/// still holds because every supported locale is RTL — there is no hardcoded
/// app-wide `Directionality` (engineering 12 §2). It wires only; it computes
/// nothing.
class HifzApp extends ConsumerWidget {
  /// Creates the app shell.
  const HifzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appearance = ref.watch(displayPreferencesProvider).appearance;
    final profile = ref.watch(activeProfileRecordProvider).asData?.value;
    // The user's explicit appearance choice wins over the OS light/dark setting
    // (sepia has no light/dark slot), so both theme slots carry the same theme.
    final theme = mihrabThemeFor(appearance);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: profile == null ? null : Locale(profile.locale.wireValue),
      theme: theme,
      darkTheme: theme,
      routerConfig: router,
    );
  }
}
