// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart'
    show cycleConfigRepositoryProvider, todayProvider;
import 'package:engine/engine.dart' show CalendarDate, JuzConfidence;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show Profile, ProfileId;

import '../design_system/theme/spacing_tokens.dart';
import '../onboarding/onboarding_view_model.dart' show coldStartSeederProvider;
import '../onboarding/widgets/confidence_step.dart';
import '../onboarding/widgets/coverage_capture_grid.dart';
import 'profiles_providers.dart';

/// Per-profile placement (E21-T05; F04): rate the held juz of an in-app-created
/// profile (a student/child born with no cards) so its schedule is seeded — the
/// same coverage + Solid/Shaky/Rusty capture as onboarding, scoped to one profile
/// and reached from the Profiles screen. Reuses the onboarding capture widgets +
/// the cold-start seeder; it touches **no** router redirect guard, and commits
/// through the single all-or-nothing write path. Intended for a profile that has
/// no cards yet (a fresh placement, never a re-seed over live state).
class ProfilePlacementScreen extends ConsumerStatefulWidget {
  /// Creates the placement flow for [profileId].
  const ProfilePlacementScreen({required this.profileId, super.key});

  /// The profile being placed.
  final ProfileId profileId;

  @override
  ConsumerState<ProfilePlacementScreen> createState() =>
      _ProfilePlacementScreenState();
}

class _ProfilePlacementScreenState
    extends ConsumerState<ProfilePlacementScreen> {
  final Set<int> _coverage = <int>{};
  final Map<int, JuzConfidence> _confidence = <int, JuzConfidence>{};
  final Map<int, CalendarDate> _memorizedOn = <int, CalendarDate>{};
  bool _justStarting = false;
  bool _rating = false;
  bool _committing = false;

  bool get _everyHeldRated =>
      _coverage.isNotEmpty && _coverage.every(_confidence.containsKey);

  void _toggleJuz(int juz) => setState(() {
        if (_coverage.remove(juz)) {
          _confidence.remove(juz);
          _memorizedOn.remove(juz);
        } else {
          _coverage.add(juz);
          _justStarting = false;
        }
      });

  void _setJustStarting(bool value) => setState(() {
        _justStarting = value;
        if (value) {
          _coverage.clear();
          _confidence.clear();
          _memorizedOn.clear();
        }
      });

  Profile? _profile() {
    final list =
        ref.read(profilesListProvider).asData?.value ?? const <Profile>[];
    for (final p in list) {
      if (p.profileId == widget.profileId) return p;
    }
    return null;
  }

  Future<void> _commit() async {
    if (_committing) return;
    setState(() => _committing = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final profile = _profile();
      final cycle =
          await ref.read(cycleConfigRepositoryProvider).byProfile(widget.profileId);
      // A beginner student (no held juz) seeds nothing — they grow via intake.
      if (profile != null && cycle != null && _coverage.isNotEmpty) {
        await ref.read(coldStartSeederProvider).placeExistingProfile(
              profile,
              cycle,
              coverage: _coverage,
              confidence: _confidence,
              today: ref.read(todayProvider),
              memorizedOn: _memorizedOn,
            );
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePlacementSaved)));
      navigator.pop();
    } on Object {
      if (!mounted) return;
      setState(() => _committing = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonRetry)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePlacementTitle)),
      body: SafeArea(child: _rating ? _confidenceStep(l10n) : _coverageStep(l10n)),
    );
  }

  Widget _coverageStep(AppLocalizations l10n) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    // Continue when some juz are held (→ rate them) or the beginner branch is
    // chosen (→ finish with an empty, intake-grown schedule).
    final canContinue = _coverage.isNotEmpty || _justStarting;
    return Column(
      children: [
        Expanded(
          child: CoverageCaptureGrid(
            heldJuz: _coverage,
            onToggle: _toggleJuz,
            justStarting: _justStarting,
            onJustStarting: _setJustStarting,
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.all(space.space4),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(
              onPressed: !canContinue
                  ? null
                  : (_coverage.isNotEmpty
                      ? () => setState(() => _rating = true)
                      : (_committing ? null : _commit)),
              child: Text(l10n.onboardingContinue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _confidenceStep(AppLocalizations l10n) {
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return Column(
      children: [
        Expanded(
          child: ConfidenceStep(
            heldJuz: _coverage,
            confidence: _confidence,
            onPick: (juz, c) => setState(() => _confidence[juz] = c),
            memorizedOn: _memorizedOn,
            today: ref.read(todayProvider),
            calendarSystem: kDefaultCalendarSystem,
            onSetMemorized: (juz, d) => setState(() => _memorizedOn[juz] = d),
            onClearMemorized: (juz) => setState(() => _memorizedOn.remove(juz)),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.all(space.space4),
          child: Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _rating = false),
                child: Text(l10n.onboardingBack),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _everyHeldRated && !_committing ? _commit : null,
                child: Text(l10n.onboardingContinue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
