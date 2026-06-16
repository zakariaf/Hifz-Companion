// SCAFFOLD — copy the relevant pieces into the recite/grade feature package, then fill the TODOs.
// The engine value types (`GradeSource`, `ReviewLogEntry`), the design-system token layer
// (AppColors, AppType, AppSpace, AppTouch, AppMotion), and the app providers resolve only inside
// the real workspace packages (docs/engineering project structure). Opening this file standalone
// shows unresolved-symbol errors — that is expected; it is a starting point, not a standalone file.
//
// TeacherSignoffToggle — canonical scaffold for the Hifz Companion talaqqī sign-off control.
//
// Three pieces:
//   1. TeacherSignoffToggle    — the labelled Switch.adaptive ("Teacher present"), RTL + Semantics.
//   2. recite/grade view-model — flips the verdict's SOURCE (self ~0.5 -> teacher 1.0); does NOT
//                                redraw the grade band (that is ui-recite-grade-flow).
//   3. store method            — persists-then-republishes via the single write path, appending a
//                                review_log row with source = teacher (offline, append-only, no server).
//   + TeacherSourcedMark       — the calm "signed off by teacher" marker (shape/glyph + a11y label).
//
// Tokens and engine rules are referenced BY NAME ONLY:
//   type.*, color.*, space.*, touch.min, motion.*  (owned by the design-system docs)
//   sourceConfidence, review_log, source = teacher  (owned by domain-grading-pipeline / PRD §8)
// Never inline hex / dp / ms here, and never restyle the muṣḥaf — this control touches no Quran glyphs.
//
// Governing docs:
//   docs/design-system/07-components.md §7 (the teacher sign-off control), §5 (signed-off stage), §6 (states)
//   docs/PRD.md §8.2 (talaqqī sign-off, sourceConfidence = 1.0, append-only review_log), §8.1 (self ~0.5),
//               §7.12 (teacher supersedes), §15.3 (halaqa = local profile switch), §8.3 (no mic/AI), R6/R3
//   docs/design-system/13-islamic-identity-and-adab.md §6 (servant to the teacher), §4 (no celebration)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Engine-side source signal (lives in the pure engine / data layer — shown here for shape only).
// See domain-grading-pipeline. A teacher carries sourceConfidence = 1.0; self ≈ 0.5.
// ---------------------------------------------------------------------------

enum GradeSource {
  self, // sourceConfidence ≈ 0.5  (PRD §8.1)
  teacher, // sourceConfidence = 1.0  (PRD §8.2) — authoritative, overrides
}

// TODO: import the real GradeSource / ReviewLogEntry from the engine package instead of redeclaring.

// ---------------------------------------------------------------------------
// 1. The control — a labelled Switch.adaptive, pinned in the grade band's lower region.
//    docs/design-system/07-components.md §7 (Switch.adaptive, "Teacher present", lower region).
//    Switch.adaptive keeps our ColorScheme colors while matching the platform switch.
// ---------------------------------------------------------------------------

/// The optional teacher (talaqqī) sign-off toggle shown in the recite/grade flow.
///
/// Flipping it changes the verdict's [GradeSource] only — never the grade itself and never the
/// reveal-on-tap flow (that is **ui-recite-grade-flow**). Visibly distinct from the self-grade so
/// the two are never conflated. Copy is autonomy-supportive ("for your teacher to confirm"),
/// never commanding, localized for fa/ckb/ar.
class TeacherSignoffToggle extends StatelessWidget {
  const TeacherSignoffToggle({
    super.key,
    required this.teacherPresent,
    required this.onChanged,
  });

  /// Whether the verdict is currently attributed to a physically-present teacher.
  final bool teacherPresent;

  /// Called when the teacher-present state flips. Wire to the view-model in piece 2.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // TODO: pull localized "Teacher present" / state copy from the l10n term-set (fa/ckb/ar),
    //       autonomy-supportive ("for your teacher to confirm") — NEVER "the app says you passed".
    final String label = 'TODO.teacherPresentLabel';

