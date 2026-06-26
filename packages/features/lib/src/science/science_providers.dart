// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'claim_row.dart';
import 'claims_register.dart';

/// One thematic section of the science screen: a group (A–J) and its claims, in
/// register order. Read-only — the screen renders it and authors nothing.
@immutable
class ClaimGroupSection {
  /// Creates a section.
  const ClaimGroupSection({required this.group, required this.claims});

  /// The thematic group this section renders.
  final ClaimGroup group;

  /// The group's claims, in register order.
  final List<ClaimRow> claims;

  @override
  bool operator ==(Object other) =>
      other is ClaimGroupSection &&
      other.group == group &&
      listEquals(other.claims, claims);

  @override
  int get hashCode => Object.hash(group, Object.hashAll(claims));
}

/// The whole bundled register, grouped A–J in register order — the read model
/// the "The science we follow" screen renders.
///
/// A pure DI [Provider]: no mutation, no clock, no network, no I/O. The data is
/// the in-binary [claimsRegister], parsed once and memoized (offline, no-AI).
final scienceGroupsProvider = Provider<List<ClaimGroupSection>>(
  (ref) => [
    for (final group in claimGroupsInRegister)
      ClaimGroupSection(group: group, claims: claimsForGroup(group)),
  ],
);

/// The flat register (every row, register order) — for the no-orphan coverage
/// test and any surface that needs a single claim by id.
final scienceRegisterProvider = Provider<List<ClaimRow>>(
  (ref) => claimsRegister,
);
