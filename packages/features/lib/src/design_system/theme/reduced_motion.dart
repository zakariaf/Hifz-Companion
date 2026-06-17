// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// Whether the OS has asked to reduce motion — the **single** place the design
/// system reads `MediaQuery.disableAnimations` (design-system 06 §5).
///
/// The OS flag always wins: callers that animate must branch on this and
/// substitute a cross-fade or instant cut; no animation plays "because it is
/// subtle." Nothing the app animates is information-bearing, so the cut hides no
/// meaning (SC 2.3.3). Reads `MediaQuery.of` (not `maybeOf`): an absent
/// `MediaQuery` in this tree is a programmer error the framework asserts on.
bool motionReduced(BuildContext context) =>
    MediaQuery.of(context).disableAnimations;
