// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:meta/meta.dart';

/// A local user profile (self, a student, or a child) on this device.
///
/// Stub: it carries no fields yet. The real value type — display name, role,
/// locale, muṣḥaf id, each a `final` field with a `const` constructor and value
/// equality — is authored by the profiles/settings feature epic. As a fieldless
/// `const` value it is equal to every other instance, which is all the stub
/// test needs.
@immutable
class Profile {
  /// Creates a profile.
  const Profile();
}