    // A ≥ touch.min (48dp) row, RTL-native via EdgeInsetsDirectional, fully semantic.
    return Semantics(
      // Announces label + state in the user's locale: e.g. "Teacher present, off".
      label: label,
      toggled: teacherPresent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48, // TODO: replace literal with AppTouch.min token.
        ),
        child: Padding(
          // RTL-correct insets — leading sits at the start (right) in fa/ckb/ar.
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: 16, // TODO: AppSpace.s4
            vertical: 8, // TODO: AppSpace.s2
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  // TODO: AppType.body / the UI type ramp — never the muṣḥaf glyph font.
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              // .adaptive => native switch on iOS, our ColorScheme everywhere.
              Switch.adaptive(
                value: teacherPresent,
                onChanged: onChanged,
                // TODO: thumb/track colors from AppColors role tokens (M3 state layers, §6).
                // Focus ring is required (WCAG 2.4.7) — keep the default focus affordance.
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. View-model wiring — flip the SOURCE, not the grade band.
//    docs/PRD.md §8.1/§8.2 (self ≈ 0.5 vs teacher = 1.0); the grade band itself is ui-recite-grade-flow.
// ---------------------------------------------------------------------------

/// Immutable UI state for the recite/grade screen (only the sign-off-relevant slice shown).
class ReciteGradeState {
  const ReciteGradeState({
    required this.teacherPresent,
    this.optionalTeacherLabel,
  });

  /// Drives [TeacherSignoffToggle]; when true the submitted verdict's source is `teacher`.
  final bool teacherPresent;

  /// Optional free-text teacher label written to review_log (e.g. a halaqa teacher's name/initials).
  final String? optionalTeacherLabel;

  ReciteGradeState copyWith({bool? teacherPresent, String? optionalTeacherLabel}) =>
      ReciteGradeState(
        teacherPresent: teacherPresent ?? this.teacherPresent,
        optionalTeacherLabel: optionalTeacherLabel ?? this.optionalTeacherLabel,
      );
}

class ReciteGradeViewModel extends AutoDisposeFamilyNotifier<ReciteGradeState, int> {
  @override
  ReciteGradeState build(int pageNumber) {
    // arg is the muṣḥaf page being recited. Self is the default source (lower confidence).
    return const ReciteGradeState(teacherPresent: false);
  }

  /// Toggle whether a physically-present teacher is signing off. Pure UI-state flip — the
  /// authoritative consequence happens at submit (below), through the single write path.
  void setTeacherPresent(bool present) {
    state = state.copyWith(teacherPresent: present);
  }

  /// Submit the verdict produced by the grade band (ui-recite-grade-flow). The ONLY thing the
  /// sign-off changes is the source: teacher => sourceConfidence = 1.0 and authoritative override.
  Future<void> submitVerdict({
    required int pageNumber,
    required int grade, // 1..4 (Again/Hard/Good/Easy) — from ui-recite-grade-flow.
    required List<int> errorLines, // stumble lines — from ui-recite-grade-flow.
  }) async {
    final GradeSource source =
        state.teacherPresent ? GradeSource.teacher : GradeSource.self;

    // TODO: call the single-write-path store method (piece 3). The store, not the view, persists.
    //       A teacher verdict overrides self/algorithm state and may graduate/demote (PRD §7.12).
    await ref.read(gradeStoreProvider).recordVerdict(
          pageNumber: pageNumber,
          grade: grade,
          errorLines: errorLines,
          source: source,
          teacherLabel: source == GradeSource.teacher ? state.optionalTeacherLabel : null,
        );

    // NO celebration on a teacher Good/Easy — recording is quiet (adab §4, PRD R3).
    // Do NOT fire confetti, a chime, a streak bump, or a haptic fanfare here.
  }
}

final reciteGradeViewModelProvider =
    AutoDisposeNotifierProviderFamily<ReciteGradeViewModel, ReciteGradeState, int>(
  ReciteGradeViewModel.new,
);

// ---------------------------------------------------------------------------
// 3. Store / single write path — persist-then-republish, then append review_log.
//    docs/PRD.md §8.2 (append-only review_log, source = teacher, optional label), §7.12 (override),
//    §15.3 (per-student log in halaqa). See eng-create-riverpod-store + eng-add-persisted-model.
//    Fully offline: this method opens NO socket. Transfer to a teacher is export/import only.
// ---------------------------------------------------------------------------

abstract interface class GradeStore {
  /// Records one verdict. For [GradeSource.teacher] this is authoritative: it may set/clear
  /// weak-flags and graduate/demote, overriding prior self/algorithm state for the page.
  ///
  /// Single write path: persist transactionally BEFORE republishing in-memory state, then append
  /// an immutable [ReviewLogEntry] (`source = teacher`) — never mutate persisted state in a view.
  Future<void> recordVerdict({
    required int pageNumber,
    required int grade,
    required List<int> errorLines,
    required GradeSource source,
    String? teacherLabel,
  });
}

final gradeStoreProvider = Provider<GradeStore>((ref) {
  // TODO: override at the composition root with the real Drift-backed store
  //       (and the active profile's review_log in halaqa mode, PRD §15.3).
  throw UnimplementedError('Override gradeStoreProvider at the composition root');
});

// ---------------------------------------------------------------------------
// + The teacher-sourced marker — calm, distinct, color-INDEPENDENT.
//    docs/design-system/07-components.md §7 (visually marked so self/teacher never conflated),
//    §4/§8 (never color alone). Lands on the page card / review_log entry (see ui-page-card).
// ---------------------------------------------------------------------------

/// A small, calm marker shown on a card/log entry whose grade came from a teacher sign-off,
/// so self and teacher inputs are never conflated. Encodes the source with a glyph + an
/// accessible label, never color alone.
class TeacherSourcedMark extends StatelessWidget {
  const TeacherSourcedMark({super.key, this.teacherLabel});

  final String? teacherLabel;

  @override
  Widget build(BuildContext context) {
    // TODO: localized "signed off by teacher" + optional label, fa/ckb/ar; servant-to-teacher tone.
    final String a11y = 'TODO.signedOffByTeacher';
    return Semantics(
      label: a11y,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shape/glyph carries the meaning (not hue): a quiet, sober mark — never a trophy/badge.
          const Icon(Icons.verified_user_outlined, size: 16), // TODO: AppColors.role + AppSpace size token.
          if (teacherLabel != null && teacherLabel!.isNotEmpty) ...[
            const SizedBox(width: 4), // TODO: AppSpace.s1
            Text(
              teacherLabel!,
              style: Theme.of(context).textTheme.labelSmall, // TODO: AppType.caption / secondary.
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Halaqa note (PRD §15.3): there is NO widget here that talks to a server. Halaqa sign-off is
//   switch profile (local) -> recite -> teacher signs off -> next student. Each write lands in
//   that student's own append-only review_log. Any remote teacher-dashboard is forbidden (adab §6).
//
// And the hard no (PRD §8.3): this control introduces NO microphone, recording, speech-to-text,
//   or automatic mistake detection. The teacher judges by ear, exactly as talaqqī does.
// ---------------------------------------------------------------------------
