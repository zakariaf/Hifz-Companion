// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The one sealed error type the `data` layer raises — surfaced to the feature
/// layer to handle exhaustively, never swallowed, never logged with user data.
///
/// Mapping is total in the normal case: a row that passed its `CHECK`s decodes
/// cleanly, so a [MappingException] is the schema/enum-drift escape hatch only.
/// The single write path (E03-T07) reuses this type — it does not invent a
/// parallel one.
sealed class PersistenceException implements Exception {
  /// Creates a persistence exception with a human-readable [message] (never
  /// shown to the user — UI copy is localized at the feature layer).
  const PersistenceException(this.message);

  /// A developer-facing description of the failure.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A stored row could not be decoded into its `models` value type — an
/// out-of-set enum token or a malformed `*_json` payload that bypassed its
/// `CHECK` (schema/enum drift).
final class MappingException extends PersistenceException {
  /// Creates a mapping exception describing the offending column/value.
  const MappingException(super.message);
}
