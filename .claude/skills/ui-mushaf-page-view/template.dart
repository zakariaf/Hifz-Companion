// template.dart — ui-mushaf-page-view
//
// Copy-paste scaffold for the immutable muṣḥaf page renderer. Fill every // TODO.
//
// THE ONE RULE (docs/PRD.md R1; docs/engineering/08-quran-data-and-immutable-rendering.md
// framing rule): the sacred text is never put at risk for any feature, performance win,
// or convenience. This View DRAWS glyphs it did not shape and rectangles it did not
// choose. It never line-breaks, re-typesets, font-swaps per theme, or shapes Arabic.
//
// What this file owns: the View. What it does NOT own (consume these from
// domain-mushaf-text-integrity / its providers, never re-derive them here):
//   - ImmutableGlyphPage / GlyphLine / assemblePage()  (layout-from-data, §3)
//   - qpcFontFamily() + FontLoader registration         (glyph-font rendering, §2)
//   - OverlayMarker + PageGeometry.wordRect()           (coordinate overlays, §4)
//   - MushafEdition {text, layout, fonts}, riwayah      (the swappable triple, §1)
//   - SHA-256 verification + refuse-to-render           (integrity, §6)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: import the /quran module types this View consumes (do NOT redefine them here):
//   ImmutableGlyphPage, GlyphLine, qpcFontFamily, OverlayMarker, OverlayKind,
//   PageGeometry, MushafEdition.
// TODO: import the reader-state provider (current page / zoom / theme) — author it with
//   eng-create-riverpod-store; never put DateTime.now() or IO in this View.
// TODO: import the design-system color/space tokens (marker colors, chrome spacing) and
//   the type.* tokens for the riwāyah label — see docs/design-system/04-typography.md.

// ── Reader presentation state (immutable UI state; provider-owned) ────────────────────

/// Sepia/dark/light is a COLOUR transform over the glyph layer, never a font swap (§5).
enum ReaderTheme { light, sepia, dark }

extension ReaderThemeFilter on ReaderTheme {
  /// A single ColorFilter applied to the whole glyph+overlay stack.
  ColorFilter get glyphColorFilter {
    // TODO: resolve from design-system theme tokens (calm, non-gamified). Dark/sepia
    //       recolour the rendered layer; the glyph outlines are untouched.
    switch (this) {
      case ReaderTheme.light:
        return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
      case ReaderTheme.sepia:
        return const ColorFilter.mode(Color(0x1A8A6D3B), BlendMode.multiply); // TODO: token
      case ReaderTheme.dark:
        return const ColorFilter.matrix(<double>[
          // TODO: invert-to-dark matrix from design-system token, not a hand-picked hex.
          -1, 0, 0, 0, 255, 0, -1, 0, 0, 255, 0, 0, -1, 0, 255, 0, 0, 0, 1, 0,
        ]);
    }
  }
}

// ── The page View ────────────────────────────────────────────────────────────────────

/// One muṣḥaf page: glyph layer + coordinate overlays, wrapped in a uniform zoom and a
/// theme colour filter. Stateless and dumb — it renders only what it is handed.
class MushafPageView extends StatelessWidget {
  const MushafPageView({
    super.key,
    required this.glyphPage, // §2/§3 immutable — never mutated here
    required this.geometry, // §4 line/word boxes for this page+font+scale (from data)
    required this.markers, // §4 chosen elsewhere (mutashābihāt etc.) — we only paint
    required this.theme,
    required this.zoom,
  });

