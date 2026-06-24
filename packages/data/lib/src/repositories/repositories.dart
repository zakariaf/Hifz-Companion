// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The framework-free repository interfaces the [PersistenceHandle] exposes —
/// the public seam the shell reaches persistence through (01 §2, §4).
///
/// They reference `models` value types only — no `package:drift`/`sqlite3`
/// symbol appears here, so the boundary cannot leak a Drift type into the
/// engine/features/quran layers. The single-write-path `commitReview` lives on
/// [ReviewRepository]; the read seams the shell consumes (the Today queue, the
/// app-ready gate) are declared here.
library;

import 'package:models/models.dart';

/// Reads `card` rows as `models` value types; the only write path is the
/// transactional [ReviewRepository] / [ColdStartRepository] (never a raw upsert
/// from a widget).
abstract interface class CardRepository {
  /// The card for `(profileId, pageId)`, or `null` if none exists. The
  /// read half of the single write path's read-modify-write (E07-T05).
  Future<Card?> byId(ProfileId profileId, int pageId);

  /// Every card for [profileId] (one row per held/un-held muṣḥaf page), read
  /// once. Used by the write path's read-modify-write and by callers that need
  /// a snapshot rather than a stream.
  Future<List<Card>> forProfile(ProfileId profileId);

  /// A reactive stream of [profileId]'s cards: it emits the current set on
  /// listen and re-emits after every committed write to the `card` table, so the
  /// Today queue re-runs `buildToday` only after a review is durably on disk
  /// (persist-before-republish; 04 §3).
  Stream<List<Card>> watchForProfile(ProfileId profileId);
}

/// Reads and **appends** `review_log` rows — never updates or deletes one (the
/// append-only *sanad* audit trail). The append is part of the single write
/// path ([ReviewRepository.commitReview]); read methods land with their first
/// consumer.
abstract interface class ReviewLogRepository {
  /// The append-only audit rows for one page (oldest first) — the read half the
  /// Progress page-detail sheet renders as a short history (E15-T06). Read-only:
  /// it opens no transaction and appends nothing.
  Future<List<ReviewLog>> forPage(ProfileId profileId, int pageId);
}

/// Reads and writes `profile` rows as `models` value types.
abstract interface class ProfileRepository {
  /// Every profile on this device (the local multi-profile set). Empty on a
  /// fresh install — the app-ready gate reads this to decide whether onboarding
  /// must run before any Quran screen (PRD R1).
  Future<List<Profile>> all();
}

/// Read-only access to the fixed Quran reference structure (the juz→page span,
/// per-page line geometry). Never writes — the muṣḥaf is unwritable at runtime
/// by construction (R1); the checksum-verified asset loader (E05) is the only
/// writer.
abstract interface class ReferenceRepository {
  /// The muṣḥaf page ids in [juz] (1–30), ascending. Empty until the core
  /// reference pack is loaded (E11); a held juz expands to these page cards.
  Future<List<int>> pageIdsForJuz(int juz);

  /// The lines on [pageNumber], in line order — the per-page glyph geometry the
  /// muṣḥaf reader assembles into an immutable page (E13). `Line.textGlyphRef`
  /// is carried **opaque** — never parsed or logged as text (R1). Empty until
  /// the core reference pack is loaded.
  Future<List<Line>> linesForPage(int pageNumber);

  /// The page a jump [target] resolves to (the muṣḥaf reader's jump-to, E13).
  ///
  /// juz/ḥizb/sūrah are **read** from the `page` reference table (`MIN(page_id)`
  /// over the matching column) — never computed (engineering 08 §3); a `page`
  /// target resolves to itself. Returns null for an out-of-range index, and for
  /// juz/ḥizb/sūrah when the reference is not yet loaded (bundle-first) — the
  /// caller stays on the current page rather than guess a sacred boundary.
  Future<int?> firstPageOf(JumpTarget target);

  /// Every scholar-reviewed mutashābihāt group (id + type + note key), ordered —
  /// the calm browse list for the trainer (E14-T06/T07). Empty until the
  /// read-only dataset is loaded (bundle-first).
  Future<List<MutashabihGroup>> allMutashabihGroups();

  /// The assembled view of mutashābihāt group [groupId] — its members each with
  /// their muṣḥaf page and validated distinguishing-word indices — or null if
  /// absent (the discrimination drill, E14-T08/T09). Carries page + indices
  /// only, never reconstructed verse text (R1).
  Future<MutashabihGroupView?> mutashabihGroupView(String groupId);

  /// The id of a mutashābihāt group containing āyah [ayahId], or null if none —
  /// resolves a confusion-hotspot pair to its drillable group (E14-T10).
  Future<String?> mutashabihGroupIdForAyah(String ayahId);
}

/// Reads the app-level `(key, value)` singleton store — a generic `String?`
/// read over `app_meta`. It owns no domain semantics: a caller that knows a key
/// (e.g. the app-ready gate reading the verified-text stamp) interprets the
/// value. There is no public write here — `app_meta` is stamped only by the
/// schema migration and the checksum-verified core installer.
abstract interface class AppMetaRepository {
  /// The value stored at [key], or `null` if the key is absent (never a throw).
  Future<String?> read(String key);
}
