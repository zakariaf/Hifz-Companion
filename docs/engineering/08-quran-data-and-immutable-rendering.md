# 08 — Quran Data & Immutable Rendering

This document specifies how Hifz Companion stores the Quran and how it puts the muṣḥaf on screen: the three independently-licensed reference layers (Uthmani text, page-layout geometry, per-page glyph fonts) and why they are kept separate; the rendering rule that the OS shaper is **never** asked to lay out Quran text; the geometry-from-data layout that forbids runtime line-breaking; the overlay painter that draws every marker as coordinates over the immutable glyph layer; and the CI integrity pipeline — checksum gates plus the visual-diff against reference muṣḥaf images — that makes "one wrong diacritic ends the project" a build invariant rather than a hope. It applies the *Decision log: Immutable muṣḥaf rendering* entry (README decision 6), supports decision 5 (*Quran asset distribution & offline integrity*), and is grounded in the evidence dossier [research/arabic-script-rendering-fonts.md](research/arabic-script-rendering-fonts.md).

The boundaries are deliberate. This doc owns the `/quran` module ([PRD §19.2](../PRD.md)) — rendering, layout geometry, and the overlay painter — plus the *governance* of the Quran reference data (what the bytes are, how they are checksummed, why they are immutable). It does **not** own how the reference tables sit in SQLite or how reference data is loaded read-only; that is [05-persistence-and-encryption.md](05-persistence-and-encryption.md). It does **not** own how asset packs are hosted, downloaded, and verified at runtime over the wire; that is [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md), with which this doc shares the checksum manifest. The localized **UI chrome** — buttons, labels, the heat-map legend in fa/ckb/ar — is *ordinary* complex text that *does* go through Flutter's shaper and is owned by [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md) and the design-system typography note. This doc owns the sacred path only.

One framing rule governs everything below, restating the README's first outranking rule and [PRD R1](../PRD.md): **the sacred text is never put at risk for any feature, performance win, or convenience.** There are two distinct rendering problems in this app, and conflating them is the classic mistake ([research/arabic-script-rendering-fonts.md](research/arabic-script-rendering-fonts.md) framing note). The muṣḥaf is sacred, fixed, and must be byte-perfect and pixel-faithful, so we solve it by *refusing to shape it at all*; the UI chrome is ordinary text we *do* trust the shaper with. The engineering obligations are opposite, and we keep the two pipelines architecturally apart.

## At a glance

