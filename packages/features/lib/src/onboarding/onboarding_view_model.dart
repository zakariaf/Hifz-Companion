// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui' show Locale;

import 'package:composition/composition.dart';
import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:flutter/foundation.dart' show immutable, mapEquals, setEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show ProfileId, ProfileLocale;

import '../design_system/pickers/cycle_preset_picker.dart' show CyclePreset;
import 'cold_start_seeder.dart' show ColdStartSeeder;
import 'widgets/custom_cycle_editor.dart' show kDefaultDailyBudgetMinutes;

/// The ordered onboarding step sequence (PRD §12.1). The cursor is finite and
/// capped — there is no dynamic step injection and no open feed.
///
/// "When memorized" is **not** a step of its own: PRD §12.1 places the optional
/// date alongside the per-juz confidence pick, so it is a sub-control of
/// [OnboardingStep.confidence] (E11-T07), not a fourth capture pass.
enum OnboardingStep {
  /// Intent + the privacy covenant (E11-T02).
  welcomePrivacy,

  /// UI-language pick, applied live as a display transform (E11-T03).
  language,

  /// Riwāyah / muṣḥaf confirmation — the bundled edition is named (E11-T03).
  riwayahConfirm,

  /// One-time core preparation: verify the bundled muṣḥaf bytes, build the
  /// reference DB, stamp `text_checksum_verified_at` (E11-T04). The default
  /// muṣḥaf is bundled in the binary (tech-decision-log #5 amendment), so this
  /// step verifies and prepares — it does not fetch the core over the network.
  coreSetup,

  /// Coverage capture — which juz the ḥāfiẓ holds (E11-T05).
  coverage,

  /// Per-juz Solid/Shaky/Rusty self-report + the optional "when memorized"
  /// sub-control (E11-T06 / E11-T07).
  confidence,

  /// Named cycle-preset pick + daily budget (E11-T08).
  cyclePreset,

  /// Terminal: the seed is committed and the first day is generated (E11-T09).
  done,
}

/// The calm core-preparation phase the [OnboardingStep.coreSetup] view renders
/// (E11-T04). The core muṣḥaf is bundled, so the phases are verify-and-prepare,
/// never a network download: `idle` → `preparing` → (`ready` | `integrityFailure`).
enum CoreSetupPhase {
  /// Not yet started.
  idle,

  /// Verifying the bundled bytes and building the reference DB.
  preparing,

  /// The muṣḥaf is verified and `text_checksum_verified_at` is stamped.
  ready,

  /// A bundled byte failed its SHA-256 — fail-closed; refuse to render text.
  integrityFailure,
}

/// The state of the final placement commit (E11-T09).
enum PlacementStatus {
  /// Still capturing — the commit has not run.
  capturing,

  /// The seed is committing through the single write path.
  committing,

  /// The commit failed; the summary offers a calm retry (nothing republished).
  failed,
}

/// The four bounded fields a Custom cycle carries (E11-T08). Each maps 1:1 to an
/// `EngineConfig`/`cycle_config` field at the placement commit; there is no raw
/// retention target here — a named choice, never a dial.
@immutable
class CustomCycleConfig {
  /// Creates a custom cycle.
  const CustomCycleConfig({
    required this.farCycleDays,
    required this.nearWindowJuz,
    required this.newLinesPerDay,
  })  : assert(farCycleDays > 0, 'farCycleDays must be > 0 (cycle ceiling)'),
        assert(nearWindowJuz > 0, 'nearWindowJuz must be > 0'),
        assert(newLinesPerDay >= 0, 'newLinesPerDay cannot be negative');

  /// The far/manzil cycle ceiling in days (the trust clamp reads this).
  final int farCycleDays;

  /// The near-window size in juz.
  final int nearWindowJuz;

  /// New lines introduced per day.
  final int newLinesPerDay;

  /// Returns a copy with the given fields replaced.
  CustomCycleConfig copyWith({
    int? farCycleDays,
    int? nearWindowJuz,
    int? newLinesPerDay,
  }) =>
      CustomCycleConfig(
        farCycleDays: farCycleDays ?? this.farCycleDays,
        nearWindowJuz: nearWindowJuz ?? this.nearWindowJuz,
        newLinesPerDay: newLinesPerDay ?? this.newLinesPerDay,
      );

  @override
  bool operator ==(Object other) =>
      other is CustomCycleConfig &&
      other.farCycleDays == farCycleDays &&
      other.nearWindowJuz == nearWindowJuz &&
      other.newLinesPerDay == newLinesPerDay;

