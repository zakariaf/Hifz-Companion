// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'placeholder_view_model.dart';

/// The feature-scoped provider for the placeholder feature — scoped, never
/// global. The only global composition root is `app/composition/providers.dart`.
final placeholderViewModelProvider =
    NotifierProvider<PlaceholderViewModel, PlaceholderState>(
  PlaceholderViewModel.new,
);
