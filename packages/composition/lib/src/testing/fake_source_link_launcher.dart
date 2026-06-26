// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import '../source_link_launcher_provider.dart';

/// A deterministic [SourceLinkLauncher] double (E19) — it records every URL it is
/// asked to open so the offline-guard test can assert the science source link
/// routes to the system browser and triggers **no in-app network call**. It
/// imports no plugin and opens no socket.
class FakeSourceLinkLauncher implements SourceLinkLauncher {
  /// Every URL passed to [open], in order.
  final List<String> opened = <String>[];

  /// What [open] returns (default `true` — a browser was launched).
  bool launches = true;

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return launches;
  }
}
