// SCAFFOLD — this file bundles the pieces of the Hifz Companion daily-reminder row.
// It is NOT a standalone Dart file: it contains a domain-blind reminder-row widget, the
// feature-layer controller that persists the choice through the SINGLE WRITE PATH and
// then schedules via an INJECTED notification boundary, plus a widget-test stub. Copy
// each labelled block into the right file under packages/, then fill every // TODO.
// Opening this file on its own shows unresolved symbols — that is expected; the real
// symbols (the design-system token layer, AppLocalizations, the Riverpod providers, the
// NotificationScheduler boundary, the CalendarPresenter, the injected `today`) resolve
// only inside the pub workspace.
//
// Three pieces, in two layers:
//   1. ReminderRow — shared ui/ leaf, DOMAIN-BLIND (a switch + a conditional time picker
//      + an honest one-liner; it knows NO engine types, schedules NOTHING, computes NOTHING).
//   2. ReminderController — features/settings controller: persists {enabled, time} through
//      the SINGLE WRITE PATH, then calls the INJECTED NotificationScheduler as a side effect.
//   3. ReminderSettingsView — features/ leaf: localizes the labels, owns RTL geometry,
//      renders the time via the CalendarPresenter + locale numerals, hands the row state + callbacks.
//
// Tokens are referenced BY NAME ONLY (color.* / type.* / space.* / touch.min / motion.*).
// The design docs own the concrete values — never inline hex / dp / sp / ms here.
//
// Governing docs:
//   docs/design-system/10-privacy-and-trust-ux.md §9 (off-by-default, protective default,
//     reversible, one honest sentence, no pre-ticked box), §10 (one calm non-escalating
//     reminder; no guilt/fear/streak), §11 (five dark-pattern audit), §6/§3 (local-only fact)
//   docs/design-system/11-voice-and-tone.md §3 (the sanctioned line "Your revision for today
//     is ready"; calm/neutral), §7 (no urgency/streak), §8/§9 (transcreation + banned-phrase gate)
//   docs/engineering/07-dates-calendars-and-correctness.md §5 (schedule on the LOCAL CIVIL DAY
//     via the injected clock edge; NO DateTime.now() in shell), §6 (not a Hijri date),
//     §4 (render the time via CalendarPresenter + locale numerals, never raw ASCII)
//   eng-create-riverpod-store (persist-before-republish single write path)
//   eng-define-service-boundary (the injectable NotificationScheduler interface + fake)
//   eng-rtl-and-bidi-layout (EdgeInsetsDirectional, FSI/PDI isolation, locale numerals)
//   eng-add-localized-string (reminder + catch-up copy strings, fa/ckb/ar)
//
// Non-negotiables this scaffold encodes:
//   - The toggle is OFF BY DEFAULT. Opt-in is one explicit tap. NO pre-ticked box.
//   - EXACTLY ONE calm daily line: "Your revision for today is ready." NO exclamation,
//     NO guilt/fear/loss ("You'll lose your hifz"), NO countdown, NO streak, NO escalation.
//   - Schedule for the device's LOCAL CIVIL DAY via the injected clock. NO DateTime.now() here.
//   - Persist {enabled, time} through the notifier FIRST, THEN call the injected scheduler.
//   - Local-only: flutter_local_notifications, no push, no server, no network. Works offline.
//   - RTL by EdgeInsetsDirectional; the time run is FSI/PDI-isolated; numerals are locale.
//   - Selection is quiet: NO confetti / badge / score / "great job" / "you're behind".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// BLOCK 1 — packages/ui/lib/src/reminder_row.dart  (shared ui/, DOMAIN-BLIND)
// A switch row + a conditional time-picker affordance + an honest one-liner. It takes
// ONLY primitives and callbacks: it does NOT import the engine, does NOT schedule any
// notification, and computes nothing. The feature layer (BLOCK 2/3) persists the choice
// and performs the actual scheduling. (10-privacy-and-trust-ux.md §9: protective default,
// explicit opt-in, one plain sentence.)
// ============================================================================

