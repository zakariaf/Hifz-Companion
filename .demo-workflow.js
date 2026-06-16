export const meta = {
  name: 'hifz-html-demo',
  description: 'Build a clickable static HTML demo of the Hifz app from the design-system docs (RTL, Persian-primary)',
  phases: [
    { title: 'Foundation', detail: 'shared tokens.css + app.css from the design-system docs' },
    { title: 'Screens', detail: 'one agent per screen builds a clickable RTL HTML page' },
    { title: 'Hub', detail: 'index landing page linking every screen' },
  ],
}

const BASE = '/Users/zakariafatahi/Projects/MobileApps/hifz'
const DEMO = `${BASE}/demo`
const CHUNK = 5

// A phone-frame, RTL, Persian-primary static demo. Shared CSS owns the design tokens.
const COMMON = `This is a STATIC HTML demo (no build, no JS framework — plain HTML + the shared CSS; minimal vanilla JS only for tab/nav switching is fine). It is a visual prototype so the founder can SEE the app before it is built in Flutter.

HARD RULES for every page:
- RTL: <html dir="rtl" lang="fa">. Persian (Farsi) is the primary UI language; copy is in Persian. Where a term is traditional Arabic (sabaq/sabqi/manzil, juz, khatm) keep it.
- Link the shared stylesheets: <link rel="stylesheet" href="styles/tokens.css"><link rel="stylesheet" href="styles/app.css">. Do NOT redefine token values inline — use the CSS variables/classes the foundation defines (colors, type, spacing, radii). If you need a one-off, use existing tokens.
- Render the page inside a PHONE FRAME (a centered ~390px-wide device mockup with a bottom tab bar), matching the design-system layout/components.
- Calm, reverent, NON-gamified: no streaks/badges/confetti/exclamation-heavy copy. Low-arousal palette from tokens. This is an Islamic Quran-retention app built free as ṣadaqah.
- Numerals: use Persian (Extended Arabic-Indic) digits ۰۱۲۳۴۵۶۷۸۹ in the UI.
- Quran text: the real app renders immutable KFGQPC glyph fonts; HERE use a web Arabic Quran font via CDN (e.g. Amiri Quran from Google Fonts) PURELY as a DEMO PLACEHOLDER, and add a small caption noting "نمونه — متن مصحف در اپ نهایی با فونت‌های گلیف KFGQPC رندر می‌شود" (demo placeholder; final app uses KFGQPC glyph fonts). Use a SHORT, well-known correct passage (e.g. al-Fātiḥa or the start of al-Baqara) and keep it minimal to avoid any text error.
- Bottom tab bar (RTL order): امروز (Today) · مصحف (Muṣḥaf) · متشابهات (Mutashābihāt) · پیشرفت (Progress) · تنظیمات (Settings). Mark the active tab per screen. Link tabs to the other pages (today.html, mushaf.html, mutashabihat.html, progress.html, settings.html) so the demo is clickable.
- A small fixed "fa / ckب / ar" language pill (visual only) top-corner is nice-to-have.
- Accessibility: real semantic HTML, sufficient contrast (per tokens), never color-only state (add labels/icons).

Read FIRST (use the Read tool): ${BASE}/docs/PRD.md (§12 screens, §13 RTL/numerals), and the relevant design-system docs listed for your screen, and ${DEMO}/styles/tokens.css + ${DEMO}/styles/app.css (already written) so you reuse the shared classes/variables.`

