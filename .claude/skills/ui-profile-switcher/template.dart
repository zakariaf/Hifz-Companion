// SCAFFOLD — copy the relevant pieces into the /profiles + /settings feature packages, then fill the TODOs.
// The data/engine value types (Profile, ProfileId, CalendarDate, ReviewLogEntry), the design-system token
// layer (AppColors, AppType, AppSpace, AppTouch, AppMotion), and the app providers resolve only inside the
// real workspace packages (docs/engineering project structure). Opening this file standalone shows
// unresolved-symbol errors — that is expected; it is a starting point, not a standalone file.
//
// ProfileSwitcher — canonical scaffold for the Hifz Companion local multi-profile switcher.
//
// Four pieces:
//   1. Profile                — a value type: a typed DISPLAY NAME (+ parentManaged flag). NO PII, no account.
//   2. ProfilesNotifier       — create / rename / SWITCH through the single write path (persist-then-republish).
//                               The active profile re-scopes today's session, review_log, heat-map, cards.
//   3. ProfileSwitcher        — the quiet active-profile chip → short list. RTL + bidi-isolated names + Semantics.
//   4. halaqa note            — switch student -> recite -> ui-teacher-signoff -> next. One device, no server.
//
// Tokens and data/engine rules are referenced BY NAME ONLY:
//   type.*, color.*, space.*, touch.min, motion.*           (owned by the design-system docs)
//   activeProfileId, review_log, CalendarDate               (owned by eng-add-persisted-model / PRD §15.3, §19.3)
// Never inline hex / dp / ms here. This control opens NO socket and reads NO DateTime.now().
//
// Governing docs:
//   docs/PRD.md §15.3 (profiles — local multi-user, no cloud; quick switcher; per-student review_log;
//               child = parent-managed, calm, no gamification; sharing = export/import, never a server),
//               §17 (a profile is just a display name; no account/login/PII), §8.2 (halaqa = local switch),
//               §16 (export/import), §19.3 (engine pure; "today" injected), R3/R5
//   docs/design-system/07-components.md §1/§2 (flat, calm, restrained M3 set), §6 (state layers, focus ring,
//               RTL, Semantics), §3 (term-set strings), §1/§8 (no celebration, no scoreboard)
//   docs/design-system/10-privacy-and-trust-ux.md §1/§8 (privacy is structural; local-first ownership),
//               §2/§3 (bidi-isolated mixed runs), §11 (no dark patterns on switch/create/erase)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// 1. The value type — a profile is a typed DISPLAY NAME, nothing more.
//    docs/PRD.md §17 ("A profile is just a display name the user types") + §15.3.
//    NO email / phone / login / identifier — there is no server, so there is no credential.
// ---------------------------------------------------------------------------

typedef ProfileId = String; // a local opaque id (e.g. a uuid v4) — NOT an account/PII.

/// One device-local profile. Self, a student, or a parent-managed child.
///
/// Carries only a user-typed [displayName] (+ [parentManaged] for a child). It is owned local
/// data, never an account — see **eng-add-persisted-model** for the real `profiles` row, and
/// **domain-backup-format** for how a profile moves to another device (export/import only).
class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    this.parentManaged = false,
  });

  final ProfileId id;

  /// The only thing the user types. May be Latin or Arabic-script — bidi-isolate it on screen.
  final String displayName;

  /// True for a parent-managed child profile (calm, no gamification — PRD §15.3).
  final bool parentManaged;
}

// ---------------------------------------------------------------------------
// 2. The store / single write path — create / rename / SWITCH.
//    docs/PRD.md §15.3 (per-student review_log; device-local), §19.3 ("today" injected, no socket).
//    Switching = set ONE app-scope active-profile state, persisted transactionally BEFORE republishing.
//    Every read model (today's session, review_log, heat-map, cards) keys off activeProfileId.
//    See eng-create-riverpod-store (single write path) + eng-add-persisted-model (the tables).
// ---------------------------------------------------------------------------

