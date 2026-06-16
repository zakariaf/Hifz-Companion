// SCAFFOLD — copy into the owning features package, then fill every // TODO.
// This is NOT a standalone Dart file: the `models`/`engine`/`data` types, the
// `l10n` strings, the muṣḥaf glyph widget, the grading pipeline, and the token
// ThemeExtensions resolve only inside the pub workspace, so opening this file on
// its own shows unresolved-symbol errors. That is expected — it is a starting point.
//
// ReciteGradeScreen — the canonical recite-from-memory + grade surface.
//
//   page hidden → recite from memory → reveal line-by-line on tap →
//   tap stumble lines → grade (Again/Hard/Good/Easy) → next
//   (+ optional in-flow teacher sign-off toggle)
//
// THE BOUNDARY (do not cross it):
//   - This screen produces the user's TAPS: a chosen Grade, the 1-based
//     `errorLines`, the `missedOrAlteredWord` flag, and the `source`.
//   - It hands them to domain-grading-pipeline, which normalizes them into one
//     `ReviewInput`, applies the SACRED-TEXT CAP, and weights source confidence.
//   - The engine (domain-scheduling-engine-rules) does all D/S/R math + the trust
//     clamp + `due_at`. This widget does NO arithmetic and NEVER caps a grade.
//   - The glyph page is composed by domain-mushaf-text-integrity. This flow MASKS
//     the surface and overlays stumble coordinates — it never renders/re-typesets
//     an āyah.
//
// Tokens are referenced BY NAME ONLY (motion.*, space.*, touch.min, haptic.*,
// color.*). The design docs own their concrete values — never inline ms / dp /
// hex / a raw Curve / HapticFeedback.heavyImpact here.
//
// Governing docs:
//   docs/design-system/07-components.md §5 (recite/grade flow), §6 (states), §7 (teacher sign-off)
//   docs/design-system/06-motion-and-haptics.md §1 (short/medium+standard), §2 (no celebration),
//                                               §4 (haptic.selection/confirm), §5 (reduce-motion)
//   docs/design-system/05-layout-spacing-touch.md (touch.min ≥48dp, space.2, ≥56dp grade buttons)
//   docs/PRD.md §8.1 (self-rating reveal-on-tap), §6.3 (verdict verbs), §8.2/§7.12/R6 (teacher),
//               §8.3/C2/R5 (no audio), R1/§11.2 (immutable text), R3/C6 (no gamification)

// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // MODERN api only — NEVER .../legacy.dart

// import 'package:hifz_models/hifz_models.dart';   // PageId, Grade, Source, ReviewInput, immutable UI-state
// import 'package:hifz_l10n/hifz_l10n.dart';        // AppLocalizations — verdict verbs, "reveal", teacher copy
// (token ThemeExtensions: MotionTokens, SpaceTokens — read via Theme.of(context).extension<…>())
// (glyph page: domain-mushaf-text-integrity exposes the immutable per-page widget)
// (grading: domain-grading-pipeline exposes the controller that builds the ReviewInput)

// ===========================================================================
// BLOCK 0 — Immutable UI state + controller (domain-grading-pipeline owns the
// normalizer; this controller only collects taps and the screen's view state).
// Lives in features/recite/. AsyncNotifier per eng-create-riverpod-store.
// ---------------------------------------------------------------------------

/// What the screen is doing right now. The grade band is enabled ONLY in
/// `grading` (i.e. after ≥1 reveal) — 07 §5 / §6.
enum ReciteStage { hidden, revealing, grading, signedOff }

@immutable
class ReciteState {
  const ReciteState({
    required this.stage,
    required this.revealedLineCount,
    required this.stumbleLines, // 1-based line indices the user tapped
    required this.teacherPresent, // source = teacher when true (07 §7)
    required this.missedOrAlteredWord, // raises the flag; the CAP is applied in the pipeline
  });

  final ReciteStage stage;
  final int revealedLineCount;
  final Set<int> stumbleLines;
  final bool teacherPresent;
  final bool missedOrAlteredWord;

  bool get hasRevealed => revealedLineCount > 0; // gates the grade band (07 §5)

  // TODO: add copyWith; keep this immutable (no public setters).
}

// TODO: wire this as an AutoDisposeAsyncNotifierProvider.family keyed by PageId
// (eng-create-riverpod-store §5). The controller exposes:
//   - revealNextLine()           → stage = revealing, revealedLineCount++
//   - toggleStumbleLine(int)     → add/remove from stumbleLines, set missedOrAlteredWord
//   - setTeacherPresent(bool)    → source self↔teacher
//   - submitGrade(Grade)         → hand (grade, errorLines, source, missedOrAlteredWord)
//                                  to domain-grading-pipeline, persist via the single
//                                  write path, THEN advance. Returns an undo handle.
//   - undoLastGrade()            → reverse the just-committed grade (07 §5 undo)
// The controller does NO stability math and NEVER caps the grade itself.

