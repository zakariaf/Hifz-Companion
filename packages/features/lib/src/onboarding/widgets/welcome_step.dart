// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';

import '../../design_system/theme/spacing_tokens.dart';

/// The first onboarding step (E11-T02): intent + the perceptible privacy
/// covenant + the servant-to-the-teacher framing, then one calm Continue.
///
/// A dumb View — it reads no clock, opens no socket, renders no muṣḥaf glyph,
/// names no edition (the riwāyah is named in E11-T03), and writes no state. It
/// advances only by calling [onContinue]. Every line is a localized `l10n.*`
/// string, calm and exclamation-free; the privacy facts are stated as facts true
/// by construction (C-048) and the servant line credits the teacher (C-046).
class WelcomeStep extends StatelessWidget {
  /// Creates the welcome step; [onContinue] advances the flow.
  const WelcomeStep({required this.onContinue, super.key});

  /// Called when the user taps Continue.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.all(space.space5),
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.onboardingWelcomeIntent,
                    style: text.titleLarge,
                  ),
                ),
                SizedBox(height: space.space5),
                _PrivacyFact(
                  icon: Icons.person_off_outlined,
                  label: l10n.onboardingWelcomePrivacyNoAccount,
                ),
                _PrivacyFact(
                  icon: Icons.mic_off_outlined,
                  label: l10n.onboardingWelcomePrivacyNoMic,
                ),
                _PrivacyFact(
                  icon: Icons.phonelink_lock_outlined,
                  label: l10n.onboardingWelcomePrivacyOnDevice,
                ),
                _PrivacyFact(
                  icon: Icons.wifi_off_outlined,
                  label: l10n.onboardingWelcomePrivacyOfflineAfter,
                ),
                SizedBox(height: space.space4),
                Semantics(
                  label: l10n.onboardingWelcomeServant,
                  child: ExcludeSemantics(
                    child: Text(
                      l10n.onboardingWelcomeServant,
                      style: text.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.all(space.space4),
            child: FilledButton(
              onPressed: onContinue,
              child: Text(l10n.onboardingContinue),
            ),
          ),
        ],
      ),
    );
  }
}

/// One privacy-covenant fact: a functional (non-figurative) leading icon plus
/// its localized statement, merged so a screen reader voices the fact as one
/// node. The icon is redundant emphasis, never the sole carrier of meaning.
class _PrivacyFact extends StatelessWidget {
  const _PrivacyFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.only(bottom: space.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: space.space3,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              Expanded(
                child: Text(label, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