/// Immutable UI state for the profile layer.
class ProfilesState {
  const ProfilesState({required this.profiles, required this.activeProfileId});

  final List<Profile> profiles;

  /// The active profile. Re-scopes the WHOLE app. Persisted; survives restart.
  final ProfileId activeProfileId;

  ProfilesState copyWith({List<Profile>? profiles, ProfileId? activeProfileId}) => ProfilesState(
        profiles: profiles ?? this.profiles,
        activeProfileId: activeProfileId ?? this.activeProfileId,
      );
}

/// Repository boundary — the only thing that touches persisted profile state.
/// Single write path: persist transactionally BEFORE the notifier republishes (eng-create-riverpod-store).
abstract interface class ProfilesRepository {
  Future<List<Profile>> loadProfiles();
  Future<ProfileId> loadActiveProfileId();

  /// Create from a typed display name only (+ parentManaged for a child). No PII is accepted.
  Future<Profile> createProfile({required String displayName, bool parentManaged});

  Future<void> renameProfile({required ProfileId id, required String displayName});

  /// Persist the new active profile. After this resolves, in-memory state may republish.
  Future<void> setActiveProfile(ProfileId id);
}

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  // TODO: override at the composition root with the real Drift-backed repository.
  throw UnimplementedError('Override profilesRepositoryProvider at the composition root');
});

class ProfilesNotifier extends AsyncNotifier<ProfilesState> {
  @override
  Future<ProfilesState> build() async {
    final repo = ref.read(profilesRepositoryProvider);
    final profiles = await repo.loadProfiles();
    final activeId = await repo.loadActiveProfileId();
    return ProfilesState(profiles: profiles, activeProfileId: activeId);
  }

  /// Create a profile from a typed display name. NEVER collect an email/phone/login here.
  Future<void> createProfile(String displayName, {bool parentManaged = false}) async {
    final repo = ref.read(profilesRepositoryProvider);
    // Persist FIRST...
    final created = await repo.createProfile(displayName: displayName, parentManaged: parentManaged);
    // ...then republish in-memory state.
    final current = state.requireValue;
    state = AsyncData(current.copyWith(profiles: [...current.profiles, created]));
  }

  Future<void> renameProfile(ProfileId id, String displayName) async {
    final repo = ref.read(profilesRepositoryProvider);
    await repo.renameProfile(id: id, displayName: displayName); // persist first
    final current = state.requireValue;
    state = AsyncData(current.copyWith(
      profiles: [
        for (final p in current.profiles)
          if (p.id == id)
            Profile(id: p.id, displayName: displayName, parentManaged: p.parentManaged)
          else
            p,
      ],
    ));
  }

  /// Switch the active profile. This re-scopes today's session, the review_log, the heat-map,
  /// and the cards to [id]. Persist BEFORE republishing; do NOT mutate state in a view.
  /// QUIET state change — no confetti/chime/streak/haptic fanfare (PRD R3; components §1/§8).
  Future<void> switchTo(ProfileId id) async {
    final repo = ref.read(profilesRepositoryProvider);
    await repo.setActiveProfile(id); // persist first
    final current = state.requireValue;
    state = AsyncData(current.copyWith(activeProfileId: id));
    // The day for the NEW active profile is computed by the pure engine against an injected
    // CalendarDate (PRD §19.3) — never DateTime.now() here. Read models that watch
    // activeProfileProvider will re-scope automatically.
  }
}

final profilesNotifierProvider =
    AsyncNotifierProvider<ProfilesNotifier, ProfilesState>(ProfilesNotifier.new);

/// The single source of truth other read models (session, review_log, heat-map) key off.
/// Every per-profile Drift query should take this as a family key so data never mixes across profiles.
final activeProfileIdProvider = Provider<ProfileId>((ref) {
  return ref.watch(profilesNotifierProvider).requireValue.activeProfileId;
});

