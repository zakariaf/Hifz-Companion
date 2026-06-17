// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// A ḥāfiẓ's cold-start self-assessment of one held juz (PRD §7.10).
///
/// The make-or-break onboarding input `coldStartCard` (E04-T06) consumes: the
/// user marks coverage, then rates each held juz as one of these three bands,
/// from which the engine seeds a conservative `(D, S)` prior. Declared here
/// because the façade signature references it; the concrete seed values
/// (`D=3, S=60` …) are **not** on the enum — they are the E04-T06 seed table.
///
/// An engine-only input enum: a confidence rating is never persisted (only its
/// derived `CardSeed` is), so it lives in `engine`, not `models`.
enum JuzConfidence {
  /// Held strongly — recited recently and reliably. Seeds the most stable
  /// prior (enters the far/manzil band).
  solid,

  /// Held but unsure — stumbles likely. Seeds a middling prior (enters near).
  shaky,

  /// Barely held / long unrevised. Seeds the weakest prior (enters active
  /// revision), so the first real recitation can only surprise upward.
  rusty,
}
