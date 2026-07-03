// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:composition/composition.dart' show activeProfileProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n/l10n.dart';
import 'package:models/models.dart' show Profile, ProfileRole;

import '../design_system/components/destructive_confirm.dart';
import '../design_system/pickers/settings_picker.dart';
import '../design_system/theme/spacing_tokens.dart';
import '../design_system/widgets/mihrab_arch_header.dart';
import 'profiles_providers.dart';

/// The Profiles screen (PRD §15.3): the device-local multi-profile switcher and
/// create. Selecting a profile re-scopes the **whole app** — Today, the heat-map,
/// the `review_log`, and cards — through `activeProfileProvider`, which every
/// read model watches; the switch is one notifier write, no socket (sharing is
/// export/import, E17). A profile is a typed display name + role, no account/PII.
class ProfilesScreen extends ConsumerWidget {
  /// Creates the Profiles screen.
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final profiles = ref.watch(profilesListProvider);
    final activeId = ref.watch(activeProfileProvider);

    return Semantics(
      key: const ValueKey<String>('screen.profiles'),
      identifier: 'screen.profiles',
      container: true,
      label: l10n.profilesScreenTitle,
      explicitChildNodes: true,
      child: Column(
        children: [
          // The pushed screens carry their own miḥrāb niche (there is no shared
          // arch header outside the tab shell). Purely decorative chrome.
          MihrabArchHeader(
            title: l10n.profilesScreenTitle,
            subtitle: l10n.profilesManageSubtitle,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: profiles.when(
                loading: () => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                error: (_, __) => Center(
                  child: TextButton(
                    onPressed: () => ref.invalidate(profilesListProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ),
                data: (list) => ListView(
                  padding: EdgeInsetsDirectional.all(space.space4),
                  children: [
                    for (final profile in list)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(bottom: space.space3),
                        child: _ProfileRow(
                          profile: profile,
                          isActive: profile.profileId == activeId,
                          onTap: () => ref
                              .read(activeProfileProvider.notifier)
                              .select(profile.profileId),
                          onRename: () => _renameProfile(context, ref, profile),
                          // The active profile can't be deleted — switch away
                          // first (avoids deleting the scoped-to profile).
                          onDelete: profile.profileId == activeId
                              ? null
                              : () => _deleteProfile(context, ref, profile),
                        ),
                      ),
                    SizedBox(height: space.space1),
                    _AddProfileButton(
                      label: l10n.profilesAddButton,
                      onTap: () => _createProfile(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createProfile(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String name, ProfileRole role})>(
      context: context,
      builder: (_) => const _CreateProfileDialog(),
    );
    if (result == null) return;
    final name = result.name.trim();
    if (name.isEmpty) return;
    final id = await ref
        .read(profilesControllerProvider)
        .createProfile(displayName: name, role: result.role);
    // Activate the new profile only after its seed is durably committed.
    ref.read(activeProfileProvider.notifier).select(id);
  }

  Future<void> _renameProfile(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameProfileDialog(initial: profile.displayName),
    );
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return;
    await ref
        .read(profilesControllerProvider)
        .renameProfile(profile.profileId, trimmed);
  }

  void _deleteProfile(BuildContext context, WidgetRef ref, Profile profile) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => DestructiveConfirmSheet(
        action: DestructiveAction.wipeProfile,
        strings: DestructiveConfirmStrings(
          // The profile name is bidi-isolated inside the consequence sentence.
          consequence:
              l10n.deleteProfileConsequence(isolate(profile.displayName)),
          confirmLabel: l10n.deleteProfileConfirm,
          cancelLabel: l10n.actionCancel,
        ),
        onConfirmed: () {
          Navigator.of(sheetContext).pop();
          ref.read(profilesControllerProvider).deleteProfile(profile.profileId);
        },
        onCancelled: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }
}

/// One switcher row — the bidi-isolated display name, the role, and the active
/// marker carried by **shape (a filled check) and a label**, never colour alone.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.isActive,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  final Profile profile;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;

    // The avatar tile reads as a glazed teal (self/student) or warm-sand (child)
    // زلیج tile; the active profile's is a solid teal glaze. The active state is
    // ALSO carried by the teal card outline, the "فعال" pill, and `selected` —
    // never colour alone.
    final Color avatarSurface;
    final Color avatarGlyph;
    if (isActive) {
      avatarSurface = scheme.primary;
      avatarGlyph = scheme.onPrimary;
    } else if (profile.role == ProfileRole.child) {
      avatarSurface = scheme.tertiaryContainer;
      avatarGlyph = scheme.onTertiaryContainer;
    } else {
      avatarSurface = scheme.primaryContainer;
      avatarGlyph = scheme.onPrimaryContainer;
    }

    return Semantics(
      button: true,
      selected: isActive,
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(space.space5)),
          side: BorderSide(
            color: isActive ? scheme.primary : scheme.outlineVariant,
            width: isActive ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.space8),
            child: Padding(
              padding: EdgeInsetsDirectional.all(space.space3),
              child: Row(
                children: [
                  Container(
                    width: space.space8,
                    height: space.space8,
                    decoration: BoxDecoration(
                      color: avatarSurface,
                      borderRadius:
                          BorderRadius.all(Radius.circular(space.space3)),
                    ),
                    child: Icon(Icons.person, color: avatarGlyph),
                  ),
                  SizedBox(width: space.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User-typed name (the only PII): first-strong isolated.
                        Text(
                          isolate(profile.displayName),
                          style: text.titleMedium?.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : null,
                          ),
                        ),
                        Text(
                          _roleLabel(l10n, profile.role),
                          style: text.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (isActive) ...[
                    SizedBox(width: space.space2),
                    _ActivePill(label: l10n.profilesActiveLabel),
                  ],
                  PopupMenuButton<_RowAction>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (action) {
                      switch (action) {
                        case _RowAction.rename:
                          onRename();
                        case _RowAction.delete:
                          onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<_RowAction>(
                        value: _RowAction.rename,
                        child: Text(l10n.profilesRename),
                      ),
                      if (onDelete != null)
                        PopupMenuItem<_RowAction>(
                          value: _RowAction.delete,
                          child: Text(l10n.profilesDelete),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _roleLabel(AppLocalizations l10n, ProfileRole role) => switch (role) {
      ProfileRole.self => l10n.profileRoleSelf,
      ProfileRole.student => l10n.profileRoleStudent,
      ProfileRole.child => l10n.profileRoleChild,
    };

/// The calm teal-outlined "فعال" status pill on the active switcher row — the
/// active marker carried by label + shape (never colour alone).
class _ActivePill extends StatelessWidget {
  const _ActivePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: space.space3,
        vertical: space.space1,
      ),
      decoration: ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: scheme.primary)),
      ),
      child: Text(
        label,
        style: text.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The "افزودنِ نمایه" affordance — a dashed-outline tile (an unfinished niche
/// waiting to be filled) with the calm teal add glyph + label. One ≥48dp target.
class _AddProfileButton extends StatelessWidget {
  const _AddProfileButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final space = Theme.of(context).extension<SpacingTokens>()!;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.all(Radius.circular(space.space5)),
          child: CustomPaint(
            painter: _DashedRRectPainter(
              color: scheme.outlineVariant,
              radius: space.space5,
              dashLength: space.space3,
              gapLength: space.space2,
            ),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: space.space8 + space.space3),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: scheme.primary),
                    SizedBox(width: space.space2),
                    Text(
                      label,
                      style: text.labelLarge?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Strokes a dashed rounded-rectangle outline (the "add" tile's edge) using the
/// path metrics of the rounded rect — colour and radius come from tokens.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

  static const double _stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(_stroke / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}

/// The create-profile dialog: a typed display name (the only PII) + a role
/// (self / student / child). Returns `(name, role)` or null on cancel.
class _CreateProfileDialog extends StatefulWidget {
  const _CreateProfileDialog();

  @override
  State<_CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<_CreateProfileDialog> {
  final TextEditingController _name = TextEditingController();
  ProfileRole _role = ProfileRole.student;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final space = Theme.of(context).extension<SpacingTokens>()!;
    return AlertDialog(
      title: Text(l10n.profilesAddButton),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: l10n.profilesNameHint),
          ),
          SizedBox(height: space.space3),
          SettingsPicker<ProfileRole>(
            options: [
              SettingsOption(
                value: ProfileRole.self,
                label: l10n.profileRoleSelf,
              ),
              SettingsOption(
                value: ProfileRole.student,
                label: l10n.profileRoleStudent,
              ),
              SettingsOption(
                value: ProfileRole.child,
                label: l10n.profileRoleChild,
              ),
            ],
            selected: _role,
            onSelected: (role) => setState(() => _role = role),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop((name: _name.text, role: _role)),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

/// The per-row manage actions.
enum _RowAction { rename, delete }

/// The rename dialog — a single display-name field, pre-filled. Returns the new
/// name or null on cancel.
class _RenameProfileDialog extends StatefulWidget {
  const _RenameProfileDialog({required this.initial});

  final String initial;

  @override
  State<_RenameProfileDialog> createState() => _RenameProfileDialogState();
}

class _RenameProfileDialogState extends State<_RenameProfileDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.profilesRename),
      content: TextField(
        controller: _name,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: l10n.profilesNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_name.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
