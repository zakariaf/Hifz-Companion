// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:models/models.dart';

/// The portable value object (domain-backup-format §1/§4) — the complete,
/// truth-only export of a device's user model and NOTHING else. The shell maps
/// `/data` DAO rows into this; the backup package never queries the DB, so a
/// per-profile export structurally cannot leak another profile's rows.
///
/// It carries only *truth* — per [ProfileExport]: the profile, its cycle config,
/// cards (D/S/`dueAt`/flags), line-blocks, the append-only review log, and
/// confusion edges. **No derived state** (no juz/ḥizb health %, no Today list,
/// no forecast, no notification cache) and **no Quran bytes** — the engine
/// recomputes the former and the muṣḥaf is referenced by [MushafRef] only (§4,
/// R1/R2). The reader recomputes everything derived on first build.
@immutable
class BackupSnapshot {
  /// Creates a snapshot. [exportedAt] is a floating `"YYYY-MM-DD"` day (never a
  /// `DateTime` instant); [schemaVersion] is the Drift `schemaVersion` at export.
  const BackupSnapshot({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.mushaf,
    required this.profiles,
  });

  /// The Drift `schemaVersion` stamped at export time. On import, a value greater
  /// than the reader's current schema is refused as [BackupError.newerFormat]
  /// before any DB write; an older one is migrated forward (§3, §4).
  final int schemaVersion;

  /// The exporting app's version — informational only, NEVER used for logic.
  final String appVersion;

  /// The floating `"YYYY-MM-DD"` day the file was exported (the status-line date).
  final String exportedAt;

  /// The muṣḥaf this device's cards are indexed against — identity only.
  final MushafRef mushaf;

  /// One entry per exported profile (all profiles, or a single one — the package
  /// is store-blind to the scope the shell chose).
  final List<ProfileExport> profiles;
}

/// The muṣḥaf identity a backup records for import-time compatibility (R2) — the
/// lighter `{id, riwayah, name, checksumSha256}`, NEVER the glyphs, fonts,
/// layout, or the mutashābihāt dataset (those are the checksum-governed asset
/// pack, re-derivable on any device; embedding them is a direct R1 hazard, §4).
/// A cross-`id`/`checksumSha256` import is refused, never coerced (§7).
@immutable
class MushafRef {
  /// Records muṣḥaf identity only.
  const MushafRef({
    required this.id,
    required this.riwayah,
    required this.name,
    required this.checksumSha256,
  });

  /// The stable muṣḥaf edition id (e.g. `kfgqpc_hafs_madani_v2`).
  final String id;

  /// The riwāyah, stated explicitly (e.g. `Ḥafṣ ʿan ʿĀṣim`) — never "the Quran".
  final String riwayah;

  /// The human-readable edition name.
  final String name;

  /// The edition's text checksum — the import-time compatibility key.
  final String checksumSha256;
}

/// One profile's complete truth: the [profile] plus its [cycleConfig], [cards],
/// [lineBlocks], the append-only [reviewLog], and [confusionEdges] — each keyed
/// by the stable UUIDs (`profileId`, `logId`, `blockId`) assigned at row creation
/// and carried verbatim. Those UUIDs are the content-address keys that make merge
/// a deduplicating set union over the append-only log (§4/§7).
@immutable
class ProfileExport {
  /// Bundles one profile's authoritative rows.
  const ProfileExport({
    required this.profile,
    required this.cycleConfig,
    required this.cards,
    required this.lineBlocks,
    required this.reviewLog,
    required this.confusionEdges,
  });

  /// The profile record (the only PII is its display name).
  final Profile profile;

  /// The profile's scheduling cycle configuration.
  final CycleConfig cycleConfig;

  /// The per-page scheduling cards (D/S/`dueAt`/flags) — a *cache of the log*,
  /// rebuilt by the engine after import (§7).
  final List<Card> cards;

  /// The memorized line ranges (line numbers only — never Quran text).
  final List<LineBlock> lineBlocks;

  /// The append-only review log — the *sanad* audit trail merge unions over by
  /// `logId`, never overwriting or duplicating a row (§7).
  final List<ReviewLog> reviewLog;

  /// The mutashābihāt confusion edges for this profile.
  final List<ConfusionEdge> confusionEdges;
}
