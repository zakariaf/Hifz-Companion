// template.dart — ui-empty-state
//
// Copy-paste scaffold for the EMPTY / FIRST-RUN / RETURN-AFTER-GAP faces of a
// screen: the welcoming first day (zero data), the calm all-done / nothing-due
// terminal surface, and the neutral SILENT welcome-back after a gap.
//
// Each is a low-arousal, NON-SHAMING surface that states the calm fact and at
// most one gentle next step. It is NEVER:
//   - a "Welcome back! You haven't opened the app in N days" greeting
//   - a "you haven't logged" / "you're behind" / streak-shame state
//   - a confetti / fanfare celebration of "all done"
//   - an engagement prompt ("come back tomorrow", FOMO, "upgrade")
// (docs/design-system/11-voice-and-tone.md §2, §3, §6, §7, §9)
//
// IMPORTANT scope: if there is a BACKLOG to offer help with after a gap, that
// is the empathy→fact→plan→choice catch-up surface — use **ui-catch-up-banner**,
// NOT this. When there's nothing to catch up, the app resumes SILENTLY: this
// surface is the *absence* of a reproach. (11-voice-and-tone §3)
//
// This View is DUMB: the EmptyStateModel arrives pre-built from the controller.
// It never reads DateTime.now() (the injected CalendarDate decides first-run /
// all-done / resume — domain-calendars-and-hifzdate), never calls the engine,
// and routes any single gentle "begin" mutation through the single write path
// (eng-create-riverpod-store).
//
// Fill every // TODO. Reference tokens by NAME — never hardcode hex / 16dp /
// 220ms / a red color / a raw HapticFeedback call.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback (behind haptic.* tokens)
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../l10n/app_localizations.dart';        // TODO: transcreated ARB strings (fa/ckb/ar)
// import '../theme/motion_tokens.dart';              // TODO: motion.* ThemeExtension
// import '../theme/haptic_tokens.dart';              // TODO: haptic.* (confirm/selection/warning), OS-gated
// import 'today_providers.dart';                     // TODO: emptyStateProvider + controller

// ---------------------------------------------------------------------------
// Read model — produced by the controller, handed to this dumb View.
// The View renders it; it NEVER decides which variant applies (that needs the
// injected "today" + persisted state, owned by the controller/engine).
// ---------------------------------------------------------------------------

/// Which calm face to show. There is NO "you lapsed" / "gap" variant here:
/// a gap with a backlog is **ui-catch-up-banner**; a gap with nothing to catch
/// up is just `resume` (the silent welcome-back — render nothing special).
enum EmptyStateKind {
  /// Before any review exists. State the calm fact + ONE gentle next step
  /// (the invitation INTO onboarding/cold-start — ui-cold-start-placement).
  firstRun,

  /// The finite, capped Today list reached its end / nothing is due.
  /// A calm closing line. NEVER a celebration. (07-components §1)
  allDone,

  /// Reopened after a gap with NOTHING to catch up. Resume SILENTLY into the
  /// normal day — no greeting, no banner. (11-voice-and-tone §3)
  resume,
}

class EmptyStateModel {
  const EmptyStateModel({
    required this.kind,
    this.nextStepAvailable = false,
  });

  final EmptyStateKind kind;

  /// True only for `firstRun` where a single gentle next step exists
  /// (e.g. "mark which juz you hold"). All-done/resume offer no action.
  final bool nextStepAvailable;
}

// ---------------------------------------------------------------------------
// The empty state. A *state* of a screen (Today / Progress / Mutashābihāt),
// not a screen of its own.
// ---------------------------------------------------------------------------

class EmptyState extends ConsumerWidget {
  const EmptyState({super.key, required this.model});

  final EmptyStateModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context);

    // SILENT welcome-back: nothing special is rendered. The app resumes into
    // the normal day. NEVER a "Welcome back! You haven't opened the app in N
    // days" greeting. (11-voice-and-tone §3)
    if (model.kind == EmptyStateKind.resume) {
      return const SizedBox.shrink();
    }

    return switch (model.kind) {
      EmptyStateKind.firstRun => _FirstRun(model: model),
      EmptyStateKind.allDone => const _AllDone(),
      EmptyStateKind.resume => const SizedBox.shrink(), // handled above
    };
  }
}

// ---------------------------------------------------------------------------
// First-run / zero-data: calm fact + ONE gentle next step (invitation, never
// command). Frames the entry into ui-cold-start-placement. (11 §2, §6)
// ---------------------------------------------------------------------------

