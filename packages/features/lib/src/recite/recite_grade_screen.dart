// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show todayProvider;
import 'package:engine/engine.dart' show ReviewGrade;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../today/today_providers.dart' show pageJuzProvider, reviewRecorderProvider;
import 'recite_providers.dart';
import 'widgets/grade_band.dart';
import 'widgets/recite_surface.dart';

/// The full-screen recite-from-memory + grade route (07-components §5), opened
/// from a Today page-card tap. A dumb View: it composes the masked reader
/// surface and the grade band, hands the user's taps to the E12-T06 pipeline
/// through the single write path, offers a calm undo, and advances back to the
/// finite Today list. It does **no** scheduling math, **never** caps a grade,
/// and **never** reads `DateTime.now()`. No celebration on any verdict — the
/// Good/Easy path is identical to Again.
class ReciteGradeScreen extends ConsumerWidget {
  /// Creates the route for [pageId].
  const ReciteGradeScreen({required this.pageId, super.key});

  /// The muṣḥaf page to recite.
  final int pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final juz = ref.watch(pageJuzProvider).asData?.value;
    final title = juz != null && juz[pageId] != null
        ? localizedPageJuz(
            page: pageId,
            juz: juz[pageId]!,
            locale: locale,
            l10n: l10n,
          )
        : l10n.pageNumber(localeDigits(pageId, locale));

    Future<void> onGrade(ReviewGrade grade) async {
      final messenger = ScaffoldMessenger.of(context);
      final handle =
          await ref.read(reciteControllerProvider(pageId).notifier).submitGrade(grade);
      // haptic.confirm only — never a success/heavy haptic, never a celebration.
      await HapticFeedback.lightImpact();
      if (handle != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.a11yAnnouncePageGraded),
            action: SnackBarAction(
              label: l10n.reciteUndo,
              onPressed: () => ref.read(reviewRecorderProvider).undoReview(
                    profile: handle.profile,
                    pageId: handle.pageId,
                    restoredCard: handle.priorCard,
                    undoneGrade: handle.grade,
                    today: ref.read(todayProvider),
                  ),
            ),
          ),
        );
      }
      // Advance: return to the finite Today list (the graded page has left it).
      if (context.mounted) context.pop();
    }

    return Scaffold(
      appBar: AppBar(
        // The calm exit sits at the start (leading) edge, in thumb reach;
        // Icons.close auto-mirrors under RTL.
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.reciteExit,
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(child: ReciteSurface(pageId: pageId)),
            ReciteGradeBand(pageId: pageId, onGrade: onGrade),
          ],
        ),
      ),
    );
  }
}
