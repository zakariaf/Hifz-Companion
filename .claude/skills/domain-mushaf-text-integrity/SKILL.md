---
name: domain-mushaf-text-integrity
description: Render or touch Quran text in the Hifz app the only safe way — byte-exact Tanzil text + SHA-256, KFGQPC per-page glyph fonts (never the OS shaper), layout from the fixed QUL dataset (never recomputed), markers as coordinate overlays on the immutable glyph layer (never re-typeset), riwāyah named, muṣḥaf swappable. Use whenever building the muṣḥaf reader, registering or selecting glyph fonts, assembling a page, drawing a weak-line / ayah / mutashābihāt overlay, applying zoom/sepia/dark, or anything that could reflow, re-typeset, or alter the sacred text.
---

# domain-mushaf-text-integrity

> **Amendment (2026-06-18) — bundled core.** Tech-decision-log #5 was amended: the core muṣḥaf — Tanzil text, the unmodified KFGQPC QCF V2 per-page fonts, and the QUL layout — is now **BUNDLED in the signed app binary** and verified by a **build-time** SHA-256 manifest (no download). The fonts therefore live in the **app bundle**, not a downloaded pack; register them only after re-verifying their bundled bytes against the manifest hash. See **domain-asset-pack-integrity** for the integrity boundary.

The existential text-fidelity discipline for everything that puts the muṣḥaf on screen or stores its bytes. Quran text is held **byte-for-byte** (Tanzil Uthmani, CC BY 3.0) and SHA-256-gated; every page is drawn by selecting that page's **dedicated KFGQPC QPC glyph font** and painting its pre-shaped glyph codes — the OS shaper is **never** asked to lay out Quran text; line/page breaks come **only** from the bundled QUL layout dataset; every marker is a **rectangle over the immutable glyph layer**, never re-typeset text; and the muṣḥaf is a swappable triple `{text, layout, fonts}` whose riwāyah is always named. A single dropped or misplaced diacritic ends the project, so this is enforced as a build invariant, not a hope.

This is the one rule that outranks every feature, performance win, or convenience: **the sacred text is never put at risk.** `docs/PRD.md` R1; `docs/engineering/08-quran-data-and-immutable-rendering.md` framing rule; `docs/design-system/13-islamic-identity-and-adab.md` §1.

## When to use

Use when building, placing, or touching:
- the muṣḥaf **reader** — the page view, the paged (never infinite-scroll) navigator, zoom and night/sepia themes
- **glyph-font rendering** — registering the 604 per-page KFGQPC fonts via `FontLoader`, resolving `fontFamily` from a page number, drawing a `GlyphLine`
- **page assembly** — grouping words into lines from the QUL `MushafPage`/`MushafWord` geometry
- **overlays on the page** — weak-line highlight, current-ayah indicator, mutashābihāt anchor, error-position marker
- the **integrity pipeline** — pinned SHA-256 checksums, the runtime "refuse unverified assets" gate, the visual-diff goldens
- the **muṣḥaf-selection / About-credits** surface where the riwāyah is named and the swappable edition is chosen
- *any* code that risks reflowing, re-typesetting, normalizing, or otherwise altering Quran text

Do NOT use this skill for → use the named sibling instead:
- hosting, downloading, and wire-verifying the asset packs over HTTPS → use **domain-asset-pack-integrity** (this skill owns *what the bytes are and how they render*; that skill owns *how they arrive*)
- the read-only Drift/SQLite DDL for the `mushaf`/`page`/`line`/`ayah` reference tables → use **eng-reference-data-persistence**
- shaped UI chrome (buttons, the heat-map legend, sabaq labels) in fa/ckb/ar — ordinary complex text that *does* go through Flutter's shaper → use **ui-rtl-localization**
- the calm color/motion tokens an overlay paints with, or the heat-map itself → use **ui-retention-heatmap** / the design-system token skills
- the scheduling math behind which page is due → use **eng-scheduling-engine** (it is text-agnostic and never sees glyphs)

The muṣḥaf path and the shaped-chrome path are architecturally separate. If your code asks Flutter to *shape* anything that is Quran text, you are on the wrong path.

