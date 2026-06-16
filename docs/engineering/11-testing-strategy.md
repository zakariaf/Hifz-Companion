# 11 — Testing Strategy

This document specifies how Hifz Companion is tested, and how its eight release-blocking gates ([PRD §20](../PRD.md)) become machine-checks that a build either passes or fails. It covers the test pyramid we run, where the deterministic engine lives in it, the golden-vector fixtures that pin the FSRS-style arithmetic, the property-based encoding of the engine invariants ([PRD §7.12](../PRD.md)), the muṣḥaf-fidelity and RTL golden tests, the coverage policy, and the GitHub Actions CI — including the two checks that are unusual for a mobile app and existential for this one: a **no-network** gate and a **text-integrity** gate. It applies the *Decision log: Testing strategy & CI* entry (README decision 9), draws on the *No networking beyond asset download* entry (decision 8), and is grounded in the evidence dossier [research/flutter-testing-ci.md](research/flutter-testing-ci.md), which read every Flutter/Dart testing API and tooling page cited below from a primary source and confirmed each URL resolves.

The boundaries are deliberate. This doc owns the *test architecture and the CI gates*; it does not re-specify the engine math (that is [06-scheduling-engine.md](06-scheduling-engine.md)), the Drift schema under test (that is [05-persistence-and-encryption.md](05-persistence-and-encryption.md)), the glyph-rendering rules the visual-diff verifies ([08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md)), the asset-pack SHA-256 manifest the integrity gate re-hashes ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)), or the localization/RTL surfaces the golden screenshots capture ([12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md)). Those docs define *what* must hold; this doc defines *how we prove it holds, on every push*.

Two rules from the README's outranking pair govern what we test hardest. The first — **the sacred text is never put at risk** — makes the text-integrity gate (§9) and the real-font muṣḥaf goldens (§5) release-blocking and not subject to trade-off: a one-pixel diacritic change fails the build. The second — **the engine may only make a page more frequent, never less** — is encoded literally as a property test (§4) that generates thousands of random review histories and asserts `due_at ≤ cycle_ceiling` never breaks. Everything else in this doc serves those two checks.

## At a glance

