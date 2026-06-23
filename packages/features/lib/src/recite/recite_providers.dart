// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recite_view_model.dart';

/// The recite view-model provider — `family`-keyed by `pageId` and `autoDispose`
/// (the flow is per-page, view-local state; eng-create-riverpod-store §5). The
/// dumb [ReciteGradeScreen] reads exactly this; tests drive it by overriding the
/// injected reader surface / recorder / clock seams, never the notifier.
final reciteControllerProvider =
    NotifierProvider.autoDispose.family<ReciteController, ReciteState, int>(
  ReciteController.new,
);
