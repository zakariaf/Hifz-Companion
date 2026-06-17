// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// A placeholder immutable value type proving the `models` package compiles and
/// its barrel resolves.
///
/// It carries no domain fields — the real value types (Card, Grade,
/// CycleConfig, ReviewResult), each `@immutable` with `final` fields and a
/// `const` constructor, are authored in E03. As a fieldless `const` value it is
/// equal to every other instance by canonicalization, which is all the stub
/// test needs.
@immutable
class ModelsPlaceholder {
  /// Creates the placeholder value.
  const ModelsPlaceholder();
}
