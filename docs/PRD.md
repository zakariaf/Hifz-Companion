# Hifz Companion — Product Requirements Document (PRD)

> **One line:** A fully offline Flutter app that makes sure a ḥāfiẓ never *silently* loses the Quran — an intelligent muṣḥaf-page revision scheduler dressed in the traditional sabaq / murājaʿa / manzil workflow.

- **Status:** Draft v1.0 (full-product spec — single complete version, not phased)
- **Date:** 2026-06-16
- **Owner:** Zakaria Fatahi
- **Intent:** Built **free**, as *ṣadaqah jāriyah* (the zakat of knowledge). Success = benefit (*nafʿ*) and reach, never revenue. There is **no monetization, no ads, no data collection, no upsell** anywhere in this product.
- **Source:** Derived from the deep-research findings in `../research/RESEARCH-FINDINGS.md` (raw: `../research/raw-research-output.json`).

---

## Table of Contents

1. [Hard Constraints](#1-hard-constraints)
2. [Product Vision & Positioning](#2-product-vision--positioning)
3. [Target Users](#3-target-users)
4. [Non-Negotiable Religious Integrity Requirements](#4-non-negotiable-religious-integrity-requirements)
5. [Scope — In / Out](#5-scope--in--out)
6. [Domain Model & Core Concepts](#6-domain-model--core-concepts)
7. [The Revision Engine (the heart)](#7-the-revision-engine-the-heart)
8. [Grading (no-AI): self + on-device teacher](#8-grading-no-ai-self--on-device-teacher)
9. [Mutashābihāt (similar-verse) System](#9-mutashābihāt-similar-verse-system)
10. [Data Model / SQLite Schema](#10-data-model--sqlite-schema)
11. [Quran Data & Immutable Rendering](#11-quran-data--immutable-rendering)
12. [Information Architecture & Screens](#12-information-architecture--screens)
13. [Localization & RTL Architecture](#13-localization--rtl-architecture)
14. [Notifications (local only)](#14-notifications-local-only)
15. [Settings, Presets & Profiles](#15-settings-presets--profiles)
16. [Backup & Data Portability (offline)](#16-backup--data-portability-offline)
17. [Privacy & Security](#17-privacy--security)
18. [Accessibility](#18-accessibility)
19. [Technical Architecture](#19-technical-architecture)
20. [Quality, Testing & Release Gates](#20-quality-testing--release-gates)
21. [Open Decisions to Confirm](#21-open-decisions-to-confirm)
22. [Glossary](#22-glossary)

---

## 1. Hard Constraints

These are absolute and shape every decision below.

| # | Constraint | Implication |
|---|---|---|
| C1 | **Offline after setup. No backend we operate, no accounts, no live services, no per-user data ever leaves the device.** | The **core muṣḥaf** (Uthmani text, the KFGQPC per-page glyph fonts, page layout, and the mutashābihāt dataset) is **bundled in the app binary** and verified at build time, so the app is **fully usable offline from first launch** — no network event in its critical path. Only **optional** packs (recitation audio, future alt-muṣḥaf) are **downloaded on demand** from a **public open-source GitHub repo** (static, public, checksum-verified open data); after any such optional fetch the app works **fully offline, forever** (airplane mode). No cloud sync, no accounts, no telemetry, no remote config, no API we run. |
| C2 | **No AI / no ML / no audio recognition.** | Grading is **self-rating** and **on-device teacher sign-off** only. No ASR, no "listen and detect mistakes," no on-device model. The mutashābihāt list is a curated static dataset; personalization comes only from the user's own logged confusion errors (plain bookkeeping, not ML). |
| C3 | **One complete version.** | No "v1 / v2" gating in the product itself. Everything specced here ships as one coherent app. (Build *order* is an engineering concern, not a product-scope one.) |
| C4 | **Languages: Persian (fa), Kurdish Sorani (ckb), Arabic (ar) — all RTL.** | Full localization of every string; RTL-first layout; locale-appropriate numerals and calendars; localizable religious terminology (the sabaq/sabqi/manzil terms differ by region). |
| C5 | **Flutter.** | Single codebase, iOS + Android. Local-first persistence (SQLite via Drift). The scheduler is a pure-Dart module with no I/O. |
| C6 | **No gamification of worship.** | No leaderboards, XP, badges on ayāt, confetti, or guilt/fear streak nags. Framing is calm loss-prevention and peace of mind. |

---

## 2. Product Vision & Positioning

### The problem we solve

Serious students and huffaz do not struggle to *find* memorization tools — they struggle to **retain** what they have already memorized. A ḥāfiẓ carries 600+ pages that decay **invisibly**; the dominant failure is forgetting, and the spiritual weight of losing hifz is heavy. Today this maintenance (*murājaʿa / manzil / dhor*) is managed in spreadsheets and on paper, which can record the past but cannot **decide what to revise today**, cannot **warn before a page rots**, and cannot **keep the daily load feasible**.

### The positioning

> **The app that makes sure a ḥāfiẓ never silently loses the Quran.**

We are a **maintenance/retention engine**, not a memorization course. The traditional revision workflow is the visible surface; a spaced-repetition scheduler is the silent engine underneath, allowed to do only three humble things paper cannot:

1. **Order** — surface the weakest / most-due pages first, within the track the user already accepts.
2. **Flag** — warn that a page is decaying *before* it is lost.
3. **Balance** — fit the day's revision into the user's time budget and re-spread gracefully after missed days.

The algorithm is demoted from "scheduler that tells you what to do" to **"the smart page-selector inside a fixed-shape traditional day."** Tradition wins on the surface; the algorithm wins only in the invisible ordering. This is what earns the trust of huffaz and teachers.

### Design principles

1. **Tradition is the interface; the math is invisible.** Users pick a *named cycle* (e.g. "1 juz/day," "7-manzil weekly khatm"), never a "retention slider."
2. **Nothing decays silently; nothing is hidden.** The engine may pull a page *forward*, never push it *past* its cycle ceiling, and is **forbidden** from ever telling a ḥāfiẓ a page is "safe to drop."
3. **Page schedules, line diagnoses.** Schedule the unit people actually recite (the muṣḥaf page); track finer (line) detail only to *localize* a weak spot.
4. **Interference is the enemy, not just decay.** Similar-verse confusion (mutashābihāt) is a first-class subsystem.
5. **Servant to the teacher.** Teacher sign-off (talaqqī) is first-class and always overrides the machine.
6. **Iḥsān.** Built free, for Allah — therefore it must be *excellent*, not "good enough because it's free."

---

## 3. Target Users

The languages (fa / ckb / ar) anchor this to **Iran, Iraqi Kurdistan, and Arabic-speaking communities**. Primary wedge first, the rest served by the same engine.

| Persona | Description | Need |
|---|---|---|
| **P1 — The finished / near-finished ḥāfiẓ (PRIMARY)** | Holds most or all 30 juz; fights decay across the whole Quran. | "Tell me exactly what to revise today; never let a juz silently rot; keep the load survivable when life interrupts." |
| **P2 — The active memorizer** | Still adding pages (sabaq) while maintaining what's done. | The same engine, plus a clean new-lesson + recent-revision loop. |
| **P3 — The adult late-starter** | Memorizing slowly alongside work/family. | Low daily budget, realistic cycles, no shame on missed days. |
| **P4 — The teacher / halaqa (LOCAL)** | Manages several students. | On-device multi-profile sign-off; no cloud — see [§15](#15-settings-presets--profiles). |
| **P5 — The parent** | Tracks a child's hifz. | A child profile under the same device. |

> Because the app is offline and account-free, "teacher" and "parent" features are **local multi-profile** on a shared device or via exported reports — never a server dashboard.

---

## 4. Non-Negotiable Religious Integrity Requirements

These outrank every feature. Any one, gotten wrong, ends the project. They are **release-blocking**.

### R1 — Text fidelity is existential
- Store the Uthmani text **byte-for-byte unmodified** from a single authoritative source (Tanzil Uthmani, CC BY 3.0, attributed).
- A **SHA-256 checksum of the text asset is verified in CI**; any byte change **fails the build**.
- Render **only** through bundled **KFGQPC per-page glyph fonts** — **never** the OS text shaper (the layer where broken ligatures and dropped/duplicated diacritics occur).
- Take page layout (line breaks, page boundaries) from a fixed dataset (QUL MushafPage); **never compute line breaks at runtime**.
- Any markers (weak-spot highlight, error position) are drawn as an **overlay of coordinates on the immutable glyph page** — never by re-typesetting or storing reconstructed text.
- A **CI visual-diff against reference muṣḥaf images** runs on the minimum supported OS versions of iOS and Android.

### R2 — State the riwāyah explicitly; stay neutral
- The muṣḥaf in use is shown in-app as **"Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf,"** never presented as "the Quran" in the absolute.
- The scheduler is **text-agnostic**; the muṣḥaf is a **swappable asset** (the data model supports alternative layouts/riwāyāt without an engine rewrite).
- **Zero bundled tafsīr, translation, or commentary in the product** — it inevitably encodes a school of thought. (Word meanings, if ever added, are an explicitly-sourced, scholar-reviewed, optional asset — out of scope here.)

### R3 — No gamification of the sacred
- No public leaderboards, no XP/points on recitation, no badges on ayāt, no confetti on completing a juz.
- **No guilt or fear-based notifications.** Notifications are neutral and calm ("Your revision for today is ready"), never "You'll lose your hifz."
- Progress is shown as a calm, non-shaming **retention heat-map**, not a streak you're punished for breaking.

### R4 — The mutashābihāt dataset must be scholar-reviewed and objective
- Scoped strictly to **objective near-identical / identical wording**, never interpretive or thematic groupings.
- Shipped as a reviewable, attributable dataset (ideally open, so it can be audited and corrected by the community).

### R5 — Privacy is part of religious trust
- Fully offline, **no account, no telemetry, no data leaves the device** (see [§17](#17-privacy--security)).
- Recitation is done aloud by the user to themselves or a teacher; **the app never records audio** (also protects women's privacy by construction — there is simply no microphone use).

### R6 — Servant to the talaqqī chain
- Teacher sign-off is a first-class grade that **overrides** any self-rating or algorithmic state.
- The app never claims authority over a teacher; copy and UX consistently frame it as an aid to revision, not a replacement for oral correction (*talaqqī*) and the *sanad* chain.

---

## 5. Scope — In / Out

### In scope (the complete product)
- The muṣḥaf-page revision **scheduler** with three lifecycle tracks and named cycle presets.
- **Cold-start** onboarding for a partial or complete ḥāfiẓ (self-assessment, no calibration grind).
- **Self-rating** and **on-device teacher sign-off** grading.
- **Daily session** screen ("what to revise today"), capped by time budget, ordered by tradition.
- **Graceful missed-day catch-up** (re-spread, never dump).
- **Whole-Quran retention heat-map** and per-juz / per-page health.
- **Mutashābihāt trainer** (discrimination drills from a bundled dataset + the user's own confusion log).
- **Muṣḥaf reader** (immutable rendering) for revision reference and to mark recitation extent.
- **Local multi-profile** (teacher/halaqa, family) on one device.
- **Optional downloadable reciter audio** (listen-to-correct aid; not required for the recite-from-memory flow).
- **Full localization** in fa / ckb / ar, all RTL, with localizable terminology, numerals, and calendars.
- **Local backup / export & import** (file-based).
- Local, calm **notifications**.

### Out of scope (explicitly excluded)
- ❌ AI recitation verification / mistake detection / any audio recognition (C2).
- ❌ Any backend, account, cloud sync, or live online service we operate (C1). *The core muṣḥaf is bundled in the binary; an on-demand download of static public optional packs from a GitHub repo is not a service.*
- ❌ **Always-on streaming** audio. *Recitation audio is supported only as an **optional reciter pack downloaded once** (then played offline) — not required for the recite-from-memory maintenance flow. See [§11](#11-quran-data--immutable-rendering).*
- ❌ Tafsīr / translation / commentary (R2).
- ❌ Gamification, social feeds, leaderboards (R3/C6).
- ❌ Monetization of any kind.

---

## 6. Domain Model & Core Concepts

### 6.1 The Quran structure (fixed reference data)
Bundled, read-only, never user-specific:
- **30 juz** → **60 ḥizb** → **240 rubʿ al-ḥizb** → **604 pages** (Ḥafṣ / Madani 15-line) → **lines (15/page)** → **ayah** (6,236) → words.
- Hierarchy is fixed glyph/layout data taken from the bundled muṣḥaf dataset; the app never recomputes it.

### 6.2 The three traditional tracks
The user always sees three familiar buckets (labels localizable — see [§13](#13-localization--rtl-architecture)):

| Track (generic) | Traditional names | Meaning |
|---|---|---|
| **New** | sabaq / al-jadīd / حفظ جدید / حیفزی نوێ | Today's new lesson being built (only for active memorizers). |
| **Near-revision** | sabqi / al-murājaʿa al-qarība / مرور نزدیک | Recently-memorized material (the rolling last ~1–3 juz) being consolidated. |
| **Far-revision** | manzil / dhor / al-murājaʿa al-baʿīda / مرور دور | The whole-Quran maintenance bulk — **the core of this app.** |

Internally these are **not three algorithms** — they are three **lifecycle phases of one page card**, distinguished by the page's stability/age. A page graduates New → Near → Far as it strengthens, and a lapse demotes it back into active revision (exactly the traditional "a forgotten manzil page rejoins revision").

### 6.3 Grading scale (one scale, all sources)
Every review — self or teacher — produces the same signal: a 4-level fluency grade plus optional **error positions** (which lines the user stumbled on).

| Grade | Meaning | Traditional verb (localized) |
|---|---|---|
| **Again (lapse)** | Could not recall / needed prompting / major break | "needed help" |
| **Hard** | Recalled but with stumbles | "minor mistakes" |
| **Good** | Fluent, clean | "recited clean" |
| **Easy** | Effortless, zero hesitation | "effortless" |

A grade is never just a number — **where** you stumbled (line indices) is the most valuable signal in hifz and drives weak-spot localization and mutashābihāt detection.

---

## 7. The Revision Engine (the heart)

This is the methodology-first design: traditional quotas define the *shape* of the day; the FSRS-style math decides *which pages* fill those quotas and *in what order*, and may only make a page **more** frequent, never less.

### 7.1 The scheduled unit: the page
- **One card = one muṣḥaf page** (604 cards for the standard muṣḥaf). Huffaz recite in flow (a whole page in one breath-chain); page-level scheduling matches recitation and keeps the card count comprehensible.
- **Sub-page (line) state is a derived overlay** used only to (a) localize weakness and (b) seed mutashābihāt links. Line-blocks are created **lazily**, only for a page that repeatedly lapses, so we don't carry thousands of fragments for the 95% of pages that are fine.
- The card **unit is a parameter**, not a hardcode, so non-15-line layouts can plug in later (R2).

### 7.2 Per-card state
```
Card {
  page_id            // 1..604 (the scheduling key)
  owner_id           // profile
  track              // NEW | NEAR | FAR | UNMEMORIZED
  D    : real [1..10]   // Difficulty
  S    : real (days)    // Stability (days for retrievability to fall to 0.9)
  last_review_at
  due_at             // next-due CEILING (always set for memorized cards; never null)
  reps, lapses : int
  weak_flag    : bool
  signoffs     : int    // teacher sign-offs counted toward graduation
  manual_lock  : bool   // teacher pinned this page into a track; auto-graduation suppressed
  prayer_critical : bool // Fātiḥa, last juz, Mulk, Kahf, Yāsīn, etc. → higher retention floor
}
```

### 7.3 The forgetting curve & interval (FSRS-style backbone)
```
DECAY  = -0.5
FACTOR = 0.9^(1/DECAY) - 1  = 19/81  ≈ 0.2346

retrievability(t, S) = (1 + FACTOR * t / S) ^ DECAY        // R(S) = 0.9 by definition
interval(S, R_target) = (S / FACTOR) * (R_target^(1/DECAY) - 1)   // days until R hits target
```
- These constants come from recognition-task research and are a **starting prior only**. Because we cannot AI-validate them, the engine never *depends* on their precision — the cycle ceiling (§7.6) is the real guarantee. The constants are tunable from the user's own lapse history over time (plain curve-fitting, no ML service).

### 7.4 Phase (track) as a function of stability
```
phase(card):
  if card.state == unmemorized:          UNMEMORIZED
  elif card.S <  NEAR_MIN_S (~9 days):   NEW        (still solidifying)
  elif card.S <  FAR_MIN_S  (~60 days):  NEAR
  else:                                  FAR
```
- Graduation is **age-and-rating driven and predictable** (a teacher can anticipate it), not a hidden jump. New → Near also requires *N teacher/self sign-offs*; Near → Far requires crossing `FAR_MIN_S` **and** falling outside the recent-juz window. A lapse shrinks S and naturally demotes the card.
- `manual_lock` lets a teacher pin a page in a track regardless of the math.

### 7.5 Retention target = high but finite, per phase
| Phase | Target retention (default, tunable) |
|---|---|
| New | 0.90 (cheap re-exposure while building) |
| Near | 0.94 |
| Far | 0.95 ordinary, **0.97+ for prayer-critical / weak / previously-lapsed pages** |

We deliberately do **not** chase a literal 0.99 globally — the cost curve explodes and blows past the daily budget, breaking trust faster than an occasional stumble does. **Near-100% retention is delivered by the cycle ceiling (§7.6), not by a fragile probability target.**

### 7.6 The trust clamp — the whole design in one rule
On every review, compute the SR-ideal next interval, but **clamp it to the user's chosen cycle ceiling**:
```
ideal_due   = today + interval(card.S, target_R(card))   // what the math wants
ceiling_due = today + cycle_ceiling_days(card, cycle)    // what the tradition promises
card.due_at = min(ideal_due, ceiling_due)                // SR may only make it MORE frequent
```
- Every page is therefore **guaranteed** to be re-recited at least once per chosen cycle (e.g. every 7 or 30 days), **no matter what the math says.** The algorithm's only freedom is to pull a weak page **forward**. It can never let a juz drift past the cycle. This is the "nothing decays silently" contract, in code.

### 7.7 Review update (lapse vs success)
```
onReview(card, grade, error_lines, source, today):
  log(card, grade, error_lines, source, today)          // append-only audit trail
  R = retrievability(daysSince(card.last_review_at), card.S)

  # sacred-text guard: a dropped/altered word is never "Good"
  if error_lines indicate a missed/added/swapped word: grade = min(grade, Hard)

  if grade == Again:                                     # lapse
     card.lapses += 1
     card.D = clamp(card.D + 1.0, 1, 10)
     card.S = max(MIN_S, card.S * lapseMultiplier(R))
     card.weak_flag = true
     maybeSplitIntoLineBlocks(card, error_lines)
  else:
     card.D = clamp(card.D - driftToEase(grade), 1, 10)
     gain   = stabilityGrowth(card.D, card.S, R, grade)
     card.S = card.S + gain * sourceConfidence(source)   # noisy self-rating moves state less
     if grade in {Good, Easy} and error_lines empty: card.weak_flag = false

  applyErrorOverlay(card.page_id, error_lines)           # only erring lines flagged
  card.D = clamp(card.D + WEAK_LINE_FACTOR * weakLineCount(card.page_id), 1, 10)

  updateGraduation(card, grade, source)                  # predictable, sign-off gated
  card.due_at = trustClamp(card, today)                  # §7.6
```

### 7.8 Building the day (visible = tradition, ordering = SR)
```
buildToday(profile, today):
  cfg   = profile.cycle_config
  cards = memorizedCards(profile);  for c in cards: c.R = retrievability(daysSince(c.last_review_at), c.S)

  # FAR (manzil): cycle guarantees full coverage; SR only orders + pulls forward
  far        = cards where phase==FAR
  cycleSlice = far pages scheduled by the chosen cycle for today      # tradition (e.g. 1 juz)
  pullFwd    = far pages where R < floor(c) and not already in cycleSlice
  farToday   = expandMutashabihat(sortByWeakestR(cycleSlice + pullFwd))

  # NEAR: literal recent-juz window, weakest-first
  nearToday  = sortByWeakestR(cards where phase==NEAR and inRecentWindow(c, cfg))

  # NEW: today's + yesterday's new lines, repeated to sign-off (active memorizers only)
  newToday   = sabaqLines(profile, cfg.new_lines_per_day)

  day = farToday + nearToday + newToday          # recited OLD before NEW (manzil → near → new)
  return loadBalance(day, cfg.daily_budget)      # §7.9
```

### 7.9 Load balancing & graceful catch-up
```
loadBalance(day, budget_minutes):
  # 1. FAR/manzil due items are MANDATORY (never drop dhor); schedule even if they overflow → gentle warning
  # 2. NEAR by urgency (target_R - R, descending): fit within budget; low-urgency pages may slip
  #    a day ONLY while predicted R stays above a hard floor (e.g. 0.85); a page crossing the
  #    floor is promoted to mandatory and can no longer be deferred.
  # 3. NEW only if budget remains and yesterday's sabaq is consolidated.
  # 4. Peak smoothing: nudge above-floor pages ±1–2 days within their ceiling to flatten spikes.
```
**Missed-day catch-up (a headline feature, not an edge case):** after a gap, the engine does **not** dump a red overdue pile. It re-flows the backlog over several days, most-decayed and prayer-critical first, and tells the user plainly: *"You missed 3 days — here is a 5-day catch-up plan that still completes your cycle."* Re-spread, never shame.

### 7.10 Cold start (the make-or-break onboarding)
Nobody can grade 604 pages on day one, and there is no review history. We **seed conservative priors and converge on real grades** — no calibration grind:
1. **Coverage capture:** the user marks which juz/surahs they hold (fast juz-level taps). Un-held pages stay `UNMEMORIZED`.
2. **Per-juz confidence:** for each held juz, pick **Solid / Shaky / Rusty** → seeds initial (D, S):
   - Solid → D=3, S=60d (enters FAR/manzil)
   - Shaky → D=5, S=14d (enters NEAR)
   - Rusty → D=7, S=4d (back to active revision)
3. **Stale-time decay (optional):** if the user gives *when* they memorized a juz, apply the forgetting curve from that date, so a juz finished years ago is treated as needing reactivation.
4. **Conservative bias:** priors deliberately *under*-estimate strength, so the first real recitation can only pleasantly surprise upward — better to over-review early than to skip a page the user has actually lost.
5. **Convergence:** real grades dominate the priors within ~2–3 weeks; the engine front-loads a light "calibration pass" so every held page gets reviewed once early.

### 7.11 Pure-cycle ("conservative") mode
For maximally traditional users/ulama who distrust any reordering: a setting that runs **fixed-rotation only** (SR ordering off, zero pull-forward) — the app becomes a faithful traditional tracker with smart load-balancing and catch-up, nothing more. SR-assist is then opt-in.

### 7.12 Engine invariants (must always hold)
- A memorized page's `due_at` is **never** later than its cycle ceiling.
- FAR/manzil due items are never silently dropped.
- The engine never displays or implies "this page is safe to stop revising."
- A teacher sign-off always supersedes self-rating and algorithmic state for that page.
- All math is pure Dart, deterministic, and golden-tested; identical inputs → identical schedule.

---

## 8. Grading (no-AI): self + on-device teacher

Two sources, one normalized signal `(grade, error_lines, source)`. **No audio, no AI.**

### 8.1 Self-rating
- After reciting a page **from memory**, the user grades it Again/Hard/Good/Easy.
- To reduce dishonest self-rating, the primary flow is **reveal-on-tap**: the page is hidden; the user recites; they reveal line-by-line (or whole page) and tap the lines where they stumbled, then the grade is *suggested* from the stumble count (still user-confirmable).
- Self-rating carries **lower confidence** (`sourceConfidence ≈ 0.5`): it moves stability less aggressively, and self-rating alone cannot push a page to the top retention tier without at least one teacher sign-off.

### 8.2 On-device teacher sign-off (talaqqī)
- A teacher, **physically present**, listens to the student recite and taps the verdict (and optionally the stumble lines) on the **same device** (or in the student's profile). `sourceConfidence = 1.0`.
- Teacher grades are authoritative: they set weak-flags, can graduate/demote a page, and override prior state.
- In **local halaqa mode** (§15), a teacher switches between student profiles on one device to sign off each.
- Sign-offs are recorded in the append-only `review_log` with `source = teacher` and an optional teacher label — a local audit trail that respects the *sanad* idea without any server.

### 8.3 What we explicitly do NOT do
- No microphone, no recording, no speech-to-text, no automatic mistake detection. Recitation correctness is judged by a human (the ḥāfiẓ or the teacher), exactly as the tradition does.

---

## 9. Mutashābihāt (similar-verse) System

Interference — confusing near-identical passages — is a leading cause of hifz failure, so it is first-class.

### 9.1 Data
- A **bundled, scholar-reviewed dataset** of the well-documented near-identical / identical passage groups (objective wording only — R4). Each group links the ayāt/pages involved and the distinguishing word(s)/phrase.
- A **personal confusion log** grown only from the user's own logged "swap" errors (page A's wording recited while in page B's location). Pure bookkeeping; no ML.

### 9.2 Behaviors
1. **Discrimination interleaving:** when a page in a group is due, its sibling(s) are pulled into the **same session** back-to-back so the brain practices telling them apart (massed contrast cures interference; spacing them apart worsens it).
2. **Confusion-aware grading:** a "wrong-branch" stumble bumps difficulty and review frequency on **all** group members (the problem is the pair, not the page).
3. **Anchor hinting:** the trainer can show the distinguishing phrase between siblings as a targeted micro-drill, rendered on the immutable glyph page as a highlight overlay (never re-typeset).

### 9.3 Standalone trainer
A dedicated **Mutashābihāt** screen: browse groups, run discrimination drills on demand, and see your personal confusion hotspots ("you keep swapping these two") — actionable in a way no spreadsheet can be.

---

## 10. Data Model / SQLite Schema

Local-first via **Drift (SQLite)**. Reference tables are read-only (shipped as a bundled, checksummed DB or generated on first run from bundled assets). User tables are per-profile.

### 10.1 Reference (read-only, bundled)
```sql
-- Fixed Quran structure & layout (from bundled muṣḥaf dataset; never recomputed)
page(page_id PK, juz, hizb, rub, surah_start, ayah_start, surah_end, ayah_end, line_count, qpc_font_name);
line(line_id PK, page_id FK, line_no, line_type, ayah_refs_json, text_glyph_ref);
ayah(ayah_id PK /* "s:a" */, surah, ayah, page_id FK, line_refs_json, sajda BOOL);
surah(surah_id PK, name_ar, revelation, ayah_count, bismillah_pre BOOL);
mushaf(mushaf_id PK, riwayah, name, line_count, page_count, font_family, checksum_sha256);

-- Mutashābihāt (scholar-reviewed, objective wording only)
mutashabih_group(group_id PK, type /* identical|near_identical|structural */, note_key);
mutashabih_member(group_id FK, ayah_id FK, distinguishing_word_index_json);
```

### 10.2 User data (per profile)
```sql
profile(profile_id PK, display_name, role /* self|student|child */, locale, mushaf_id FK,
        created_at, settings_json);

card(profile_id FK, page_id FK, track, d REAL, s REAL, last_review_at, due_at,
     reps INT, lapses INT, weak_flag BOOL, signoffs INT, manual_lock BOOL,
     prayer_critical BOOL, enabled BOOL, PRIMARY KEY(profile_id, page_id));

line_block(block_id PK, profile_id FK, page_id FK, line_start, line_end, error_count);
-- created lazily only for repeatedly-lapsing pages

review_log(log_id PK, profile_id FK, page_id FK, reviewed_at, track_at_review,
           grade, error_lines_json, elapsed_days, r_predicted,
           s_before, s_after, d_before, d_after,
           source /* self|teacher */, teacher_label NULLABLE);   -- append-only

confusion_edge(profile_id FK, ayah_a FK, ayah_b FK, weight REAL, last_confused_at);

cycle_config(profile_id PK FK, cycle_type, new_lines_per_day, near_window_juz,
             far_target_per_day, far_cycle_days, daily_budget_minutes,
             pure_cycle_mode BOOL, term_label_set, region_preset);

-- App-level (not per profile)
app_meta(key PK, value);   -- schema_version, text_checksum_verified_at, active_profile, etc.
```

### 10.3 Notes
- `review_log` is **append-only** — the trustworthy audit trail; never updated or deleted by normal flows (export/erase only).
- All timestamps stored UTC; displayed in the locale's calendar/numerals.
- Strength roll-ups (juz/ḥizb health %) are **computed from `card.R`**, not stored as a separate authority. Juz health uses a **min-leaning** aggregate (one weak page is what fails you in ṣalāh — surface the weakest link).

---

## 11. Quran Data & Immutable Rendering

### 11.1 Asset source: core bundled in the binary; optional packs from an open-source GitHub repo
The **core muṣḥaf is bundled in the app binary** and verified at build time, so the app is fully usable offline from first launch (no core download). **Optional** packs live in a **public, open-source GitHub repository** (itself a form of *waqf* — auditable, community-correctable open data), published as **versioned asset packs** (GitHub immutable Releases) and downloaded only on demand:

| Asset pack | Contents | Source / License | Delivery |
|---|---|---|---|
| **Core (bundled)** | Uthmani text (**Tanzil**, CC BY 3.0); page layout/segmentation (**QUL**); per-page **KFGQPC QCF V2** glyph fonts; **mutashābihāt** dataset | open / attributed (verify KFGQPC font terms) | **Bundled in the app binary**, verified at build time — no download. |
| **Reciter audio (optional)** | One reciter's ayah-level audio | open / attributed | Downloaded on demand, per reciter; large; skippable. |
| **Alt. muṣḥaf (optional, future)** | Other riwāyāt / layouts | open | Downloaded on demand (R2 — swappable muṣḥaf). |

The text is **never used for layout**; rendering is glyph-font only (§11.2).

### 11.1.1 Integrity (critical — guards R1)
- The **core muṣḥaf is bundled in the signed app binary** and pinned by a **build-time SHA-256 manifest**: CI fails the build if any bundled text/layout/font byte changes (§11.3). Because the core ships inside the binary, it is present and verified the instant the app is installed — there is **no core download** and no offline-at-first-run failure mode for the muṣḥaf.
- The app binary also ships the **pinned SHA-256 checksums and pinned release version** of every **optional** pack. A downloaded optional pack is **rejected and re-fetched** unless its hash matches exactly; the app **refuses to render Quran text** from any unverified asset.
- Optional-pack downloads are **HTTPS GET from GitHub immutable Releases / its CDN** — no API we run, no per-user data sent (the request carries only a public asset URL); a 404 on a pinned asset means "keep the verified local copy," never "fetch something else."
- The core and optional packs are versioned; an app update may bundle a newer, re-verified core or pin a newer, re-verified optional pack.

### 11.2 Rendering rules (enforce R1)
- Each page renders by selecting that page's **dedicated glyph font** and drawing its glyph codepoints — the font *is* the typeset page. The OS shaper is never asked to lay out Quran text.
- Highlights/overlays (weak line, mutashābihāt anchor, current ayah) are drawn as **rectangles/coordinates over the glyph layer**, computed from the bundled line/word geometry — never by editing text.
- Line breaks and page breaks come **only** from the bundled layout data.
- The reader supports zoom and night/sepia themes by transforming the rendered layer, not the text.

### 11.3 Integrity pipeline (CI + runtime)
1. **CI (build-time)** verifies the **bundled core**'s text/layout/604-font SHA-256 manifest matches the committed bundled assets, and that the bundled text matches the authoritative Tanzil hash → mismatch fails the build. The same gate verifies any **optional** pack's pinned checksums match its published GitHub immutable Release.
2. **CI** verifies each of the 604 **bundled** page fonts is present and unmodified (hash manifest).
3. **Runtime** re-verifies every **downloaded optional** pack's SHA-256 before first use (§11.1.1) and refuses unverified Quran assets; the bundled core is already build-time-verified.
4. **Visual-diff**: render every page on min-iOS and min-Android against reference muṣḥaf images within a tight pixel tolerance → diffs fail the build.
5. Spot-check sajda marks, ayah numbering, and basmala presence per surah against the reference.

---

## 12. Information Architecture & Screens

Bottom nav (RTL order — rightmost is "home"): **Today · Muṣḥaf · Mutashābihāt · Progress · Settings**. (Teacher/halaqa mode adds a profile switcher.)

### 12.1 Onboarding / Cold-start (§7.10)
- Welcome (intent + privacy + "we never record audio / never charge").
- Language pick (fa/ckb/ar) and muṣḥaf confirmation (riwāyah stated — R2).
- **Core muṣḥaf setup** — the core is **bundled** in the binary, so this is a brief, offline build-verify step (no download), not a network gate (§11.1.1). (Optional reciter audio is downloaded later, on demand.)
- **Coverage capture** (which juz held).
- **Per-juz confidence** (Solid/Shaky/Rusty); optional "when memorized."
- Cycle preset pick (named — §15) and daily time budget.
- Done → first day generated.

### 12.2 Today (the core screen)
- A short, **finite, capped** list: "Revise today" grouped Far → Near → New, in recitation order.
- Each item: page number/juz (localized numerals), track chip, a calm decay indicator. Tap → recite flow.
- **Recite flow:** page hidden → recite from memory → reveal-on-tap → mark stumble lines → grade (Again/Hard/Good/Easy) → next. Optional **teacher sign-off** toggle in-flow.
- After a missed gap: a gentle **catch-up banner** with the re-spread plan (§7.9), never a red shame-pile.
- Honest budget feedback: if the chosen scope can't fit the budget, the app says so and offers to raise budget / lengthen cycle / pause new sabaq — it never silently lets pages rot.

### 12.3 Muṣḥaf (reader)
- Immutable page rendering (§11). Swipe pages (RTL), jump to juz/ḥizb/surah/page.
- Weak lines and mutashābihāt anchors shown as overlays (toggleable).
- "Mark my memorized range" tool feeding coverage; "start revision here" entry to the recite flow.

### 12.4 Mutashābihāt
- Browse groups, run discrimination drills, view personal confusion hotspots (§9.3).

### 12.5 Progress
- **Whole-Quran retention heat-map** (604 pages / 30 juz), calm color scale = the emotional hook ("keep your Quran green"). Tap a juz → page detail.
- Per-juz / per-page health, weakest pages list, upcoming load forecast, simple history from `review_log`.
- **No streaks-as-pressure**; an optional, private, opt-in continuity indicator only.

### 12.6 Settings, Profiles, Backup
- §15 and §16.

---

## 13. Localization & RTL Architecture

First-class, not an afterthought. **All three languages are RTL** and fully translated.

### 13.1 Languages & scripts
| Locale | Language | Script | Notes |
|---|---|---|---|
| `fa` | Persian (Farsi) | Perso-Arabic, RTL | Primary. |
| `ckb` | Kurdish **Sorani** | Arabic-based (Sorani), RTL | Extra letters: پ چ ژ گ ڤ ڕ ڵ ۆ ێ ە — font must cover them. |
| `ar` | Arabic | Arabic, RTL | Quran/script base. |

> Kurmanji (Kurdish, Latin/Hawar) is **out of scope** by decision.

> Quran text itself is **always** the Uthmani muṣḥaf via QPC fonts regardless of UI language — only the **UI chrome** is localized. The Quran is never "translated" in-app (R2).

### 13.2 RTL layout
- `Directionality: TextDirection.rtl` app-wide; mirror all directional widgets, icons (back/next, progress), and the bottom nav.
- Use logical (start/end) insets everywhere; never hardcode left/right.
- Mixed-content safety: page numbers, "Juz 7," and Latin technical strings inside RTL text use proper bidi isolation (`Unicode FSI/PDI`, Flutter `Bidi`/`Directionality`).

### 13.3 Numerals & calendars
- **Numerals:** render digits in the locale set — Persian/Kurdish use **Extended Arabic-Indic** (۰۱۲۳۴۵۶۷۸۹); Arabic uses **Arabic-Indic** (٠١٢٣٤٥٦٧٨٩). Use `intl` `NumberFormat` per locale; never concatenate raw ASCII digits into localized strings.
- **Calendars:** support **Hijri (Umm al-Qurā)**, **Solar Hijri / Jalālī** (default for `fa`, and offered for Kurdish), and **Gregorian**. User-selectable; "next due / last reviewed" dates render in the chosen calendar and numerals.
- **Week start** and date formatting follow locale.

### 13.4 Localizable religious terminology
The sabaq/sabqi/manzil vocabulary is regional. Track labels, grade verbs, and cycle names are **string resources**, with region-appropriate default sets the user can switch:

| Concept | ar (default) | fa | ckb (best-effort — **needs native + scholar review**) |
|---|---|---|---|
| New lesson | الحفظ الجديد / السبق | حفظ جدید / سبق | حیفزی نوێ |
| Near-revision | المراجعة القريبة | مرور نزدیک | پێداچوونەوەی نزیک |
| Far-revision | المراجعة البعيدة / المنزل | مرور دور / منزل | پێداچوونەوەی دوور / مەنزڵ |
| Revision (general) | مراجعة | مرور | پێداچوونەوە |
| Manzil (the 7) | منزل | منزل | مەنزڵ |

> The Kurdish (Sorani) terms above are placeholders pending **native-speaker and scholarly review** — see [§21](#21-open-decisions-to-confirm). The architecture must make swapping a term-set trivial (one ARB/JSON file per locale + an optional regional override).

### 13.5 Fonts
- **Quran:** KFGQPC per-page QCF fonts (fixed; §11).
- **UI (fa/ar):** a high-quality Perso-Arabic UI font (e.g. **Vazirmatn** / **Estedad** / **Noto Naskh Arabic**) — bundled in the app, no font-CDN fetch.
- **UI (ckb, Sorani):** a font with **full Kurdish (Sorani) glyph coverage** (e.g. **Rabar**, **NRT**, **Speda**, or verified Vazirmatn coverage) — **verify all Sorani letters render** before locking.
- **UI fonts are bundled in the app binary.** The Quran (QPC) glyph fonts are also **bundled** in the binary (as hash-verified assets, §11 — amended 2026-06-18); no font is fetched from a font CDN or downloaded at runtime.

### 13.6 String management
- Flutter `gen_l10n` with ARB files per locale; 100% coverage gate in CI (no missing keys, no hardcoded user-facing strings).
- Pluralization and gender handled via ICU messages where the language needs it.

---

## 14. Notifications (local only)

- **Local notifications only** (`flutter_local_notifications`); no push, no server (C1).
- One calm daily reminder at a user-set time: *"Your revision for today is ready."* Tone is neutral and supportive — **never** guilt or fear (R3).
- Optional "catch-up ready" note after missed days, framed as help, not blame.
- Fully optional and easily silenced; no nagging escalation.

---

## 15. Settings, Presets & Profiles

### 15.1 Cycle presets (named, tradition-shaped)
Offered as named choices (not sliders). Defaults tuned for fa/ckb/ar regions; all editable:
- **7-Manzil weekly khatm** (the seven manāzil; full Quran every 7 days).
- **1 juz / day** (30-day cycle) · **½ juz / day** (60-day) · **2 juz / day** (15-day).
- **Custom** (far-cycle length, near-window size in juz, new-lines/day, daily budget).
- **Pure-cycle mode** toggle (§7.11) for maximal conservatism.

### 15.2 Terminology & display
- Term-set selector (regional vocabulary, §13.4); calendar; numeral system; language.
- Muṣḥaf selector (riwāyah shown; swappable per R2).
- Theme (light/sepia/dark), Quran font size/zoom.

### 15.3 Profiles (local multi-user — no cloud)
- Multiple profiles on one device (self, students, children).
- **Teacher / halaqa mode:** a quick profile switcher so a teacher signs off each student in turn on the same device; per-student `review_log` with teacher labels.
- **Child profile:** parent-managed; calm, no gamification.
- Profiles are device-local; sharing across devices is via export/import (§16), never a server.

---

## 16. Backup & Data Portability (offline)

- **Export:** write an encrypted-optional backup file (all profiles, cards, logs, configs) to local storage / share-sheet (user chooses where — local file, their own cloud drive, AirDrop, etc.). The app itself performs **no** network transfer.
- **Import / restore:** from a previously exported file; clear merge/replace semantics.
- **Transfer between devices / to a teacher:** export → user moves the file by any means they like → import. This is how "teacher sees student data" works without a backend.
- **Erase:** one action wipes all local data (right-to-be-forgotten by construction).
- Format: documented, versioned JSON (or SQLite dump) so data is never trapped.

---

## 17. Privacy & Security

- **No account, no login, no PII required.** A profile is just a display name the user types.
- **No telemetry, no analytics, no crash-reporting-to-server, no ads SDKs.** (Local-only diagnostic logs at most, never transmitted.)
- **No microphone / no audio recording** anywhere — recitation is judged by humans (R5). This also structurally protects women's privacy.
- **Network is used only to download static public Quran asset packs** (core pack once at onboarding; optional reciter packs on demand) from the open-source GitHub repo. **No per-user data is ever sent** — the request carries only a public asset URL. After download, the app works in airplane mode permanently.
- All data stays on-device; backups are user-initiated local files.

---

## 18. Accessibility

- Full **RTL** correctness and large-text support; respect OS text-scale.
- Adjustable Quran zoom and high-contrast/sepia/dark themes for low-vision reciters.
- Sufficient color contrast on the heat-map; never rely on color alone (use labels/patterns) — important for color-blind users.
- Semantic labels on all controls for screen readers, in each locale.
- Large tap targets for the recite/grade flow (used daily, often quickly).

---

## 19. Technical Architecture

### 19.1 Stack
- **Flutter** (iOS + Android), single codebase, RTL-first.
- **Persistence:** Drift (SQLite). Reference data bundled (checksummed); user data in local DB.
- **State:** Riverpod (or Bloc) — pick one and keep it consistent.
- **Scheduler:** a **pure-Dart package** (`engine/`) with **zero I/O** — deterministic, fully unit/golden-tested, independently versioned. The app layer feeds it state and persists results.
- **Localization:** `flutter_localizations` + `intl` + `gen_l10n` (ARB).
- **Notifications:** `flutter_local_notifications`.
- **Fonts/assets:** all bundled; no `google_fonts` runtime fetch.

### 19.2 Module layout
```
/engine        pure-Dart scheduler (forgetting curve, tracks, trust clamp, load balance, cold start) — no Flutter
/data          Drift schema, DAOs, reference-data loader + checksum verifier
/assets        asset-pack downloader (GitHub Releases), SHA-256 verifier, local cache
/quran         immutable rendering (QPC fonts), layout geometry, overlay painter
/features
  /today       daily session + recite/grade flow
  /mushaf      reader
  /mutashabihat trainer
  /progress    heat-map + stats
  /onboarding  cold-start
  /settings    presets, profiles, backup
/l10n          ARB files (ar, fa, ckb) + term-sets
/profiles      local multi-profile
```

### 19.3 Determinism & offline guarantees
- The engine is pure and deterministic (no wall-clock inside; "today" is injected) → reproducible schedules and golden tests.
- The **only** permitted network use is the asset-pack download client (HTTPS GET to GitHub Releases/CDN); a build-time check asserts **no analytics, ads, or backend SDKs** are linked (enforces C1). No sockets to any service we operate.
- Onboarding downloads and **checksum-verifies** the core asset pack (§11.1.1) before building the local DB; if a verified Quran asset is unavailable, the app refuses to render Quran text (R1).

---

## 20. Quality, Testing & Release Gates

**Release-blocking gates (all must pass):**
1. **Text & asset integrity:** the app's pinned SHA-256 checksums match the published GitHub Release packs (CI), and the runtime rejects any downloaded asset whose hash mismatches (R1).
2. **Visual-diff:** all 604 pages render-match reference images on min-OS iOS/Android.
3. **Engine golden tests:** scheduler outputs match pinned fixtures (curve, intervals, trust clamp never exceeds ceiling, manzil never dropped, lapse demotes, cold-start seeds).
4. **Invariant tests** (§7.12) as property-based checks.
5. **Localization completeness:** zero missing ARB keys; no hardcoded user-facing strings; RTL golden screenshots per locale; numeral/calendar rendering verified per locale.
6. **Network restraint:** release binary contains no analytics/ads/backend SDKs; the only network client is the asset-pack downloader (HTTPS to GitHub Releases).
7. **Mutashābihāt dataset:** scholar sign-off recorded; objective-wording scope verified.
8. **Manual muṣḥaf review:** a qualified ḥāfiẓ/scholar visually proofs a sample of pages, sajda marks, numbering, and basmala on real devices.

**Other testing:** unit (engine, DAOs), widget (recite flow, heat-map, RTL), integration (cold-start → first day → review → catch-up), accessibility audit, performance (page render + scheduler under a full 604-card load).

---

## 21. Open Decisions to Confirm

**Decided this round:** Languages are **Persian (fa), Kurdish Sorani (ckb), Arabic (ar)** — **Kurmanji dropped.** **(Amended 2026-06-18, owner decision — tech-decision-log #5/#8 amended:)** the **core muṣḥaf is bundled in the app binary** (byte-exact Tanzil Uthmani text + the unmodified KFGQPC QCF V2 per-page fonts + the QUL layout), verified by a **build-time** SHA-256 manifest, so the app is **fully usable offline from first launch**. Only **optional** packs (reciter audio, future alt-muṣḥaf) are **downloaded on demand** from the public open-source GitHub repo (exact-tag-pinned, runtime SHA-256 fail-closed), then fully offline. Recitation **audio is supported** as an optional downloadable reciter pack.

**Remaining:**
1. **Kurdish & Persian terminology.** The track/cycle term-sets need **native-speaker + scholarly review** before locking defaults (§13.4).
2. **Muṣḥaf edition for Iran/Kurdistan.** Default is KFGQPC **Madani 15-line (Ḥafṣ)**. Confirm acceptable, or whether a locally-familiar Ḥafṣ edition is preferred (architecture already treats the muṣḥaf as swappable).
3. **Mutashābihāt source dataset (scholarly review required — do not decide solo).** QUL's "Mutashabihat ul Quran" is a strong **candidate** dataset (E14), but QUL's "matching ayah and phrases" is likely **broader than R4**: it must be **scoped to objective, near-identical wording only** (R4) and **scholar-reviewed** before inclusion. Who provides the scholarly sign-off is open.
4. **Reciter(s) for the optional audio pack.** Which qārī, and the audio source/license (e.g. an open ayah-level set).
5. **Scholarly endorser(s).** Who attaches their name (R-series trust). Until then, copy stays "aid to revision, servant to the teacher."
6. **Open-source license intent.** Recommended for a free *ṣadaqah* project: code under a permissive or AGPL license; the Quran-data repo's text/dataset under CC BY (respecting KFGQPC font terms).
7. **Translations / tafsīr (out of scope unless explicitly approved).** Per R2 / non-negotiable #2 the app bundles **zero** tafsīr/translation. QUL *hosts* translations, but availability ≠ inclusion: they may be added only if a **named scholar approves** them as an **optional, off-by-default, clearly-labeled, license-cleared** pack — and only then via an **explicit tech-decision-log amendment**.

---

## 22. Glossary

- **Ḥifẓ / Hifz** — memorization of the Quran. **Ḥāfiẓ (pl. ḥuffāẓ)** — one who has memorized it.
- **Sabaq** — the new daily lesson. **Sabqi** — recent revision (near). **Manzil / Dhor** — far/old revision; also "manzil" = one of the seven traditional divisions for a weekly khatm.
- **Murājaʿa (Ar.) / Morūr (Fa.)** — revision.
- **Talaqqī** — learning/reciting orally to a teacher who corrects. **Sanad / Ijāza** — the chain of transmission and its certification.
- **Khatm / Khatma** — a complete pass through the whole Quran.
- **Mutashābihāt** — verses with near-identical or similar wording, a primary source of confusion.
- **Riwāya** — a transmission of the Quranic recitation (e.g. Ḥafṣ ʿan ʿĀṣim).
- **Muṣḥaf** — the physical/standard codex layout (here: Madani 15-line).
- **FSRS / DSR** — the modern spaced-repetition model (Difficulty, Stability, Retrievability) used here as a silent backbone, never user-facing.

---

*Built free, seeking only the pleasure of Allah. Taqabbal Allāhu minnā wa minkum.*
