// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:data/data.dart' show todayFor;
import 'package:engine/engine.dart' show CalendarDate;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The injected "today" — the device's local civil day, read once at the app
/// edge and threaded through the session (07 §5).
///
/// This is the single sanctioned `DateTime.now()` in the whole scheduling
/// surface: the engine, repositories, controllers, and the day plan all receive
/// `ref.read(todayProvider)` and never read a clock themselves, which is what
/// makes the schedule reproducible on any runner in any zone ([PRD §7.12,
/// §19.3]).
///
/// It is a thin DI `Provider`, not a `Notifier`/`AsyncNotifier`: no business
/// logic, no persistence, no mutation. Read it **once** per session (e.g. into a
/// session anchor at construction) — never re-`watch` it on a clock tick, so a
/// midnight rollover cannot re-shuffle an open Today screen (07 §5). Tests and
/// previews override it with a fixed date via `overrideWithValue`.
final todayProvider = Provider<CalendarDate>(
  (ref) => todayFor(DateTime.now()),
);