  @override
  int get hashCode => Object.hash(farCycleDays, nearWindowJuz, newLinesPerDay);
}

/// The immutable, resume-safe capture for the whole onboarding flow.
///
/// It holds **inputs only**: the chosen locale, the named muṣḥaf edition, the
/// core-prep phase, the held-juz set (absence = `UNMEMORIZED`, never a stored
/// "0%"), the per-juz self-reported [JuzConfidence], the optional per-juz
/// "when memorized" [CalendarDate]s, the named [CyclePreset], the daily budget,
/// and the step [cursor]. There is **no** `D`/`S`/`R`, readiness-%, streak,
/// score, or `DateTime` field — seeding via `coldStartCard` is deferred entirely
/// to the placement commit (E11-T09).
@immutable
class OnboardingState {
  /// Creates the capture state (defaults to a fresh flow at [welcomePrivacy]).
  const OnboardingState({
    this.cursor = OnboardingStep.welcomePrivacy,
    this.locale,
    this.mushafEditionId,
    this.coreSetupPhase = CoreSetupPhase.idle,
    this.coverage = const <int>{},
    this.confidence = const <int, JuzConfidence>{},
    this.memorizedOn = const <int, CalendarDate>{},
    this.cyclePreset,
    this.pureCycleMode = false,
    this.customCycle,
    this.dailyBudgetMinutes,
    this.placement = PlacementStatus.capturing,
  });

  /// The current step.
  final OnboardingStep cursor;

  /// The chosen UI locale (fa / ckb / ar), or null until picked.
  final Locale? locale;

  /// The named riwāyah/edition id (e.g. `kfgqpc_hafs_madani_v2`) — never "the
  /// Quran" in the absolute (R2). Null until confirmed.
  final String? mushafEditionId;

  /// The core-preparation phase (E11-T04).
  final CoreSetupPhase coreSetupPhase;

  /// The held juz (1–30). A juz absent here is `UNMEMORIZED` by absence.
  final Set<int> coverage;

  /// Per-held-juz self-reported confidence.
  final Map<int, JuzConfidence> confidence;

  /// Optional per-held-juz "when memorized" date (sparse; absent ⇒ no decay).
  final Map<int, CalendarDate> memorizedOn;

  /// The named cycle preset (E11-T08), or null until picked.
  final CyclePreset? cyclePreset;

  /// Whether Pure-cycle mode (fixed rotation, fidelity) is on (E11-T08).
  final bool pureCycleMode;

  /// The four bounded Custom fields, set only when [cyclePreset] is `custom`.
  final CustomCycleConfig? customCycle;

  /// The daily revision time budget in minutes, or null until set.
  final int? dailyBudgetMinutes;

  /// The placement-commit status (E11-T09).
  final PlacementStatus placement;

  /// Whether every held juz has a confidence pick (the gate to leave coverage).
  bool get everyHeldJuzRated =>
      coverage.isNotEmpty && coverage.every(confidence.containsKey);

  /// Returns a copy with the given fields replaced.
  OnboardingState copyWith({
    OnboardingStep? cursor,
    Locale? locale,
    String? mushafEditionId,
    CoreSetupPhase? coreSetupPhase,
    Set<int>? coverage,
    Map<int, JuzConfidence>? confidence,
    Map<int, CalendarDate>? memorizedOn,
    CyclePreset? cyclePreset,
    bool? pureCycleMode,
    CustomCycleConfig? customCycle,
    int? dailyBudgetMinutes,
    PlacementStatus? placement,
  }) =>
      OnboardingState(
        cursor: cursor ?? this.cursor,
        locale: locale ?? this.locale,
        mushafEditionId: mushafEditionId ?? this.mushafEditionId,
        coreSetupPhase: coreSetupPhase ?? this.coreSetupPhase,
        coverage: coverage ?? this.coverage,
        confidence: confidence ?? this.confidence,
        memorizedOn: memorizedOn ?? this.memorizedOn,
        cyclePreset: cyclePreset ?? this.cyclePreset,
        pureCycleMode: pureCycleMode ?? this.pureCycleMode,
        customCycle: customCycle ?? this.customCycle,
        dailyBudgetMinutes: dailyBudgetMinutes ?? this.dailyBudgetMinutes,
        placement: placement ?? this.placement,
      );

