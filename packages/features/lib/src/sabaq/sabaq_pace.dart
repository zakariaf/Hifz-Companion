// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:models/models.dart' show CycleConfig;

/// Whether new memorization (sabaq) is currently active for a profile, read from
/// its [CycleConfig] daily pace (E21; PRD §7.8, §15.1).
///
/// Page-granular intake is **user-driven** — the ḥāfiẓ marks a page memorized
/// when they have memorized it — so the pace is deliberately *not* an engine cap
/// on the consolidating New band (the time budget already bounds that, and a cap
/// would starve consolidation). It is an **intake** signal: a `newLinesPerDay`
/// of 0 means new memorization is paused / off — the app shows **no**
/// "start a new lesson" surface (framed as protecting what is already earned,
/// never a failure) — and any positive value means intake is active.
///
/// The pace value itself is never shown as a recommended number: no registered
/// CLAIMS row prescribes a safe new-lines/day figure (the traditional "3–5
/// lines/day" is `[TRAD]` prose, not a graded claim), so it ships opt-in at 0.
bool sabaqIntakeActive(CycleConfig config) => config.newLinesPerDay > 0;
