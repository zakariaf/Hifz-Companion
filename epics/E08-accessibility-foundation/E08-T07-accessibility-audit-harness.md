# E08-T07 — PR-blocking accessibility audit harness: contrast, tap-target, and label meetsGuideline as a CI gate

| | |
|---|---|
| **Epic** | [E08 — Accessibility Foundation](EPIC.md) |
| **Size** | M (≈1-2 days) |
| **Depends on** | E08-T02, E08-T03, E08-T06 |
| **Skills** | eng-write-dart-test |

## Goal

A reusable accessibility-audit harness exists under `packages/features/test/a11y/`, asserting Flutter's automated guidelines over the real running E07 shell screens — `meetsGuideline(textContrastGuideline)`, `meetsGuideline(androidTapTargetGuideline)` (48×48 dp), `meetsGuideline(iOSTapTargetGuideline)` (44×44 pt), and `meetsGuideline(labeledTapTargetGuideline)` — plus explicit label-presence assertions over the semantics tree. The tap-target, label, and label-presence checks run in CI's `fast` lane on **every** PR; the contrast check (which needs the real theme/fonts rendered) rides the pinned `@Tags(['golden'])` lane. Together they form a PR-blocking gate (A1/A6/A7) extending E01's lanes: a control below the contrast floor, under 48 dp/44 pt, or without a localized label fails its `meetsGuideline` and blocks the PR. The throwing `HttpOverrides` offline guard stays installed; the harness asserts **behaviour** (the guideline holds), never a coverage percentage.

## Context & references

| Reference | What to take from it |
|---|---|
| `docs/design-system/09-accessibility-and-inclusivity.md` §6 | The touch floor this gate enforces: every interactive control ≥ **48×48 dp** (Android) / **44×44 pt** (iOS), ≥ 8 dp apart; the daily recite/grade controls larger still; quran zoom / OS text-scale must never shrink a hit area below the floor — asserted via `androidTapTargetGuideline` / `iOSTapTargetGuideline` widget tests |
| `docs/design-system/09-accessibility-and-inclusivity.md` §10 (A1/A6/A7) | The release-blocking checklist rows this task implements: **A1** text contrast ≥ 4.5:1 (≥ 3:1 large) via `meetsGuideline(textContrastGuideline)` over golden screens; **A6** targets ≥ 48×48 dp / 44×44 pt via `androidTapTargetGuideline` / `iOSTapTargetGuideline`; **A7** every control a localized label via `labeledTapTargetGuideline` + the ARB-coverage gate. "Automated checks catch the easy 80%" — this harness is that 80%; the RTL/multilingual 20% is E08-T08 (traversal) and E08-T09 (manual A9), never replaced by this gate |
| `docs/engineering/12-localization-rtl-accessibility-impl.md` §8 | The localization & accessibility gate table: the **Accessibility** row — "Widget `SemanticsTester` + manual TalkBack/VoiceOver pass" catching unlabeled controls, small targets, scale break — is the row this task wires as a build failure; the gate is layered and mostly compile-time/grep, this adds the widget-guideline layer. "We refuse goldens rendered with a placeholder font" — the contrast golden loads the **real** bundled UI fonts, never `Ahem` |
| `docs/PRD.md` §20 | The release gates are pass/fail build checks; accessibility (gate 5 / §20.5) is release-blocking with the same authority as muṣḥaf-integrity and ARB-coverage; this task turns A1/A6/A7 into a PR gate whose results are visible in the public CI logs (auditable by strangers) |
| Skill **eng-write-dart-test** (+ `template.dart`) | The accessibility audit as **widget tests** at the cheapest tier — `meetsGuideline(...)` for contrast / tap-target / label; assert **behaviour, never a coverage percentage** (§10); the throwing `HttpOverrides` offline guard installed via the shared bootstrap (`useOfflineTestPolicy()`, Block H); real bundled fonts via `FontLoader` (never `Ahem`) for the contrast golden (§5/§6); `@Tags(['golden'])` for the pinned-OS lane (§5, §8); widget tests use in-memory Riverpod fakes, never a real DB/assets (§6) |
| CLAIMS register | The harness surfaces **no user-facing number or copy of its own** — it is a test gate, so it introduces no CLAIMS row. The gate **defends** C-048 (no-network / banned-import gate stays green: the offline guard is installed in every harness test) and C-031 (accessibility is a release gate). No claim is invented; any due/catch-up value in a screen under audit remains the trust-clamped engine value (C-016), unchanged by this task |
| Sibling **E08-T02** | Supplies the labeled/merged semantics tree the `labeledTapTargetGuideline` and label-presence assertions traverse: the `a11y/semantics.dart` helpers (`labeled`/`mergedItem`/`decoration`) applied to `HomeShell` nav items and the four placeholder cards. T02 wired `labeledTapTargetGuideline` over the shell as a smoke check; **this task** makes it the PR-blocking gate |
| Sibling **E08-T03** | Supplies the text-scale path the contrast/clip audit runs against — the audit pumps the shell at 1.0× and at 200% (+ the iOS AX ceiling) so the contrast/label/tap checks hold under scale; T03 owns the legibility goldens, this task owns the guideline gate |
| Sibling **E08-T06** | Supplies the never-color-alone state chips and the color-only-state widget-audit; this harness runs **alongside** that audit in the same `fast` lane so a color-only state and a sub-floor contrast pair both fail on the same PR. T06's audit is bespoke; this task's `meetsGuideline` set is the Flutter-stock complement |
| Siblings **E08-T08 / E08-T09 / E08-T10** | T08's per-locale RTL traversal test and T09's recorded A9 manual procedure are the human/RTL 20% this automated gate cannot judge — both depend on this harness being green first; T10's deliberate-violation proof flips each guideline red on purpose to prove the gate checks something, then reverts |