  @override
  bool operator ==(Object other) =>
      other is OnboardingState &&
      other.cursor == cursor &&
      other.locale == locale &&
      other.mushafEditionId == mushafEditionId &&
      other.coreSetupPhase == coreSetupPhase &&
      setEquals(other.coverage, coverage) &&
      mapEquals(other.confidence, confidence) &&
      mapEquals(other.memorizedOn, memorizedOn) &&
      other.cyclePreset == cyclePreset &&
      other.pureCycleMode == pureCycleMode &&
      other.customCycle == customCycle &&
      other.dailyBudgetMinutes == dailyBudgetMinutes &&
      other.placement == placement;

  @override
  int get hashCode => Object.hash(
        cursor,
        locale,
        mushafEditionId,
        coreSetupPhase,
        Object.hashAllUnordered(coverage),
        Object.hashAllUnordered(confidence.keys),
        Object.hashAllUnordered(confidence.values),
        Object.hashAllUnordered(memorizedOn.keys),
        Object.hashAllUnordered(memorizedOn.values),
        cyclePreset,
        Object.hash(
          pureCycleMode,
          customCycle,
          dailyBudgetMinutes,
          placement,
        ),
      );
}

/// The complete, immutable input to the placement commit (E11-T09), assembled
/// from the captured [OnboardingState] + the injected `today`. It carries no
/// `DateTime` and no seeded `(D, S)` — only the user's captured self-report.
@immutable
class PlacementInput {
  /// Creates the placement input.
  const PlacementInput({
    required this.coverage,
    required this.confidence,
    required this.memorizedOn,
    required this.cyclePreset,
    required this.pureCycleMode,
    required this.customCycle,
    required this.dailyBudgetMinutes,
    required this.locale,
    required this.today,
  });

  /// The held juz (1–30).
  final Set<int> coverage;

  /// Per-held-juz confidence.
  final Map<int, JuzConfidence> confidence;

  /// Optional per-held-juz "when memorized" dates.
  final Map<int, CalendarDate> memorizedOn;

  /// The named cycle preset.
  final CyclePreset cyclePreset;

  /// Whether Pure-cycle mode is on.
  final bool pureCycleMode;

  /// The four bounded Custom fields (used only when [cyclePreset] is custom).
  final CustomCycleConfig? customCycle;

  /// The daily revision time budget in minutes.
  final int dailyBudgetMinutes;

  /// The profile's locale (from the captured UI locale).
  final ProfileLocale locale;

  /// The injected scheduling "today" — every seeded card is due now.
  final CalendarDate today;
}

/// The injected one-time core-preparation action (E11-T04). It returns the
/// resulting [CoreSetupPhase] — `ready` when the bundled muṣḥaf verifies and the
/// reference DB + checksum stamp are written, `integrityFailure` when a bundled
/// byte fails its SHA-256 (fail-closed). The live adapter over E05's
/// `CoreReferenceInstaller.installCorePack` is wired at the app root once the
/// real bundled assets land; it throws un-overridden so a test must inject a
/// fake (the core install must never be implicit).
final coreSetupActionProvider = Provider<Future<CoreSetupPhase> Function()>(
  (ref) => throw UnimplementedError(
    'coreSetupActionProvider must be overridden at the composition root with '
    'the live installCorePack adapter (E05) or a test fake.',
  ),
);

/// The cold-start seed orchestration, wired from the composition seams (the
/// reference read + the cold-start write path + the pure engine). The placement
/// commit (E11-T09) routes through it; the capture controller never writes
/// directly. Tests override it with a recording/fault-injecting fake.
final coldStartSeederProvider = Provider<ColdStartSeeder>((ref) {
  final persistence = ref.watch(persistenceProvider);
  return ColdStartSeeder(
    reference: persistence.reference,
    coldStart: persistence.coldStart,
    engine: ref.watch(engineProvider),
  );
});

/// The resume-safe onboarding capture controller (E11-T01).
///
/// It is a **pure capture surface**: every command updates the in-memory
/// [OnboardingState] and republishes; none touches a repository, a DAO, or a
/// `db.transaction`, and none invents `(D, S)` or stores a seeded `D`/`S`/`R`.
/// It reads "today" only from the injected [todayProvider] (`CalendarDate`),
/// never `DateTime.now()`. It **navigates nothing** — the View/redirect routes;
/// this controller only publishes [state].
///
/// Sanad-safe by construction: because no row is written before the placement
/// commit (E11-T09), an app kill mid-flow leaves no half-captured persisted
/// state and no half-seeded `Card` — the redirect guard simply restarts
/// onboarding with an empty state (abandon = clean restart, commit-once-at-end).
///
/// `autoDispose` + `family`(`ProfileId?`)-keyed: a fresh device onboards under
/// the `null` scope; re-running placement for an existing profile (teacher mode,
/// E16) is isolated under that profile's id, and abandoning the flow disposes
/// the captured state.
class OnboardingController extends Notifier<OnboardingState> {
  /// Creates the controller for the [profileScope] family key (`null` on a
  /// fresh device's first onboarding).
  OnboardingController(this.profileScope);