// ===========================================================================
// BLOCK 1 — The screen.
// ---------------------------------------------------------------------------

/// The full-screen recite-from-memory + grade route, opened from a page card.
class ReciteGradeScreen extends ConsumerWidget {
  const ReciteGradeScreen({super.key, required this.pageId});

  // final PageId pageId;
  final Object pageId; // TODO: replace Object with PageId

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final state = ref.watch(reciteControllerProvider(pageId)); // TODO
    // final l10n = AppLocalizations.of(context)!;                // TODO
    // final reduceMotion = MediaQuery.of(context).disableAnimations; // 06 §5

    // RTL is the default and only direction; primitives via eng-rtl-and-bidi-layout.
    // The whole app is wrapped in Directionality(textDirection: rtl) already;
    // never hardcode left/right — use *Directional insets/alignment.
    return Scaffold(
      // TODO: a calm exit/abort in the AppBar leading (start) edge, in thumb reach (07 §5).
      body: SafeArea(
        child: Column(
          children: [
            // TOP: the immutable glyph page, masked → reveal-on-tap. (BLOCK 2)
            const Expanded(child: _ReciteSurface()),
            // BOTTOM (Easy thumb band): the grade band + teacher toggle. (BLOCK 3/4)
            const _GradeBand(),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// BLOCK 2 — The reveal-on-tap surface + stumble-line hit-areas.
// The page is HIDDEN first; the ḥāfiẓ recites from memory; tapping reveals the
// next line. Stumble taps grow each line's hit-area to ≥ touch.min and draw a
// COORDINATE OVERLAY on the immutable glyph layer — never a re-typeset. (07 §5, R1)
// ---------------------------------------------------------------------------

class _ReciteSurface extends ConsumerWidget {
  const _ReciteSurface();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final motion = Theme.of(context).extension<MotionTokens>()!;
    // final space = Theme.of(context).extension<SpaceTokens>()!;
    // final state = ref.watch(reciteControllerProvider(pageId)); // TODO

    return Stack(
      children: [
        // The immutable, byte-exact glyph page — domain-mushaf-text-integrity.
        // We NEVER build glyphs here; we compose its widget and mask/reveal it.
        // const MushafPageGlyphs(pageId: ...), // TODO

        // The mask: an overlay over the surface (NOT a re-layout). Each glyph line
        // sits under a transparent ≥ touch.min hit-area; revealed lines fade in at
        // motion.duration.short / motion.curve.standard (06 §1), instantly under
        // reduce-motion (06 §5). Tapping a revealed line toggles a stumble mark.
        // TODO: for each line index `i`:
        //   - if i >= revealedLineCount: an opaque mask covers the line; the whole
        //     surface taps to reveal the next line (controller.revealNextLine()).
        //   - if i  < revealedLineCount: a transparent Semantics hit-area, height
        //     ≥ touch.min (NOT the visual glyph height), padded with transparent
        //     space so the tap target grows without touching the glyph layer:
        //
        //   GestureDetector(
        //     onTap: () {
        //       ref.read(reciteControllerProvider(pageId).notifier).toggleStumbleLine(i + 1);
        //       HapticFeedback.selectionClick(); // haptic.selection — a discrete, reversible choice (06 §4)
        //     },
        //     behavior: HitTestBehavior.translucent,
        //     child: SizedBox(
        //       height: touchMin, // ≥48dp via SpaceTokens / touch.min — never inline a dp
        //       child: _stumbleOverlay(isMarked: state.stumbleLines.contains(i + 1)),
        //     ),
        //   )
        //
        // _stumbleOverlay draws a quiet coordinate-aligned highlight on TOP of the
        // glyph layer (a CustomPaint over the page rect) — it never reflows text.
      ],
    );
  }
}

// ===========================================================================
// BLOCK 3 — The four-level grade band.
// Four FilledButtons, ≥56dp tall / ≥48dp wide, space.2 apart, in RTL verb order.
// DISABLED until ≥1 reveal (reads as WAITING, not broken — 07 §6). The grade is
// SUGGESTED from the stumble count but stays user-confirmable (07 §5). On commit:
// haptic.confirm + a quiet advance — NEVER a celebration for Good/Easy (06 §2/§4).
// ---------------------------------------------------------------------------

class _GradeBand extends ConsumerWidget {
  const _GradeBand();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context)!;
    // final space = Theme.of(context).extension<SpaceTokens>()!;
    // final state = ref.watch(reciteControllerProvider(pageId)); // TODO
    // final enabled = state.hasRevealed; // disabled-until-revealed (07 §5/§6)

    // RTL verb order (07 §5; verbs from PRD §6.3) — localized, NOT enum names:
    //   Again  → l10n.gradeNeededHelp        Hard → l10n.gradeMinorMistakes
    //   Good   → l10n.gradeRecitedClean      Easy → l10n.gradeEffortless
    // A Row in an RTL Directionality lays these out right-to-left automatically.
    return Padding(
      padding: const EdgeInsetsDirectional.all(0), // TODO: space.4 screen margin via SpaceTokens
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: when !enabled, show a calm hint ("reveal to grade") — WAITING, not error (07 §6).
          Row(
            children: const [
              // _GradeButton(grade: Grade.again, ...),  // ≥56dp tall, ≥48dp wide
              // SizedBox(width: space.2),               // space.2 inter-button gap
              // _GradeButton(grade: Grade.hard, ...),
              // SizedBox(width: space.2),
              // _GradeButton(grade: Grade.good, ...),
              // SizedBox(width: space.2),
              // _GradeButton(grade: Grade.easy, ...),
            ],
          ),
          // SizedBox(height: space.4),
          const _TeacherSignOffToggle(), // BLOCK 4
        ],
      ),
    );
  }
}

