// template.dart — ui-catch-up-banner
//
// Copy-paste scaffold for the missed-day catch-up banner: a CALM, SUPPORTIVE
// surface shown on Today after a gap. It renders the ENGINE'S pre-built
// re-spread plan (most-decayed / prayer-critical first) and follows the
// empathy → honest fact → concrete plan → choice template
// (docs/design-system/11-voice-and-tone.md §4). It is NEVER a red overdue
// pile, a broken-streak state, a "you're behind" scold, or a
// "Welcome back, you haven't opened the app in N days" greeting.
//
// This View is DUMB: the CatchUpPlan arrives pre-built from the controller.
// It never computes the re-spread (that is domain-scheduling-engine-rules),
// never reads DateTime.now() (the "N days missed" count comes from the
// injected CalendarDate — domain-calendars-and-hifzdate), never calls the
// engine, and routes any "start the plan" mutation through the single write
// path (eng-create-riverpod-store).
//
// Fill every // TODO. Reference tokens by NAME — never hardcode hex / 16dp /
// 220ms / a red color / a raw HapticFeedback call.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback (behind haptic.* tokens)
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../l10n/app_localizations.dart';        // TODO: transcreated ARB strings (fa/ckb/ar)
// import '../theme/motion_tokens.dart';              // TODO: motion.* ThemeExtension
// import '../theme/haptic_tokens.dart';              // TODO: haptic.* (confirm/selection/warning), OS-gated
// import 'today_providers.dart';                     // TODO: catchUpPlanProvider + controller

// ---------------------------------------------------------------------------
// Read model — produced by the engine + controller, handed to this dumb View.
// The View renders it; it NEVER recomputes the spread or the day-count.
// ---------------------------------------------------------------------------

/// One muṣḥaf page placed into the catch-up plan, built by **ui-page-card**.
/// Carries no D/S/R, no percentage, no "safe to drop" — only display state.
class CatchUpPlanRow {
  const CatchUpPlanRow({
    required this.pageNumber, // localized at render via intl NumberFormat
    required this.juzNumber,
    required this.decay, // calm decay band — green receding, never red
    required this.isMandatory, // FAR/manzil due item — never dropped to shorten
  });

  final int pageNumber;
  final int juzNumber;
  final double decay;
  final bool isMandatory;
}

/// The pre-built re-spread plan. `missedDays` is the elapsed-day count from the
/// injected CalendarDate (domain-calendars-and-hifzdate), NOT DateTime.now().
/// `spreadDays` is the engine's re-spread horizon. Rows are ordered
/// most-decayed / prayer-critical first by the engine (domain-scheduling-engine-rules).
class CatchUpPlan {
  const CatchUpPlan({
    required this.missedDays,
    required this.spreadDays,
    required this.rows,
  });

  final int missedDays;
  final int spreadDays;
  final List<CatchUpPlanRow> rows;
}

// ---------------------------------------------------------------------------
// The banner. A *state* of the Today daily-session list (ui-daily-session-list),
// not a screen. Shown ONLY when there is a plan to offer help with — otherwise
// the app resumes SILENTLY into the normal day (no banner, no greeting).
// ---------------------------------------------------------------------------

class CatchUpBanner extends ConsumerWidget {
  const CatchUpBanner({super.key, required this.plan});

  final CatchUpPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // TODO: locale numerals via intl NumberFormat for the active locale
    //   (Extended Arabic-Indic ۰۱۲۳ for fa/ckb, Arabic-Indic ٠١٢٣ for ar).
    //   Wrap any mixed Latin/numeral run ("Juz 7", a page number) in bidi
    //   isolation (FSI/PDI) so a count never breaks the RTL line.
    //   (11-voice-and-tone §8; eng-rtl-and-bidi-layout)
    final missedDaysText = _localizedNumber(context, plan.missedDays);
    final spreadDaysText = _localizedNumber(context, plan.spreadDays);

