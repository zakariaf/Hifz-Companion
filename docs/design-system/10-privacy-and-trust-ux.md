# 10 — Privacy & Trust UX

This file treats **trust as a design material**. Hifz Companion is structurally private by construction — no account, no login, no PII, no telemetry, no analytics, no microphone, no backend we operate; the only network use is a one-time, checksum-verified HTTPS download of *public* Quran assets, after which the app runs in airplane mode permanently ([PRD §17, §1/C1, R5, §11.1.1](../PRD.md)). That makes the design problem unusual: there is no data to collect responsibly, so this file is not about consent flows or data minimization. It is about the harder problem the structure creates — **a guarantee the user cannot see is a guarantee the user does not trust** — and about refusing the manipulative patterns the rest of the industry treats as default. It implements Pillar 5 (*private & offline by feel*) and supports Pillar 7 (*servant to the teacher*) and Pillar 2 (*calm, not cute*). It does not own a token family: it composes the calm palette from [03-color-and-themes.md](03-color-and-themes.md), the plain non-coercive wording from [11-voice-and-tone.md](11-voice-and-tone.md), the bottom-anchored one-tap ergonomics from [05-layout-spacing-touch.md](05-layout-spacing-touch.md), the locale handling from [12-localization-and-rtl.md](12-localization-and-rtl.md), and the accessible semantics from [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md). The verifiability claims here are the design face of the engineering integrity work (reproducible builds, checksum-pinned assets, F-Droid) cross-referenced from [`../PRD.md` §11.1.1, §19.3](../PRD.md).

## At a glance

| Concern | Decision | Evidence anchor | Cross-ref |
|---|---|---|---|
| Privacy framing | Stated as a **checkable fact**, never a feeling ("no network code after setup" not "we value your privacy") | Song et al. 2024; Acquisti | [11](11-voice-and-tone.md) |
| Perceptibility | An invisible guarantee is an untrusted one → give a *felt* proof (airplane-mode demo) | Wash 2010 (folk models) | this file |
| Where to surface it | At every decision moment, not once in a policy | Tsai et al. 2011 | [05](05-layout-spacing-touch.md) |
| No-collection posture | Truthful "Data Not Collected" / no-tracking, forced by architecture | Balash et al. 2024 | [PRD §19.3](../PRD.md) |
| Network actions | One-line honest, in-context rationale; nothing about the user sent | Android perms guidance; Liu et al. 2018 | [PRD §11.1.1](../PRD.md) |
| The few real choices | Protective default, reversible, one plain sentence | Felt et al. 2015; Acquisti et al. 2017 | [05](05-layout-spacing-touch.md) |
| Verifiability | Open source + reproducible builds + F-Droid (binaries run, not source) | F-Droid 2019; Mozilla 2023 | [PRD §11.1](../PRD.md) |
| Dark patterns | The five strategies are a release-gate checklist; any instance is a defect | Gray et al. 2018; Di Geronimo et al. 2020 | [09](09-accessibility-and-inclusivity.md) |

---

## 1. This audience parses privacy critically — trust here is religious, not cosmetic

**Statement.** The people this app serves have been burned by exactly this category, and for them privacy is a matter of *adab* and worship, not a settings toggle. The design must earn trust the way it is lost in this market — through structure, not reassurance.