  final ImmutableGlyphPage glyphPage;
  final PageGeometry geometry;
  final List<OverlayMarker> markers;
  final ReaderTheme theme;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    // The whole muṣḥaf path is RTL and lives in its OWN pipeline: no type.* token, no
    // shared TextStyle, no MediaQuery.textScalerOf (§1; typography §1/§7).
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ColorFiltered(
        colorFilter: theme.glyphColorFilter, // §5 sepia/dark = filter, not font
        child: Transform.scale(
          scale: zoom, // §5 uniform; NEVER a re-flow / text-scale
          alignment: Alignment.topRight, // RTL origin
          child: Stack(
            children: <Widget>[
              _GlyphLayer(glyphPage: glyphPage),
              // Sibling overlay layer addressed by the SAME geometry (§4).
              Positioned.fill(
                child: CustomPaint(
                  painter: MushafOverlayPainter(markers: markers, geometry: geometry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The immutable glyph layer: one Text per line, font-selected, never shaped.
class _GlyphLayer extends StatelessWidget {
  const _GlyphLayer({required this.glyphPage});

  final ImmutableGlyphPage glyphPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      // Lines come straight from the bundled layout (assemblePage, §3). The View does
      // NOT decide where a line ends — every break is a dataset row.
      children: <Widget>[
        for (final GlyphLine line in glyphPage.lines) _buildGlyphLine(line),
      ],
    );
  }

  /// Drawing one line: the font selection IS the shaping (§2). We apply the page's
  /// dedicated QPC family to the opaque glyph string and do nothing else to it.
  Widget _buildGlyphLine(GlyphLine line) {
    return Text(
      line.glyphCodes, // opaque QPC codes — NEVER normalize/split/search/log as text
      textDirection: TextDirection.rtl,
      softWrap: false, // §3 no runtime line-breaking on Quran text
      maxLines: 1,
      style: TextStyle(
        fontFamily: qpcFontFamily(line.pageNumber), // the font IS the typeset page
        // §2 NO fallback on the sacred path: a fallback re-shapes the moment a glyph is
        // missing. Missing glyph => visible tofu => caught by the visual-diff gate.
        fontFamilyFallback: const <String>[],
        // TODO: page-font size from the reader's own metric (NOT a type.* token, NOT the
        //       OS textScaler). Zoom is handled by Transform.scale above, not here.
      ),
    );
  }
}

// ── The overlay painter: coordinates over the glyph layer, never text (§4) ─────────────

class MushafOverlayPainter extends CustomPainter {
  MushafOverlayPainter({required this.markers, required this.geometry});

  final List<OverlayMarker> markers;
  final PageGeometry geometry; // line/word boxes from data — never measured from shaped text

  @override
  void paint(Canvas canvas, Size size) {
    for (final OverlayMarker m in markers) {
      final Paint paint = _paintFor(m.kind); // calm, theme-aware; tokens own the colour
      for (final WordRef w in m.words) {
        // Resolve each (line, position) word-ref to a device rectangle from the SAME
        // bundled geometry the glyphs use. We draw a box, NEVER glyphs.
        final Rect box = geometry.wordRect(w.lineNumber, w.position);
        canvas.drawRRect(RRect.fromRectXY(box, 3, 3), paint);
      }
    }
  }

  Paint _paintFor(OverlayKind kind) {
    // TODO: map each OverlayKind to a design-system color token (weakLine / currentAyah /
    //       mutashabihAnchor / errorPosition). Calm, non-gamified; no celebration colour.
    final Paint p = Paint()..style = PaintingStyle.fill;
    switch (kind) {
      case OverlayKind.weakLine:
        p.color = const Color(0x22D08C00); // TODO: token
      case OverlayKind.currentAyah:
        p.color = const Color(0x1133691E); // TODO: token
      case OverlayKind.mutashabihAnchor:
        p.color = const Color(0x223949AB); // TODO: token
      case OverlayKind.errorPosition:
        p.color = const Color(0x22B71C1C); // TODO: token
    }
    return p;
  }

  @override
  bool shouldRepaint(MushafOverlayPainter old) =>
      old.markers != markers || old.geometry != geometry;
}

// ── The reader screen: RTL paging + riwāyah chrome ────────────────────────────────────

/// The muṣḥaf reader: swipe across the immutable pages, with the edition's riwāyah named.
/// State (current page, zoom, theme) comes from a provider — author it with
/// eng-create-riverpod-store; this View only reads and paints.
class MushafReaderScreen extends ConsumerWidget {
  const MushafReaderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: read reader state from the provider:
    //   final state = ref.watch(mushafReaderProvider);
    //   final edition = state.edition; final pageCount = edition.pageCount;
    //   final zoom = state.zoom; final theme = state.theme;
    final MushafEdition edition = _placeholderEdition; // TODO: from provider

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _RiwayahLabel(edition: edition), // UI CHROME — shaped, type.*, locale numerals
            Expanded(
              child: PageView.builder(
                // RTL paging: page 1 -> 2 advances right-to-left (see eng-rtl-and-bidi-layout).
                reverse: Directionality.of(context) == TextDirection.rtl,
                itemCount: edition.pageCount, // TODO: from provider/edition
                // TODO: controller: ref.read(mushafReaderProvider.notifier).pageController
                onPageChanged: (int index) {
                  // TODO: ref.read(mushafReaderProvider.notifier).goToPage(index + 1);
                  // Navigation rebuilds with a new pageNumber/geometry only — glyph
                  // content is never mirrored or reordered (just a new immutable page).
                },
                itemBuilder: (BuildContext context, int index) {
                  final int pageNumber = index + 1;
                  // TODO: resolve the verified ImmutableGlyphPage + PageGeometry + markers
                  //       for `pageNumber` from the /quran module / providers. If the asset
                  //       is unverified, REFUSE to render Quran text (show a calm retry,
                  //       never an unverified page) — §6 / PRD §11.1.1.
                  final ImmutableGlyphPage page = _resolveVerifiedPage(pageNumber);
                  final PageGeometry geom = _resolveGeometry(pageNumber);
                  final List<OverlayMarker> markers = _resolveMarkers(pageNumber);

                  return Center(
                    child: MushafPageView(
                      glyphPage: page,
                      geometry: geom,
                      markers: markers,
                      theme: ReaderTheme.light, // TODO: from provider
                      zoom: 1.0, // TODO: from provider (independent of OS chrome text-scale)
                    ),
                  );
                },
              ),
            ),
            // TODO: zoom +/- and light/sepia/dark controls -> provider mutations only.
          ],
        ),
      ),
    );
  }

  // TODO: replace these stubs with verified lookups from the /quran module.
  ImmutableGlyphPage _resolveVerifiedPage(int pageNumber) => throw UnimplementedError();
  PageGeometry _resolveGeometry(int pageNumber) => throw UnimplementedError();
  List<OverlayMarker> _resolveMarkers(int pageNumber) => const <OverlayMarker>[];
  static final MushafEdition _placeholderEdition = throw UnimplementedError();
}

/// Riwāyah / edition name — UI CHROME, not the sacred path. Ordinary shaped text in
/// type.* tokens with locale numerals (intl). Never call the page "the Quran" absolutely;
/// the muṣḥaf is a swappable triple (§1, R2). Wording reviewed via domain-adab-...
class _RiwayahLabel extends StatelessWidget {
  const _RiwayahLabel({required this.edition});

