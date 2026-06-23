// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show ReviewGrade;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/grade/grade_band.dart';
import '../../design_system/grade/grade_choice.dart';
import '../../design_system/grade/teacher_signoff_toggle.dart';
import '../../design_system/theme/spacing_tokens.dart';
import '../recite_providers.dart';

/// The recite grade band (07-components §5/§6): the E10 four-level band, disabled
/// until ≥1 reveal (reading as **waiting**, not broken), plus the in-flow teacher
/// sign-off slot (E12-T08 authors its source-marker behaviour). It maps the E10
/// [GradeChoice] to the engine [ReviewGrade] and forwards it via [onGrade]; it
/// applies **no** sacred-text cap and does **no** scheduling math.
class ReciteGradeBand extends ConsumerWidget {
  /// Creates the band for [pageId].
  const ReciteGradeBand({
    required this.pageId,
    required this.onGrade,
    super.key,
  });

  /// The page being graded.
  final int pageId;

  /// Forwards the user-confirmed grade to the controller's single write path.
  final ValueChanged<ReviewGrade> onGrade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final state = ref.watch(reciteControllerProvider(pageId));
    final controller = ref.read(reciteControllerProvider(pageId).notifier);

    return Padding(
      padding: EdgeInsetsDirectional.all(space.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // The E10 GradeBand itself renders the calm "reveal to grade" waiting
          // hint when disabled — no duplicate hint here.
          GradeBand(
            enabled: state.hasRevealed,
            onGrade: (choice) => onGrade(_toReviewGrade(choice)),
          ),
          SizedBox(height: space.space3),
          TeacherSignoffToggle(
            teacherPresent: state.teacherPresent,
            onChanged: (v) => controller.setTeacherPresent(present: v),
          ),
        ],
      ),
    );
  }

  ReviewGrade _toReviewGrade(GradeChoice choice) => switch (choice) {
        GradeChoice.again => ReviewGrade.again,
        GradeChoice.hard => ReviewGrade.hard,
        GradeChoice.good => ReviewGrade.good,
        GradeChoice.easy => ReviewGrade.easy,
      };
}
