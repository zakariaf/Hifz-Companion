// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show todayProvider;
import 'package:engine/engine.dart' show Card, ReviewTrack, estMinutes;
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l10n/l10n.dart';

import '../a11y/reduce_motion_substitution.dart';
import '../design_system/state/mihrab_state_layer.dart';
import '../design_system/theme/spacing_tokens.dart';
import '../design_system/widgets/plain_screen_header.dart';
import '../l10n/term_set.dart';
import '../session/session_route.dart';
import '../settings/settings_providers.dart';
import 'today_providers.dart';
import 'today_session.dart';
import 'widgets/budget_feedback_line.dart';
import 'widgets/session_skeleton.dart';
import 'widgets/today_all_done.dart';
import 'widgets/today_retry_view.dart';

/// The Today tab (plain redesign, 2026-09-05): a **dumb** View over the 1:1
/// [todayControllerProvider]. One job — the day's count and honest time
/// estimate with a single **Start** button — then the finite, budget-capped
/// list grouped Far → Near → New for orientation. It renders the controller's
/// four calm states (`loading` skeleton, `error` retry, the all-done close, the
/// populated day), never calls the engine, never sorts/caps/load-balances, and
/// never reads `DateTime.now()`.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(todayControllerProvider);

    // Each state carries a distinct key so the calm content cross-fade (instant
    // under the OS Reduce Motion flag, E08-T05) is detected on transition.
    final content = session.when(
      loading: () =>
          const SessionSkeleton(key: ValueKey<String>('today.loading')),
      error: (error, _) => TodayRetryView(
        key: const ValueKey<String>('today.error'),
        message: l10n.commonRetry,
        onRetry: () => ref.invalidate(todayControllerProvider),
      ),
      data: (data) => data.isEmpty && data.catchUp == null
          ? const TodayAllDone(key: ValueKey<String>('today.allDone'))
          : _TodayDay(
              key: const ValueKey<String>('today.populated'),
              session: data,
            ),
    );

    return Semantics(
      identifier: 'screen.today',
      container: true,
      label: l10n.todaySemanticTitle,
      explicitChildNodes: true,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _TodayHeader(),
            Expanded(child: ReduceMotionSwitcher(child: content)),
          ],
        ),
      ),
    );
  }
}

/// The large title with the date (in the chosen calendar) and the active
/// profile's name as its caption, and the Settings gear.
class _TodayHeader extends ConsumerWidget {
  const _TodayHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final today = ref.watch(todayProvider);
    final calendar = ref.watch(displayPreferencesProvider).calendarSystem;
    final profile = ref.watch(activeProfileRecordProvider).asData?.value;
    final date = isolatedDateLabel(CalendarPresenter(calendar, locale), today);
    final name = profile?.displayName;
    return PlainScreenHeader(
      title: l10n.navToday,
      caption: name == null || name.isEmpty ? date : '$date · ${isolate(name)}',
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n.navSettings,
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}

/// The populated day: the optional gap banner, the hero (ring + count + time +
/// Start), the honest budget line when the scope overflows, then the grouped
/// list. Rows open the session from that page.
class _TodayDay extends ConsumerWidget {
  const _TodayDay({required this.session, super.key});

  final TodaySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final juz = ref.watch(pageJuzProvider);
    final catchUp = session.catchUp;
    // The catch-up plan's pages ARE today's session when a gap is open; the
    // banner above says so. Otherwise the three sections in recitation order.
    final pages = catchUp != null
        ? catchUp.items
        : <Card>[...session.far, ...session.near, ...session.newSabaq];

    return juz.when(
      loading: () => const SessionSkeleton(),
      error: (_, __) => TodayRetryView(
        message: l10n.commonRetry,
        onRetry: () => ref.invalidate(pageJuzProvider),
      ),
      data: (juzMap) => ListView(
        padding: EdgeInsetsDirectional.only(bottom: space.space7),
        children: <Widget>[
          if (catchUp != null)
            _GapBanner(
              key: const ValueKey<String>('today.catchUp'),
              plan: catchUp,
            ),
          _HeroCard(pages: pages, reviewedToday: session.reviewedTodayCount),
          if (session.budgetOverflow)
            BudgetFeedbackLine(
              onRaiseBudget: () => context.push('/settings?focus=cycle'),
              onLengthenCycle: () => context.push('/settings?focus=cycle'),
              onPauseNewSabaq: () => context.push('/settings?focus=cycle'),
            ),
          for (final track in const <ReviewTrack>[
            ReviewTrack.far,
            ReviewTrack.near,
            ReviewTrack.newPage,
          ])
            _Section(
              track: track,
              pages: pages.where((c) => _trackOf(c) == track).toList(),
              juzOf: (pageId) => juzMap[pageId] ?? 0,
            ),
        ],
      ),
    );
  }

  ReviewTrack _trackOf(Card card) => switch (card.track) {
        ReviewTrack.newPage || ReviewTrack.unmemorized => ReviewTrack.newPage,
        ReviewTrack.near => ReviewTrack.near,
        ReviewTrack.far => ReviewTrack.far,
      };
}

/// The compact after-a-gap banner: the fact (days without revision), the path
/// (the re-spread plan), and one calm adjust action. Never a red pile, never
/// "you're behind" (C-042); the pages themselves are the list below.
class _GapBanner extends StatelessWidget {
  const _GapBanner({required this.plan, super.key});

