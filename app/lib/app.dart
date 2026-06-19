// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:features/features.dart' show MihrabAppearance, mihrabThemeFor;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';

import 'composition/router.dart';

/// The root widget of the Hifz Companion shell.
///
/// It builds [MaterialApp.router] over the injected [routerProvider], declares
/// the fa/ckb/ar supported-locale set (all right-to-left), and forces
/// [TextDirection.rtl] by construction from that all-RTL set — direction is
/// never set per widget. It wires only; it computes nothing.
class HifzApp extends ConsumerWidget {
  /// Creates the app shell.
  const HifzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: hifzLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: mihrabThemeFor(MihrabAppearance.light),
      darkTheme: mihrabThemeFor(MihrabAppearance.dark),
      routerConfig: router,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