## Implementation notes

TEST-FIRST: this task **is** the test (the harness is the deliverable). Write each guideline assertion against the current E07 shell so it passes green; the deliberate-violation proof that each guideline can go red is sibling E08-T10. Do not introduce any production code beyond a tiny shared audit helper if one removes duplication.

1. **Harness location.** `packages/features/test/a11y/accessibility_audit.dart` — a small shared helper (not a `_test.dart`), exposing one function per concern that any screen's audit test calls, e.g. `Future<void> auditShellAccessibility(WidgetTester tester, Widget screen, {required Locale locale})`. It pumps `screen` inside a `ProviderScope` with the E07 in-memory fakes (Drift store + asset loader overridden), under `MaterialApp(locale: locale, localizationsDelegates: …, supportedLocales: …)` so labels resolve through `AppLocalizations`, and runs the guideline set. Keep it thin and downward-only (l10n + the `a11y/` helpers + the shell harness; no engine, no drift, no http). REUSE SPDX header (`GPL-3.0-or-later`) on every file.

2. **Tap-target + label guidelines (the `fast` lane).** `packages/features/test/a11y/shell_tap_target_audit_test.dart` and `…/shell_label_audit_test.dart`. The canonical shape:
   ```dart
   testWidgets('HomeShell meets the Android 48×48 dp tap-target floor (fa)', (tester) async {
     final handle = tester.ensureSemantics();           // semantics on for the audit
     await pumpShellUnderTest(tester, locale: const Locale('fa'));
     await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
     await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));    // 44×44 pt
     await expectLater(tester, meetsGuideline(labeledTapTargetGuideline)); // every tappable node labeled
     handle.dispose();
   });
   ```
   Run these in a `for (final locale in [Locale('ar'), Locale('fa'), Locale('ckb')])` loop so the label audit exercises the localized tree in all three. These need **no** real fonts (tap size and label presence are font-independent), so they stay in the `fast` lane — no `@Tags(['golden'])`.

3. **Label-presence assertions (defence in depth).** `labeledTapTargetGuideline` proves *tappable* nodes are labeled; add an explicit pass over the semantics tree (`tester.getSemantics(...)` / a `SemanticsTester`-style walk) asserting each `HomeShell` nav item exposes a non-empty localized `label` and a `button`/`header` role, and that no English label leaks in a non-`ar` build (compare against the ARB value, not a literal). This catches a *non-tappable but should-be-announced* element the guideline would miss.

4. **Contrast guideline (the pinned `golden` lane).** `packages/features/test/a11y/shell_contrast_audit_test.dart`, `@Tags(['golden'])` + `library;`. `textContrastGuideline` measures rendered foreground/background, so it must load the **real** bundled UI fonts via `FontLoader` in `setUpAll` (never `Ahem`, which would mis-measure), pin `devicePixelRatio`/`physicalSize`/theme, and pump the shell once per appearance the shell exposes (the values live in E06; this asserts the floor over the rendered chrome):
   ```dart
   await expectLater(tester, meetsGuideline(textContrastGuideline));
   ```
   Run it under the chrome themes the shell renders, and (per A1) re-run at 200% text scale via `MediaQuery.withClampedTextScaling`/`textScaler` from the E08-T03 path so contrast holds under scale. Tag-gating routes it to the Linux-only pinned golden CI job.