/// One calm daily-reminder configuration row. DOMAIN-BLIND: primitives + callbacks only.
///
/// - [enabled]            : current toggle state. The feature layer defaults this to FALSE
///                          (off by default — 10-privacy-and-trust-ux.md §9). The row never
///                          self-initializes to true.
/// - [title]              : localized switch label, e.g. "Daily reminder" (term-set string).
/// - [honestLine]         : the localized one-liner, e.g. the transcreation of
///                          "A neutral reminder at a time you choose. Silence it anytime."
///                          (10-privacy-and-trust-ux.md §9 table). Local-only fact, no rhetoric.
/// - [formattedTime]      : the chosen time ALREADY rendered by the CalendarPresenter in the
///                          user's calendar + locale numerals (BLOCK 3). The row never formats
///                          a time itself and never concatenates raw ASCII digits.
/// - [timeSemanticsLabel] : the accessible label for the time affordance, per locale.
/// - [onEnabledChanged]   : invoked on toggle. The feature layer routes it through the
///                          controller's single write path (the row must NOT persist/schedule).
/// - [onEditTimePressed]  : invoked when the user taps to change the time (opens the picker).
class ReminderRow extends StatelessWidget {
  const ReminderRow({
    super.key,
    required this.enabled,
    required this.title,
    required this.honestLine,
    required this.formattedTime,
    required this.timeSemanticsLabel,
    required this.onEnabledChanged,
    required this.onEditTimePressed,
  });

  final bool enabled;
  final String title;
  final String honestLine;
  final String formattedTime;
  final String timeSemanticsLabel;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onEditTimePressed;

