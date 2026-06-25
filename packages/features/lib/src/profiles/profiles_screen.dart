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
      child: SafeArea(
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
                  padding: EdgeInsetsDirectional.only(bottom: space.space2),
                  child: _ProfileRow(
                    profile: profile,
                    isActive: profile.profileId == activeId,
                    onTap: () => ref
                        .read(activeProfileProvider.notifier)
                        .select(profile.profileId),
                    onRename: () => _renameProfile(context, ref, profile),
                    // The active profile can't be deleted — switch away first
                    // (avoids deleting the profile the app is scoped to).
                    onDelete: profile.profileId == activeId
                        ? null
                        : () => _deleteProfile(context, ref, profile),
                  ),
                ),
              SizedBox(height: space.space3),
              FilledButton.tonalIcon(
                onPressed: () => _createProfile(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.profilesAddButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createProfile(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String name, ProfileRole role})>(
      context: context,
      builder: (_) => const _CreateProfileDialog(),
    );
    final name = result?.name.trim() ?? '';
    if (name.isEmpty) return;
    final id = await ref
        .read(profilesControllerProvider)
        .createProfile(displayName: name, role: result!.role);
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

    return Semantics(
      button: true,
      selected: isActive,
      child: Card(
        elevation: 0,
        color: isActive
            ? scheme.surfaceContainerHighest
            : scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: space.space8),
            child: Padding(
              padding: EdgeInsetsDirectional.all(space.space4),
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.person_outline,
                    color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  SizedBox(width: space.space4),
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
                    Text(
                      l10n.profilesActiveLabel,
                      style: text.labelMedium?.copyWith(color: scheme.primary),
                    ),
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