## The canonical pattern

1. **Model the muṣḥaf as an immutable, co-versioned triple — never a blob.** A `MushafEdition` binds `{textSha256, layoutSha256, fontSha256[1..604]}` selected by `mushafId`, with `riwayah` and `displayName` fields; `lineCount`/`pageCount` are parameters, not hardcodes. This is what makes the muṣḥaf swappable by construction. `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 (the three reference layers; `MushafEdition`); `docs/PRD.md` R2 (text-agnostic scheduler, swappable asset) and §10.1 (`mushaf` table).

2. **Store the text byte-for-byte; it is the audit source, never a render input.** The Tanzil Uthmani text is stored verbatim, SHA-256-pinned, used only for structure/search/audit — it is **never** drawn on screen and **never** used to derive layout. The only thing drawn is glyph codes. `docs/engineering/08-quran-data-and-immutable-rendering.md` §1 (text is the audit source of truth) and §3 (text is never a layout input); `docs/PRD.md` R1.

3. **Render every page by selecting its dedicated glyph font and drawing opaque glyph codes — the OS shaper is never on the sacred path.** Resolve the family with `qpcFontFamily(pageNumber)` (e.g. `QPC_P001`); draw the `GlyphLine.glyphCodes` string with `TextDirection.rtl` and **`fontFamilyFallback: const []`**. The font selection *is* the shaping. Glyph codes are opaque addresses into a glyph table — never normalized, munged, searched, or logged as "the verse." `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 (`GlyphLine`, `buildGlyphLine`, no fallback); `docs/PRD.md` §11.2; `docs/design-system/13-islamic-identity-and-adab.md` §1 (the font *is* the typeset page; not a styleable token).

4. **Register the 604 page fonts only after they pass their hash.** The fonts are **bundled in the app binary** (per the 2026-06-18 amendment) — so read each font's bytes from the **asset bundle** and verify them before use: load with `FontLoader(qpcFontFamily(page))..addFont(...)` over bytes read through `vault.readVerified(expectedSha256: ed.fontSha256[page])`, which reads the bundled asset and throws on mismatch. Refuse to register an unverified font. `docs/engineering/08-quran-data-and-immutable-rendering.md` §2 (`registerVerifiedPageFonts`, `FontLoader`); `docs/PRD.md` §11.1.1 (refuse to render unverified assets).

5. **Take layout from data; never compute a line break at runtime.** Group words strictly by `page-{pageNumber}-line-{lineNumber}` from the QUL dataset — **never** by verse boundary, because one muṣḥaf line mixes words from multiple ayāt. No `softWrap`, no width-driven wrapping, no `TextPainter` line computation on Quran text. Juz/ḥizb/page/line/ayah counts are read, never recomputed. `docs/engineering/08-quran-data-and-immutable-rendering.md` §3 (`assemblePage`, group by page-line); `docs/PRD.md` §11.2 / §6.1; `docs/design-system/13-islamic-identity-and-adab.md` §1 (page position is a retrieval cue).

6. **Draw every marker as a coordinate overlay on the immutable glyph layer — never re-typeset.** Weak-line, current-ayah, mutashābihāt-anchor, and error-position markers are `OverlayMarker`s carrying only `(pageNumber, [WordRef])` — no text. A `CustomPainter` resolves each `WordRef` to a `Rect` from the **same** bundled geometry the glyphs use and draws a calm rounded box; colors/radii come from design-system tokens (`color.semantic.warning` for a decaying line), markers are diagnostic, never decorative or congratulatory. Persist only `(page, line, position)` refs, never reconstructed text. `docs/engineering/08-quran-data-and-immutable-rendering.md` §4 (`OverlayMarker`, `MushafOverlayPainter`); `docs/PRD.md` R1 / §11.2; `docs/design-system/13-islamic-identity-and-adab.md` §1 + §3 (markers diagnostic, never ornament on the words).

