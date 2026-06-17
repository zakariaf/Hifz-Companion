// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:go_router/go_router.dart';

import '../placeholder/placeholder_screen.dart';

/// The app router. One route for now — the placeholder screen. The RTL
/// bottom-nav shell (Today · Muṣḥaf · Mutashābihāt · Progress · Settings, in
/// RTL order) is built in E07.
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderScreen(),
    ),
  ],
);