5. **CI wiring — extend E01's lanes, do not add a job.** The `fast` lane already runs `flutter test` on every PR; the new tap-target/label audit `_test.dart` files run there by default with zero new YAML. The contrast audit, being `@Tags(['golden'])`, runs in the existing `golden` lane. If a thin gate-doc or job comment is needed, follow the CI shape in `docs/engineering/11-testing-strategy.md` §8 (the four-lane mapping) — but the intent is **wiring, not a fifth job**. The public CI logs must show the guideline results so the accessibility trust story is auditable by strangers (PRD §20).

6. **Offline + no-network (non-negotiable, by construction).** Every harness test installs the throwing `HttpOverrides` via the shared bootstrap (`useOfflineTestPolicy()`); the audit pumps in-memory fakes only; a banned-import grep over `features/test/a11y` finds no `http`/`dio`/`dart:io HttpClient`/`drift` symbol. The audit opens no socket and reaches no model — it is local widget rendering plus the stock Flutter guideline matchers.

7. **Sacred-text boundary.** The harness audits **chrome only** — `HomeShell` nav and the inert placeholder cards. It never pumps, audits, or contrast-measures the muṣḥaf glyph layer: the glyph fonts are not OS-scaled, the reader is fed the page *reference* (E08-T02), and no audit assertion derives from a QPC glyph codepoint. The contrast guideline runs over UI text on UI surfaces, never over a rendered āyah.

8. **Pitfalls to avoid.** Forgetting `tester.ensureSemantics()` (the tap-target/label guidelines silently pass with an empty tree); putting the **contrast** test in the `fast` lane (it needs real fonts/theme → the `golden` lane, or it mis-measures or flakes across hosts); rendering the contrast golden with `Ahem` (defeats the measurement); auditing a toy widget instead of the real `HomeShell` (the harness proves nothing about the running app — the whole point of depending on E07); asserting a coverage percentage anywhere (forbidden — assert the guideline holds); calling `pumpAndSettle()` on a screen with an indefinite indicator (pump explicit durations); leaving the deliberate-violation proof in this task (that is E08-T10 — here the gate is green).

## Acceptance criteria

- [ ] `packages/features/test/a11y/accessibility_audit.dart` exists as a thin shared helper that pumps an E07 shell screen under a given `Locale` with in-memory Riverpod fakes and `AppLocalizations` wired, with `ensureSemantics()` enabled; it is downward-only (no engine/drift/http import) and carries the REUSE SPDX header.
- [ ] A `fast`-lane widget test asserts `meetsGuideline(androidTapTargetGuideline)` **and** `meetsGuideline(iOSTapTargetGuideline)` over `HomeShell` (and the four placeholder cards) in `ar`/`fa`/`ckb`, and passes against the current shell.
- [ ] A `fast`-lane widget test asserts `meetsGuideline(labeledTapTargetGuideline)` over the shell in all three locales, plus an explicit semantics-tree pass that every nav item has a non-empty **localized** label + a `button`/`header` role and no English label leaks in a non-`ar` build.
- [ ] A `@Tags(['golden'])` test asserts `meetsGuideline(textContrastGuideline)` over the rendered shell on the **real** bundled UI fonts (never `Ahem`), pinned DPR/size, across the chrome themes the shell exposes, including a 200%-text-scale pass.
- [ ] The tap-target/label audits run in CI's `fast` lane and the contrast audit in the `golden` lane **on every PR**, with **no new CI job** added; the guideline results are visible in the public CI logs.
- [ ] A control made deliberately unlabeled / sub-48 dp / below the contrast floor would fail its `meetsGuideline` (this is *proven* in E08-T10; here each guideline is asserted and green).
- [ ] No harness test asserts a coverage percentage; every test asserts a guideline/label behaviour with a meaningful `expect`/`expectLater`.

## Tests

This task's deliverable **is** the test suite; all files live under `packages/features/test/a11y/`, `flutter_test`, run on every PR. Each carries the REUSE SPDX header (`GPL-3.0-or-later`), installs the throwing `HttpOverrides` (`useOfflineTestPolicy()`), and uses in-memory Riverpod fakes (never a real DB/assets). Fixtures are inline literals; `today` is a fixed `SerialDay`/`CalendarDate` (no `DateTime.now()`).