**Evidence.**
- The defining cautionary case is **Muslim Pro**, among the most-installed Muslim apps in the world, found in 2020 to be sending users' precise location to the data broker X-Mode, whose data reached US defence contractors and the military — and critically, **the practice was undisclosed, with no install-time dialog explaining the transfer** ([Cox, 2020, Vice/Motherboard](https://www.vice.com/en/article/muslim-pro-location-data-military-xmode/)). For an app touching worship the breach was existential, not a line-item infraction.
- A peer-reviewed HCI study of the category — reviewing 11 Islamic apps and interviewing ten devoted users — concludes with an explicit call for "ethical and transparent data practices in religious technologies to maintain user trust," naming privacy as a first-order design concern for this user, not a compliance afterthought ([Kabir et al., 2024/2025, *Islamic Lifestyle Applications*](https://www.tandfonline.com/doi/full/10.1080/10447318.2025.2595545)).
- The lesson generalizes from a parallel intimate-data domain: a study of 30 top fertility apps found them activating on average **3.8 third-party trackers immediately on first launch, before any consent dialog**, and argued that such data demands a higher duty of care because users *cannot* see or stop the leak — protection must come from removing the collection surface, not from promising restraint ([Mehrnezhad & Almeida, 2021](https://dl.acm.org/doi/10.1145/3411764.3445132)).

**In practice.**
- The privacy posture is treated as a **release-blocking trust requirement** (mirroring PRD R5: "privacy is part of religious trust"), not a marketing screen — it is owned by architecture: the build contains no analytics, ads, or backend SDK, asserted by a build-time check ([PRD §19.3](../PRD.md)).
- The onboarding Welcome screen states the structural guarantee *before* asking anything of the user, in the locale's plain register: fa/ckb/ar each get a transcreated (not literally translated) sentence reviewed by a native speaker, set in the bundled Perso-Arabic UI font in `type.body`, on `color.bg.primary`, laid out with `EdgeInsetsDirectional` so it reads right-to-left natively ([11-voice-and-tone.md](11-voice-and-tone.md), [12-localization-and-rtl.md](12-localization-and-rtl.md)).
- Because this user is faith-motivated, the framing names the *intent* — built free as *ṣadaqah jāriyah*, no data collected by construction — which is itself the trust signal a privacy-literate audience tests against the running app.

**Anti-patterns — we will never:**
- Treat privacy as a one-time legal screen to dismiss; it is a structural property re-stated where the user weighs trust.
- Reach for any third-party SDK that phones home (analytics, ads, crash-reporting-to-server, attribution) — the Muslim Pro failure mode is forbidden at the dependency level ([PRD §17, §19.3](../PRD.md)).
- Use the words "we care about your privacy" as a substitute for a checkable fact (see §3).

---

## 2. Make the invisible guarantee *perceptible*, not merely correct

**Statement.** The central design problem is that a structural guarantee the user cannot see loses, by default, to the assumption that "an app is watching me." Correctness is not enough; the interface must make the structural fact *experiential* and *checkable*.

**Evidence.**
- Users reason about privacy through **folk theories / mental models** of how a system works, and those models — not the technical reality — drive both concern and protective behavior; the foundational interview study shows non-technical users hold incomplete, often wrong models of threats and defences ([Wash, 2010, *Folk Models of Home Computer Security*](https://dl.acm.org/doi/10.1145/1837110.1837125)). The corollary: if a user's model of "an app on my phone" assumes a server is logging them, the *absence* of that server is invisible and default distrust wins by inertia.
- This is why the deliverable is **perceptibility**: a true claim the user cannot verify is psychologically weak, so the burden falls on the interface to make the fact felt (it works in airplane mode — try it) and checkable (the code is open, the asset URLs are public), the same logic by which surfacing privacy at the decision point changes behavior (§3; [Tsai et al., 2011](https://pubsonline.informs.org/doi/10.1287/isre.1090.0260)).

**In practice.**
- **The airplane-mode proof.** An onboarding line invites the user to enable airplane mode and watch the app keep working after the one-time download — turning an abstract claim into a felt demonstration. The line uses `type.body`, a calm `color.text.secondary`, and no exclamation mark (Pillar 2).
- **A one-screen "what stays / what we send / what we can see" panel** in About/Privacy: *what stays here* (everything — your hifz record, on this phone), *what we send* (only a request for public Quran files; nothing about you), *what we can see* (nothing). Three short rows, each redundantly labeled with text + a non-color icon so meaning never depends on hue ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md); [WCAG 2.2 SC 1.4.1](https://www.w3.org/TR/WCAG22/)).
- All three rows render identically across fa/ckb/ar via logical insets; numerals (if any) use the locale set — Extended Arabic-Indic for fa/ckb, Arabic-Indic for ar — through `intl` `NumberFormat`, never raw ASCII ([12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Assume a true privacy claim "speaks for itself"; if the user cannot perceive or check it, we have not delivered it.
- Show a fake "securing your data…" or "syncing…" animation — there is no server to sync with, and a theatrical spinner would be a lie (see §3, §8).
- Bury the airplane-mode proof or the privacy panel behind a settings sub-menu the user must hunt for.

---

## 3. Honesty must be specific and verifiable — rhetoric and over-disclosure both read as evasion

**Statement.** With a privacy-literate audience, generic reassurance backfires and a wall of legalese signals something to hide. Say the few load-bearing, checkable facts plainly, once — and pair each with a way to verify it.

**Evidence.**
- Discourse analysis of how period/fertility companies responded to a privacy shock shows firms leaning on value-talk and brand ("our users' privacy is paramount to us"); the authors demonstrate these statements function as *reputation management* and call for privacy communication that is **specific, verifiable, and accountable** rather than rhetorical ([Song et al., 2024](https://dl.acm.org/doi/10.1145/3613904.3642384)). "We care about your privacy" is the phrasing of a company that collects data; "the app has no network code after setup — check airplane mode" is the phrasing of one that does not.
- The opposite failure is a **transparency dilemma**: notices and disclosures by themselves do not reliably resolve privacy concern, and excessive, framing-laden disclosure can reduce rather than build trust ([Acquisti, *The Economics of Privacy*](https://www.heinz.cmu.edu/~acquisti/economics-privacy.htm)). The implication is not "say less" but "say the few checkable facts plainly."
- Verifiability has a concrete vehicle: **open source**. Qualitative work on OSS trust finds the ability to inspect and independently audit code is a real basis for confidence — "you can look" answers "why should I trust this software?" ([Wermke et al., 2022, *Committed to Trust*](https://www.semanticscholar.org/paper/Committed-to-Trust:-A-Qualitative-Study-on-Security-Wermke-W%C3%B6hler/ca2925811878d47cd80113ece88c708cc4a594b0)). For a *ṣadaqah* project whose Quran data already lives in a public repo (a form of *waqf*; [PRD §11.1](../PRD.md)), open code and checksum-pinned asset URLs turn "trust us" into "verify us."

**In practice.**
- The Privacy/About screen is **one short, jargon-free screen**, not a scroll of policy. Each claim is paired with its check: a link to the open-source repository, the public checksum-pinned asset URLs ([PRD §11.1.1](../PRD.md)), and the airplane-mode demo from §2.
- Copy is owned by [11-voice-and-tone.md](11-voice-and-tone.md): plain, declarative, no marketing adjectives, no exclamation marks — "your hifz record stays on this phone" over "your data is safe with us." The same register is transcreated for fa/ckb/ar, not literally translated, so the calm, dignified tone survives the language (Persian *taʿārof* register handled in [11](11-voice-and-tone.md)).
- Links and the repository URL are mixed Latin runs inside RTL text; they are wrapped in bidi isolation (FSI/PDI) so a URL never visually breaks the right-to-left line ([12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Use rhetorical reassurance ("your privacy is paramount," "bank-level security") in place of a specific, checkable statement.
- Bury the few real facts under a wall of boilerplate legalese; over-disclosure erodes trust as surely as rhetoric ([Acquisti](https://www.heinz.cmu.edu/~acquisti/economics-privacy.htm)).
- Make a privacy claim we cannot point the user to a way of verifying.

---

## 4. Earn and showcase a truthful "no data collected" posture

**Statement.** Because the architecture forbids collection, the app can make the one claim most apps cannot: nothing is collected, nothing is tracked. That truthful posture is a measurable, behavior-moving trust asset — and it must be *forced by the build*, not typed into a form.

**Evidence.**
- A large privacy-label study (n=1,505, Prolific, January 2023) found that label contents sharply move risk perception and willingness to install: when a label showed *sensitive info collected and used for cross-app/website tracking*, participants were dramatically more likely to report a decrease in willingness to install (a ~304× effect on reported decrease), and participants struggled with jargon like "diagnostics," "identifiers," "track," and "linked" ([Balash et al., 2024](https://www.usenix.org/conference/soups2024/presentation/balash)). The inverse posture — truthfully collecting nothing — is therefore a strong trust asset, *provided* it is re-stated in plain language rather than left to store metadata.
- Lay users misparse privacy-label terminology and find labels disconnected from real controls, so a "no collection" guarantee must be **re-stated in plain words inside the app**, not delegated to the App Store / Play data-safety form ([Zhang et al., 2022, *How Usable Are iOS App Privacy Labels?*](https://petsymposium.org/popets/2022/popets-2022-0106.php)).

**In practice.**
- The truthful store posture (Apple "Data Not Collected"; Play Data Safety "no data shared/collected") is **made true by architecture, then referenced** — the build-time SDK check ([PRD §19.3](../PRD.md)) guarantees the label cannot become a lie through a future dependency.
- In-app, the same fact is stated in plain language on the privacy panel (§2/§3), avoiding the jargon Balash and Zhang flag — "tracking," "identifiers," "diagnostics" are replaced with concrete sentences the user can picture.
- Each language gets its own reviewed phrasing of "nothing is collected"; the row sits on `color.surface.container` with a non-color status icon so the assurance is legible to color-blind and screen-reader users alike ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)).

**Anti-patterns — we will never:**
- Rely on the store's self-reported privacy form as the *proof* of our posture (it is widely untrustworthy — see §7); it is a consequence of the architecture, not the evidence.
- Add a dependency that quietly collects diagnostics or identifiers and then "discloses" it in fine print.
- Use the label's own jargon ("identifiers," "tracking") in user copy where a plain sentence is clearer.

---

## 5. Name the absence of the microphone as a stated protection

**Statement.** The app structurally has no audio recording. Rather than leaving that as a silent gap, the app *names* it: recitation is judged by the ḥāfiẓ or a present teacher, and the app cannot listen — which also protects women's privacy by construction.

**Evidence.**
- A removed capability, *named*, is a trust signal — the same mechanism by which a truthful "not collected" declaration moves trust upward (§4; [Balash et al., 2024](https://www.usenix.org/conference/soups2024/presentation/balash)). The Muslim Pro lesson is that an *undisclosed* capability destroys trust; the inverse is that a *disclosed absence* builds it ([Cox, 2020](https://www.vice.com/en/article/muslim-pro-location-data-military-xmode/)).
- Runtime permissions are most trusted when requested in context with a truthful rationale; the relevant fact here is that the app requests **no** microphone, camera, contacts, or location permission at all, which an honest app should surface rather than hide ([Android Developers: *Request runtime permissions*](https://developer.android.com/training/permissions/requesting); under-used and frequently-wrong rationales documented in [Liu et al., 2018](https://ieeexplore.ieee.org/document/8506574/)).

**In practice.**
- Onboarding and the privacy panel both state plainly: the app has no microphone access; recitation correctness is judged by you or your teacher, not by the app ([PRD §8.3, R5](../PRD.md)). This is the no-AI / no-audio constraint (C2) turned into a felt privacy guarantee.
- The "no microphone" line is given equal weight to the "no account" and "no telemetry" lines on the panel — three peers, each `type.body`, each with a non-color icon, so the protection is not lost in a list.
- The framing for women's privacy is stated calmly and without singling out — "the app never records audio" — so it reads as a structural fact, not a gendered caveat, and is transcreated per locale in the dignified register of [11-voice-and-tone.md](11-voice-and-tone.md).

**Anti-patterns — we will never:**
- Add a microphone, recording, speech-to-text, or any audio-recognition capability — it is locked out by C2/R5 and the absence is a feature ([PRD §8.3](../PRD.md)).
- Request a permission the app does not use "just in case"; the permission set stays minimal and honest.
- Leave the no-audio guarantee implicit; a silent absence earns no trust, a named one does.

---

## 6. Frame the few network actions honestly and in context

**Statement.** The app's only network use is the one-time core-pack download and optional reciter/muṣḥaf packs — each an HTTPS GET of a *public* asset URL carrying no per-user data. Every such action is explained in context, at the moment it happens, with a truthful one-line rationale.

**Evidence.**
- Permissions and network actions are most trusted when requested **in context, at the moment the feature needs them, with a truthful rationale** — not up front in a batch ([Android Developers: *Request runtime permissions*](https://developer.android.com/training/permissions/requesting); the contextual-integrity field study [Wijesekera et al., 2015](https://people.eecs.berkeley.edu/~daw/papers/perms-sec15.pdf)).
- A large audit found runtime-permission rationales are under-used (in under a quarter of apps) and frequently *wrong*, so the bar is low and an honest, accurate rationale is itself a differentiator ([Liu et al., 2018](https://ieeexplore.ieee.org/document/8506574/)).

**In practice.**
- The core-pack download screen states, in context: "Downloading the Quran files once from a public open-source repository. This sends nothing about you." — never a vague "connecting…". It shows real progress and the integrity check, then confirms the app is now permanently offline ([PRD §11.1.1, §12.1](../PRD.md)).
- The optional reciter-audio screen carries the same honest line, plus the cost (size, skippable), so the user weighs an informed choice ([PRD §11.1](../PRD.md)).
- If the device is offline at first run, the screen explains plainly that a *one-time* download is needed and offers retry — not an error wall — and after that the app never needs the network again. Copy and numerals follow the locale ([12-localization-and-rtl.md](12-localization-and-rtl.md)); the primary "Download" / "Retry" action sits in the bottom thumb band ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)).

**Anti-patterns — we will never:**
- Make a network request without an in-context, plain-language explanation of what is fetched and that nothing about the user is sent.
- Disguise the one-time download as an ongoing "sync," or imply the app keeps talking to a server after setup.
- Batch a scary permissions/network prompt up front, divorced from the feature that needs it.

---

## 7. Verifiability must be structural, not self-reported — open source, reproducible builds, F-Droid

**Statement.** Self-reported store disclosures are widely untrustworthy, so our trust must rest on a property a third party can independently check. The strongest available answer to "the guarantee is invisible" is: rebuild it yourself.

**Evidence.**
- Mozilla's *See No Evil* study compared Google Play **Data Safety** labels of top apps against their own privacy policies and found discrepancies in roughly **80%** — labels "false or misleading," with loopholes letting data-sharing go undeclared ([Mozilla Foundation, 2023](https://www.mozillafoundation.org/en/blog/mozilla-study-data-privacy-labels-for-most-top-apps-in-google-play-store-are-false-or-misleading/)). A self-reported "we don't collect data" form is therefore weak evidence to a literate audience.
- Open source supplies the missing property, but only if the claim about the *running binary* can be verified — "source code does not run on computers; binaries do." F-Droid's position is that smartphone users are otherwise "forced to operate on faith," and **reproducible builds** close the gap by letting independent parties rebuild the published source and confirm the shipped app matches it bit-for-bit ([F-Droid, 2019, *Trust, Privacy, and Free Software*](https://f-droid.org/en/2019/05/05/trust-privacy-and-free-software.html); [F-Droid: *Reproducible Builds*](https://f-droid.org/docs/Reproducible_Builds/)).

**In practice.**
- The Privacy/About screen links the **open-source repository** and the **public checksum-pinned asset URLs** ([PRD §11.1, §11.1.1](../PRD.md)) — so "verify us" is a tap away, not a slogan. This is the design face of the engineering integrity pipeline (engineering doc 13 / [PRD §11.3, §19.3](../PRD.md)).
- The release path targets **reproducible builds and F-Droid** so a third party can confirm the published binary matches the public source — the verifiability counterpart of every claim on the privacy panel.
- The verification links are mixed Latin/RTL runs and use bidi isolation; their tap targets meet the 48×48dp minimum and sit on the grid so fa/ckb/ar users reach them identically ([05-layout-spacing-touch.md](05-layout-spacing-touch.md), [12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Point to the store's self-reported privacy form as proof of our posture; ~80% of such labels mislead ([Mozilla, 2023](https://www.mozillafoundation.org/en/blog/mozilla-study-data-privacy-labels-for-most-top-apps-in-google-play-store-are-false-or-misleading/)).
- Ship a closed binary whose behavior cannot be independently checked against public source.
- Hide the repository or asset-URL links where a user inclined to verify cannot find them.

---

## 8. Local-first ownership and real erasure are the privacy *features* — explain both halves honestly

**Statement.** The user owns their hifz record: it lives on their device, survives the project's disappearance, and is theirs to export or erase. Because there is no server, "delete" actually deletes. Both the power and the responsibility of ownership are stated plainly.

**Evidence.**
- The seven **local-first** ideals include *the network is optional*, *security and privacy by default*, and *you retain ultimate ownership and control*; the thesis is that cloud users become mere "borrowers" of their own data, whereas a local-first user is an owner ([Kleppmann et al., 2019, *Local-First Software*](https://dl.acm.org/doi/10.1145/3359591.3359737)). Framing privacy as *ownership* is both true here and motivating.
- Honesty must state the tradeoff, not just the upside (the specificity principle of §3; [Song et al., 2024](https://dl.acm.org/doi/10.1145/3613904.3642384)): a user-held backup removes the cloud-snooping channel entirely but makes the user responsible for the file, so both halves are stated.

**In practice.**
- **Backup as a privacy feature.** Backups are user-initiated local files the app moves nowhere ([PRD §16](../PRD.md)); the export screen states both halves: "Your backup is a file you keep. We never upload it, and only you can restore from it." Optional encryption follows the safe-default rule of §9.
- **Erasure is real, immediate, honest.** One action wipes all local data — right-to-be-forgotten by construction ([PRD §16](../PRD.md)). The copy says plainly that because there is no server, nothing is recoverable elsewhere — a guarantee most apps cannot truthfully make. Erase sits in the hard-to-reach top corner behind a confirmation, using thumb-zone difficulty as a natural safety margin, never as friction-for-friction's-sake ([05-layout-spacing-touch.md](05-layout-spacing-touch.md)).
- Export/import and erase are one deliberate action each, fully transcreated for fa/ckb/ar, with locale numerals and calendar in any backup-date display ([12-localization-and-rtl.md](12-localization-and-rtl.md)).

**Anti-patterns — we will never:**
- Imply a backup is uploaded or synced to a server; the app performs no network transfer for user data ([PRD §16](../PRD.md)).
- Offer a "soft delete" that secretly retains data, or imply erasure when something persists.
- Hide the export or erase action, or gate either behind an account, upgrade, or unrelated step (see §9, forced action).

---

## 9. For the few real choices, default to the safe path — opinionated, never coercive

**Statement.** The app has only a handful of genuine choices — notifications, optional reciter-audio download, optional backup encryption. Each follows warning-science: the protective option is the default and the visually primary one, the consequential action is one deliberate step away, one decision per screen, no jargon — and every default is reversible and explained in a single sentence.

**Evidence.**
- Users do not fully read or understand privacy/security text, so behavior must be steered by **defaults and opinionated design**, not by comprehension: redesigning a warning around brief, non-technical, specific text — visually promoting the safe choice and putting the risky option behind an extra step — raised adherence to the safe choice by ~30 percentage points even without full comprehension ([Felt et al., 2015, *Improving SSL Warnings*](https://adrifelt.github.io/sslinterstitial-chi.pdf)).
- Defaults are powerful because of status-quo bias, which is exactly why they are weaponized as dark patterns (pre-ticked consent, opt-out tracking); the same review catalogs the *legitimate* nudge levers an honest app uses to help rather than trick — information, presentation/salience, defaults, timing, reversibility ([Acquisti et al., 2017, *Nudges for Privacy and Security*](https://www.heinz.cmu.edu/~acquisti/papers/AcquistiAdjeridBalebakoBrandimarteCranorKomanduriLeonSadehSchaubSleeper-ACMCS-2017.pdf)).

**In practice.**

| Choice | Safe default | Reversible? | The honest one-line |
|---|---|---|---|
| Daily reminder | one calm reminder, off-by-default until the user opts in / easily silenced | yes, one tap | "A neutral reminder at a time you choose. Silence it anytime." |
| Reciter audio | not downloaded (skippable) | yes | "Optional. Large download from a public repo; nothing about you is sent." |
| Backup encryption | offered, protective default on | yes | "Locks your backup file with a password only you hold." |

- The safe choice is the visually primary control (a `FilledButton` in the bottom thumb band, [05-layout-spacing-touch.md](05-layout-spacing-touch.md)); the consequential action is a plainer, secondary affordance — never hidden, but one deliberate step away. One decision per screen, mirroring the onboarding template.
- No pre-ticked boxes; opt-in is an explicit tap. Each toggle's state is announced to screen readers per locale ([09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md)), and the explanatory sentence is transcreated for fa/ckb/ar in the calm register of [11-voice-and-tone.md](11-voice-and-tone.md).

**Anti-patterns — we will never:**
- Pre-tick a consent or opt-in box, or make the privacy-protective option the harder, buried one.
- Default notifications to an aggressive cadence or use status-quo bias to keep the user opted into something they did not choose.
- Use a single legitimate nudge lever (default, salience, timing) to manipulate rather than to help; the protective path is always the easy path.

---

## 10. The reminder layer stays calm and peripheral — attention is taken only as the task needs

**Statement.** The notification and reminder layer is where well-meaning apps slide into manipulation. Hifz Companion takes only the attention the task requires: one neutral, optional daily reminder, no guilt, no fear, no streak pressure, no escalation. Honesty about attention is continuous with honesty about data.

**Evidence.**
- The **calm-technology** tradition holds that technology should demand the smallest possible amount of attention, live in the periphery, and never pull a person out of being human ([Weiser & Brown, 1995, codified by Case, 2016, *Calm Technology*](https://calmtech.com/)). For a worship-adjacent app this is doctrinal, not stylistic — [PRD R3/C6, §14](../PRD.md) forbid guilt/fear notifications, streak nags, and gamification of the sacred.
- Coercive engagement mechanics (streaks-as-pressure, loss-aversion nags) erode the very autonomy and trust the app exists to serve — the autonomy-supportive framing that persuades without backfiring is the same lever behind the servant-to-the-teacher voice (Pillar 7; [11-voice-and-tone.md](11-voice-and-tone.md)).

**In practice.**
- One local notification (`flutter_local_notifications`, no push, no server; [PRD §14](../PRD.md)): "Your revision for today is ready." Neutral, supportive, never "You'll lose your hifz." Fully optional, trivially silenced, no escalating cadence.
- After missed days, the optional "catch-up ready" note is framed as help, not blame, mirroring the re-spread (never shame-pile) catch-up of [PRD §7.9, §12.2](../PRD.md). Copy is owned by [11-voice-and-tone.md](11-voice-and-tone.md) and transcreated per locale.
- The reminder time renders in the user's calendar and numerals (Hijri / Solar-Hijri-Jalālī / Gregorian; [12-localization-and-rtl.md](12-localization-and-rtl.md)); the notification itself uses no celebratory motion or sound beyond the OS default (Pillar 2; [06-motion-and-haptics.md](06-motion-and-haptics.md)).

**Anti-patterns — we will never:**
- Send guilt-, fear-, or loss-framed notifications, or any "you'll lose your hifz" nag ([PRD R3](../PRD.md)).
- Build a streak the user is punished for breaking, or escalate reminder frequency to re-engage a lapsed user.
- Use notifications to advertise, upsell, or pull the user back for engagement's sake — there is nothing to sell and no metric to farm.

---

## 11. Audit every screen against the five dark-pattern strategies — as a release gate

**Statement.** Every screen is held to a named, checkable standard: the five dark-pattern strategies. Any instance found is a defect, logged and fixed before release. This makes "no dark patterns" auditable rather than aspirational.

**Evidence.**
- Practitioner-collected examples cluster into five high-level strategies that recur across manipulative UX: **nagging** (repeated interruption toward the designer's goal), **obstruction** (making a path like cancelling or exporting artificially hard), **sneaking** (hiding or delaying relevant information), **interface interference** (manipulating visual hierarchy to privilege one option), and **forced action** (gating a desired thing behind an unrelated requirement) ([Gray et al., 2018, *The Dark (Patterns) Side of UX Design*](https://dl.acm.org/doi/10.1145/3173574.3174108)). A 2024 synthesis unifies prior taxonomies and defines dark patterns as designs using **manipulation, coercion, or deception to undermine user autonomy** ([Gray et al., 2024, *An Ontology of Dark Patterns Knowledge*](https://dl.acm.org/doi/10.1145/3613904.3642436)).
- This is the industry's default gravity, not a fringe: an automated audit of 240 popular mobile apps found **95% contained at least one dark pattern**, averaging around seven distinct types, with most users unable to perceive them ([Di Geronimo et al., 2020, *UI Dark Patterns and Where to Find Them*](https://dl.acm.org/doi/10.1145/3313831.3376600)). Naming the taxonomy lets us hold the design to a checkable standard.

**In practice.** Each release audits every screen against the five strategies:

| Strategy | Our commitment | How the app structurally avoids it |
|---|---|---|
| **Nagging** | none | nothing to upsell; one optional reminder, no re-engagement loop (§10) |
| **Obstruction** | none | export, import, erase, and silencing reminders are one tap each (§8, §9) |
| **Sneaking** | none | no hidden network calls; every fetch is explained in context (§6); no pre-checked options (§9) |
| **Interface interference** | none | the privacy-protective option is never visually buried; honest hierarchy (§9; [05](05-layout-spacing-touch.md)) |
| **Forced action** | none | no account, no upgrade, no unrelated gate; the only required step is the one-time, clearly-explained asset download (§6) |

- The audit is added to the accessibility/release checklist in [09-accessibility-and-inclusivity.md](09-accessibility-and-inclusivity.md) so it ships as a gate, alongside RTL and contrast checks, in all three locales.
- Because there is no monetization, no ads, and no engagement metric ([PRD owner intent, §5](../PRD.md)), the *incentive* to deploy these patterns is absent — the audit confirms the architecture, rather than fighting a business model.

**Anti-patterns — we will never:**
- Ship a screen that nags, obstructs, sneaks, interferes with honest hierarchy, or forces an unrelated action — any instance is a logged defect.
- Treat "no dark patterns" as a vibe; it is an auditable release gate against a named taxonomy ([Gray et al., 2018](https://dl.acm.org/doi/10.1145/3173574.3174108)).
- Introduce an engagement metric or revenue surface that would create the incentive these patterns serve.

---

## References

- Acquisti, A. *The Economics of Privacy and Personal Data* (review page and collected work on the limits of privacy transparency, control, framing, and disclosure). Carnegie Mellon University. https://www.heinz.cmu.edu/~acquisti/economics-privacy.htm
- Acquisti, A., Adjerid, I., Balebako, R., Brandimarte, L., Cranor, L. F., Komanduri, S., Leon, P. G., Sadeh, N., Schaub, F., & Sleeper, M. (2017). Nudges for Privacy and Security: Understanding and Assisting Users' Choices Online. *ACM Computing Surveys*, 50(3). https://www.heinz.cmu.edu/~acquisti/papers/AcquistiAdjeridBalebakoBrandimarteCranorKomanduriLeonSadehSchaubSleeper-ACMCS-2017.pdf
- Android Developers. *Request runtime permissions* (best practice: ask in context, provide an honest rationale). https://developer.android.com/training/permissions/requesting
- Balash, D. G., Ali, M. M., Kanich, C., & Aviv, A. J. (2024). "I would not install an app with this label": Privacy Label Impact on Risk Perception and Willingness to Install iOS Apps. *Twentieth Symposium on Usable Privacy and Security (SOUPS 2024)*, USENIX, 413–432. https://www.usenix.org/conference/soups2024/presentation/balash
- Case, A. (2016). *Calm Technology: Principles and Patterns for Non-Intrusive Design*. O'Reilly. (Codifying Weiser & Brown, Xerox PARC, 1995.) https://calmtech.com/
- Cox, J. (2020). How the U.S. Military Buys Location Data from Ordinary Apps / Muslim Pro Stops Sharing Location Data After Motherboard Investigation. *Vice (Motherboard)*. https://www.vice.com/en/article/muslim-pro-location-data-military-xmode/
- Di Geronimo, L., Braz, L., Fregnan, E., Palomba, F., & Bacchelli, A. (2020). UI Dark Patterns and Where to Find Them: A Study on Mobile Applications and User Perception. *Proceedings of the 2020 CHI Conference on Human Factors in Computing Systems (CHI '20)*. https://dl.acm.org/doi/10.1145/3313831.3376600
- F-Droid (2019). *Trust, Privacy, and Free Software*. F-Droid project blog; and F-Droid, *Reproducible Builds* (documentation). https://f-droid.org/en/2019/05/05/trust-privacy-and-free-software.html · https://f-droid.org/docs/Reproducible_Builds/
- Felt, A. P., Ainslie, A., Reeder, R. W., Consolvo, S., Thyagaraja, S., Bettes, A., Harris, H., & Grimes, J. (2015). Improving SSL Warnings: Comprehension and Adherence. *Proceedings of the 2015 CHI Conference on Human Factors in Computing Systems (CHI '15)*. https://adrifelt.github.io/sslinterstitial-chi.pdf
- Gray, C. M., Kou, Y., Battles, B., Hoggatt, J., & Toombs, A. L. (2018). The Dark (Patterns) Side of UX Design. *Proceedings of the 2018 CHI Conference on Human Factors in Computing Systems (CHI '18)*, 1–14. https://dl.acm.org/doi/10.1145/3173574.3174108
- Gray, C. M., Santos, C., Bielova, N., & Mildner, T. (2024). An Ontology of Dark Patterns Knowledge: Foundations, Definitions, and a Pathway for Shared Knowledge-Building. *Proceedings of the 2024 CHI Conference on Human Factors in Computing Systems (CHI '24)*. https://dl.acm.org/doi/10.1145/3613904.3642436
- Kabir, M., Kabir, M. R., & Islam, R. S. (2024/2025). Islamic Lifestyle Applications: Meeting the Spiritual Needs of Modern Muslims. *International Journal of Human–Computer Interaction* (Taylor & Francis). https://www.tandfonline.com/doi/full/10.1080/10447318.2025.2595545 · preprint: https://arxiv.org/abs/2402.02061
- Kleppmann, M., Wiggins, A., van Hardenberg, P., & McGranaghan, M. (2019). Local-First Software: You Own Your Data, in Spite of the Cloud. *Onward! 2019 (ACM SIGPLAN)*. https://dl.acm.org/doi/10.1145/3359591.3359737
- Liu, X., Leng, Y., Yang, W., Wang, W., Zhai, C., & Xie, T. (2018). A Large-Scale Empirical Study on Android Runtime-Permission Rationale Messages. *IEEE Symposium on Visual Languages and Human-Centric Computing (VL/HCC 2018)*, 137–146. https://ieeexplore.ieee.org/document/8506574/
- Mehrnezhad, M., & Almeida, T. (2021). Caring for Intimate Data in Fertility Technologies. *Proceedings of the 2021 CHI Conference on Human Factors in Computing Systems (CHI '21)*. https://dl.acm.org/doi/10.1145/3411764.3445132
- Mozilla Foundation — Caltrider, J., Rykov, M., & MacDonald, Z. (2023). *Mozilla Study: Data Privacy Labels for Most Top Apps in Google Play Store are False or Misleading* ("See No Evil"). https://www.mozillafoundation.org/en/blog/mozilla-study-data-privacy-labels-for-most-top-apps-in-google-play-store-are-false-or-misleading/
- Song, Q., Hernandez, R. H., Kou, Y., & Gui, X. (2024). "Our Users' Privacy is Paramount to Us": A Discourse Analysis of How Period and Fertility Tracking App Companies Address the Roe v Wade Overturn. *Proceedings of the 2024 CHI Conference on Human Factors in Computing Systems (CHI '24)*. https://dl.acm.org/doi/10.1145/3613904.3642384
- Tsai, J. Y., Egelman, S., Cranor, L., & Acquisti, A. (2011). The Effect of Online Privacy Information on Purchasing Behavior: An Experimental Study. *Information Systems Research*, 22(2), 254–268. https://pubsonline.informs.org/doi/10.1287/isre.1090.0260
- Wash, R. (2010). Folk Models of Home Computer Security. *Proceedings of the Sixth Symposium on Usable Privacy and Security (SOUPS '10)*. https://dl.acm.org/doi/10.1145/1837110.1837125
- Wermke, D., Wöhler, N., Klemmer, J. H., Fourné, M., Acar, Y., & Fahl, S. (2022). Committed to Trust: A Qualitative Study on Security & Trust in Open Source Software Projects. *IEEE Symposium on Security and Privacy (S&P 2022)*. https://www.semanticscholar.org/paper/Committed-to-Trust:-A-Qualitative-Study-on-Security-Wermke-W%C3%B6hler/ca2925811878d47cd80113ece88c708cc4a594b0
- Wijesekera, P., Baokar, A., Hosseini, A., Egelman, S., Wagner, D., & Beznosov, K. (2015). Android Permissions Remystified: A Field Study on Contextual Integrity. *24th USENIX Security Symposium*. https://people.eecs.berkeley.edu/~daw/papers/perms-sec15.pdf
- W3C (2023, updated 2024). *Web Content Accessibility Guidelines (WCAG) 2.2* — SC 1.4.1 Use of Color. https://www.w3.org/TR/WCAG22/
- Zhang, S., Feng, Y., Yao, Y., Cranor, L. F., & Sadeh, N. (2022). How Usable Are iOS App Privacy Labels? *Proceedings on Privacy Enhancing Technologies (PoPETs)*, 2022(4), 204–228. https://petsymposium.org/popets/2022/popets-2022-0106.php