const SCREENS = [
  { file: 'onboarding.html', label: 'Onboarding / cold-start', docs: 'docs/design-system/11-voice-and-tone.md, docs/design-system/01-design-principles.md, docs/PRD.md §12.1 + §7.10',
    scope: 'The onboarding flow shown as a sequence of cards on one scrollable page: (1) welcome + intent (free ṣadaqah; "ما هرگز صدای شما را ضبط نمی‌کنیم / هرگز برای خواندن قرآن هزینه نمی‌گیریم"; works offline); (2) language pick fa/ckb/ar; (3) muṣḥaf + riwāyah stated ("حفص از عاصم — مصحف مدینه"); (4) one-time core-pack download with a progress bar + integrity check; (5) coverage capture (which juz are memorized — a 30-juz grid with toggles); (6) per-juz confidence Solid/Shaky/Rusty (محکم/لرزان/زنگارگرفته); (7) named cycle preset + daily minutes. End with a "شروع" button to today.html.' },
  { file: 'today.html', label: 'Today / daily session', docs: 'docs/design-system/07-components.md, docs/design-system/05-layout-spacing-touch.md, docs/PRD.md §12.2 + §7.8-7.9',
    scope: 'The core Today screen: a calm header (date in Hijri+Jalālī, today\'s budget e.g. "۴۵ دقیقه"), then a finite capped "مرور امروز" list grouped مرور دور/منزل (far) → مرور نزدیک (near) → سبق (new) in recitation order. Each row is a page card: page number (e.g. صفحهٔ ۲۵۴), juz, a track chip, and a calm decay dot (color+label, not color-only). Include the graceful missed-day catch-up banner variant ("۳ روز غیبت — برنامهٔ ۵ روزه جبران"). Tapping a card conceptually opens recite.html. Active tab: امروز.' },
  { file: 'recite.html', label: 'Recite & grade flow', docs: 'docs/design-system/07-components.md, docs/design-system/06-motion-and-haptics.md, docs/PRD.md §8.1',
    scope: 'The reveal-on-tap recite flow for one page: the muṣḥaf page is hidden/blurred ("از حفظ بخوانید"), a reveal control, then after revealing, the four calm grade buttons دوباره/سخت/خوب/آسان (Again/Hard/Good/Easy) and an optional "علامت‌گذاری سطرهای لغزش" (mark stumble lines) and a "تأیید استاد (تلقّی)" teacher sign-off toggle. No microphone, no audio, no AI — make that obvious. Calm, no celebration. Show a small progress ("۳ از ۱۲").' },
  { file: 'mushaf.html', label: 'Muṣḥaf reader', docs: 'docs/design-system/04-typography.md, docs/engineering/08-quran-data-and-immutable-rendering.md, docs/PRD.md §11.2',
    scope: 'The muṣḥaf reader: a single page rendered book-like (demo placeholder Quran font, the placeholder caption), the riwāyah line, page/juz/hizb indicator in Persian numerals, RTL page navigation (‹ صفحهٔ بعد / صفحهٔ قبل ›), and a toggle to show weak-line / mutashābihāt overlay markers (drawn as faint highlight bands over lines — demo). Sepia/dark/light theme chips. Active tab: مصحف.' },
  { file: 'mutashabihat.html', label: 'Mutashābihāt trainer', docs: 'docs/design-system/07-components.md, docs/science/05-interference-and-mutashabihat.md, docs/PRD.md §9.3',
    scope: 'The mutashābihāt (similar-verse) trainer: a list of confusable groups; an open discrimination drill showing two near-identical passages side-by-side (or stacked) with the DIVERGING words highlighted, and an "کدام صفحه؟" disambiguation prompt; plus a "نقاط اشتباه شما" personal confusion-hotspots list. Demo placeholder Quran font + caption. Active tab: متشابهات.' },
  { file: 'progress.html', label: 'Progress / retention heat-map', docs: 'docs/design-system/08-data-visualization.md, docs/PRD.md §12.5, docs/design-system/03-color-and-themes.md',
    scope: 'The Progress screen centered on the whole-Quran retention HEAT-MAP: a 30-juz (or 604-page) grid where calm green recedes to a muted neutral as pages decay — NEVER alarming red — with a legend, redundant encoding (a tiny number/label per cell, not color alone), and a "ضعیف‌ترین اجزاء" weakest-juz list. A calm upcoming-load forecast. NO streaks. Active tab: پیشرفت.' },
  { file: 'settings.html', label: 'Settings', docs: 'docs/design-system/07-components.md, docs/design-system/12-localization-and-rtl.md, docs/PRD.md §15',
    scope: 'A grouped Settings list: زبان (fa/ckb/ar), تقویم (هجری قمری/شمسی/میلادی), سیستم اعداد, مجموعه اصطلاحات (term-set), پوسته (روشن/سپیا/تیره), مصحف/روایت, چرخهٔ مرور (cycle preset), بودجهٔ روزانه, یادآور (opt-in, off by default, calm), پروفایل‌ها (multi-profile / حالت استاد), پشتیبان‌گیری (export/import, no cloud + the honest tradeoff line), and "علمی که دنبال می‌کنیم" (link to science.html). Each row a stock single-choice control. Active tab: تنظیمات.' },
  { file: 'science.html', label: 'The science we follow', docs: 'docs/science/11-the-in-app-science-screen.md, docs/science/CLAIMS.md, docs/design-system/10-privacy-and-trust-ux.md',
    scope: 'The "علمی که دنبال می‌کنیم" screen: plain-language claims (why revision is spaced, why whole-page recall, why no streaks, why the engine never says a page is "safe to drop", how the schedule works = your own grades, no AI) each as a row with a neutral certainty label (قوی/متوسط/محدود/نظر کارشناسی) and a tappable source. A short, reverent intro. No diagnosis, no fiqh rulings, sect-neutral. Reachable from settings.html.' },
]

