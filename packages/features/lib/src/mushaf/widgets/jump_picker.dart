// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show persistenceProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show JumpTarget, JumpUnit;

import '../../design_system/theme/spacing_tokens.dart';
import '../mushaf_providers.dart';

/// Opens the calm jump-to picker over the reader (E13-T04). The reader opened at
/// [entryPage] is the reader-state store's family key the seek lands on.
Future<void> showMushafJumpPicker(
  BuildContext context, {
  required int entryPage,
}) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => MushafJumpPicker(entryPage: entryPage),
    );

/// A calm picker to jump to a juz (1–30), ḥizb (1–60), sūrah (1–114), or page
/// (1–604). The target page is **read** from the bundled structure
/// (`ReferenceRepository.firstPageOf` — never computed) and the E13-T03 pager is
/// seeked by setting the reader-state store's page; the jump writes no card,
/// appends no `review_log`, and shows no "unread" nudge or progress badge. Every
/// index renders in the active locale's numeral set, FSI/PDI-safe, with the
/// muṣḥaf itself untouched.
class MushafJumpPicker extends ConsumerStatefulWidget {
  /// Creates the picker seeking the reader opened at [entryPage].
  const MushafJumpPicker({required this.entryPage, super.key});

  /// The reader-state store family key the resolved page is set on.
  final int entryPage;

  @override
  ConsumerState<MushafJumpPicker> createState() => _MushafJumpPickerState();
}

class _MushafJumpPickerState extends ConsumerState<MushafJumpPicker> {
  JumpUnit _unit = JumpUnit.page;

  Future<void> _jumpTo(int index) async {
    final target = JumpTarget(unit: _unit, index: index);
    // Read the resolved page from the bundled structure (never computed). On the
    // bundle-first empty reference a juz/ḥizb/sūrah target resolves to null —
    // stay on the current page rather than guess a sacred boundary.
    final page =
        await ref.read(persistenceProvider).reference.firstPageOf(target);
    if (page != null) {
      ref
          .read(mushafReaderStateProvider(widget.entryPage).notifier)
          .setPage(page);
    }
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  String _unitLabel(AppLocalizations l10n, JumpUnit unit) => switch (unit) {
        JumpUnit.juz => l10n.mushafUnitJuz,
        JumpUnit.hizb => l10n.mushafUnitHizb,
        JumpUnit.surah => l10n.mushafUnitSurah,
        JumpUnit.page => l10n.mushafUnitPage,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final space = theme.extension<SpacingTokens>()!;
    final locale = Localizations.localeOf(context);
    final maxIndex = JumpTarget.maxIndexFor(_unit);

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsDirectional.all(space.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: space.space4,
          children: [
            Text(
              l10n.mushafJumpTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SegmentedButton<JumpUnit>(
              segments: [
                for (final unit in JumpUnit.values)
                  ButtonSegment<JumpUnit>(
                    value: unit,
                    label: Text(_unitLabel(l10n, unit)),
                  ),
              ],
              selected: {_unit},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _unit = selection.first),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 72,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.4,
                ),
                itemCount: maxIndex,
                itemBuilder: (context, i) => _IndexTile(
                  label: formatLocaleNumber(locale, i + 1),
                  onTap: () => _jumpTo(i + 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable index cell — a locale-numeral [label] at the ≥48 dp touch floor.
class _IndexTile extends StatelessWidget {
  const _IndexTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(48),
      ),
      child: Text(label, style: theme.textTheme.titleMedium),
    );
  }
}