7. **Themes and zoom transform the rendered layer, not the text.** Wrap the immutable glyph page + overlays in a uniform `Transform.scale` (RTL `Alignment.topRight` origin) and a `ColorFiltered` theme filter for sepia/dark. No per-theme font swap; no OS text-scale reflow on the muṣḥaf — printed line breaks must never move. `docs/engineering/08-quran-data-and-immutable-rendering.md` §5 (`mushafPageView`, scale + `ColorFilter`); `docs/PRD.md` §11.2 / §18.

8. **State the riwāyah; never present the bundled muṣḥaf as "the Quran" absolutely.** Show `displayName` as "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf" at onboarding, in settings, and in About/Credits, with Tanzil/QUL/KFGQPC attribution and the byte-for-byte checksum guarantee stated plainly. Ship zero tafsīr/translation/commentary; the muṣḥaf is identical across fa/ckb/ar (only chrome localizes). `docs/PRD.md` R2; `docs/design-system/13-islamic-identity-and-adab.md` §5 (state the riwāyah, attribute, sect-neutral).

9. **Gate integrity in CI and at runtime, fail-closed.** CI verifies the pinned text/layout/604-font SHA-256 of the **bundled** core assets at build time, and against the authoritative Tanzil hash, and runs a visual-diff of all 604 pages on min-OS iOS/Android — with the **real KFGQPC fonts loaded via `FontLoader`** (never Ahem, which draws squares) — within a tight pixel tolerance; any mismatch or diff fails the build. Runtime re-verifies the bundled bytes before first use and refuses to render unverified Quran text. The automated gate never replaces the qualified ḥāfiẓ/scholar's on-device proof. `docs/engineering/08-quran-data-and-immutable-rendering.md` §6 (`verifyAssetIntegrity`, goldens, test-vector table); `docs/PRD.md` §11.3 / R1.

10. **No gamification, decoration, or device-gating on the sacred surface.** No badge, counter, mascot, confetti, glow, or ornamental border over an āyah; no page-flip sound effect or haptic fanfare; no wuḍūʾ/piety gate to open the muṣḥaf. The reader is "no dashboard": the words dominate, chrome recedes to the edges. `docs/design-system/13-islamic-identity-and-adab.md` §3 (chrome defers to the words) + §2 (reverence is presentation, not device-gating) + §4 (never gamify worship); `docs/PRD.md` R3.

## Do / Don't

| Do | Don't |
|---|---|
| Model the muṣḥaf as `MushafEdition` = `{textSha256, layoutSha256, fontSha256[1..604]}` keyed by `mushafId` | Store the muṣḥaf as one blob, or hardcode 604/15 instead of `pageCount`/`lineCount` |
| Draw glyph codes in the page's dedicated `QPC_P###` font with `fontFamilyFallback: const []` | Set any `fontFamilyFallback` on Quran text — a missing glyph must surface as visible tofu, never re-shape |
| Keep `GlyphLine.glyphCodes` opaque; treat them as addresses into a glyph table | Normalize, re-encode, search, compare, or log glyph codes as "the verse" |
| Use the byte-exact Tanzil text only for structure/search/audit | Use the text for layout, or draw the text instead of glyphs |
| Group words by `page-{p}-line-{l}` straight from the QUL dataset | Group by verse, `softWrap`, width-wrap, or run `TextPainter` line computation on Quran text |
| Draw markers as `OverlayMarker` → `Rect` boxes via `CustomPainter`, colors from `color.semantic.*` tokens | Re-typeset, reconstruct, or store any verse to draw a highlight |
| Zoom via uniform `Transform.scale` (RTL `topRight`); sepia/dark via `ColorFiltered` | Swap fonts per theme, or let OS text-scale reflow the muṣḥaf and move line breaks |
| Register fonts via `FontLoader` only after `vault.readVerified` passes the hash | Bundle/load fonts without re-verifying, or modify/sub-set/rename the KFGQPC fonts |
| Show `displayName` "Ḥafṣ ʿan ʿĀṣim — Madani muṣḥaf" with Tanzil/QUL/KFGQPC attribution | Call the bundled muṣḥaf "the Quran" absolutely, or ship any tafsīr/translation |
| Load **real** KFGQPC fonts in the 604-page golden harness, tight tolerance, min-OS | Render goldens with Ahem, or accept a loose pixel tolerance "close enough" |
| Keep the muṣḥaf path architecturally apart from shaped chrome | Pull the muṣḥaf into a shared `TextStyle` / generic "Arabic text" style |