  @override
  Widget build(BuildContext context) {
    // RTL-correct: logical start/end insets only — NEVER EdgeInsets.only(left:/right:).
    // (eng-rtl-and-bidi-layout.) Pull the concrete value from the space.* token, do not inline.
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 0, // TODO: space.4 (logical start)
        end: 0, // TODO: space.4 (logical end)
        top: 0, // TODO: space.3
        bottom: 0, // TODO: space.3
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- The switch: OFF BY DEFAULT, opt-in is one explicit tap (§9). -----------
          // SwitchListTile gives a >=48x48dp target + a per-locale on/off Semantics value.
          // The switch IS the visually primary control and the protective default is off.
          MergeSemantics(
            child: SwitchListTile(
              value: enabled,
              onChanged: onEnabledChanged, // single tap on/off; one tap silences (§9 reversible).
              // TODO: title: Text(title, style: <type.body token>),
              title: Text(title),
              contentPadding: EdgeInsetsDirectional.zero, // logical; tune with space.* tokens.
              // TODO: activeColor: <color.accent token> (state pairs color WITH the switch shape).
            ),
          ),

          // --- The conditional time picker: shown ONLY when the reminder is enabled. ---
          // (One decision per moment — §9. When off there is nothing to schedule, so no time.)
          if (enabled)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 0 /* TODO: space.2 */),
              child: Semantics(
                // Per-locale accessible label; the value (the time) is the visible run below.
                label: timeSemanticsLabel,
                button: true,
                child: InkWell(
                  onTap: onEditTimePressed,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: 0, // TODO: space.2 — ensure the whole row stays >= touch.min (48dp).
                      bottom: 0, // TODO: space.2
                    ),
                    child: Row(
                      children: [
                        // TODO: a non-color icon (e.g. a clock glyph) so meaning is not hue-only.
                        const SizedBox(width: 0 /* TODO: space.2 */),
                        // The time is a mixed Latin/numeric run inside RTL chrome: it MUST be
                        // bidi-isolated (FSI/PDI) so it never breaks the right-to-left line, and
                        // it is ALREADY in locale numerals (BLOCK 3) — never raw ASCII here.
                        // (07-dates-calendars-and-correctness.md §4; eng-rtl-and-bidi-layout.)
                        Text(
                          formattedTime, // TODO: wrap in Unicode.FSI + Unicode.PDI when assembled.
                          // TODO: style: <type.body / type.numeral token>.
                          textDirection: TextDirection.ltr, // the isolated numeric run reads LTR.
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // --- The honest one-liner: a checkable, local-only fact. No privacy rhetoric. ---
          // "A neutral reminder at a time you choose. Silence it anytime." (§9 table); the
          // local-only fact is stated, never "we care about your privacy" (§3). Calm color.
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 0 /* TODO: space.2 */),
            child: Text(
              honestLine,
              // TODO: style: <type.caption token>, color: <color.text.secondary token>.
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BLOCK 2 — packages/features/lib/src/settings/reminder_controller.dart
// Persists {enabled, time} through the SINGLE WRITE PATH (persist-before-republish), THEN
// performs the actual OS scheduling via the INJECTED NotificationScheduler boundary. The
// controller reads the clock ONLY at the injected edge — NEVER DateTime.now() here.
// (eng-create-riverpod-store; eng-define-service-boundary; 07-...-correctness.md §5.)
// ============================================================================

/// The persisted reminder preference. Off by default (10-privacy-and-trust-ux.md §9).
@immutable
class ReminderPrefs {
  const ReminderPrefs({this.enabled = false, this.hour = 0, this.minute = 0});
  final bool enabled; // OFF by default — never pre-ticked.
  final int hour; // local wall-clock hour the user chose (0–23).
  final int minute; // local wall-clock minute the user chose (0–59).

  ReminderPrefs copyWith({bool? enabled, int? hour, int? minute}) => ReminderPrefs(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

/// The injected side-effect boundary that talks to flutter_local_notifications.
/// NO push, NO server. Defined as an interface in the data/services layer with a
/// deterministic FAKE for tests (eng-define-service-boundary). Shown here as the shape
/// the controller depends on — the row/controller NEVER touch the OS plugin directly.
abstract class NotificationScheduler {
  /// Schedule ONE daily local notification at the given LOCAL wall-clock time, repeating
  /// each LOCAL CIVIL DAY. The body is the ONE sanctioned line (passed in, already localized):
  /// "Your revision for today is ready." (11-voice-and-tone.md §3). NO escalation, ONE per day.
  Future<void> scheduleDaily({required int hour, required int minute, required String body});

  /// Cancel every scheduled reminder. Silencing is one tap (10-privacy-and-trust-ux.md §9).
  Future<void> cancelAll();
}

class ReminderController extends Notifier<ReminderPrefs> {
  @override
  ReminderPrefs build() {
    // TODO: load persisted prefs from the repository; default = ReminderPrefs() (enabled: false).
    return const ReminderPrefs();
  }

  /// Toggle the reminder. SINGLE WRITE PATH: persist FIRST, THEN republish, THEN schedule.
  Future<void> setEnabled(bool enabled) async {
    final next = state.copyWith(enabled: enabled);
    // TODO: await ref.read(reminderRepositoryProvider).save(next);  // persist transactionally FIRST.
    state = next; // republish in-memory state ONLY after the write commits.
    await _reschedule(next); // side effect AFTER the write — never before, never from the view.
  }

  /// Change the reminder time. Same single-write-path ordering.
  Future<void> setTime(int hour, int minute) async {
    final next = state.copyWith(hour: hour, minute: minute);
    // TODO: await ref.read(reminderRepositoryProvider).save(next);
    state = next;
    await _reschedule(next);
  }

  Future<void> _reschedule(ReminderPrefs prefs) async {
    final scheduler = ref.read(notificationSchedulerProvider); // injected boundary.
    if (!prefs.enabled) {
      await scheduler.cancelAll(); // off => nothing scheduled.
      return;
    }
    // The body is the ONE calm line, ALREADY localized for the active locale by the caller.
    // The scheduler keys this off the device's LOCAL civil day (07-...-correctness.md §5/§6) —
    // there is NO DateTime.now() in this controller; the time is the user's chosen wall-clock,
    // and the local-day resolution lives at the scheduler/app edge.
    final body = ''; // TODO: l10n.reminderBody — the transcreation of "Your revision for today is ready."
    await scheduler.scheduleDaily(hour: prefs.hour, minute: prefs.minute, body: body);
  }
}

// TODO: final reminderControllerProvider =
//     NotifierProvider<ReminderController, ReminderPrefs>(ReminderController.new);
// TODO: final notificationSchedulerProvider = Provider<NotificationScheduler>(
//     (ref) => throw UnimplementedError('override at the composition root / fake in tests'));
// TODO: final reminderRepositoryProvider = Provider<ReminderRepository>(...);

// ============================================================================
// BLOCK 3 — packages/features/lib/src/settings/reminder_settings_view.dart
// Localizes the labels, owns RTL geometry, renders the chosen time via the CalendarPresenter
// + locale numerals (07-...-correctness.md §4), and hands ReminderRow its state + callbacks.
// ============================================================================

class ReminderSettingsView extends ConsumerWidget {
  const ReminderSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(reminderControllerProvider);
    // final l10n = AppLocalizations.of(context)!;            // TODO
    // final presenter = ref.watch(calendarPresenterProvider); // TODO: the ONE place a time/date
    //   becomes localized text; renders in the user's calendar + locale numerals downstream.

    // Render the chosen time via the presenter so digits are Extended Arabic-Indic (fa/ckb) /
    // Arabic-Indic (ar) via intl NumberFormat — NEVER raw ASCII concatenated into a string.
    final formattedTime = ''; // TODO: presenter.formatTimeOfDay(prefs.hour, prefs.minute);

    return ReminderRow(
      enabled: prefs.enabled, // controller defaults this to false — off by default.
      title: '', // TODO: l10n.reminderTitle
      honestLine: '', // TODO: l10n.reminderHonestLine — transcreation, local-only fact, no rhetoric.
      formattedTime: formattedTime,
      timeSemanticsLabel: '', // TODO: l10n.reminderTimeA11yLabel — per-locale.
      onEnabledChanged: (v) => ref.read(reminderControllerProvider.notifier).setEnabled(v),
      onEditTimePressed: () async {
        // TODO: open a time picker; on result call .setTime(hour, minute).
        // The picker's displayed numerals must follow the locale; resolve via the presenter,
        // not the default Material picker's ASCII digits.
      },
    );
  }
}

// TODO: final reminderControllerProvider = ...   // (from BLOCK 2)
// TODO: final calendarPresenterProvider = ...     // the CalendarPresenter (07-...-correctness.md §4)

// ============================================================================
// BLOCK 4 — packages/features/test/settings/reminder_row_test.dart  (widget-test stub)
// Pin the non-negotiables: off by default, time hidden until enabled, ONE sanctioned line,
// persist-then-schedule ordering, NO guilt/streak copy, NO DateTime.now().
// ============================================================================

// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('reminder is OFF by default and shows the honest local-only line', (tester) async {
//     // TODO: pump ReminderSettingsView with a FAKE NotificationScheduler + in-memory repo.
//     // TODO: expect the switch value == false (off by default — §9).
//     // TODO: expect the time picker affordance is NOT shown while disabled.
//     // TODO: expect the honest one-liner is present and contains NO privacy rhetoric.
//   });
//
//   testWidgets('enabling schedules exactly ONE daily reminder with the sanctioned line', (tester) async {
//     // TODO: toggle on; expect fakeScheduler.scheduleDaily called exactly once.
//     // TODO: expect the body == the transcreation of "Your revision for today is ready."
//     // TODO: expect NO exclamation mark, NO "lose"/"behind"/"streak"/"don't miss" in the body
//     //       (mirror the 11-voice-and-tone.md §9 banned-phrase gate).
//   });
//
//   testWidgets('persist happens BEFORE schedule (single write path)', (tester) async {
//     // TODO: assert the repository.save call is observed before scheduler.scheduleDaily.
//   });
//
//   testWidgets('disabling cancels all reminders in one tap', (tester) async {
//     // TODO: toggle off; expect fakeScheduler.cancelAll called; scheduleDaily not re-called.
//   });
//
//   // No DateTime.now() anywhere in the row/controller — the local-day edge owns the clock.
//   // (07-dates-calendars-and-correctness.md §5; enforced repo-wide by the CI grep gate.)
// }