  final MushafEdition edition;

  @override
  Widget build(BuildContext context) {
    // TODO: localize via l10n (eng-add-localized-string); set type.label/type.caption from
    //       docs/design-system/04-typography.md; format any number with intl NumberFormat
    //       for the resolved locale (Extended Arabic-Indic fa/ckb, Arabic-Indic ar).
    return Padding(
      padding: const EdgeInsets.all(8), // TODO: space.* token
      child: Text(
        edition.displayName, // e.g. the named riwāyah (Ḥafṣ ʿan ʿĀṣim)
        textDirection: TextDirection.rtl,
        // TODO: style: type.label  (this IS allowed to use the UI font — it is chrome)
      ),
    );
  }
}

// ── Golden test stub (eng-write-dart-test) ────────────────────────────────────────────
//
// Muṣḥaf goldens MUST load the REAL KFGQPC fonts via FontLoader — never Ahem, which draws
// squares and proves nothing about diacritic placement (§6). Render under light + sepia +
// dark + a zoom step, inside an RTL Directionality, against matchesGoldenFile.
//
//   void main() {
//     setUpAll(() async {
//       await loadRealKfgqpcFontsForGoldens(); // FontLoader, NOT Ahem
//     });
//     testWidgets('muṣḥaf page renders pixel-faithfully (light/sepia/dark + zoom)', (t) async {
//       // TODO: pump MushafPageView for a fixed page across the theme + zoom matrix
//       // TODO: expectLater(find.byType(MushafPageView), matchesGoldenFile('goldens/...'));
//     });
//   }