## Checklist

Before any muṣḥaf-touching change is done:

- [ ] The edition is a `MushafEdition` triple keyed by `mushafId`; `riwayah`/`displayName` set; `pageCount`/`lineCount` are parameters, not hardcodes.
- [ ] Quran text is stored byte-for-byte (Tanzil Uthmani), SHA-256-pinned, and is used only for structure/audit — never drawn, never a layout input.
- [ ] Pages render with `Text(line.glyphCodes, textDirection: TextDirection.rtl, style: TextStyle(fontFamily: qpcFontFamily(page), fontFamilyFallback: const []))`; the OS shaper is never asked to lay out Quran text.
- [ ] Glyph codes stay opaque — no normalize / re-encode / search / compare / log-as-verse.
- [ ] Page assembly groups words by `page-{p}-line-{l}` from the QUL dataset; **no** verse grouping, `softWrap`, width-wrap, or runtime line-breaking on Quran text.
- [ ] The 604 per-page fonts are loaded via `FontLoader` only after `vault.readVerified(expectedSha256: ed.fontSha256[page])` passes; unverified fonts are refused; fonts are unmodified (no sub-set/rehint/rename).
- [ ] Markers are `OverlayMarker`s of `(page, line, position)` refs painted as boxes via `CustomPainter` over the immutable layer; colors/radii are design-system tokens; nothing re-typesets or persists reconstructed text.
- [ ] Markers are diagnostic only — no badge, counter, confetti, glow, or ornament over an āyah; the reader is "no dashboard"; muṣḥaf is paged, not infinite-scrolled.
- [ ] Zoom is a uniform `Transform.scale` (RTL `topRight` origin); sepia/dark is a `ColorFilter`; no per-theme font swap; no OS text-scale reflow of the muṣḥaf.
- [ ] The muṣḥaf is identical across fa/ckb/ar (RTL); only chrome localizes; no tafsīr/translation/commentary ships; `displayName` names the riwāyah, never "the Quran" absolutely.
- [ ] Source attribution (Tanzil/QUL/KFGQPC) + the byte-for-byte/checksum guarantee surface in About/Credits.
- [ ] CI gates: pinned text/layout/604-font SHA-256 match the release and the authoritative Tanzil hash; runtime refuses unverified assets before first render.
- [ ] Visual-diff goldens load the real KFGQPC fonts (never Ahem), run on min-OS iOS+Android, tight tolerance, and spot-check sajda marks / ayah numbering / basmala presence; the scholar's on-device proof remains a release gate.
- [ ] No wuḍūʾ / piety / ritual gate blocks opening the muṣḥaf; any reverent framing is optional and dismissible.

This skill governs the words of Allah on screen; *iḥsān* is the standard because the work is *ṣadaqah jāriyah*. When in doubt, render less and shape nothing: a missing glyph that fails loudly is always better than a substituted one that fails silently.

## Files

- `template.dart` — copy-paste scaffold: the `MushafEdition` triple, verified `FontLoader` registration, the glyph-line renderer with no fallback, data-driven page assembly, the `MushafOverlayPainter`, the zoom/theme transform frame, and the Riverpod reader widget with TODO markers. Tokens and engine/rule names are referenced by name only.
- `references.md` — the precise governing doc sections, grouped Primary / supporting / sibling, each with the one thing to take from it.

Related skills: **domain-asset-pack-integrity** (how the verified packs are downloaded and wire-checked before this skill renders them), **eng-reference-data-persistence** (the read-only Drift tables the layout/text/edition rows live in), **eng-scheduling-engine** (the text-agnostic scheduler that decides which page is due, never seeing glyphs), **ui-retention-heatmap** (the calm progress surface and the color tokens an overlay paints with), **ui-rtl-localization** (the shaped fa/ckb/ar chrome that *does* go through Flutter's shaper — the opposite path from the muṣḥaf).