const tokensPrompt = `Read ${BASE}/docs/design-system/README.md, ${BASE}/docs/design-system/03-color-and-themes.md, ${BASE}/docs/design-system/04-typography.md, ${BASE}/docs/design-system/05-layout-spacing-touch.md, and ${BASE}/docs/design-system/06-motion-and-haptics.md (use the Read tool). They define the "Mihrab" design system tokens (color.*, type.*, space.*, motion.*).

Write TWO shared stylesheets for a static HTML demo of the Hifz app (RTL, Persian-primary):

1) ${DEMO}/styles/tokens.css — :root CSS custom properties for the design tokens you find in the docs: the calm Islamic color palette (light theme; also provide [data-theme="dark"] and [data-theme="sepia"] overrides), type scale (sizes/weights/line-heights), spacing scale, radii, and the retention heat-map color ramp (calm green → muted neutral, NEVER alarming red). Use the actual values/intent from the docs; where a doc gives a name but not a hex, choose a tasteful low-arousal value consistent with the doc's stated palette and note it with a CSS comment. Import a Persian/Arabic UI font (Vazirmatn) and an Arabic Quran demo font (Amiri Quran) via Google Fonts @import or <link> guidance in a comment.

2) ${DEMO}/styles/app.css — the shared component styles built ON the tokens (reference var(--...) only, never raw values): the phone-frame device mockup (~390px, centered, subtle shadow), the bottom tab bar, cards, list rows, chips (track chips), buttons (calm, primary/secondary), the page-card, the heat-map grid cell, badges/certainty labels, headers, the language pill, and RTL-correct utilities (logical margins/padding, flex direction). Set html[dir=rtl] correctness. Calm, reverent, generous spacing, no gaudy shadows.

Both files must make the per-screen HTML pages look consistent and on-brand. Use the Write tool for each. Return JSON {written:true}.`

phase('Foundation')
await agent(tokensPrompt, { label: 'css-foundation', phase: 'Foundation', agentType: 'general-purpose', schema: { type: 'object', properties: { written: { type: 'boolean' } }, required: ['written'] } })

async function chunked(items, fn, size) {
  const out = []
  for (let i = 0; i < items.length; i += size) {
    const res = await parallel(items.slice(i, i + size).map((it, j) => () => fn(it, i + j)))
    out.push(...res)
  }
  return out
}

const screenPrompt = (s) => `Build ONE screen of the Hifz app HTML demo: ${DEMO}/${s.file} — ${s.label}.

${COMMON}

THIS SCREEN: ${s.scope}
Governing docs for this screen: ${s.docs}

Make it a polished, realistic, on-brand mock using the shared classes from app.css/tokens.css. Fill it with believable Persian content and Persian numerals. Use the Write tool to create ${DEMO}/${s.file}. Return JSON {file:'${s.file}'}.`

phase('Screens')
const screens = await chunked(SCREENS, (s) =>
  agent(screenPrompt(s), { label: `screen:${s.file}`, phase: 'Screens', agentType: 'general-purpose', schema: { type: 'object', properties: { file: { type: 'string' } } } }), CHUNK)
const screensOk = screens.filter(Boolean)
log(`screens written: ${screensOk.length}/${SCREENS.length}`)

phase('Hub')
const list = SCREENS.map(s => `${s.file} — ${s.label}: ${s.scope.slice(0, 160)}`).join('\n')
const indexPrompt = `Build ${DEMO}/index.html — the landing hub for the Hifz app HTML demo. ${COMMON.split('Read FIRST')[0]}

This index is NOT inside the phone frame; it is a clean landing page that: (1) titles the demo ("Hifz Companion — نمونهٔ نمایشی" / a clear note this is a static visual prototype of a free, offline, no-AI Flutter Quran-retention app); (2) briefly states the concept (the retention engine wrapped in sabaq/sabqi/manzil; nothing decays silently); (3) shows a responsive GALLERY of cards, one per screen, each linking to its page, ideally with a small framed thumbnail/preview look. Screens to link:
index→onboarding.html, today.html, recite.html, mushaf.html, mutashabihat.html, progress.html, settings.html, science.html.
Screens:\n${list}\n
Add a short "این یک نمونهٔ نمایشی است" disclaimer (demo placeholder Quran rendering; final app uses KFGQPC glyph fonts; RTL Persian-primary). Link styles/tokens.css and styles/app.css. Use the Write tool. Return JSON {written:true}.`
await agent(indexPrompt, { label: 'demo-index', phase: 'Hub', agentType: 'general-purpose', schema: { type: 'object', properties: { written: { type: 'boolean' } } } })

return { screensWritten: screensOk.length, totalScreens: SCREENS.length, files: screensOk.map(r => r.file) }