  final TodayCatchUp plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        space.space4,
        0,
        space.space4,
        space.space3,
      ),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(space.space4),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space4,
            space.space3,
            space.space2,
            space.space3,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: space.space1,
                  children: <Widget>[
                    Text(
                      toLocaleNumerals(
                        l10n.catchUpMissedDays(plan.missedDays),
                        locale,
                      ),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      toLocaleNumerals(
                        l10n.catchUpPlanLine(plan.planDays),
                        locale,
                      ),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/settings?focus=cycle'),
                child: Text(l10n.catchUpAdjust),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The hero: a ring (reviewed today over the whole day), the page count, the
/// honest time estimate with the per-track breakdown, and the one primary
/// action. The ring is a position, never a score or a streak.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.pages, required this.reviewedToday});

  final List<Card> pages;
  final int reviewedToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final remaining = pages.length;
    final total = remaining + reviewedToday;
    final minutes = pages.fold<int>(0, (sum, c) => sum + estMinutes(c));
    const region = kDefaultTermSetRegion;
    final breakdown = <String>[
      toLocaleNumerals(l10n.todayAboutMinutes(minutes), locale),
      for (final track in const <ReviewTrack>[
        ReviewTrack.far,
        ReviewTrack.near,
        ReviewTrack.newPage,
      ])
        if (pages.any((c) => c.track == track))
          '${trackLabel(l10n, track, region)} '
              '${isolateLtr(localeDigits(pages.where((c) => c.track == track).length, locale))}',
    ].join(' · ');

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(space.space4),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.all(space.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: space.space4,
            children: <Widget>[
              Row(
                spacing: space.space4,
                children: <Widget>[
                  SizedBox(
                    width: space.space8 + space.space4,
                    height: space.space8 + space.space4,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CircularProgressIndicator(
                          value: total == 0 ? 0 : reviewedToday / total,
                          strokeWidth: space.space2,
                          strokeCap: StrokeCap.round,
                          backgroundColor: scheme.primaryContainer,
                          color: scheme.primary,
                        ),
                        Center(
                          child: Text(
                            isolateLtr(localeDigits(reviewedToday, locale)),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: space.space1,
                      children: <Widget>[
                        Text(
                          toLocaleNumerals(
                            l10n.todayPagesCount(remaining),
                            locale,
                          ),
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          breakdown,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: space.space8 + space.space1,
                child: FilledButton(
                  key: const ValueKey<String>('today.start'),
                  onPressed: () => context.push(sessionLocation()),
                  child: Text(l10n.todayStartSession),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One track section: a quiet header (the localized term-set word + count) and
/// a grouped card of compact rows. An empty section renders nothing.
class _Section extends StatelessWidget {
  const _Section({
    required this.track,
    required this.pages,
    required this.juzOf,
  });

  final ReviewTrack track;
  final List<Card> pages;
  final int Function(int pageId) juzOf;

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    const region = kDefaultTermSetRegion;
    final header = switch (track) {
      ReviewTrack.far => l10n.sectionFarManzil(region),
      ReviewTrack.near => l10n.sectionNearSabqi(region),
      ReviewTrack.newPage ||
      ReviewTrack.unmemorized =>
        l10n.sectionNewSabaq(region),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            space.space5,
            space.space5,
            space.space5,
            space.space2,
          ),
          child: Semantics(
            header: true,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    header,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
                Text(
                  toLocaleNumerals(l10n.todayPagesCount(pages.length), locale),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: space.space4),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: scheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(space.space4),
                side: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: Column(
              children: <Widget>[
                for (var i = 0; i < pages.length; i++)
                  _PageRow(
                    key: ValueKey<int>(pages[i].pageId),
                    card: pages[i],
                    juz: juzOf(pages[i].pageId),
                    last: i == pages.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One compact row: the page, then juz + when it was last recited (a neutral
/// orientation fact), a sign-off glyph when a teacher graded it, and a chevron.
/// The whole row is one ≥48dp tap into the session starting at this page.
class _PageRow extends ConsumerWidget {
  const _PageRow({
    required this.card,
    required this.juz,
    required this.last,
    super.key,
  });

  final Card card;
  final int juz;
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final space = theme.extension<SpacingTokens>()!;
    final today = ref.watch(todayProvider);
    final last = card.lastReviewedDay;
    final lastReviewed = last == null
        ? l10n.todayNotYetReviewed
        : toLocaleNumerals(
            l10n.todayLastReviewedDaysAgo(last.daysUntil(today)),
            locale,
          );
    final juzText = l10n.juzLabel(isolateLtr(localeDigits(juz, locale)));
    return MergeSemantics(
      child: InkWell(
        onTap: () => context.push(sessionLocation(startPageId: card.pageId)),
        overlayColor: MihrabStateLayer.overlayColor(scheme.onSurface),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: this.last
                ? null
                : Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.space8 + space.space2),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: space.space4,
                vertical: space.space2,
              ),
              child: Row(
                spacing: space.space3,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          l10n.pageNumber(
                            isolateLtr(localeDigits(card.pageId, locale)),
                          ),
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$juzText · $lastReviewed',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (card.signoffs > 0)
                    // A teacher (talaqqī) sign-off is marked by shape + label,
                    // never colour alone, so self/teacher are never conflated.
                    Semantics(
                      label: l10n.stateSignedOff,
                      child: Icon(
                        Icons.verified_outlined,
                        size: space.space5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  Icon(
                    Icons.arrow_forward_ios, // auto-mirrors: forward in RTL
                    size: space.space4,
                    color: scheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