  /// The profile this placement is for (`null` for first-run self-onboarding).
  final ProfileId? profileScope;

  @override
  OnboardingState build() => const OnboardingState();

  /// The injected scheduling "today" (read once, never `DateTime.now()`).
  CalendarDate get today => ref.read(todayProvider);

  /// Sets the chosen UI [locale] (applied live as a display transform).
  void setLocale(Locale locale) => state = state.copyWith(locale: locale);

  /// Confirms the named muṣḥaf [editionId] (stores the named choice only, R2).
  void confirmMushaf(String editionId) =>
      state = state.copyWith(mushafEditionId: editionId);

  /// Mirrors the core-preparation [phase] into the captured state so the cursor
  /// guard can fail-closed before the verified muṣḥaf (E11-T04 drives this).
  void setCoreSetupPhase(CoreSetupPhase phase) =>
      state = state.copyWith(coreSetupPhase: phase);

  /// Runs the one-time core preparation (E11-T04): verify the bundled muṣḥaf
  /// bytes, build the reference DB, stamp `text_checksum_verified_at`. The
  /// concrete install is injected via [coreSetupActionProvider] (its live
  /// adapter over E05's `installCorePack` is wired at the app root); this
  /// command only drives the calm phases. **Fail-closed**: any error lands on
  /// [CoreSetupPhase.integrityFailure] — the cursor guard then refuses to reach
  /// coverage, so no muṣḥaf glyph can render from unverified bytes.
  Future<void> runCoreSetup() async {
    // Re-entrancy guard: ignore a trigger while a preparation is already in
    // flight (a rapid double-entry must not run two installs).
    if (state.coreSetupPhase == CoreSetupPhase.preparing) return;
    state = state.copyWith(coreSetupPhase: CoreSetupPhase.preparing);
    try {
      final phase = await ref.read(coreSetupActionProvider)();
      state = state.copyWith(coreSetupPhase: phase);
      if (phase == CoreSetupPhase.ready) {
        // The install just wrote `text_checksum_verified_at`. coreVerifiedProvider
        // is a one-shot FutureProvider that read the (then-absent) stamp at
        // startup and cached `false`; invalidate it so it re-reads the now-present
        // stamp and the redirect guard opens the reader without an app restart.
        ref.invalidate(coreVerifiedProvider);
      }
    } on Object {
      state = state.copyWith(coreSetupPhase: CoreSetupPhase.integrityFailure);
    }
  }

  /// Toggles whether [juz] (1–30) is held; un-holding also drops its confidence
  /// and "when memorized" so they cannot orphan.
  void toggleJuz(int juz) {
    final coverage = Set<int>.of(state.coverage);
    final confidence = Map<int, JuzConfidence>.of(state.confidence);
    final memorizedOn = Map<int, CalendarDate>.of(state.memorizedOn);
    if (coverage.remove(juz)) {
      confidence.remove(juz);
      memorizedOn.remove(juz);
    } else {
      coverage.add(juz);
    }
    state = state.copyWith(
      coverage: coverage,
      confidence: confidence,
      memorizedOn: memorizedOn,
    );
  }

  /// Records the self-reported [confidence] for a **held** [juz] (no-op
  /// otherwise — an un-held juz never carries a rating).
  void setJuzConfidence(int juz, JuzConfidence confidence) {
    if (!state.coverage.contains(juz)) return;
    state = state.copyWith(
      confidence: Map<int, JuzConfidence>.of(state.confidence)
        ..[juz] = confidence,
    );
  }

  /// Records the optional "when memorized" [date] for a **held** [juz].
  void setMemorizedOn(int juz, CalendarDate date) {
    if (!state.coverage.contains(juz)) return;
    state = state.copyWith(
      memorizedOn: Map<int, CalendarDate>.of(state.memorizedOn)..[juz] = date,
    );
  }

  /// Clears the optional "when memorized" date for [juz] (back to skipped —
  /// absence, never a sentinel epoch-zero date).
  void clearMemorizedOn(int juz) {
    if (!state.memorizedOn.containsKey(juz)) return;
    state = state.copyWith(
      memorizedOn: Map<int, CalendarDate>.of(state.memorizedOn)..remove(juz),
    );
  }

