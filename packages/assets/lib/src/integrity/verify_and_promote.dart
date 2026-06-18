// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import '../pinned_manifest.dart';
import 'sha256_of_file.dart';

/// The result of verifying one downloaded optional-pack file — a **sealed** type
/// so there is no ambiguous soft path (never a nullable `File?` or a bool +
/// out-param). Either the file is verified and promoted, or it is refused.
sealed class VerifyOutcome {
  /// Const base constructor for the sealed hierarchy.
  const VerifyOutcome();
}

/// The file matched its pinned digest and was promoted to the canonical store.
final class Promoted extends VerifyOutcome {
  /// Creates a promoted outcome carrying the [verified] file.
  const Promoted(this.verified);

  /// The verified file at its promoted (canonical) location.
  final File verified;
}

/// The file did not match after exactly one re-fetch — the caller **refuses to
/// render Quran text**; no degraded render, no flag-later.
final class Refused extends VerifyOutcome {
  /// Creates a refused outcome for [fileName].
  const Refused(this.fileName);

  /// The name of the file that failed verification.
  final String fileName;
}

/// The total, fail-closed verification state machine for one **downloaded**
/// (optional-pack) file (engineering 09 §3; bundle-first: the core is bundled
/// and verified via the asset vault, not this download path).
///
/// Branches, every one enumerated, no third path and **exactly one** re-fetch:
/// - matches first attempt → promote → [Promoted];
/// - mismatch → delete + re-fetch **once** via [refetch];
/// - re-fetch matches → promote → [Promoted];
/// - re-fetch mismatches → delete → [Refused];
/// - missing / truncated / unreadable → treated identically to a mismatch (a
///   short file's digest differs by the avalanche property; an absent file
///   never matches).
///
/// The expected digest comes **only** from [entry] (the binary-baked manifest),
/// never a sidecar `SHA256SUMS`. [downloaded] is the first temp `.part`;
/// [refetch] re-downloads it once (the caller's injected callback — no socket
/// here); [promote] moves a verified temp file to its canonical location
/// (injected so tests need no real app-documents directory).
Future<VerifyOutcome> verifyAndPromote({
  required ManifestEntry entry,
  required File downloaded,
  required Future<File> Function() refetch,
  required Future<File> Function(File verified) promote,
}) async {
  if (digestMatches(await _safeHash(downloaded), entry.sha256)) {
    return Promoted(await promote(downloaded));
  }
  await _deleteQuietly(downloaded);

  final retry = await refetch();
  if (digestMatches(await _safeHash(retry), entry.sha256)) {
    return Promoted(await promote(retry));
  }
  await _deleteQuietly(retry);
  return Refused(entry.name);
}

/// Hashes [file], or returns a sentinel that can never match a real digest if
/// the file is missing/unreadable — so an absent or truncated file is a
/// mismatch by construction, never an uncaught throw.
Future<String> _safeHash(File file) async {
  try {
    return await sha256OfFile(file);
  } on FileSystemException {
    return '';
  }
}

Future<void> _deleteQuietly(File file) async {
  try {
    if (file.existsSync()) await file.delete();
  } on FileSystemException {
    // Best-effort: an unverified .part is never read as Quran regardless.
  }
}