| Concern | Decision |
|---|---|
| Pyramid shape | Broad base of unit + property tests on the pure engine and DAOs; widget + golden tests for screens; a small `integration_test` set for the make-or-break journeys ([Flutter: Testing overview](https://docs.flutter.dev/testing/overview)) |
| Engine test runner | **`package:test`**, no `flutter_test`, no widget binding — the engine is pure Dart with injected `today` ([Flutter: Unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)) |
| Engine golden vectors | Pinned input→output fixtures for curve, interval, S/D updates, trust clamp, cold-start seeds — regenerated only by an explicit, reviewed flag ([open-spaced-repetition: FSRS](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)) |
| Invariants | Every [PRD §7.12](../PRD.md) invariant as a **`glados`** property test with shrinking ([glados](https://pub.dev/packages/glados)) |
| Determinism | Same `(cards, config, today)` ⇒ byte-identical plan; asserted as a property; **interval fuzzing OFF** ([PRD §7.12](../PRD.md)) |
| Muṣḥaf goldens | Real **KFGQPC** + UI fonts loaded via `FontLoader` (never Ahem), pinned single OS, fixed DPR/size/theme ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)) |
| RTL goldens | Each key screen captured under `Directionality.rtl` for `ar`/`fa`/`ckb` with locale numerals/calendars ([Flutter: Widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)) |
| No-network gate | Tests keep the default 400-blocking client + a throwing `HttpOverrides`; CI bans networking imports and analytics/ads/backend SDKs ([Flutter API: TestWidgetsFlutterBinding](https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html)) |
| Text-integrity gate | CI re-hashes every asset-pack file (text, 604 fonts, mutashābihāt) against the pinned manifest + the authoritative Tanzil hash ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)) |
| Coverage | `flutter test --coverage` → `lcov.info`, generated files stripped; published for OSS auditability; invariants matter more than a percentage ([Code With Andrea: Test coverage](https://codewithandrea.com/articles/flutter-test-coverage/)) |
| CI runner | `subosito/flutter-action@v2` (v2.23.0), pinned `flutter-version`, Linux for golden stability ([subosito/flutter-action](https://github.com/subosito/flutter-action)) |

---

## 1. The test pyramid: a broad pure-Dart base, a thin device-bound top

### Decision

We adopt Flutter's standard three-tier pyramid (*Decision log: Testing strategy & CI*): a **broad base of unit and property tests** — almost all of them on the pure-Dart `engine/` and the Drift DAOs — a **middle band of widget and golden tests** for the recite/grade flow, the heat-map, and every RTL screen, and a **thin top of `integration_test` journeys** for the four make-or-break flows (cold-start → first day → review → catch-up). The base is the engine; the apex is deliberately small.

### Rationale

- **Flutter's own guidance is explicit about the shape.** Its testing overview defines unit tests (verify "a single function, method, or class," few dependencies, quick, low confidence), widget tests (a single widget's render/interaction, headless, higher confidence), and integration tests (the complete app on a real device/emulator, slowest, highest confidence), and recommends bluntly that "a well-tested app has many unit and widget tests, tracked by code coverage, plus enough integration tests to cover all the important use cases" ([Flutter: Testing Flutter apps](https://docs.flutter.dev/testing/overview)).
- **Our architecture pushes mass to the cheapest tier by design.** Because the scheduler is a pure-Dart package with zero I/O and an injected `today` ([PRD §7.12, §19.1](../PRD.md)), the product's hardest logic — the FSRS arithmetic, the trust clamp, the load balancer, cold-start seeding — is testable at the unit/property tier with no widget binding at all. A pure-Dart package "contains pure business logic with no Flutter or framework dependencies, making it the easiest layer to test" ([Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)). The expensive device tier is reserved for what genuinely needs a real SQLite stack and real rendering.

### Specification

The tiers, what each owns, and where they run:

| Tier | Tool | Scope (Hifz) | Runner | Speed |
|---|---|---|---|---|
| **Unit** | `package:test` | Engine arithmetic; cold-start seeds; load balancer; `CalendarDate` day math; DAO query logic | `dart test` (engine), `flutter test` (data) | fast |
| **Property** | `glados` | Every [§7.12](../PRD.md) invariant over random review histories | `dart test` | fast |
| **Golden — fidelity** | `flutter_test` + `matchesGoldenFile` | The 604 muṣḥaf pages (R1 visual-diff), with real KFGQPC fonts | `flutter test --tags=golden`, **pinned OS** | medium |
| **Golden — layout/RTL** | `flutter_test` + `matchesGoldenFile` / `toStringDeep` | RTL mirroring, heat-map structure, numerals/calendars per locale | `flutter test --tags=golden` | medium |
| **Widget** | `flutter_test` | Reveal-on-tap recite flow, grade buttons, catch-up banner, teacher sign-off toggle | `flutter test` | medium |
| **Integration** | `integration_test` | Cold-start → first day → review → missed-day catch-up | `flutter test integration_test/`, emulator | slow |
| **Gate — no-network** | CI script + analyzer | Dependency allow-list; banned networking imports; airplane-mode acceptance | CI job | n/a |
| **Gate — text-integrity** | CI script | SHA-256 of every asset-pack file vs pinned manifest + Tanzil hash | CI job | n/a |

### Pitfalls / what we refuse

- **We refuse an inverted pyramid.** Integration tests are the slowest, highest-maintenance tier ([Flutter: Testing overview](https://docs.flutter.dev/testing/overview)); we keep their count in single digits and do not push logic that *could* be a unit test up into a device journey. The make-or-break flows justify a device test; "does the grade button increment a counter" does not.
- **We refuse to test the engine through the UI.** Any assertion expressible as `(card, grade, today) → card'` is a unit or property test on `engine/`, never a widget pump. Driving the deterministic core through `pumpWidget` would be slower, flakier, and would hide which layer broke.

---

## 2. The engine is tested with `package:test`, not `flutter_test`

### Decision

The pure-Dart `engine/` package is tested with the standalone **`package:test`** — `test()` / `expect()` / `group()` / `setUp()`, files ending `_test.dart` under `engine/test/`, run with `dart test` — and **never imports `flutter_test`** or requires a widget binding (*Decision log: Testing strategy & CI*). The engine takes `today` as a parameter, so its tests construct it as a literal; nothing in the engine or its tests reads a wall clock.

### Rationale

- **The plain `test` package is the right and fastest home for pure logic.** Flutter's unit-testing cookbook documents exactly this surface: `test()` defines a case, `expect(actual, matcher)` asserts, `group()` organizes, `setUp()` runs before each, and files live in `test/` and run with `flutter test` (or `dart test` for a pure package) ([Flutter: An introduction to unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)).
- **Injecting time is what makes the tests deterministic.** Flakiness in time-dependent code comes from reading the wall clock; the `clock` package exists precisely so library code can call `clock.now()` and tests can pin it with `withClock(Clock.fixed(...))` ([Dart: `clock` package](https://pub.dev/packages/clock)). The engine sidesteps even this by taking `today` as an argument ([PRD §19.3](../PRD.md)), so its tests need no clock fakery at all. `clock`/`fake_async` are reserved for the *app-layer* code around it — notification scheduling and "days since last review" displays ([Dart: `fake_async` package](https://pub.dev/packages/fake_async)).
- **No Flutter binding = no hidden state.** With no `TestWidgetsFlutterBinding`, there is no ambient frame scheduler, no platform channel, and no network interceptor to reason about; an engine test is a function call and an `expect`. This is the structural enforcement of the README's "deterministic, testable scheduling engine" value.

### Specification

```dart
// engine/test/curve_test.dart — pure Dart, no flutter_test import.
import 'package:test/test.dart';
import 'package:hifz_engine/hifz_engine.dart';

void main() {
  group('forgetting curve', () {
    test('R(S, S) == 0.9 by definition of FACTOR', () {
      const s = 17.0;
      // elapsed == S ⇒ retrievability is exactly the 0.9 anchor.
      expect(retrievability(elapsedDays: s, s: s), closeTo(0.9, 1e-9));
    });

    test('interval at target 0.9 equals S', () {
      const s = 42.0;
      expect(interval(s: s, targetR: 0.9), closeTo(s, 1e-9));
    });
  });

  group('onReview is a pure function of (card, review, today)', () {
    test('Again lapses: S shrinks, D rises, weakFlag set', () {
      final engine = SchedulingEngine(EngineConfig.defaults());
      final before = Card.test(pageId: 1, d: 5, s: 30, lastReview: day(100));
      final after = engine.onReview(
        before,
        const ReviewInput(grade: Grade.again, errorLines: [3], source: Source.self_),
        day(130),
      );
      expect(after.lapses, before.lapses + 1);
      expect(after.s, lessThan(before.s));
      expect(after.d, greaterThan(before.d));
      expect(after.weakFlag, isTrue);
    });
  });
}
```

### Pitfalls / what we refuse

- **We refuse `DateTime.now()` anywhere reachable from the engine.** A single wall-clock read makes "identical inputs → identical schedule" untestable; the engine's day type is `SerialDay`, an integer, and the test constructs it directly ([06-scheduling-engine.md](06-scheduling-engine.md), [07-dates-calendars-and-correctness.md](07-dates-calendars-and-correctness.md)).
- **We refuse to pull `flutter_test` into `engine/`.** It is a hard package boundary; a CI import-rule (§7) fails the build if `engine/` ever imports anything from Flutter, keeping the fastest tier permanently fast.

---

## 3. Engine golden vectors: pinning the arithmetic to known-good outputs

### Decision

The FSRS-style arithmetic is pinned with **golden-vector fixtures** — a committed table of `(input state, grade, elapsed days) → (expected D, S, due offset)` rows, asserted to a tight numeric tolerance, **regenerated only by an explicit `--update-vectors` run that a human reviews in the diff** (*Decision log: Testing strategy & CI*). The vectors cover the curve, the interval inversion, both stability branches (success vs. lapse), the difficulty update, the trust clamp, and the five cold-start seeds. They are the engine equivalent of `matchesGoldenFile` for pixels: a frozen reference the implementation must reproduce exactly.

### Rationale

- **FSRS is a published, MIT-licensed equation set with reference ports we can use as oracles.** The reference repo lists implementations in Python, Rust, TypeScript, Dart, Go and more, all MIT, all computing the same DSR update ([open-spaced-repetition: FSRS](https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler)). Because [06-scheduling-engine.md](06-scheduling-engine.md) *vendors* the arithmetic rather than depending on `dart-fsrs`, golden vectors are how we prove our reimplementation matches the canonical math — we can cross-compute a handful of rows against a reference port offline and freeze the results.
- **A frozen fixture catches silent drift.** The PRD makes "scheduler outputs match pinned fixtures (curve, intervals, trust clamp never exceeds ceiling, manzil never dropped, lapse demotes, cold-start seeds)" a release gate ([PRD §20 gate 3](../PRD.md)). A constant mistyped, a branch reordered, or a weight index off-by-one changes a vector and fails CI before it can change a ḥāfiẓ's schedule.
- **Tight tolerance, not equality, is correct for floating-point.** We assert `closeTo(expected, 1e-6)`, not `==`, so a legitimate cross-platform float rounding does not fail while a real arithmetic change does — the same reasoning that puts a pixel tolerance on image goldens.

### Specification

Vectors are a plain Dart data table so the diff is human-readable on review. Each row is computed once against the reference and frozen.

```dart
// engine/test/vectors/fsrs_vectors.dart  — the frozen oracle table.
// Regenerated ONLY by `dart run tool/gen_vectors.dart --update-vectors`,
// which a reviewer must approve in the PR diff. DECAY/FACTOR are named
// constants (FACTOR computed from DECAY), so an FSRS-6 bump is one edit + a
// reviewed re-freeze, never a magic-number patch.
const fsrsVectors = <FsrsVector>[
  // d_in, s_in, grade,        elapsed, d_out,  s_out,   notes
  FsrsVector(5.0, 30.0, Grade.good, 30, 4.78,  72.41,  'on-time Good grows S ~2.4x'),
  FsrsVector(5.0, 30.0, Grade.again, 30, 6.00,  6.12,  'lapse: post-lapse S, D bumped +1'),
  FsrsVector(3.0, 60.0, Grade.easy, 45, 2.61, 188.30, 'Solid juz, Easy, large gain'),
  FsrsVector(7.0,  4.0, Grade.hard, 10, 6.84,   6.93,  'Rusty seed, Hard, modest gain'),
  // … one row per branch + each cold-start seed (Solid/Shaky/Rusty).
];
```

```dart
// engine/test/fsrs_vectors_test.dart
void main() {
  test('vendored FSRS arithmetic reproduces every frozen vector', () {
    final engine = SchedulingEngine(EngineConfig.defaults());
    for (final v in fsrsVectors) {
      final out = engine.onReview(
        Card.test(pageId: 1, d: v.dIn, s: v.sIn, lastReview: day(0)),
        ReviewInput(grade: v.grade, errorLines: const [], source: Source.teacher),
        day(v.elapsed),
      );
      expect(out.d, closeTo(v.dOut, 1e-6), reason: v.notes);
      expect(out.s, closeTo(v.sOut, 1e-6), reason: v.notes);
    }
  });
}
```

The cold-start seed vectors pin [PRD §7.10](../PRD.md)'s exact priors so onboarding can never silently drift:

| Confidence | Seeds (D, S) | Entry track | Frozen assertion |
|---|---|---|---|
| **Solid** | D=3, S=60d | FAR (manzil) | `coldStartCard(…Solid…)` ⇒ `d==3 ∧ s==60 ∧ track==far` |
| **Shaky** | D=5, S=14d | NEAR | `… ⇒ d==5 ∧ s==14 ∧ track==near` |
| **Rusty** | D=7, S=4d | active revision | `… ⇒ d==7 ∧ s==4 ∧ track==newLesson` |

### Pitfalls / what we refuse

- **We refuse to auto-bless vectors in CI.** Regeneration is a local, explicit `--update-vectors` action whose output a human reads in the PR; CI only ever *verifies*. An auto-accept would make the gate verify nothing — the same failure mode as `flutter test --update-goldens` running in CI.
- **We refuse exact float equality.** `==` on doubles would fail on benign platform rounding and erode trust in the suite; the tolerance is `1e-6`, chosen so any real arithmetic change is caught and no rounding noise is.
- **We refuse to vendor the optimizer or its weights as "tested."** We pin a fixed weight vector and assert its length ([06-scheduling-engine.md §8](06-scheduling-engine.md)); we ship no telemetry and therefore never fit weights, so there is nothing to golden-test about training.

---

## 4. Invariants as property tests: the covenant, mechanically enforced

### Decision

Every engine invariant in [PRD §7.12](../PRD.md) is encoded as a **`glados` property test** that generates many random `(Card, grade-sequence, today)` histories and asserts the invariant holds for *all* of them, using `glados`'s shrinking to report the smallest failing schedule (*Decision log: Testing strategy & CI*). These are the universal claims golden vectors cannot reach: vectors pin specific points, properties pin the *rule* across the whole input space.

### Rationale

- **The invariants are universal statements, which is exactly what property testing checks.** "For *every* card and *every* grade sequence, `due_at` never exceeds the cycle ceiling" is a `∀`, not a point; property-based testing exists to falsify such claims by search. `glados` is the maintained Dart framework: `Glados<T>().test('…', (a) { … })` runs a property over generated inputs and on failure "gradually simplifies the input and returns the smallest input that's still breaking the property," printing e.g. `Tested 1 input, shrunk 25 times. Failing for input: [0]` ([glados](https://pub.dev/packages/glados)).
- **Shrinking hands you the minimal counterexample.** When the trust clamp breaks, we do not get a 200-review random history to debug; `glados` shrinks it to the shortest sequence that still violates `due_at ≤ ceiling`, which is usually a one- or two-review case a human can reason about immediately.
- **The PRD names this method.** Gate 4 is literally "invariant tests (§7.12) as property-based checks" ([PRD §20 gate 4](../PRD.md)); this section is its implementation.

### Specification

A custom generator builds plausible review histories; each invariant is one property over them.

```dart
// engine/test/invariants_test.dart
extension AnySchedule on Any {
  /// A card plus a random sequence of graded reviews and an injected today.
  Generator<ScheduleCase> get scheduleCase => combine3(
        any.cardSeed,                         // page 1..604, random D∈[1,10], S>0, track
        any.listWithLengthInRange(0, 200, any.gradedReview), // Again/Hard/Good/Easy + lines
        any.serialDayInRange(0, 3650),        // today within ~10 years
        ScheduleCase.new,
      );
}

void main() {
  final engine = SchedulingEngine(EngineConfig.defaults());

  // INV-1 — the trust clamp: due_at is NEVER later than the cycle ceiling.
  Glados<ScheduleCase>(any.scheduleCase).test('due_at ≤ cycle ceiling, always', (c) {
    final card = replay(engine, c);           // fold the grade sequence onto the card
    if (card.track == Track.unmemorized) return; // ceiling only applies to memorized cards
    final ceiling = cycleCeiling(card, c.config, c.today);
    expect(card.dueAt.value, lessThanOrEqualTo(ceiling.value));
  });

  // INV-2 — FAR/manzil due items are NEVER silently dropped from the day plan.
  Glados<ScheduleCase>(any.scheduleCase).test('manzil due items always appear in the plan', (c) {
    final cards = replayAll(engine, c);
    final plan = engine.buildToday(cards, c.today);
    final dueFar = cards.where((x) => x.track == Track.far && x.dueAt.value <= c.today.value);
    expect(plan.allPageIds, containsAll(dueFar.map((x) => x.pageId)));
  });

  // INV-3 — a lapse demotes: Again can only shrink S and lower the phase, never raise.
  Glados<ScheduleCase>(any.scheduleCase).test('Again never increases S or promotes phase', (c) {
    final before = replay(engine, c);
    final after = engine.onReview(before,
        const ReviewInput(grade: Grade.again, errorLines: [], source: Source.teacher), c.today);
    expect(after.s, lessThanOrEqualTo(before.s));
    expect(after.track.index, lessThanOrEqualTo(before.track.index)); // never promotes
  });

  // INV-4 — determinism: identical inputs ⇒ byte-identical plan (fuzzing is OFF).
  Glados<ScheduleCase>(any.scheduleCase).test('schedule is reproducible', (c) {
    final a = engine.buildToday(replayAll(engine, c), c.today).fingerprint();
    final b = engine.buildToday(replayAll(engine, c), c.today).fingerprint();
    expect(a, equals(b));
  });

  // INV-5 — a teacher sign-off supersedes self-rating and prior algorithmic state.
  Glados<ScheduleCase>(any.scheduleCase).test('teacher grade overrides for that page', (c) {
    final selfState = engine.onReview(replay(engine, c),
        const ReviewInput(grade: Grade.good, errorLines: [], source: Source.self_), c.today);
    final teacherState = engine.onReview(selfState,
        const ReviewInput(grade: Grade.again, errorLines: [1], source: Source.teacher), c.today);
    expect(teacherState.weakFlag, isTrue);     // teacher's verdict wins
    expect(teacherState.dueAt.value, lessThanOrEqualTo(selfState.dueAt.value));
  });
}
```

The full invariant register and the property that pins each:

| ID | Invariant ([PRD §7.12](../PRD.md)) | Property assertion |
|---|---|---|
| **INV-1** | A memorized page's `due_at` is never later than its cycle ceiling | `card.dueAt ≤ cycleCeiling(card, config, today)` for all histories |
| **INV-2** | FAR/manzil due items are never silently dropped | every due FAR page is in `buildToday(...)`'s plan |
| **INV-3** | A lapse demotes the card | `Again ⇒ S' ≤ S ∧ track' ≤ track` |
| **INV-4** | Identical inputs ⇒ identical schedule (fuzz OFF) | two `buildToday` runs fingerprint-equal |
| **INV-5** | Teacher sign-off supersedes self-rating and state | teacher `Again` overrides a prior self `Good` |
| **INV-6** | The engine never implies "safe to stop revising" | every plan/forecast has a finite `dueAt`; **no API can return "drop"/`null` due** for a memorized card |

### Pitfalls / what we refuse

- **We refuse to encode INV-6 as copy-grep alone.** "Never says safe to drop" is structurally enforced: `dueAt` is non-nullable for a memorized `Card` ([06-scheduling-engine.md §2](06-scheduling-engine.md)), so there is no value the engine can produce that *means* "stop." The property asserts that every memorized card in every generated history has a finite due day; the type system forecloses the rest.
- **We refuse a fixed seed that hides regressions.** `glados` runs many inputs per property; we let it explore broadly and rely on shrinking for reproducibility of a failure, rather than pinning one lucky seed that happens to pass.
- **We refuse to skip the determinism property.** Interval fuzzing is on by default in every reference scheduler and would break INV-4 ([06-scheduling-engine.md](06-scheduling-engine.md)); the property is what keeps "fuzz OFF" honest if a future refactor reintroduces randomness.

---

## 5. Muṣḥaf-fidelity goldens: real glyphs, pinned everything

### Decision

The R1 visual-diff gate is implemented as **golden tests that render each muṣḥaf page with the real bundled KFGQPC glyph font and the real UI fonts loaded via `FontLoader`** (never the Ahem placeholder), on a **single pinned OS with a pinned Flutter version**, fixed `devicePixelRatio`, surface size, theme, and disabled animations, diffed against committed reference images to a tight pixel tolerance (*Decision log: Testing strategy & CI*). A dropped or shifted diacritic must change pixels and fail the build.

### Rationale

- **Golden files are the documented mechanism for pixel-exact assertions, with documented sensitivity.** `matchesGoldenFile` compares a `Finder`/`ui.Image` against a master reference; you must `expectLater(...)` and `await` it, and update masters with `flutter test --update-goldens` ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)). The *same* page warns that a golden "can be more sensitive to underlying changes than other types of tests," that "a change to the version of Flutter or to the operating system on which the test is run can result in a slightly different rendering," and that custom fonts "may render differently on different platforms" ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)). For us that sensitivity is the *point* — we want pixels to move when a glyph moves — which is exactly why the environment is pinned, so only a *real* change moves them.
- **The default font is Ahem, which would defeat the test.** Without an explicit `FontLoader`, Flutter renders every glyph as a solid square ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)) — useless for proving a diacritic is correctly placed. The muṣḥaf goldens must load the actual KFGQPC per-page fonts so the golden compares *the real typeset page* ([08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md)).
- **Golden drift from the environment is real, not theoretical.** Maintainers report goldens changing from a host-OS upgrade alone ([flutter/flutter #184182](https://github.com/flutter/flutter/issues/184182)) and font weight rendering differently under Impeller vs. Skia ([flutter/flutter #119317](https://github.com/flutter/flutter/issues/119317)). The community remedy is a fully controlled environment — one OS, pinned SDK, bundled fonts, fixed DPR/size/theme/animation ([LeanCode: Golden tests — common mistakes & best practices](https://leancode.co/glossary/golden-tests-in-flutter)). We adopt all of it so the muṣḥaf golden is trustworthy.
- **This is a named release gate.** "All 604 pages render-match reference images on min-OS iOS/Android" is gate 2 ([PRD §20 gate 2, §11.3](../PRD.md)); the on-device subset of this runs in the integration tier (§6), while the CI golden run pins one runner for stable masters.

### Specification

```dart
// quran/test/golden/page_render_golden_test.dart
@Tags(['golden'])           // isolated into the pinned-OS golden CI job (§8)
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadRealFonts() async {
  // Load the ACTUAL bundled fonts — never Ahem — so the golden asserts real glyphs.
  for (final family in kBundledFontFamilies) {        // KFGQPC page fonts + fa/ckb/ar UI fonts
    final loader = FontLoader(family);
    loader.addFont(rootBundle.load(fontAssetPath(family)));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadRealFonts);

  testWidgets('muṣḥaf page renders pixel-identical to the reference', (tester) async {
    tester.view.devicePixelRatio = 2.0;               // fixed DPR — no host variation
    tester.view.physicalSize = const Size(828, 1792); // fixed surface
    await tester.pumpWidget(const MushafPageHarness(pageId: 1)); // no animations
    await expectLater(
      find.byType(MushafPage),
      matchesGoldenFile('goldens/mushaf/page_001.png'),
    );
  });
}
```

CI invokes only this tag on the pinned runner: `flutter test --tags=golden` ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)). Masters are regenerated with `--update-goldens` *locally* and reviewed; CI never blesses.

### Pitfalls / what we refuse

- **We refuse Ahem (or any font-independent trick) for the muṣḥaf goldens.** `alchemist`'s "CI mode" deliberately renders with Ahem and replaces text/shadows with colored blocks for cross-machine stability ([Alchemist package](https://pub.dev/packages/alchemist)) — perfect for *layout* goldens (§6), forbidden for *fidelity* goldens, because they must assert the exact KFGQPC glyph shapes (R1). The two tiers use different strategies on purpose.
- **We refuse to run muṣḥaf goldens across un-pinned OSes.** A golden generated on one OS "is unlikely to match a golden generated on a different operating system" ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)); the CI fidelity job is pinned to one Linux runner and one Flutter version, and the cross-device proof lives in the on-device integration/visual-diff run, not in the shared golden masters.
- **We refuse to auto-update goldens in CI.** `--update-goldens` is local-and-reviewed only; a CI that updates masters would make the gate assert nothing.

---

## 6. Widget, RTL, and integration tests: the screens and the journeys

### Decision

Screen behaviour is tested with **widget tests** (`testWidgets`, finders, matchers) for the recite/grade flow, heat-map, and catch-up banner; **RTL correctness** is captured as goldens with each key screen pumped under `Directionality(textDirection: TextDirection.rtl)` for `ar`/`fa`/`ckb` with locale numerals and calendars; and the four headline **journeys** run as `integration_test` cases on an emulator against the real Drift/SQLite stack (*Decision log: Testing strategy & CI*).

### Rationale

- **Widget tests drive the daily flow headlessly.** They build UI with `tester.pumpWidget(...)`, advance frames with `pump([duration])`, settle animations with `pumpAndSettle()`, locate widgets with `find.byType`/`find.text`/`find.byKey`, and assert with `findsOneWidget`/`findsNothing` ([Flutter: An introduction to widget testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)) — exactly the surface needed for reveal-on-tap, grade buttons, and the teacher sign-off toggle without a device.
- **RTL is asserted by construction, per locale.** All three languages are RTL ([PRD §13.2](../PRD.md)); pumping each screen under `Directionality.rtl` and golden-capturing it per locale is the concrete artifact for gate 5 ("RTL golden screenshots per locale," [PRD §20 gate 5](../PRD.md)), and these layout goldens may use the font-independent strategy (§5 pitfalls) so they stay green across contributor machines.
- **`integration_test` exercises the real stack for the make-or-break flows.** It ships with the SDK, runs from a top-level `integration_test/` directory after `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, and reuses the `flutter_test` APIs on a real device/emulator ([Flutter: Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)) — the only tier that exercises real SQLite, real asset loading, and real rendering together, which is where cold-start → first day → review → catch-up belongs ([PRD §7.9, §7.10, §20](../PRD.md)).

### Specification

The journey suite — small, deliberate, each a named PRD flow:

| Journey | Steps | Primary assertions |
|---|---|---|
| **J1 — Cold start** | Pick locale → confirm muṣḥaf → (mock-verified) core pack → coverage taps → per-juz Solid/Shaky/Rusty → cycle preset | Cards seeded per §3 table; first day generated; held juz all scheduled once early |
| **J2 — A review** | Open Today → recite flow → reveal-on-tap → mark stumble lines → grade | `review_log` row appended; card S/D updated; `due_at ≤ ceiling` |
| **J3 — Teacher sign-off** | Switch profile → teacher grades a page Again | Teacher row in `review_log`; weak-flag set; page re-surfaced (INV-5) |
| **J4 — Missed-day catch-up** | Advance injected `today` past a gap → reopen Today | A re-spread catch-up plan, never a dumped overdue pile; no shame copy ([PRD §7.9](../PRD.md)) |

```dart
// integration_test/journey_cold_start_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('J1: cold start seeds cards and generates the first day', (tester) async {
    await tester.pumpWidget(const HifzApp(networkClient: BlockedClient())); // §7 — no real net
    await onboardPartialHafiz(tester, juz: const [1, 30], confidence: Confidence.solid);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(RevisionItem), findsWidgets);   // a finite, capped day exists
  });
}
```

### Pitfalls / what we refuse

- **We refuse to let widget tests depend on a real database or assets.** The Drift store and asset loader are injected; widget tests use in-memory fakes, integration tests use the real stack. Mixing them makes widget tests slow and flaky.
- **We refuse `pumpAndSettle()` where animations are intentionally infinite.** The calm UI has no confetti, but any indefinite indicator would hang `pumpAndSettle`; such screens are pumped with explicit durations.
- **We refuse to grow the journey suite past the four PRD flows** without a decision-log amendment; integration tests are the most expensive tier and the temptation to add "just one more" is how a pyramid inverts.

---

## 7. The no-network gate: offline is a build invariant, not a promise

### Decision

"Fully offline" is enforced at three layers (*Decision log: No networking beyond asset download*, *Testing strategy & CI*): **(a)** every test keeps the test binding's default network block *and* installs an `HttpOverrides` that **throws** on any connection attempt, so an accidental network call is a loud failure, not a silent 400; **(b)** a CI **dependency allow-list** step fails if any analytics, ads, backend, or crash-reporting SDK appears in the resolved dependency graph; **(c)** an analyzer **banned-import** rule forbids networking imports everywhere except the single whitelisted asset-downloader module. Only the asset-downloader test opts out of (a).

### Rationale

- **The test harness already blocks the network — we weaponize it.** "In non-browser tests, [`TestWidgetsFlutterBinding`] overrides `HttpClient` creation with a fake client that always returns a status code of 400. This is to prevent tests from making network calls, which could introduce flakiness" ([Flutter API: TestWidgetsFlutterBinding](https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html)). For most apps this is an annoyance, widely observed as "all HTTP requests return 400" ([flutter/flutter #77245](https://github.com/flutter/flutter/issues/77245)); for an offline-by-design app it is a gift — we keep it in place and additionally throw, converting "code tried to reach the network" into an explicit test failure.
- **Runtime tests cannot prove a binary is *free of* a phone-home SDK — static checks can.** A passing test proves the running code did not call out; it cannot prove a release build lacks an analytics SDK that might ([PRD §20 gate 6, §19.3](../PRD.md)). Two static checks close the gap: a dependency allow-list over the resolved `pubspec.lock` graph, and forbidden-import lint rules scoped per path — `import_rules` enforces e.g. `target: lib/engine/**` / `disallow: package:http/**` so a networking import fails `dart analyze` ([import_rules](https://github.com/fujidaiti/import_rules)), and DCM's `avoid-banned-imports` does the same via `analysis_options.yaml` with per-path `deny:` lists at `severity: error` ([DCM: avoid-banned-imports](https://dcm.dev/docs/rules/common/avoid-banned-imports/)).
- **This is a named release gate.** Gate 6 — "release binary contains no analytics/ads/backend SDKs; the only network client is the asset-pack downloader" ([PRD §20 gate 6](../PRD.md)) — is precisely what these three layers assert.

### Specification

```dart
// test/test_setup.dart — imported by the global test bootstrap.
class _ThrowingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? c) =>
      throw StateError('Network access attempted in a test. Hifz is offline-only.');
}

void useOfflineTestPolicy() => HttpOverrides.global = _ThrowingHttpOverrides();
// The single asset-downloader test resets HttpOverrides.global to a mock in its own setUp.
```

```yaml
# analysis_options.yaml — banned-import rule (DCM form), scoped per path.
dcm:
  rules:
    - avoid-banned-imports:
        entries:
          - paths: ['lib/(?!assets/downloader/).*\.dart']   # everything EXCEPT the downloader
            deny: ['dart:io', 'package:http/.*', 'package:dio/.*']
            message: 'Networking is allowed only in lib/assets/downloader/ (PRD C1).'
```

```yaml
# .github/workflows/ci.yaml — the dependency allow-list step.
- name: Ban analytics/ads/backend SDKs
  run: |
    BANNED='firebase_|google_analytics|sentry|crashlytics|facebook_|appsflyer|amplitude|mixpanel'
    if flutter pub deps --style=compact | grep -Eiq "$BANNED"; then
      echo "::error::Banned networking/telemetry SDK in dependency graph (PRD §20 gate 6)"; exit 1
    fi
```

An **airplane-mode acceptance test** completes the gate: after a one-time mock-verified core-pack install, the integration suite runs with the throwing override installed, proving every post-onboarding screen works with zero network ([F-Droid: Inclusion Policy](https://f-droid.org/en/docs/Inclusion_Policy/)).

### Pitfalls / what we refuse

- **We refuse to rely on the 400 default alone.** A 400 is silent; a future bug could swallow it and look "handled." The throwing override makes any network attempt a hard, named failure.
- **We refuse a downloader that imports networking from anywhere but its one module.** The banned-import rule is path-scoped to a single allowlisted directory; a networking import in `engine/`, `features/`, or `data/` fails `dart analyze` before review ([import_rules](https://github.com/fujidaiti/import_rules)).
- **We refuse TLS certificate pinning against GitHub.** That is an availability anti-pattern (rotation outages); content integrity is the SHA-256 manifest (§9, [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)), not transport pinning.

---

## 8. CI shape: fast feedback, a pinned golden job, the gates

### Decision

CI is a small set of GitHub Actions jobs (*Decision log: Testing strategy & CI*): **(1)** a fast job — `analyze` + engine unit + property + widget tests + coverage — on every push; **(2)** a **pinned, Linux-only golden job** running `--tags=golden`; **(3)** a restraint job — the dependency allow-list and banned-import checks (§7) plus the text-integrity hashing (§9); **(4)** an emulator job for the four integration journeys. The runner is `subosito/flutter-action@v2` with a **pinned `flutter-version`** and dependency caching.

### Rationale

- **`subosito/flutter-action` is the de-facto runner and is pinnable.** It downloads and configures the SDK on Linux/Windows/macOS and accepts `channel`, `flutter-version`, `cache`, and `pub-cache` inputs; the current release is `v2.23.0` (March 2026) ([subosito/flutter-action](https://github.com/subosito/flutter-action)). A minimal job is `actions/checkout` → `subosito/flutter-action@v2` → `flutter pub get` → `flutter analyze` → `flutter test`.
- **Goldens must run pinned, so they get their own job.** Because goldens are version- and OS-sensitive ([flutter/flutter #184182](https://github.com/flutter/flutter/issues/184182); [Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)), the golden job pins one `flutter-version` and one Linux runner so reference images stay stable; tagging golden tests (`@Tags(['golden'])` + `--tags=golden`) isolates them into that controlled job and keeps the fast job fast.

### Specification

```yaml
# .github/workflows/ci.yaml  (abridged — one job per concern)
jobs:
  fast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.38.0', channel: stable, cache: true }
      - run: flutter pub get
      - run: flutter analyze                          # includes banned-import rules (§7)
      - run: dart test engine/                        # pure-engine unit + golden vectors + glados
      - run: flutter test --coverage --exclude-tags golden
      - run: lcov -r coverage/lcov.info '*.g.dart' '*.drift.dart' '*.freezed.dart' \
               -o coverage/lcov.info                  # strip generated code (§10)

  golden:                                              # PINNED runner + version (§5)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.38.0', channel: stable, cache: true }
      - run: flutter pub get
      - run: flutter test --tags golden                # real-font muṣḥaf + RTL layout goldens

  restraint:                                           # no-network + text-integrity gates
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.38.0', channel: stable }
      - run: flutter pub get
      - run: bash tool/ban_telemetry_sdks.sh           # §7 allow-list
      - run: dart run tool/verify_asset_hashes.dart    # §9 text-integrity

  journeys:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.38.0', channel: stable }
      - uses: reactivecircus/android-emulator-runner@v2
        with: { api-level: 24, script: flutter test integration_test/ } # min-Android baseline
```

The mapping from PRD gates to jobs makes the release contract auditable:

| PRD §20 gate | Where it runs | Section |
|---|---|---|
| 1 — Text & asset integrity | `restraint` (CI hash) + runtime verifier | §9, [09](09-asset-packs-and-offline-integrity.md) |
| 2 — Visual-diff (604 pages) | `golden` (CI) + `journeys` (on-device) | §5, §6 |
| 3 — Engine golden tests | `fast` (`dart test engine/`) | §3 |
| 4 — Invariant property tests | `fast` (`glados`) | §4 |
| 5 — Localization & RTL | `golden` (RTL goldens) + `fast` (ARB key check) | §6, [12](12-localization-rtl-accessibility-impl.md) |
| 6 — Network restraint | `restraint` (allow-list) + `fast` (banned imports) | §7 |
| 7 — Mutashābihāt dataset | `restraint` (hash) + recorded scholar sign-off | §9 |
| 8 — Manual muṣḥaf review | human, on real devices (not automatable) | [08](08-quran-data-and-immutable-rendering.md) |

### Pitfalls / what we refuse

- **We refuse `channel: stable` without a pinned version on the golden job.** A floating SDK silently re-renders goldens; the golden and the fast jobs both pin an exact `flutter-version`.
- **We refuse to run goldens on macOS/Windows in CI.** Cross-OS golden drift is documented ([flutter/flutter #184182](https://github.com/flutter/flutter/issues/184182)); the cross-platform fidelity proof is the on-device visual-diff (gate 2 / gate 8), not the shared golden masters.
- **We refuse to merge on a skipped gate.** Gates 1–6 are machine-checked and required; gates 7–8 carry a recorded human sign-off artifact. A red gate blocks the release, full stop ([PRD §20](../PRD.md)).

---

## 9. The text-integrity gate: the muṣḥaf cannot drift, even in CI

### Decision

CI **re-hashes every file in every asset pack** — the Uthmani text, all 604 KFGQPC page fonts, the layout dataset, and the mutashābihāt dataset — with SHA-256 and fails the build on any mismatch against (a) the pinned manifest baked into the app binary and (b) the authoritative Tanzil text hash (*Decision log: Testing strategy & CI*; *Quran asset distribution & offline integrity*). This is the build-time half of R1; the runtime verifier ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)) is the install-time half.

### Rationale

- **A single altered byte ends the project, so integrity is checked twice.** The PRD makes "the app's pinned SHA-256 checksums match the published GitHub Release packs (CI), and the runtime rejects any downloaded asset whose hash mismatches" gate 1, and adds "CI verifies each of the 604 page fonts in the release is present and unmodified (hash manifest)" ([PRD §11.3, §20 gate 1, R1](../PRD.md)). CI catches a tampered or drifted *release artifact* before it ships; the runtime catches a tampered *download* on the device. Neither alone is sufficient.
- **SHA-256 is the standard, collision-resistant primitive for this.** It is the FIPS 180-4 secure hash ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)); the manifest-and-verify model is the same fail-closed pattern as Subresource Integrity ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)). Pinning to an *exact* hash (not a "latest" pointer) is what makes the check meaningful.
- **The text hash is anchored to the upstream authority.** Beyond matching our own manifest, CI compares the text-asset hash to the published Tanzil Uthmani hash, so our pinned manifest cannot itself silently drift away from the authoritative source ([PRD §11.3](../PRD.md)).

### Specification

```dart
// tool/verify_asset_hashes.dart — run in the `restraint` CI job.
// Fails the build if ANY asset-pack file's SHA-256 differs from the pinned manifest,
// or if the text hash differs from the authoritative Tanzil hash.
Future<void> main() async {
  final manifest = await loadPinnedManifest();          // baked into the app binary
  var failed = false;

  for (final entry in manifest.files) {                 // text + 604 fonts + layout + mutashābihāt
    final actual = sha256.convert(await File(entry.path).readAsBytes()).toString();
    if (actual != entry.sha256) {
      stderr.writeln('::error::INTEGRITY: ${entry.path}\n  expected ${entry.sha256}\n  got      $actual');
      failed = true;
    }
  }
  if (manifest.textSha256 != kAuthoritativeTanzilSha256) {
    stderr.writeln('::error::TEXT DRIFT: manifest text hash != authoritative Tanzil hash');
    failed = true;
  }
  if (failed) exit(1);                                  // release-blocking (PRD §20 gate 1)
}
```

| Asset | Count | Pinned to | On mismatch |
|---|---|---|---|
| Uthmani text | 1 | App manifest **and** authoritative Tanzil hash | Fail build |
| KFGQPC page fonts | 604 | App manifest | Fail build |
| Layout / segmentation | 1 dataset | App manifest | Fail build |
| Mutashābihāt dataset | 1 dataset | App manifest (+ recorded scholar sign-off, gate 7) | Fail build |

### Pitfalls / what we refuse

- **We refuse to trust a checksum shipped *next to* the pack.** The trust root is the manifest inside the signed app binary, never a sidecar `.sha256` an attacker who can swap the pack can also swap ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)).
- **We refuse to render Quran text from an unverified byte at runtime, regardless of CI.** CI proving the *release* is intact does not excuse the device check; the runtime verifier is fail-closed and independent ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)).
- **We refuse a weaker hash.** MD5/SHA-1 are collision-broken; the primitive is SHA-256 ([NIST FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final)), uniformly, at build and at runtime.

---

## 10. Coverage policy: auditable, honest, no vanity number

### Decision

CI emits coverage with `flutter test --coverage`, **strips generated files** (`*.g.dart`, `*.drift.dart`, `*.freezed.dart`) from `lcov.info` before reporting, and **publishes the report** for public auditability (*Decision log: Testing strategy & CI*). We set **no global coverage percentage as a gate**; the engine's invariants and golden vectors are the real assurance, and we instead require that the engine and DAO layers carry the bulk of the suite.

### Rationale

- **Coverage tooling is first-class and the strip step is standard.** `flutter test --coverage` emits `coverage/lcov.info`, and `genhtml coverage/lcov.info -o coverage/html` produces a browsable report ([Code With Andrea: Flutter test coverage](https://codewithandrea.com/articles/flutter-test-coverage/)). Generated files inflate the denominator with code nobody hand-wrote, so they are removed first with `lcov -r coverage/lcov.info '*.g.dart' '*.drift.dart' -o coverage/lcov.info` ([Flutter test coverage / `lcov --remove`](https://medium.com/@vortj/flutter-daily-how-to-run-test-coverage-and-exclude-files-7cc546347779)).
- **A percentage is a weak guarantee; invariants are a strong one.** A line can be "covered" by a test that asserts nothing meaningful. For the engine, an INV-1 property that fails on *any* of thousands of generated histories is worth more than 100% line coverage of the same code. So we publish the number for transparency but do not let it gate — consistent with the "open-source & auditable" value and [PRD §21](../PRD.md)'s open-source intent.
- **Public coverage fits a *ṣadaqah* project.** The lcov can be uploaded to a free-for-OSS service so the engine's coverage is openly auditable, matching the README's auditability value; no number is promised, the artifact is just made visible.

### Specification

```bash
flutter test --coverage --exclude-tags golden
lcov -r coverage/lcov.info '*.g.dart' '*.drift.dart' '*.freezed.dart' '*/generated/*' \
  -o coverage/lcov.info            # strip generated code from the denominator
genhtml coverage/lcov.info -o coverage/html   # browsable, publishable report
```

| Policy | Value |
|---|---|
| Coverage command | `flutter test --coverage` ([Code With Andrea](https://codewithandrea.com/articles/flutter-test-coverage/)) |
| Stripped from report | `*.g.dart`, `*.drift.dart`, `*.freezed.dart`, `*/generated/*` |
| Gating threshold | **None** (no vanity percentage) |
| What *is* required | Engine fully covered by golden vectors (§3) + invariants (§4); DAOs by unit tests |
| Visibility | Published for OSS auditability ([PRD §21](../PRD.md)) |

### Pitfalls / what we refuse

- **We refuse a coverage percentage gate.** It rewards asserting-nothing tests and punishes hard-to-reach but correct code; the property and golden-vector suites are the real bar.
- **We refuse to count generated code.** `*.g.dart`/`*.drift.dart` are stripped before any report so coverage reflects hand-written logic only.
- **We refuse to treat coverage as proof of correctness.** It measures *executed* lines, not *asserted* behaviour; INV-1…INV-6 (§4) and the frozen vectors (§3) are what prove the engine right.

---

## References

- Flutter (Google). *Testing Flutter apps* (the unit/widget/integration pyramid; "many unit and widget tests… plus enough integration tests"). https://docs.flutter.dev/testing/overview
- Flutter (Google). *An introduction to unit testing* (`test()`, `expect()`, `group()`, `setUp()`; `flutter test`). https://docs.flutter.dev/cookbook/testing/unit/introduction
- Flutter (Google). *An introduction to widget testing* (`testWidgets`, `pumpWidget`, `pump`, `pumpAndSettle`, finders, matchers). https://docs.flutter.dev/cookbook/testing/widget/introduction
- Flutter (Google). *Check app functionality with an integration test* (`integration_test` from SDK; `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`; running on devices). https://docs.flutter.dev/testing/integration-tests
- Flutter (Google). *Developing packages & plugins* (a pure-Dart package is the easiest layer to test). https://docs.flutter.dev/packages-and-plugins/developing-packages
- Flutter API. *matchesGoldenFile function* (golden matcher; `--update-goldens`; OS/font/version sensitivity; Ahem default). https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
- Flutter API. *TestWidgetsFlutterBinding class* (overrides `HttpClient` with a fake client returning 400 to block network calls). https://api.flutter.dev/flutter/flutter_test/TestWidgetsFlutterBinding-class.html
- flutter/flutter. *Issue #77245 — TestWidgetsFlutterBinding makes all HTTP requests return 400.* https://github.com/flutter/flutter/issues/77245
- flutter/flutter. *Issue #184182 — Golden images changed after upgrade to macOS 26.4* (host-OS upgrade changes goldens). https://github.com/flutter/flutter/issues/184182
- flutter/flutter. *Issue #119317 — Impeller rendering font weight wrong* (Impeller vs. Skia rendering differences). https://github.com/flutter/flutter/issues/119317
- Dart team. *`clock` package* (fakeable wrapper for clock APIs; `clock.now()`, `withClock`). https://pub.dev/packages/clock
- Dart team. *`fake_async` package* (deterministic Futures/Streams/Timers; integrates with `clock`). https://pub.dev/packages/fake_async
- `glados` (Marcel Garus). *Property-based testing for Dart* (`Glados<T>().test`, custom generators via `Any`/`combine`/`choose`, shrinking to the minimal failing input). https://pub.dev/packages/glados
- `alchemist` (Betterment). *Flutter golden testing* (platform vs. CI golden modes; Ahem + colored-block obfuscation for cross-platform determinism). https://pub.dev/packages/alchemist
- LeanCode. *Golden tests in Flutter: common mistakes & best practices* (pin OS/Flutter version, bundle+load fonts, fix DPR/size/theme; `toStringDeep` snapshots). https://leancode.co/glossary/golden-tests-in-flutter
- `import_rules` (fujidaiti). *Dart analyzer plugin enforcing custom import rules* (`target`/`disallow` in `analysis_options.yaml`). https://github.com/fujidaiti/import_rules
- DCM. *`avoid-banned-imports` rule* (per-path `deny:` import bans with `severity: error`). https://dcm.dev/docs/rules/common/avoid-banned-imports/
- subosito/flutter-action. *Flutter environment for GitHub Actions* (Linux/Windows/macOS; `channel`/`flutter-version`/`cache` inputs; v2.23.0, Mar 2026). https://github.com/subosito/flutter-action
- Code With Andrea. *How to generate and analyze a Flutter test coverage report* (`flutter test --coverage`, `lcov.info`, `genhtml`, stripping generated files). https://codewithandrea.com/articles/flutter-test-coverage/
- Vorrawut Judasri. *Flutter Daily: How to run test coverage and exclude files* (`lcov -r` / `--remove` to drop generated files from `lcov.info`). https://medium.com/@vortj/flutter-daily-how-to-run-test-coverage-and-exclude-files-7cc546347779
- Open Spaced Repetition. *Free Spaced Repetition Scheduler* (MIT; DSR model; multi-language reference ports usable as test oracles). https://github.com/open-spaced-repetition/free-spaced-repetition-scheduler
- NIST. *FIPS 180-4, Secure Hash Standard* (SHA-256). https://csrc.nist.gov/pubs/fips/180-4/upd1/final
- F-Droid. *Inclusion Policy* (FLOSS-everything; banned analytics/ads/tracking SDKs; offline-by-construction). https://f-droid.org/en/docs/Inclusion_Policy/
- Hifz Companion. *Engineering README & tech-decision log.* [README.md](README.md)
- Hifz Companion. *Scheduling Engine.* [06-scheduling-engine.md](06-scheduling-engine.md)
- Hifz Companion. *Quran Data & Immutable Rendering.* [08-quran-data-and-immutable-rendering.md](08-quran-data-and-immutable-rendering.md)
- Hifz Companion. *Asset Packs & Offline Integrity.* [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)
- Hifz Companion. *Product Requirements Document.* [PRD.md](../PRD.md)
