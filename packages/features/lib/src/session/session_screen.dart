// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:engine/engine.dart' show ReviewGrade;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../design_system/grade/grade_band.dart';
import '../design_system/grade/grade_choice.dart';
import '../design_system/theme/spacing_tokens.dart';
import '../recite/recite_providers.dart';
import '../recite/widgets/recite_surface.dart';
import '../today/today_providers.dart';
import 'session_view_model.dart';

/// The continuous revision session (plain redesign, 2026-09-05): the day's
/// pages one after another — a masked page, one-tap reveal, stumble lines, the
/// four-level grade band, then the next page slides in — with a thin progress
/// bar and a "{n} of {total}" position in the top bar, and a plain factual
/// close. A dumb View over [sessionControllerProvider]: it does no scheduling
/// math, never caps a grade, reads no wall-clock date, and celebrates nothing
/// (the Good/Easy path is identical to Again).
class SessionScreen extends ConsumerWidget {
  /// Creates the session, optionally starting from [startPageId].
  const SessionScreen({this.startPageId, super.key});

  /// The page a Today row tap asked to start from, or null for the first page.
  final int? startPageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final day = ref.watch(todayControllerProvider);

    // Build the queue once the day's plan is known; the controller ignores a
    // second `begin` so a rebuild never restarts a running session.
    if (session.stage == SessionStage.preparing) {
      final plan = day.asData?.value;
      if (plan != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(sessionControllerProvider.notifier)
              .begin(sessionQueueFor(plan, startPageId: startPageId));
        });
      }
    }

    final body = switch (session.stage) {
      SessionStage.preparing => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      SessionStage.running => _RunningView(
          key: ValueKey<int>(session.currentPageId!),
          session: session,
        ),
      SessionStage.done => _DoneView(session: session),
    };

    return Semantics(
      identifier: 'screen.session',
      container: true,
      label: l10n.sessionSemanticTitle,
      explicitChildNodes: true,
      child: Scaffold(body: SafeArea(child: body)),
    );
  }
}

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.session, super.key});

  final SessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final pageId = session.currentPageId!;
    final recite = ref.watch(reciteControllerProvider(pageId));
    final reciteController =
        ref.read(reciteControllerProvider(pageId).notifier);
    final juz = ref.watch(pageJuzProvider).asData?.value[pageId];
    final title = juz == null
        ? l10n.pageNumber(isolateLtr(localeDigits(pageId, locale)))
        : localizedPageJuz(page: pageId, juz: juz, locale: locale, l10n: l10n);
    final position = l10n.sessionPosition(
      isolateLtr(localeDigits(session.index + 1, locale)),
      isolateLtr(localeDigits(session.queue.length, locale)),
    );

    Future<void> onGrade(GradeChoice choice) async {
      final messenger = ScaffoldMessenger.of(context);
      final controller = ref.read(sessionControllerProvider.notifier);
      final handle = await controller.grade(_toReviewGrade(choice));
      // haptic.confirm only — never a success/heavy haptic, never a celebration.
      await HapticFeedback.lightImpact();
      if (handle != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.a11yAnnouncePageGraded),
            action: SnackBarAction(
              label: l10n.reciteUndo,
              onPressed: controller.undoLast,
            ),
          ),
        );
      }
    }

    return Column(
      children: <Widget>[
        // The top bar: the calm exit at the start edge (thumb reach), the page
        // title, and the position readout. A position, never a score.
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.space2),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.reciteExit,
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(end: space.space3),
                child: Text(
                  position,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.space5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(space.space1),
            child: LinearProgressIndicator(
              value: session.index / session.queue.length,
              minHeight: space.space1,
              backgroundColor: scheme.surfaceContainerHighest,
              color: scheme.primary,
            ),
          ),
        ),
        // Servant-to-the-teacher: the sign-off choice precedes the verdict —
        // a quiet chip, off by default; on, the grade's source is the teacher.
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: space.space4,
            vertical: space.space2,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilterChip(
              label: Text(l10n.teacherSignoffLabel),
              tooltip: l10n.teacherSignoffSupporting,
              selected: recite.teacherPresent,
              onSelected: (v) => reciteController.setTeacherPresent(present: v),
            ),
          ),
        ),
        Expanded(child: ReciteSurface(pageId: pageId)),
        Padding(
          padding: EdgeInsetsDirectional.all(space.space4),
          child: GradeBand(enabled: recite.hasRevealed, onGrade: onGrade),
        ),
      ],
    );
  }

  ReviewGrade _toReviewGrade(GradeChoice choice) => switch (choice) {
        GradeChoice.again => ReviewGrade.again,
        GradeChoice.hard => ReviewGrade.hard,
        GradeChoice.good => ReviewGrade.good,
        GradeChoice.easy => ReviewGrade.easy,
      };
}

/// The plain close: what was recited, how long it took, which pages come back
/// sooner, and tomorrow's count. A fact sheet — no praise, no streak, no
/// confetti, and never "done with" a page (C-019).
class _DoneView extends ConsumerWidget {
  const _DoneView({required this.session});

  final SessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final minutes = ref.read(sessionControllerProvider.notifier).elapsedMinutes;
    final tomorrow = ref.watch(tomorrowDueCountProvider).asData?.value;
    final sooner = session.comesBackSooner;

    if (session.queue.isEmpty) {
      return _DoneScaffold(
        title: l10n.todayEmpty,
        children: const <Widget>[],
      );
    }

    return _DoneScaffold(
      title: l10n.sessionDoneTitle,
      subtitle:
          '${toLocaleNumerals(l10n.sessionPagesReviewed(session.reviewedCount), locale)}'
          ' · ${toLocaleNumerals(l10n.sessionMinutesSpent(minutes), locale)}',
      children: <Widget>[
        if (sooner.isNotEmpty)
          _FactRow(
            label: l10n.sessionComesBackSooner,
            value: sooner
                .map(
                  (p) => l10n.pageNumber(isolateLtr(localeDigits(p, locale))),
                )
                .join('، '),
          ),
        if (tomorrow != null)
          _FactRow(
            label: l10n.sessionTomorrow,
            value: toLocaleNumerals(l10n.todayPagesCount(tomorrow), locale),
            last: true,
          ),
      ],
    );
  }
}

class _DoneScaffold extends StatelessWidget {
  const _DoneScaffold({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final sub = subtitle;
    return Column(
      children: <Widget>[
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.reciteExit,
            onPressed: () => context.go('/today'),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: space.space6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: space.space8 + space.space4,
                  height: space.space8 + space.space4,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: space.space7,
                    color: scheme.primary,
                  ),
                ),
                SizedBox(height: space.space6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                if (sub != null) ...[
                  SizedBox(height: space.space2),
                  Text(
                    sub,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
                if (children.isNotEmpty) ...[
                  SizedBox(height: space.space6),
                  DecoratedBox(
                    decoration: ShapeDecoration(
                      color: scheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(space.space4),
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    child: Column(children: children),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space4,
            0,
            space.space4,
            space.space6,
          ),
          child: SizedBox(
            width: double.infinity,
            height: space.space8 + space.space1,
            child: FilledButton(
              onPressed: () => context.go('/today'),
              child: Text(l10n.sessionBackToToday),
            ),
          ),
        ),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: space.space4,
          vertical: space.space3,
        ),
        child: Row(
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            SizedBox(width: space.space3),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