- `accessibility_audit.dart` — shared helper (not a `_test.dart`): `pumpShellUnderTest(tester, {required Locale locale})` and per-concern `auditTapTargets` / `auditLabels` functions, with `ensureSemantics()`.
- `shell_tap_target_audit_test.dart` — **`fast` lane**: for each of `ar`/`fa`/`ckb`, `expectLater(tester, meetsGuideline(androidTapTargetGuideline))` and `meetsGuideline(iOSTapTargetGuideline)` over `HomeShell` + the four placeholder cards; passes green.
- `shell_label_audit_test.dart` — **`fast` lane**: for each locale, `meetsGuideline(labeledTapTargetGuideline)`; plus a semantics-tree walk asserting each nav item exposes a non-empty localized label (equal to its ARB value, never an English literal) and the right role; no English label in a non-`ar` build.
- `shell_contrast_audit_test.dart` — **`@Tags(['golden'])` (`golden` lane)**: real bundled UI fonts via `FontLoader` in `setUpAll` (never `Ahem`); pinned DPR/size; `meetsGuideline(textContrastGuideline)` over the rendered shell per chrome theme, and once more under 200% text scale (the E08-T03 path).
- **Offline / no-network + gates**: a throwing `HttpOverrides` is installed in every harness test; a banned-import grep over `features/test/a11y` finds no `http`/`dio`/`HttpClient`/`drift`/glyph-layer symbol; E01's banned-import + dependency allow-list gates stay green (C-048); the `features/**` hardcoded-string, physical-side, and ASCII-digit greps stay green. No test asserts a coverage percentage.

## Definition of Done

- [ ] All acceptance criteria met; the tap-target + label audits are green in CI's `fast` lane and the contrast audit green in the `golden` lane on every PR; the guideline results appear in the public CI logs.
- [ ] **Offline / no-network** (non-negotiable): every harness test installs a throwing `HttpOverrides` and pumps in-memory fakes only; `features/test/a11y` imports no `package:http`/`dio`/`dart:io HttpClient` and opens no socket; E01's no-network + banned-import gates stay green (C-048).
- [ ] **No AI / no microphone** (non-negotiable): the harness is widget rendering plus stock Flutter guideline matchers — no ASR, ML, model, audio, or microphone permission; the screen-reader path under audit is one-way OS output and records nothing.
- [ ] **Quran text fidelity** (non-negotiable): the harness audits chrome only; it never pumps, contrast-measures, or scales the muṣḥaf glyph layer, and no assertion derives from a QPC glyph codepoint — the muṣḥaf is untouched by any a11y goal (ds-09 §5, §7; PRD R1).
- [ ] **RTL + fa/ckb/ar localization** (non-negotiable): the label and tap-target audits run under each of `ar`/`fa`/`ckb`; every audited label resolves through `AppLocalizations` (no English literal in a non-`ar` build); the contrast golden loads the real bundled UI fonts, never `Ahem`.
- [ ] **Accessibility** (this epic's subject): the A1/A6/A7 release-checklist rows are PR-blocking automated gates — contrast ≥ floor, targets ≥ 48 dp/44 pt, every control labeled — extending E01's lanes and applied to the real running E07 shell.
- [ ] **Sect-neutral adab / no gamification** (non-negotiable): the harness introduces no user-facing copy, streak, score, badge, or guilt/loss surface; it asserts only that the existing chrome meets the guidelines (C-009).
- [ ] **Nothing safe to drop / no unsourced number**: the harness surfaces no number or claim of its own and invents no CLAIMS id; any due/catch-up value in a screen under audit remains the trust-clamped engine value (C-016), unchanged.
- [ ] **Deterministic tests**: no `DateTime.now()`/`Calendar.current` reachable from the harness; `today` is injected; `ensureSemantics()` is enabled and disposed; explicit pumps (no `pumpAndSettle()` on an indefinite indicator); no test asserts a coverage percentage (eng-write-dart-test §10).
- [ ] **Standards**: every harness file carries the REUSE SPDX header (`GPL-3.0-or-later`), passes the analyzer/lint config, uses full-word/unit-bearing names and typed `catch`, and the shared helper is `///`-documented; the gate is wiring into E01's existing lanes, not a fifth CI job.
