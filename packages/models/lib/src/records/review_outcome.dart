// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

import 'card.dart';
import 'confusion_edge.dart';
import 'line_block.dart';
import 'review_log.dart';

/// The complete, already-computed result of one review — the engine's output
/// DTO that the single write path persists in one transaction (05 §3; PRD §7.7).
///
/// It carries the engine's decisions, **never** a recomputation: the immutable
/// [logRow] to append, the [cardUpdate] to upsert (the engine's D/S/`dueAt`/
/// flags — the trust clamp is the only `dueAt` sink, E04), and the optional
/// [newLineBlocks] to insert and [confusionBumps] to bump. `commitReview`
/// (E03-T07) persists exactly this; the FSRS/clamp arithmetic that produced it
/// lives in the pure engine (E04).
@immutable
class ReviewOutcome {
  /// The append-only audit row to insert.
  final ReviewLog logRow;

  /// The card's new engine state to upsert.
  final Card cardUpdate;

  /// Line blocks to lazily create for a repeatedly-lapsing page (often empty).
  final List<LineBlock> newLineBlocks;

  /// Mutashābihāt confusion edges to bump on a wrong-branch stumble (often
  /// empty).
  final List<ConfusionEdge> confusionBumps;

  /// Creates a review outcome. The optional lists default to empty.
  const ReviewOutcome({
    required this.logRow,
    required this.cardUpdate,
    this.newLineBlocks = const [],
    this.confusionBumps = const [],
  });
}