| Concern | Decision |
|---|---|
| Text source | **Tanzil** Uthmani text, byte-for-byte, CC BY 3.0, attributed; SHA-256 verified ([Tanzil: Download](https://tanzil.net/download/)) |
| Layout source | **QUL** (Tarteel) MushafPage/MushafWord page-line-word geometry, JSON/SQLite ([QUL: Mushaf Layout](https://qul.tarteel.ai/resources/mushaf-layout/19)) |
| Glyph fonts | **KFGQPC** QPC V2 per-page glyph fonts (604), one font per page, redistributed unmodified ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)) |
| Rendering | Draw pre-shaped glyph codes in the page's dedicated font; the OS shaper never lays out Quran text ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)) |
| Glyph string ↔ font | One atomic, checksum-pinned pair; glyph codes are opaque, never parsed as Arabic text ([Quran Foundation: Font Rendering](https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/)) |
| Layout rule | Group by `page-{p}-line-{l}`, never by verse; line breaks from data, never computed ([Quran Foundation: Page Layout](https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/)) |
| Overlays | Weak-line / mutashābihāt / current-ayah markers drawn as coordinates over the glyph layer ([PRD §11.2](../PRD.md)) |
| Themes / zoom | Transform the rendered layer (scale, color filter), never the text ([PRD §11.2](../PRD.md)) |
| Text fidelity gate | SHA-256 of text + 604 fonts in CI; mismatch fails the build ([PRD §11.3, R1](../PRD.md)) |
| Visual-diff gate | All 604 pages render-matched to reference images on min-OS iOS/Android with real fonts ([PRD §20.2](../PRD.md)) |

---

## 1. The three reference layers: text, layout, fonts — separate and co-versioned

### Decision

The muṣḥaf is modelled as **three independent, separately-licensed, co-versioned assets**, never a single blob: (a) the **Uthmani text** (Tanzil, CC BY 3.0), stored byte-for-byte and checksummed, used for search/audit/structure but **never for layout or rendering**; (b) the **page-layout geometry** (QUL MushafPage/MushafWord), the fixed page→line→word position data; (c) the **per-page glyph fonts** (KFGQPC QPC V2), one font file per muṣḥaf page, redistributed unmodified. A muṣḥaf edition is the triple `{text-checksum, layout-dataset, font-set}` selected by `mushaf_id` ([PRD §10.1](../PRD.md) `mushaf` table). This is *Decision log: Immutable muṣḥaf rendering*, and it is what makes the muṣḥaf swappable by construction ([PRD R2](../PRD.md)).

### Rationale

- **The three layers carry three different licences and must be tracked separately.** The Uthmani text is Tanzil under CC BY 3.0 ("permission is granted to copy and distribute verbatim copies … changing the text is not allowed"), attributed with a link to tanzil.net ([Tanzil: Download](https://tanzil.net/download/)); the page-layout is QUL/open, structured page/line/word position data exportable as JSON or SQLite ([QUL: Mushaf Layout](https://qul.tarteel.ai/resources/mushaf-layout/19)); the glyph fonts are KFGQPC's own terms, which permit free use/copy/distribution but **forbid modification, sub-setting, or renaming** without written approval ([Open Hub: KFGQPC License](https://openhub.net/licenses/KFGQPC)). Three separate attribution entries, three separate checksums.
- **Text and layout are genuinely independent data, co-designed per edition.** A muṣḥaf line mixes words from multiple verses, and editions physically differ — IndoPak 15-line is 610 pages, 16-line is 548 — so the layout cannot be derived from the text and "page boundaries must be taken from data, never recomputed" ([Quran Foundation: Page Layout](https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/)). The glyph font is *also* co-designed with the layout: line typography is tuned per edition so each word "fits perfectly on its designated line" ([QuranPortal: Rendering the Quran Muṣḥaf Digitally](https://quranportal.io/blog/rendering-the-quran-mushaf-digitally)). Mixing a layout from one edition with a font from another corrupts the page.
- **The text is the audit source of truth, not a rendering input.** Because the glyph codes are opaque (§3), the only human-readable, checksummable, byte-comparable representation of the Quran in the app is the stored Tanzil text. It backs CI's R1 text-fidelity gate ([PRD §11.3](../PRD.md)) and any non-rendered use (structure, ayah references), and it is *never* the thing drawn on screen.
- **Swappability is a religious requirement, not a feature.** [PRD R2](../PRD.md) requires the scheduler to be text-agnostic and the muṣḥaf to be a swappable asset; modelling it as a triple selected by `mushaf_id` lets a future riwāyah/layout plug in as a new triple with no engine rewrite.

### Specification

Default edition for v1 is **KFGQPC Madani 15-line, Ḥafṣ ʿan ʿĀṣim, QPC V2** ([PRD R2, §21](../PRD.md); the architecture treats it as swappable, so a locally-familiar Ḥafṣ edition can replace it without code changes). The reference layers map onto the [PRD §10.1](../PRD.md) reference tables ([05-persistence-and-encryption.md](05-persistence-and-encryption.md) owns the DDL); the `mushaf` row binds the triple and pins every checksum:

```dart
/// A muṣḥaf edition is the immutable triple {text, layout, fonts}, co-versioned
/// and selected by mushaf_id. All three checksums are pinned in the binary and
/// re-verified at runtime before any Quran asset is trusted (§6; doc 09).
class MushafEdition {
  final String mushafId;            // e.g. 'kfgqpc_hafs_madani_v2'
  final String riwayah;             // 'Ḥafṣ ʿan ʿĀṣim'
  final String displayName;         // shown in-app, never "the Quran" absolutely (R2)
  final int pageCount;              // 604 for Madani 15-line
  final int lineCount;              // 15 (a parameter, not a hardcode — PRD §7.1)
  final String textSha256;          // Tanzil Uthmani text asset
  final String layoutSha256;        // QUL page/line/word geometry asset
  final Map<int, String> fontSha256; // page 1..604 -> that page's font file hash
}
```

| Layer | Source | Asset | License / attribution | Checksum |
|---|---|---|---|---|
| Text | Tanzil Project | Uthmani UTF-8 text ([Tanzil: Download](https://tanzil.net/download/)) | CC BY 3.0 — verbatim, attributed, link to tanzil.net | `textSha256` |
| Layout | QUL (Tarteel) | MushafPage/MushafWord JSON/SQLite ([QUL: Mushaf Layout](https://qul.tarteel.ai/resources/mushaf-layout/19)) | open / attributed | `layoutSha256` |
| Fonts | KFGQPC | 604 per-page QPC V2 glyph fonts ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)) | KFGQPC terms — unmodified redistribution only | `fontSha256[1..604]` |

### Pitfalls / what we refuse

- **We refuse to derive layout from text.** Page and line boundaries are never computed from the text at runtime or build time; they come only from the QUL dataset (§4). A muṣḥaf line is not a verse boundary.
- **We refuse to mix layers across editions.** A QPC V2 font is only ever paired with the V2 layout and the matching text; the triple is verified together (§6). Cross-edition mixing silently corrupts the page.
- **We refuse to modify the KFGQPC fonts.** No sub-setting, re-hinting, renaming, or re-compression — the licence forbids it ([Open Hub: KFGQPC License](https://openhub.net/licenses/KFGQPC)) and modification would also break fidelity. Fonts are redistributed and checksummed exactly as published.

---

## 2. Why glyph fonts and not the OS shaper — the existential decision

### Decision

Each muṣḥaf page is rendered by selecting that page's **dedicated KFGQPC glyph font** and drawing its pre-shaped glyph codes; **the OS text shaper (HarfBuzz/Skia/Impeller) is never asked to lay out Quran text.** The glyph-code string and its page font are one atomic, checksum-pinned unit, and are never parsed as, substituted by, or fallen back to real Arabic text on the sacred path. This is the single most important decision in the engineering set (README pillar 1, *Decision log: Immutable muṣḥaf rendering*).

### Rationale

- **Flutter's Arabic shaping is font-, platform-, and backend-dependent — exactly the failure mode the muṣḥaf cannot tolerate.** Flutter ships no Arabic shaper of its own; HarfBuzz performs glyph selection, positioning, and mark attachment, and the rasteriser differs between Android (FreeType) and iOS (CoreGraphics) and between Skia and Impeller ([Esfahbod, *State of Text Rendering 2024*](https://behdad.org/text2024/)). Mark attachment — the stacking of vocalisation marks the Quran is saturated with — is precisely the step most likely to vary.
- **This is not theoretical: the Flutter tracker has shipped exactly these bugs.** Quran diacritics rendered "to the wrong side of the letter" with the KFGQPC HAFS font in Flutter while correct in native iOS ([flutter#16886](https://github.com/flutter/flutter/issues/16886)); the combination `الإ` "shatters into disconnected parts" under Lateef/Scheherazade New but renders correctly under Amiri — same text, same Flutter, different font, still **open**, triaged P2 to the Engine team ([flutter#143975](https://github.com/flutter/flutter/issues/143975)); and the Impeller-on-iOS renderer itself corrupted Arabic text at **P0** ([flutter#119805](https://github.com/flutter/flutter/issues/119805)). A misplaced ḥaraka changes what is read; for a muṣḥaf this is catastrophic.
- **The serious Quran-tech ecosystem already converged on the fix.** The KFGQPC QPC fonts are *glyph-based*: each glyph is "a visual representation of an entire word," with shaping, ligature-joining, and mark-stacking done **once** by the calligrapher (Uthman Taha) and the King Fahd Complex and frozen into the glyph outlines, so at runtime the engine "is not asked to shape anything — it just draws glyph N from font P" ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)). Because glyphs are pre-baked per the printed page, the system needs one font per page — "most Muṣḥaf has 604 pages" ([QUL: Glyph-Based Fonts](https://qul.tarteel.ai/docs/glyph-based)). The font *is* the frozen typeset page.
- **It makes the visual-diff gate deterministic enough to gate on (§6).** A guarantee that every glyph on every page is identical on every device cannot be founded on a shaping step whose output we do not control; removing the shaper from the sacred path is the only thing that makes [PRD §20.2](../PRD.md)'s pixel-tolerance gate meaningful.

### Specification

The glyph codes ship as **opaque codepoint strings** the per-page font interprets visually; the Quran Foundation tutorial is explicit that "QCF glyph codes contain special Unicode characters … Using `textContent` will display incorrect characters," and that pairing the *wrong* font with a glyph string (or feeding standard Unicode into a QCF font) yields "garbled output or placeholder squares" ([Quran Foundation: Font Rendering](https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/)). Flutter's analogue of `innerHTML`-vs-`textContent` is simply applying the matching `fontFamily` to the raw glyph string and never sanitizing, normalizing, or re-encoding it.

```dart
/// A single muṣḥaf line as stored in the layout dataset: the opaque glyph-code
/// string PLUS the identity of the font that interprets it. These travel together
/// and are verified together; one without the other is meaningless or corrupting.
class GlyphLine {
  final int pageNumber;     // 1..604 — also names the font family
  final int lineNumber;     // 1..15
  final LineType type;      // ayah | surahName | basmala | centered (§4)
  final String glyphCodes;  // opaque QPC V2 codepoints — NEVER parsed as Arabic text
}

/// Resolve the page's dedicated font. Mirrors the qcf_quran precedent, which
/// resolves fontFamily automatically from the page number and bundles 604 fonts
/// fully offline (pub.dev/packages/qcf_quran). Our fonts arrive in the verified
/// core pack (doc 09), not the binary, but the mechanic is identical.
String qpcFontFamily(int pageNumber) => 'QPC_P${pageNumber.toString().padLeft(3, '0')}';

/// Drawing one line: the font selection IS the shaping. Flutter draws the
/// pre-baked glyphs by codepoint; it does no Arabic shaping because the string
/// is already glyphs, not characters.
Widget buildGlyphLine(GlyphLine line) => Text(
      line.glyphCodes,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: qpcFontFamily(line.pageNumber),
        // No fontFamilyFallback — a fallback font would silently re-shape the
        // sacred path. Missing glyph => visible tofu => caught by the visual-diff
        // gate (§6), which is what we want: fail loudly, never substitute quietly.
        fontFamilyFallback: const [],
      ),
    );
```

The per-page fonts are registered for the `fontFamily` lookup. Because they arrive in the downloaded, checksum-verified core pack rather than the app bundle ([PRD §11.1.1](../PRD.md)), they are loaded at runtime with `FontLoader` (which builds a family from font bytes and registers it with the engine via `loadFontFromList`) rather than declared statically in `pubspec.yaml` ([Flutter API: FontLoader](https://api.flutter.dev/flutter/services/FontLoader-class.html)). Flutter "does not simulate" missing weights/styles, so each page is a real file and the family resolves to exactly one glyph table ([Flutter: Use a custom font](https://docs.flutter.dev/cookbook/design/fonts)).

```dart
/// Register every verified per-page font with the engine after the core pack is
/// downloaded and its hashes pass (doc 09). Refuses to register an unverified font.
Future<void> registerVerifiedPageFonts(MushafEdition ed, AssetVault vault) async {
  for (var page = 1; page <= ed.pageCount; page++) {
    final bytes = await vault.readVerified(             // throws if hash != fontSha256[page]
      kind: AssetKind.pageFont,
      page: page,
      expectedSha256: ed.fontSha256[page]!,
    );
    final loader = FontLoader(qpcFontFamily(page))
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }
}
```

### Pitfalls / what we refuse

- **We refuse a `fontFamilyFallback` on the sacred path.** A fallback hands the OS shaper the sacred string the moment a glyph is missing — the precise corruption we are eliminating. Missing glyphs must surface as visible tofu and be caught by the visual-diff gate, not papered over.
- **We refuse to treat glyph codes as text.** No normalization, no `String` munging, no using them for search or comparison, no logging them as "the verse." They are addresses into a glyph table; the checksummed Tanzil text (§1) is the only text representation.
- **We refuse the Unicode-font shortcut for the muṣḥaf.** Ordinary Unicode Quran fonts (QPC Hafs, IndoPak, Scheherazade) exist and are simpler ([Quran Foundation: Font Rendering](https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/); [Tanzil: Quranic Fonts](https://tanzil.net/docs/quranic_fonts)) — but they hand shaping back to the OS, which is the whole risk. They are acceptable *only* for the UI chrome ([12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md)), never for the muṣḥaf.
- **We refuse to let the muṣḥaf leak into a generic "Arabic text" style.** The `/quran` module and its glyph fonts are kept architecturally separate from the app's shaped chrome; a shared `TextStyle` that pulled the muṣḥaf into the shaped path would defeat the entire decision.

---

## 3. Layout is data, never runtime line-breaking

### Decision

Page boundaries, line boundaries, line types, and word positions come **only** from the bundled QUL layout dataset. Words are grouped by `page-{pageNumber}-line-{lineNumber}`, **never** by verse boundaries, and line breaks are **never** computed at runtime. This is [PRD §11.2/§6.1](../PRD.md) and the supporting half of *Decision log: Immutable muṣḥaf rendering*.

### Rationale

- **A muṣḥaf line mixes words from multiple verses.** The Quran Foundation guide is explicit: group words by `page-{page_number}-line-{line_number}`, "not by verse boundaries," because "a single Muṣḥaf line often contains words from multiple verses," and naive verse-based wrapping "would incorrectly fragment verses across lines, destroying the authentic physical layout" ([Quran Foundation: Page Layout](https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/)).
- **Editions differ physically, so layout cannot be inferred.** IndoPak 15-line is 610 pages, 16-line is 548; "page boundaries must be taken from data, never recomputed" ([Quran Foundation: Page Layout](https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/)). The QUL dataset preserves printed-page layout via MushafPage/MushafWord models exported as JSON/SQLite ([QUL: Mushaf Layout](https://qul.tarteel.ai/resources/mushaf-layout/19)).
- **The structure is fixed reference data the app never recomputes.** [PRD §6.1](../PRD.md): the 30 juz → 604 pages → 15 lines/page → ayah hierarchy is "fixed glyph/layout data … the app never recomputes it." This is why the `page`/`line`/`ayah` tables are read-only ([05-persistence-and-encryption.md](05-persistence-and-encryption.md)).

### Specification

Each word in the QUL dataset carries `page_number`, `line_number`, and `position`; lines also carry a type (a verse line, a centred sūra-name banner, or a basmala line) ([Quran Foundation: Page Layout](https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/)). The renderer consumes this geometry verbatim:

```dart
enum LineType { ayah, surahName, basmala, centered }

/// Build one page from the bundled layout. Pure data assembly: every break is a
/// row in the dataset. The renderer NEVER decides where a line ends.
List<GlyphLine> assemblePage(int pageNumber, MushafLayout layout) {
  final words = layout.wordsOnPage(pageNumber); // already carry line_number, position
  final byLine = <int, List<LayoutWord>>{};
  for (final w in words) {
    (byLine[w.lineNumber] ??= []).add(w);       // group by page-line, NEVER by verse
  }
  return [
    for (final lineNo in byLine.keys.toList()..sort())
      GlyphLine(
        pageNumber: pageNumber,
        lineNumber: lineNo,
        type: layout.lineType(pageNumber, lineNo),
        glyphCodes: byLine[lineNo]!
            .map((w) => w.glyphCode)              // each word's opaque glyph(s)
            .join(),                              // concatenation, not shaping
      ),
  ];
}
```

Justified muṣḥaf lines fill the page width; because each word is a discrete glyph, the renderer must not inject spurious inter-word gaps (the web analogue collapses container whitespace with `font-size: 0` then restores per-glyph size ([QuranPortal: Rendering the Quran Muṣḥaf Digitally](https://quranportal.io/blog/rendering-the-quran-mushaf-digitally))). In Flutter the equivalent is to lay each line as a single run in its page font with justification driven by the line's known word geometry, never by the shaper's word-splitting.

### Pitfalls / what we refuse

- **We refuse runtime line-breaking.** No `softWrap`, no width-driven wrapping, no `TextPainter` line computation on Quran text. Every break is a dataset row.
- **We refuse verse-based grouping.** Grouping by ayah fragments verses across lines and destroys the physical layout; grouping is strictly by `page-line`.
- **We refuse to recompute the hierarchy.** Juz/ḥizb/rubʿ/page/line/ayah counts are read from data; the app never calculates them, even when they look trivially derivable.

---

## 4. Overlays: coordinates over the glyph layer, never re-typeset

### Decision

Every marker — weak-line highlight, mutashābihāt anchor, error position, current-ayah indicator — is drawn as a **rectangle/coordinate overlay on top of the immutable glyph layer**, computed from the same bundled line/word geometry, **never** by editing, re-typesetting, reconstructing, or re-storing the text ([PRD R1, §9.2, §11.2](../PRD.md)).

### Rationale

- **PRD R1 mandates it.** "Any markers … are drawn as an overlay of coordinates on the immutable glyph page — never by re-typesetting or storing reconstructed text" ([PRD R1](../PRD.md)). Re-typesetting would re-introduce the shaper (§2) and a second, divergent representation of the page.
- **The geometry already exists.** Overlays consume the same `page_number`/`line_number`/`position` word geometry as the layout (§3), so a highlight aligns to the printed page without ever touching the glyphs ([research/arabic-script-rendering-fonts.md](research/arabic-script-rendering-fonts.md) §5, implication 4). The anchor-hinting micro-drill ([PRD §9.2](../PRD.md)) is a highlight over the distinguishing word's rectangle, not a re-render of the phrase.
- **It keeps the glyph layer literally immutable.** The painter draws *beneath or above* the unmodified glyph text; the sacred layer is never recomposed, satisfying the README's first outranking rule.

### Specification

The glyph page renders into one layer; the overlay painter renders into a sibling layer addressed by the same geometry. A marker is a span of words (or whole lines) resolved to device rectangles:

```dart
/// An overlay marker is a semantic span, resolved to rectangles at paint time
/// from the SAME bundled geometry the glyphs use. It carries no text.
class OverlayMarker {
  final OverlayKind kind;   // weakLine | mutashabihAnchor | errorPosition | currentAyah
  final int pageNumber;
  final List<WordRef> words; // (lineNumber, position) refs into the layout
}

class MushafOverlayPainter extends CustomPainter {
  final List<OverlayMarker> markers;
  final PageGeometry geometry; // line/word boxes for this page+font+scale (from data)

  @override
  void paint(Canvas canvas, Size size) {
    for (final m in markers) {
      final paint = _paintFor(m.kind); // calm, theme-aware; design-system owns color tokens
      for (final w in m.words) {
        final Rect box = geometry.wordRect(w.lineNumber, w.position);
        canvas.drawRRect(RRect.fromRectXY(box, 3, 3), paint); // a box, never glyphs
      }
    }
  }

  @override
  bool shouldRepaint(MushafOverlayPainter old) =>
      old.markers != markers || old.geometry != geometry;
}
```

The painter draws only geometric primitives. Colours and corner radii are design-system tokens (the calm, non-gamified palette is owned by the design-system docs); this doc fixes only that markers are *coordinates*, not text.

### Pitfalls / what we refuse

- **We refuse to store reconstructed text.** No marker, drill, or highlight persists a rebuilt copy of any verse; markers persist only `(page, line, position)` refs.
- **We refuse to re-typeset a highlighted phrase.** The mutashābihāt anchor drill highlights the distinguishing word *in place* over the glyph layer; it never re-renders the phrase in another font or widget.
- **We refuse overlays that depend on shaped text metrics.** Overlay rectangles come from the bundled word geometry, not from measuring shaped Arabic — there is no shaped Arabic on this path to measure.

---

## 5. Themes, zoom, and night/sepia — transform the layer, not the text

### Decision

Zoom and light/sepia/dark themes are applied by **transforming the rendered glyph layer** (uniform scale, color filter), never by altering the text, the font, the layout, or the glyph codes ([PRD §11.2, §18](../PRD.md)).

### Rationale

- **PRD §11.2 requires it.** "The reader supports zoom and night/sepia themes by transforming the rendered layer, not the text" ([PRD §11.2](../PRD.md)). Any per-theme font swap or re-layout would re-introduce the shaper and break the per-page font ↔ glyph-string pairing (§2).
- **Accessibility needs zoom without re-flow.** Low-vision reciters need a larger muṣḥaf ([PRD §18](../PRD.md)); a uniform scale of the immutable layer enlarges the page faithfully while keeping every line break exactly as printed — which a text-scale-driven re-flow would destroy.
- **Sepia/dark is a colour transform.** A `ColorFilter` over the glyph layer recolours the whole page deterministically, leaving the glyph outlines untouched, so the visual-diff reference set need only be captured once per theme transform, not per font variant.

### Specification

```dart
/// The reader frame: an immutable glyph page + its overlays, wrapped in a uniform
/// scale and a theme color filter. The sacred layer is identical bytes regardless
/// of zoom or theme; only the presentation transform changes.
Widget mushafPageView(int pageNumber, ReaderTheme theme, double zoom) {
  final page = ImmutableGlyphPage(pageNumber: pageNumber);      // §2/§3, never mutated
  final overlays = OverlayLayer(pageNumber: pageNumber);        // §4
  return ColorFiltered(
    colorFilter: theme.glyphColorFilter,                        // sepia/dark = filter, not font
    child: Transform.scale(
      scale: zoom,                                              // uniform; no re-flow
      alignment: Alignment.topRight,                            // RTL origin
      child: Stack(children: [page, overlays]),
    ),
  );
}
```

### Pitfalls / what we refuse

- **We refuse per-theme font swaps.** There is exactly one font per page; dark mode is a colour filter, not a "dark font."
- **We refuse OS text-scale re-flow on the muṣḥaf.** The app honours OS text-scale for *chrome* ([PRD §18](../PRD.md)), but the muṣḥaf zooms as a uniform layer transform so printed line breaks never move. (Chrome text-scaling is owned by [12-localization-rtl-accessibility-impl.md](12-localization-rtl-accessibility-impl.md).)

---

## 6. The integrity pipeline: checksum gates + visual-diff

### Decision

Quran-asset integrity is enforced at **three points**, all fail-closed: (1) **CI** verifies the binary's pinned SHA-256 of the text and all 604 page fonts (plus layout) against the published release, and verifies the release text matches the authoritative Tanzil hash — mismatch fails the build; (2) **runtime** re-verifies every downloaded pack's SHA-256 before first use and refuses to render Quran text from any unverified asset; (3) a **visual-diff** renders all 604 pages on min-OS iOS/Android with the real fonts against reference muṣḥaf images within a tight pixel tolerance — diffs fail the build ([PRD §11.3, §20.1–20.2, R1](../PRD.md)). This is *Decision log: Immutable muṣḥaf rendering* meeting *Decision log: Quran asset distribution & offline integrity* ([09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md) owns the wire/runtime half).

### Rationale

- **Text fidelity is existential and must be a build invariant.** [PRD R1](../PRD.md): the Uthmani text is stored byte-for-byte from a single authoritative source and "a SHA-256 checksum of the text asset is verified in CI; any byte change fails the build." A wrong diacritic ends the project, so it is gated, not reviewed-by-eye-and-hoped.
- **Glyph fonts make the visual-diff trustworthy.** Because we removed the shaper from the sacred path (§2), the same glyph codes in the same font produce the same pixels — which is exactly what lets a pixel-tolerance gate be meaningful. Goldens are documented to be OS-, font-, and Flutter-version-sensitive ([Flutter API: matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)), so they are pinned and run with the **real KFGQPC fonts loaded** via `FontLoader` (never the default Ahem placeholder, which draws squares) ([Flutter API: FontLoader](https://api.flutter.dev/flutter/services/FontLoader-class.html)).
- **The visual-diff must run on the minimum supported OS versions** of iOS and Android ([PRD §11.3.4, §20.2, R1](../PRD.md)), precisely because shaping/raster output historically varied by platform (§2) — even with glyph fonts, the gate proves the chosen approach holds on the floor of the support matrix.

### Specification

The CI gate over assets, and the golden harness, run as distinct jobs ([11-testing-strategy.md](11-testing-strategy.md) owns the CI shape):

```dart
// CI step 1 — text + font + layout checksums match the pinned manifest and the
// authoritative Tanzil hash. Pure Dart; no rendering.
void verifyAssetIntegrity(MushafEdition ed, ReleaseManifest release) {
  assertEqual(sha256(release.textBytes), ed.textSha256);       // R1: byte-for-byte
  assertEqual(ed.textSha256, kAuthoritativeTanzilUthmaniSha);  // matches Tanzil source
  assertEqual(sha256(release.layoutBytes), ed.layoutSha256);
  for (var p = 1; p <= ed.pageCount; p++) {
    assertPresentAndEqual(release.fontBytes(p), ed.fontSha256[p]); // all 604 fonts
  }
}
```

```dart
// CI step 2 — visual-diff: every page, real fonts, min-OS runner, tight tolerance.
// Golden references are the approved muṣḥaf images; any diff fails the build.
void main() {
  setUpAll(() async {
    await loadRealKfgqpcFontsForGoldens();   // FontLoader, NOT Ahem (which draws squares)
  });

  for (var page = 1; page <= 604; page++) {
    testGoldens('muṣḥaf page $page renders pixel-faithfully', (tester) async {
      await tester.pumpWidget(ImmutableGlyphPage(pageNumber: page));
      await expectLater(
        find.byType(ImmutableGlyphPage),
        matchesGoldenFile('goldens/mushaf/page_$page.png'),
      );
    });
  }
}
```

Test vectors / spot-checks the gate must include ([PRD §11.3.5](../PRD.md)):

| Check | What it asserts | Source of truth |
|---|---|---|
| Text hash | Stored Uthmani text = authoritative Tanzil bytes | [Tanzil: Download](https://tanzil.net/download/) |
| Font manifest | All 604 page fonts present and unmodified | pinned `fontSha256` ([PRD §11.3.2](../PRD.md)) |
| Page count | Exactly 604 pages for the Madani 15-line edition | QUL layout |
| Sajda marks | Each of the 15 sajdas rendered at its reference position | reference muṣḥaf images |
| Ayah numbering | Per-surah ayah counts and end markers match | reference muṣḥaf images |
| Basmala | Basmala present/absent correctly per surah (absent only for At-Tawba) | reference muṣḥaf images |
| Tolerance | Pixel diff within the gate's tight threshold on min-OS iOS+Android | golden references |

A **qualified ḥāfiẓ/scholar** also visually proofs a sample of pages, sajda marks, numbering, and basmala on real devices as a release gate ([PRD §20.8](../PRD.md)); the automated gate does not replace human muṣḥaf review, it makes regressions impossible to ship silently between reviews.

### Pitfalls / what we refuse

- **We refuse to render unverified Quran assets.** If a downloaded pack's hash does not match, the app rejects it, re-fetches once, and then **refuses to render Quran text** rather than show an unverified muṣḥaf ([PRD §11.1.1, §19.3](../PRD.md); enforced in [09-asset-packs-and-offline-integrity.md](09-asset-packs-and-offline-integrity.md)).
- **We refuse goldens rendered with the Ahem font.** Muṣḥaf goldens load the real KFGQPC fonts; a golden of squares proves nothing about diacritic placement.
- **We refuse a loose tolerance.** The pixel tolerance is tight because the failure mode (a shifted mark, a broken ligature) is small in pixels but catastrophic in meaning; "close enough" is not a standard the sacred text gets.
- **We refuse to treat the automated gate as sufficient.** The scholar's on-device review ([PRD §20.8](../PRD.md)) remains a release-blocking gate; CI guards against *regression*, not against an originally-wrong reference.

---

## References

- Tanzil Project. *Download Quran Text* (Uthmani UTF-8; verbatim copies only, attributed, link to tanzil.net). https://tanzil.net/download/
- Tanzil Project. *Text License* (Quran text under Creative Commons Attribution 3.0 — CC BY 3.0; copyright Tanzil Project; verbatim, attribution required). https://tanzil.net/docs/text_license
- Tanzil Project. *Quranic Fonts* (KFGQPC HAFS Uthmanic Script and Uthman Taha Naskh vs Unicode-shaping fonts Scheherazade / me_quran / PDMS Saleem). https://tanzil.net/docs/quranic_fonts
- The Quranic Universal Library (Tarteel). *Glyph-Based Fonts* (each glyph = a whole Quranic word; one font per page; 604 pages; QPC V1/V2/V4). https://qul.tarteel.ai/docs/glyph-based
- The Quranic Universal Library (Tarteel). *Mushaf Layout* (MushafPage/MushafWord page/line/word position data; JSON/SQLite export). https://qul.tarteel.ai/resources/mushaf-layout/19
- Quran Foundation. *Integrating Quran Font Rendering* (code_v2 vs text_qpc_hafs; glyph codes are special Unicode that must not be treated as plain text; per-page `p{page}.woff2`, versions v1/v2/v4). https://api-docs.quran.foundation/docs/tutorials/fonts/font-rendering/
- Quran Foundation. *Page Layout API Guide* (group words by page-line not verse; a line mixes verses; edition page-count differences; data-driven layout). https://api-docs.quran.foundation/docs/tutorials/fonts/page-layout/
- QuranPortal. *Rendering the Quran Muṣḥaf Digitally* (geometry-first per-page fonts; per-edition line typography; whitespace-collapse for justified word-glyphs). https://quranportal.io/blog/rendering-the-quran-mushaf-digitally
- Esfahbod, Behdad. *State of Text Rendering 2024* (HarfBuzz = glyph selection/positioning/mark attachment; platform-dependent rasterisers). https://behdad.org/text2024/
- flutter/flutter. *Issue #16886 — Arabic Quran diacritics problem* (KFGQPC HAFS diacritics misplaced in Flutter, correct in native iOS). https://github.com/flutter/flutter/issues/16886
- flutter/flutter. *Issue #143975 — Arabic text rendering with specific letter* (`الإ` shatters under Lateef/Scheherazade New; open; P2, Engine team). https://github.com/flutter/flutter/issues/143975
- flutter/flutter. *Issue #119805 — [Impeller] Incorrect Arabic Text Rendering* (P0 Impeller-on-iOS Arabic rendering/weight bug). https://github.com/flutter/flutter/issues/119805
- Flutter (Google). *Use a custom font* (`pubspec.yaml` `fonts:` declaration; `TextStyle(fontFamily:)`; no weight/style simulation). https://docs.flutter.dev/cookbook/design/fonts
- Flutter API. *FontLoader class* (build a family from font bytes; register at runtime via `loadFontFromList`). https://api.flutter.dev/flutter/services/FontLoader-class.html
- Flutter API. *matchesGoldenFile function* (golden comparison; OS/font/Flutter-version sensitivity; custom comparators / tolerance). https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html
- pub.dev. *qcf_quran* (Flutter package bundling 604 per-page QCF fonts fully offline; automatic per-page `fontFamily`; QCF_BSML symbol font). https://pub.dev/packages/qcf_quran
- Open Hub. *King Fahd Glorious Quran Printing Complex License* (free use/copy/distribute; no modification/sale/reproduction without written approval). https://openhub.net/licenses/KFGQPC
- Hifz Companion. *Engineering README & tech-decision log* (Decision 6: Immutable muṣḥaf rendering). [README.md](README.md)
- Hifz Companion. *Arabic-Script & Quran Text Rendering in Flutter — Research Note.* [research/arabic-script-rendering-fonts.md](research/arabic-script-rendering-fonts.md)
- Hifz Companion. *Product Requirements Document* (R1, R2, §6.1, §9.2, §10.1, §11, §18, §20). [PRD.md](../PRD.md)
