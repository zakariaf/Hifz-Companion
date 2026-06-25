// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show activeProfileProvider, profileRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/models.dart' show Profile;

import 'display_preferences.dart';
import 'preferences_writer.dart';

/// The active profile's row, streamed reactively (null until a profile exists
/// and is selected). It re-emits after every committed preference write, so the
/// app chrome (theme, calendar, numerals) re-renders without a second cache
/// (eng-create-riverpod-store §5). Keyed implicitly by [activeProfileProvider]:
/// a halaqa switch re-subscribes it to the new student's row.
final activeProfileRecordProvider = StreamProvider<Profile?>((ref) {
  final id = ref.watch(activeProfileProvider);
  if (id == null) return Stream<Profile?>.value(null);
  return ref.watch(profileRepositoryProvider).watchById(id);
});

/// The active profile's decoded [DisplayPreferences] — a pure display projection
/// of `settings_json`, falling back to the calm per-field defaults until a
/// profile (or a stored value) exists. The View reads this for a picker's
/// current selection; the app root reads it to choose the theme/calendar.
final displayPreferencesProvider = Provider<DisplayPreferences>((ref) {
  final profile = ref.watch(activeProfileRecordProvider).asData?.value;
  return DisplayPreferences.fromSettings(profile?.settings);
});

/// The single write path for preference mutations — reads the current active
/// profile id on demand and persists transactionally before the
/// [activeProfileRecordProvider] stream republishes.
final preferencesWriterProvider = Provider<PreferencesWriter>((ref) {
  return PreferencesWriter(
    profiles: ref.watch(profileRepositoryProvider),
    readActiveProfileId: () => ref.read(activeProfileProvider),
  );
});
