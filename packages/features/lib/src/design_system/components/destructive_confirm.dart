// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../state/mihrab_state_layer.dart';
import '../theme/mihrab_colors.dart';
import '../theme/spacing_tokens.dart';

/// The irreversible action a [DestructiveConfirmSheet] guards.
enum DestructiveAction {
  /// Erase all hifz records for everyone on the device (whole-device blast
  /// radius — gated by a second deliberate gesture).
  eraseAll,

  /// Wipe a single profile.
  wipeProfile,

  /// Abort and discard the current draft.
  abortDiscard,
}

/// The localized copy a [DestructiveConfirmSheet] renders — already-localized
/// strings only. [secondConsequence]/[secondConfirmLabel] apply to the
/// whole-device [DestructiveAction.eraseAll]'s second step.
@immutable
class DestructiveConfirmStrings {
  /// Creates the copy bundle.
  const DestructiveConfirmStrings({
    required this.consequence,
    required this.confirmLabel,
    required this.cancelLabel,
    this.secondConsequence,
    this.secondConfirmLabel,
  });

  /// The concrete, irreversible consequence (what is erased / permanent /
  /// nothing recoverable elsewhere).
  final String consequence;

  /// The destructive trigger label (step 1).
  final String confirmLabel;

  /// The SAFE primary label (Cancel / Keep my data).
  final String cancelLabel;

  /// The step-2 consequence (eraseAll only).
  final String? secondConsequence;

  /// The step-2 destructive trigger label (eraseAll only).
  final String? secondConfirmLabel;
}

/// The two-step irreversible-action gate (ui-destructive-confirm; privacy 10
/// §8–§11).
///
/// The **safe** Cancel / Keep-my-data is the visually-primary `FilledButton`,
/// holds default focus + the [MihrabFocusRing], and sits low in the thumb band;
/// the destructive trigger is a plainer secondary affordance in the hard-to-reach
/// top-start corner. A whole-device [DestructiveAction.eraseAll] needs a second
/// deliberate gesture before [onConfirmed]; [onCancelled] is always one easy tap.
/// The leaf performs **no** wipe — it reports the confirmed intent only (the
/// transactional erase is E17). Completion is quiet — no celebration, no alarm
/// flourish.
class DestructiveConfirmSheet extends StatefulWidget {
  /// Creates the gate for [action] with [strings] + the intent callbacks.
  const DestructiveConfirmSheet({
    required this.action,
    required this.strings,
    required this.onConfirmed,
    required this.onCancelled,
    super.key,
  });

  /// The irreversible action being confirmed.
  final DestructiveAction action;

  /// The localized copy.
  final DestructiveConfirmStrings strings;

  /// Fires once, after the (possibly second) deliberate destructive gesture.
  final VoidCallback onConfirmed;

  /// Fires on the safe path — always one easy tap.
  final VoidCallback onCancelled;

  @override
  State<DestructiveConfirmSheet> createState() =>
      _DestructiveConfirmSheetState();
}

class _DestructiveConfirmSheetState extends State<DestructiveConfirmSheet> {
  bool _onSecondStep = false;

  bool get _needsSecondStep => widget.action == DestructiveAction.eraseAll;

  void _onDestructive() {
    if (_needsSecondStep && !_onSecondStep) {
      setState(() => _onSecondStep = true);
    } else {
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MihrabColors>()!;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    final minTouch = Size(space.space8, space.space8);

    final consequence = _onSecondStep
        ? (widget.strings.secondConsequence ?? widget.strings.consequence)
        : widget.strings.consequence;
    final destructiveLabel = _onSecondStep
        ? (widget.strings.secondConfirmLabel ?? widget.strings.confirmLabel)
        : widget.strings.confirmLabel;

    return Padding(
      padding: EdgeInsetsDirectional.all(space.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The destructive trigger sits at the hard-to-reach top-start corner,
          // plainer than the safe action — never the bright/default button.
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: _onDestructive,
              style: TextButton.styleFrom(
                foregroundColor: colors.semanticWarning,
                minimumSize: minTouch,
              ),
              child: Text(destructiveLabel),
            ),
          ),
          SizedBox(height: space.space3),
          Text(consequence, style: text.bodyMedium),
          SizedBox(height: space.space5),
          // The SAFE action is primary + focused, low in the thumb band.
          MihrabFocusRing(
            child: FilledButton(
              onPressed: widget.onCancelled,
              autofocus: true,
              style: FilledButton.styleFrom(minimumSize: minTouch),
              child: Text(widget.strings.cancelLabel),
            ),
          ),
        ],
      ),
    );
  }
}