class _FirstRun extends ConsumerWidget {
  const _FirstRun({required this.model});

  final EmptyStateModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // RTL is the layout's geometry — EdgeInsetsDirectional / AlignmentDirectional
    // everywhere, never left/right. The one template serves fa/ckb/ar; ckb's
    // longer transcreated copy reflows within the same insets. (PRD §13.2)
    return Semantics(
      container: true,
      // TODO: one calm announcement of the state + its single next step,
      //   in the user's locale (07-components per-locale Semantics).
      label: '', // TODO: l10n.firstRunSemanticsLabel
      child: Padding(
        padding: const EdgeInsetsDirectional.all(0), // TODO: space.6 — generous whitespace
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // logical start = right in RTL
          children: [
            // Calm fact — NO shame, NO "nothing here, get started!".
            // Statement of readiness: "Your revision will appear here once
            // you begin." (11 §6) Plain-and-warm, no exclamation. (11 §2)
            Text(
              '', // TODO: l10n.firstRunFact — transcreated, warm, no blame
              style: theme.textTheme.bodyMedium, // TODO: type.body token
            ),
            const SizedBox(height: 0), // TODO: space.4 token

            // ONE gentle next step — an INVITATION into onboarding/cold-start
            // (ui-cold-start-placement), never a mandate. Button is a verb in
            // the locale's idiom. (11 §6)
            if (model.nextStepAvailable)
              FilledButton(
                onPressed: () => _begin(ref),
                child: const Text(''), // TODO: l10n.firstRunBegin — verb, calm
              ),
          ],
        ),
      ),
    );

    // NEVER on this surface:
    // - a saturated/red warning fill, alarm styling, or a performing
    //   mascot/hero illustration (07-components Pillar 2 — calm, not cute)
    // - "you haven't logged" / "you're behind" / any guilt nag (11 §3, §9)
    // - "come back tomorrow" / streak-at-risk / FOMO / "upgrade" (11 §7)
  }

  /// The single gentle commit → `haptic.confirm` (lightImpact), always paired
  /// with the on-screen change, OS-gated. NO reward haptic. (06-motion §4)
  void _begin(WidgetRef ref) {
    // TODO: fire haptic.confirm via the haptic.* token wrapper (OS-gated),
    //   e.g. ref.read(hapticsProvider).confirm();
    //   Do NOT call HapticFeedback.lightImpact() directly at the call site.

    // TODO: route the navigation/mutation through the controller (single write
    //   path / go_router) — e.g. ref.read(onboardingControllerProvider...).
    //   This enters ui-cold-start-placement; it does NOT compute anything here.
  }
}

// ---------------------------------------------------------------------------
// All-done / nothing-due terminal surface: a calm closing line. The finite,
// capped Today list reached its end. INFORMATIONAL — never a celebration.
// (07-components §1; 11 §2)
// ---------------------------------------------------------------------------

class _AllDone extends StatelessWidget {
  const _AllDone();

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '', // TODO: l10n.allDoneSemanticsLabel — calm, in the user's locale
      child: Padding(
        padding: const EdgeInsetsDirectional.all(0), // TODO: space.6 token
        child: Text(
          // e.g. "Today's revision is complete." — calm, no exclamation,
          // no "you've mastered" / "safe to drop" / "done with". (11 §2, §5)
          '', // TODO: l10n.allDoneLine — transcreated, plain, no celebration
          style: theme.textTheme.bodyMedium?.copyWith(
            // TODO: color.text.secondary — informational, recessive. (07 §1)
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    // NEVER on this surface:
    // - confetti / fanfare / a streak increment / a badge / an exclamation
    //   mark (07-components §1 anti-patterns; 06-motion §2 — no celebratory
    //   motion). Acknowledgment is copy + a motion.duration.short fade only.
    // - a "success/reward" haptic for finishing the day (06-motion §4)
    // - "you've mastered" / "safe to drop" / "done with this" (11 §5)
  }
}

/// TODO: format any count in the active locale's numeral set via intl
/// NumberFormat (Extended Arabic-Indic ۰۱۲ for fa/ckb, Arabic-Indic ٠١٢ for ar),
/// and wrap any mixed Latin/numeral run ("Juz 7") in bidi isolation (FSI/PDI)
/// so a count never breaks the RTL line. Never concatenate raw ASCII digits
/// into a localized string. (11-voice-and-tone §8; eng-rtl-and-bidi-layout)
String _localizedNumber(BuildContext context, int value) =>
    value.toString(); // TODO: replace with NumberFormat.decimalPattern(locale)