// ---------------------------------------------------------------------------
// 3. The switcher widget — a quiet active-profile chip → short list. NOT a server dashboard.
//    docs/design-system/07-components.md §6 (state layers, focus ring, RTL, Semantics), §3 (term-sets).
//    RTL-native via EdgeInsetsDirectional; user-typed names bidi-isolated (privacy-ux §2/§3).
// ---------------------------------------------------------------------------

/// The quick profile switcher: shows whose data is on screen and switches it.
///
/// Device-local only — there is no remote roster or "teacher dashboard" (PRD §15.3, §5 P4 note).
class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(profilesNotifierProvider);

    return asyncState.when(
      loading: () => const SizedBox.shrink(), // quiet, no spinner theatre
      error: (_, __) => const SizedBox.shrink(),
      data: (s) {
        final active = s.profiles.firstWhere((p) => p.id == s.activeProfileId);

        // TODO: localized term-set strings (fa/ckb/ar): "switch profile", "new profile".
        final String switchLabel = 'TODO.switchProfileLabel';

        // A ≥ touch.min (48dp) control, RTL-native, fully semantic.
        return Semantics(
          // e.g. "Active profile: <name>; switch profile" in the user's locale.
          label: '$switchLabel: ${active.displayName}',
          button: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48), // TODO: AppTouch.min
            child: PopupMenuButton<ProfileId>(
              tooltip: switchLabel,
              onSelected: (id) => ref.read(profilesNotifierProvider.notifier).switchTo(id),
              itemBuilder: (context) => [
                for (final p in s.profiles)
                  PopupMenuItem<ProfileId>(
                    value: p.id,
                    // Bidi-isolate a user-typed (possibly Latin) name so it never breaks the RTL row.
                    child: _ProfileName(name: p.displayName, parentManaged: p.parentManaged),
                  ),
                // TODO: a "new profile" entry → create flow (typed display name only, no PII).
              ],
              child: Padding(
                // Leading sits at the START (right) in fa/ckb/ar.
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12, // TODO: AppSpace.s3
                  vertical: 8, // TODO: AppSpace.s2
                ),
                child: _ProfileName(name: active.displayName, parentManaged: active.parentManaged),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Renders a profile name, bidi-isolated for mixed Latin/Arabic runs.
class _ProfileName extends StatelessWidget {
  const _ProfileName({required this.name, required this.parentManaged});

  final String name;
  final bool parentManaged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FSI ... PDI isolates the run so a Latin name can't visually break the RTL line
        // (privacy-ux §2/§3; see eng-rtl-and-bidi-layout for the helper).
        Text(
          '⁨$name⁩', // TODO: use the project's BidiIsolate helper instead of raw FSI/PDI.
          style: Theme.of(context).textTheme.bodyMedium, // TODO: AppType.body
        ),
        // A child profile reads as parent-managed via a calm glyph + label — NEVER a badge/score.
        if (parentManaged) ...[
          const SizedBox(width: 4), // TODO: AppSpace.s1
          // TODO: AppColors role + a localized "child" Semantics, not a decorative trophy.
          const Icon(Icons.family_restroom_outlined, size: 16),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Halaqa note (PRD §15.3, §8.2): there is NO widget here that talks to a server.
//    The halaqa loop is, on ONE device:
//        switchTo(studentId)  ->  recite (ui-recite-grade-flow)
//                             ->  teacher signs off (ui-teacher-signoff, source = teacher)
//                             ->  switchTo(nextStudentId)
//    Each sign-off lands in THAT student's own append-only review_log (keyed by activeProfileId).
//    Cross-device sharing (student -> teacher's phone) is export/import only — domain-backup-format.
//
// Hard no's this control must preserve:
//   - No account / login / PII (PRD §17) — a profile is a typed name.
//   - No socket, no DateTime.now() (PRD §19.3) — schedules are deterministic and offline.
//   - No gamification: no streaks/badges/scores/confetti, no per-profile "completion %" or ranking,
//     least of all on a child profile (PRD R3; components §1/§8; domain-adab-and-religious-integrity).
//   - No microphone / recording / AI (PRD §8.3, R5).
// ---------------------------------------------------------------------------
