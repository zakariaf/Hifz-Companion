// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

/// The discrimination-drill route's path prefix under the E07 `ShellRoute`. The
/// full route (`DiscriminationDrillScreen` + its `GoRoute`) is registered in the
/// app router; this constant is the single source of the location both the
/// trainer's group tap and the route registration use, so they can never drift.
const String kMutashabihatDrillPathPrefix = '/mutashabihat/drill';

/// The typed deep-link location for drilling one confusable [groupId].
String mutashabihatDrillLocation(String groupId) =>
    '$kMutashabihatDrillPathPrefix/${Uri.encodeComponent(groupId)}';