    // The View is dumb: render only. RTL is the layout's geometry — use
    // EdgeInsetsDirectional / AlignmentDirectional everywhere, never left/right.
    return Card(
      // TODO: calm surface — surfaceContainer at Level 0–1. NO red, NO
      //   saturated warning fill, NO alarm styling. (07-components §1; 11 §2)
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      margin: const EdgeInsetsDirectional.all(0), // TODO: space.* token
      child: Padding(
        padding: const EdgeInsetsDirectional.all(0), // TODO: space.4 token
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // logical start = right in RTL
          children: [
            // ----- (1) EMPATHY FIRST — calm, non-blaming acknowledgment -----
            // NEVER "you're behind", NEVER "Welcome back! You haven't opened
            // the app in N days". The fact below is the lead-in to HELP, never
            // a standalone reproach. (11 §3, §4)
            Text(
              '', // TODO: l10n.catchUpEmpathyLine — transcreated, warm, no blame
              style: theme.textTheme.bodyMedium, // TODO: type.body token
            ),

            // ----- (2) HONEST FACT — N days, stated plainly, not amplified ---
            Text(
              '', // TODO: l10n.catchUpMissedDays(missedDaysText) — locale numerals
              style: theme.textTheme.bodyMedium, // TODO: type.body
            ),

            // ----- (3) CONCRETE PLAN — the engine's re-spread, calm header ----
            // "here is an M-day catch-up that still completes your cycle"
            Text(
              '', // TODO: l10n.catchUpPlanHeadline(spreadDaysText) — locale numerals
              style: theme.textTheme.bodyMedium, // TODO: type.body
            ),

            // The re-spread rows — most-decayed / prayer-critical first
            // (ordered by the engine). Built as page cards via **ui-page-card**.
            // Decay reads as green RECEDING to muted neutral, never red
            // (08-data-visualization §3). FAR/manzil rows (isMandatory) stay.
            for (final row in plan.rows)
              const SizedBox.shrink(), // TODO: PageCard(row: row) — ui-page-card

            // ----- (4) CHOICE — real, user-owned options; never one mandate ---
            // Restoration-of-freedom: the cycle/budget are the user's.
            // (11 §4, §6). NEVER a single mandated fix; NEVER a silent drop.
            Row(
              children: [
                FilledButton(
                  onPressed: () => _startPlan(ref),
                  child: const Text(''), // TODO: l10n.catchUpStart — verb, calm
                ),
                const SizedBox(width: 0), // TODO: space.2 token
                TextButton(
                  onPressed: () {
                    // TODO: open length/budget adjust or defer — choices, not a
                    //   mandate. (raise budget / lengthen cycle / pause new sabaq
                    //   live in ui-daily-session-list's budget-feedback line.)
                  },
                  child: const Text(''), // TODO: l10n.catchUpAdjust
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // NEVER on this surface:
    // - confetti / fanfare / a streak-repair animation on accept or complete
    //   (06-motion-and-haptics §2 — celebratory motion does not exist)
    // - a "success/reward" haptic, or a buzz to nag a missed day (06 §4)
    // - a red overdue count, a broken-streak state, or "you're behind" (11 §3)
    // - any "safe to drop" / "mastered" framing, or a silently dropped FAR page
    //   (domain-adab-and-religious-integrity; domain-scheduling-engine-rules)
  }

  /// Starting the plan COMMITS an action → `haptic.confirm` (lightImpact),
  /// always paired with the on-screen state change, OS-gated. NO reward haptic.
  /// (06-motion-and-haptics §4)
  void _startPlan(WidgetRef ref) {
    // TODO: fire haptic.confirm via the haptic.* token wrapper (OS-gated),
    //   e.g. ref.read(hapticsProvider).confirm();
    //   Do NOT call HapticFeedback.lightImpact() directly at the call site.

    // TODO: route the mutation through the single write path on the controller
    //   (persist-before-republish) — NOT a direct state write in the View.
    //   e.g. ref.read(todayControllerProvider.notifier).startCatchUpPlan();
    // Acknowledge with copy + a motion.duration.short + motion.curve.standard
    //   fade only — never a celebration. (06 §1, §2)
  }

  /// TODO: format `value` in the active locale's numeral set via intl
  /// NumberFormat (Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar).
  /// Never concatenate raw ASCII digits into a localized string. (11 §8)
  String _localizedNumber(BuildContext context, int value) =>
      value.toString(); // TODO: replace with NumberFormat.decimalPattern(locale)
}