  /// Sets the named [preset] (E11-T08 maps it to `EngineConfig` at the commit).
  void setCyclePreset(CyclePreset preset) =>
      state = state.copyWith(cyclePreset: preset);

  /// Toggles Pure-cycle mode (fixed rotation / fidelity) — exactly one flag.
  void setPureCycle({required bool enabled}) =>
      state = state.copyWith(pureCycleMode: enabled);

  /// Sets the four bounded Custom-cycle fields (only meaningful when the
  /// selected preset is `custom`).
  void setCustomCycle(CustomCycleConfig config) =>
      state = state.copyWith(customCycle: config);

  /// Sets the daily revision budget in [minutes].
  void setDailyBudget(int minutes) =>
      state = state.copyWith(dailyBudgetMinutes: minutes);

  /// Whether [next] would advance from the current step (its precondition is
  /// met) — the chrome's Continue affordance reads this to enable/disable.
  bool get canAdvance => _canLeave(state.cursor);

  /// Advances the cursor if the current step's precondition is met. The
  /// precondition for [OnboardingStep.coreSetup] is the fail-closed gate
  /// (`coreSetupPhase == ready`) — no coverage/confidence step is reachable
  /// before the muṣḥaf is verified.
  void next() {
    if (!_canLeave(state.cursor)) return;
    const order = OnboardingStep.values;
    final i = state.cursor.index;
    if (i + 1 < order.length) state = state.copyWith(cursor: order[i + 1]);
  }

  /// Moves the cursor back one step without dropping any captured value.
  void back() {
    final i = state.cursor.index;
    if (i > 0) state = state.copyWith(cursor: OnboardingStep.values[i - 1]);
  }

  /// The placement commit + first-day handoff (E11-T09): commits the captured
  /// placement through the single write path and, **only after** the durable
  /// commit resolves, flips the active profile so the router resolves the first
  /// generated day (the normal Today stream re-emits over the committed cards).
  /// Persist strictly precedes republish; a failed commit republishes nothing
  /// (a calm [PlacementStatus.failed] retry state), and a kill mid-flow leaves
  /// no half-seeded state (the `seedColdStart` transaction rolls back).
  Future<void> commitAndBuildFirstDay() async {
    // Re-entrancy guard (sanad-critical): a rapid double-trigger must never run
    // two seed commits / two write transactions.
    if (state.placement == PlacementStatus.committing) return;
    state = state.copyWith(placement: PlacementStatus.committing);
    try {
      final id = await ref
          .read(coldStartSeederProvider)
          .commitPlacement(_placementInput());
      ref.read(activeProfileProvider.notifier).select(id);
    } on Object {
      state = state.copyWith(placement: PlacementStatus.failed);
    }
  }

  PlacementInput _placementInput() => PlacementInput(
        coverage: state.coverage,
        confidence: state.confidence,
        memorizedOn: state.memorizedOn,
        // A sensible named default if the user left the preset/budget untouched.
        cyclePreset: state.cyclePreset ?? CyclePreset.weeklyKhatm,
        pureCycleMode: state.pureCycleMode,
        customCycle: state.customCycle,
        dailyBudgetMinutes:
            state.dailyBudgetMinutes ?? kDefaultDailyBudgetMinutes,
        locale: _profileLocaleFor(state.locale),
        today: today,
      );

  static ProfileLocale _profileLocaleFor(Locale? locale) =>
      switch (locale?.languageCode) {
        'ar' => ProfileLocale.ar,
        'ckb' => ProfileLocale.ckb,
        _ => ProfileLocale.fa,
      };

  bool _canLeave(OnboardingStep step) => switch (step) {
        OnboardingStep.welcomePrivacy => true,
        OnboardingStep.language => state.locale != null,
        // v1 ships one bundled edition, so the riwāyah step names and confirms
        // it (a display) — the commit defaults `mushafEditionId` when absent.
        OnboardingStep.riwayahConfirm => true,
        OnboardingStep.coreSetup =>
          state.coreSetupPhase == CoreSetupPhase.ready,
        OnboardingStep.coverage => state.coverage.isNotEmpty,
        OnboardingStep.confidence => state.everyHeldJuzRated,
        // A sensible named default (and budget) is applied at the commit if the
        // user leaves the preset/budget untouched, so the step never blocks.
        OnboardingStep.cyclePreset => true,
        OnboardingStep.done => false,
      };
}
