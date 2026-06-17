// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The closed value sets shared by the persisted user records.
///
/// Each enum is the Dart half of a schema `CHECK (... IN (...))` constraint
/// (05 §2): every member carries its exact `wireValue` — the lowercase/UPPER
/// token SQLite stores — so the DAO (E03-T06) maps a row to an enum (and back)
/// from one source of truth and a future schema/enum drift is caught by
/// `enums_test.dart`. Modelling these as enums makes an invalid `track`,
/// `grade`, `source`, `role`, or `locale` unrepresentable in memory, the same
/// way the `CHECK` makes it unrepresentable on disk.
library;

/// Which kind of local profile a row describes (05 §2 `role`).
///
/// A device-local distinction only — self, a teacher's student, or a
/// parent-managed child (PRD §15). Never an account or a server identity.
enum ProfileRole {
  /// The device owner's own hifz profile.
  self('self'),

  /// A student whose progress a teacher tracks on this device (halaqa).
  student('student'),

  /// A parent-managed child profile on this device.
  child('child');

  const ProfileRole(this.wireValue);

  /// The exact token stored in the `profile.role` `CHECK` set (05 §2).
  final String wireValue;
}

/// The UI/content language of a profile (05 §2 `locale`).
///
/// The three shipped RTL locales — Arabic (the ARB template/base content
/// language), Persian, and Sorani Kurdish. A locale *code*, never a
/// user-facing label: the rendered language name lives in `l10n`.
enum ProfileLocale {
  /// Arabic — the ARB template / base content language.
  ar('ar'),

  /// Persian (Farsi) — the primary audience locale.
  fa('fa'),

  /// Sorani Kurdish.
  ckb('ckb');

  const ProfileLocale(this.wireValue);

  /// The exact code stored in the `profile.locale` `CHECK` set (05 §2).
  final String wireValue;
}

/// Which revision track a card is on (05 §2 `card.track` / `review_log`).
///
/// The sabaq/sabqi/manzil distinction the engine schedules by: a freshly
/// memorized page (`newPage`), a recent page in the near window (`near`), a
/// page in the long far cycle (`far`), or a page not yet memorized
/// (`unmemorized`). The Dart name `newPage` avoids the `new` keyword; the wire
/// token is the schema's UPPER-case `NEW`.
enum ReviewTrack {
  /// A freshly memorized page being consolidated (sabaq). Wire token `NEW`.
  newPage('NEW'),

  /// A recent page in the near-revision window (sabqi). Wire token `NEAR`.
  near('NEAR'),

  /// A page in the long far-revision cycle (manzil). Wire token `FAR`.
  far('FAR'),

  /// A page not yet memorized — the only track with a null `dueAt`. Wire token
  /// `UNMEMORIZED`.
  unmemorized('UNMEMORIZED');

  const ReviewTrack(this.wireValue);

  /// The exact token stored in the `track`/`track_at_review` `CHECK` set.
  final String wireValue;
}

/// The four-level self-rating or teacher verdict for one revision (05 §2
/// `review_log.grade`).
///
/// The reveal-on-tap grade band (PRD §7.7) — never an audio/AI-inferred score.
/// `again` is the lapse grade that demotes a card; the sacred-text guard means
/// a dropped or altered word is never `good` (grading-pipeline rules, E03-T07
/// consumers).
enum ReviewGrade {
  /// A lapse — recalled wrongly or not at all. Demotes the card. Wire `again`.
  again('again'),

  /// Recalled with difficulty / stumbles. Wire `hard`.
  hard('hard'),

  /// Recalled correctly. Wire `good`.
  good('good'),

  /// Recalled effortlessly. Wire `easy`.
  easy('easy');

  const ReviewGrade(this.wireValue);

  /// The exact token stored in the `review_log.grade` `CHECK` set (05 §2).
  final String wireValue;
}

/// Who produced a grade (05 §2 `review_log.source`).
///
/// Reveal-on-tap self-rating, or an on-device teacher (talaqqī) sign-off — a
/// *sanad* act that overrides the machine. There is no third, AI/audio source
/// by construction (PRD C6).
enum GradeSource {
  /// The ḥāfiẓ's own reveal-on-tap self-rating.
  self('self'),

  /// A physically-present teacher's sign-off (overrides the machine).
  teacher('teacher');

  const GradeSource(this.wireValue);

  /// The exact token stored in the `review_log.source` `CHECK` set (05 §2).
  final String wireValue;
}
