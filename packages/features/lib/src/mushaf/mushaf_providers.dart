// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart'
    show MushafEdition, ProfileId, kKfgqpcHafsMadaniV2Edition;

import 'mushaf_view_model.dart';

/// The active muṣḥaf edition the reader names and renders (R2). v1 ships the one
/// bundled edition — KFGQPC Ḥafṣ ʿan ʿĀṣim, Madani 15-line; **E16
/// settings-profiles-teacher** overrides this provider when the user swaps the
/// `mushaf_id` triple. Defined here (scoped to the reader feature) rather than
/// global: the reader is the only surface that reads the active edition today.
final activeEditionProvider = Provider<MushafEdition>(
  (ref) => kKfgqpcHafsMadaniV2Edition,
);

/// The 1:1 reader view-model provider — `family`-keyed by the active
/// [ProfileId] (T05's weak-line refs key on it) and `autoDispose` (the heavy
/// reader is released with its screen). The dumb `MushafReaderScreen` reads
/// exactly this; tests drive it by overriding the injected providers
/// ([activeEditionProvider]), never the notifier.
final mushafReaderViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<MushafReaderViewModel, MushafReaderState, ProfileId>(
  MushafReaderViewModel.new,
);