/// One grade button. M3 FilledButton (elevation-less emphasis); pressed/disabled/
/// focused via M3 STATE LAYERS over role colors — never ad-hoc opacity (07 §6).
/// A visible focus ring (color.outline) is required (WCAG 2.2 SC 2.4.7).
class _GradeButton extends ConsumerWidget {
  const _GradeButton({
    required this.grade,
    required this.label,
    required this.enabled,
    required this.consequence, // for Semantics: "again — review again soon" (07 §5)
  });

  // final Grade grade;
  final Object grade; // TODO: replace Object with Grade
  final String label;
  final bool enabled;
  final String consequence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      // Announce the verdict AND its consequence so a non-visual user grades confidently (07 §5).
      label: '$label — $consequence',
      button: true,
      enabled: enabled,
      child: SizedBox(
        height: 0, // TODO: ≥56dp via SpaceTokens — never inline 56
        child: FilledButton(
          onPressed: enabled
              ? () async {
                  // Single write path: the controller persists via the pipeline BEFORE
                  // republishing, then advances. We get back an undo handle (07 §5).
                  // await ref.read(reciteControllerProvider(pageId).notifier).submitGrade(grade);
                  HapticFeedback.lightImpact(); // haptic.confirm — a grade is committed (06 §4)
                  // NO success haptic, NO chime, NO confetti — same path for Again and Easy (06 §2).
                  // TODO: show a brief, non-intrusive UNDO affordance (SnackBar) — 07 §5.
                }
              : null, // disabled = WAITING (07 §6); M3 dims via state layer automatically
          child: Text(label), // localized verdict verb; wraps/grows, never truncates
        ),
      ),
    );
  }
}

// ===========================================================================
// BLOCK 4 — The teacher sign-off toggle: the human override, made first-class.
// A Switch.adaptive ("Teacher present") that switches the reported SOURCE
// self↔teacher. It is VISUALLY DISTINCT so self/teacher are never conflated.
// The OVERRIDE semantics (teacher supersedes self + algorithm) live in
// domain-grading-pipeline / the engine — this widget only reports `source`. (07 §7)
// ---------------------------------------------------------------------------

class _TeacherSignOffToggle extends ConsumerWidget {
  const _TeacherSignOffToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final l10n = AppLocalizations.of(context)!;
    // final state = ref.watch(reciteControllerProvider(pageId)); // TODO

    return Semantics(
      // Autonomy-supportive copy: "for your teacher to confirm" — NEVER commanding (07 §7).
      // toggled: state.teacherPresent,
      child: SwitchListTile.adaptive(
        // title: Text(l10n.teacherPresent), // localized fa/ckb/ar, RTL via Directionality
        title: const Text('Teacher present'), // TODO: localize
        value: false, // TODO: state.teacherPresent
        onChanged: (v) {
          // ref.read(reciteControllerProvider(pageId).notifier).setTeacherPresent(v);
          HapticFeedback.selectionClick(); // haptic.selection — a discrete choice (06 §4)
        },
        // TODO: render a visually distinct treatment when ON (a calm teacher affordance),
        // so a teacher-sourced grade is never mistaken for a self-grade (07 §7).
      ),
    );
  }
}
