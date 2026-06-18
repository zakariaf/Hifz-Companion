// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Test-first suite for the build-time checksum gate's pure core (E05-T10;
// engineering 08 §6, 11 §9; PRD §11.3 steps 1-2, §20 gate 1). Plain
// `package:test` — no `flutter_test`, no widget binding, no rendering — driven
// by an in-memory `ReleaseManifest` fake so the suite is fully offline (no real
// release download, no network, no real KFGQPC fonts; pixels are E05-T11).
//
// The rejections ARE the spec: a single-byte-flipped text, a missing/modified
// font, a wrong font count, a wrong page count, a manifest drifted from the
// Tanzil anchor, and a cross-edition font/layout pairing each produce a failure
// — and the verifier collects EVERY drift in one pass, never throw-on-first.
//
// What this proves vs. what stays asset-gated: this exercises the verifier
// LOGIC against synthetic fixtures. The gate over the REAL bundled assets, the
// real `kAuthoritativeTanzilUthmaniSha256` const, and a published release pack
// is E05-T10's remaining half — blocked on the (licence-gated) real muṣḥaf
// assets, alongside E05-T11's pixel visual-diff and the E20 scholar proof.

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

import '../src/verify_asset_integrity.dart';

String _hex(Uint8List b) => sha256.convert(b).toString();
Uint8List _bytes(String s) => Uint8List.fromList(s.codeUnits);

/// In-memory [ReleaseManifest] over synthetic byte blobs — no disk, no network.
class _FakeRelease implements ReleaseManifest {
  _FakeRelease({
    required this.textBytes,
    required this.layoutBytes,
    required Map<int, Uint8List> fonts,
  }) : _fonts = fonts;

  @override
  final Uint8List textBytes;
  @override
  final Uint8List layoutBytes;
  final Map<int, Uint8List> _fonts;

  @override
  Uint8List fontBytes(int page) => _fonts[page]!;
  @override
  bool hasFont(int page) => _fonts.containsKey(page);
  @override
  int get fontCount => _fonts.length;
}

void main() {
  // A tiny two-page synthetic edition: the "text"/"layout"/font blobs are
  // arbitrary bytes; only their digests matter. canonicalPageCount is overridden
  // to 2 so the happy path is green without 604 fixtures (the 604 invariant has
  // its own case below).
  final text = _bytes('the-uthmani-text');
  final layout = _bytes('the-qul-layout');
  final font1 = _bytes('font-page-1');
  final font2 = _bytes('font-page-2');
  final tanzilAnchor = _hex(text); // pinned text == authoritative, by default

  ExpectedManifest expected({int pageCount = 2}) => ExpectedManifest(
        pageCount: pageCount,
        textSha256: _hex(text),
        layoutSha256: _hex(layout),
        fontSha256: {1: _hex(font1), 2: _hex(font2)},
      );

  _FakeRelease release({
    Uint8List? textOverride,
    Uint8List? layoutOverride,
    Map<int, Uint8List>? fontsOverride,
  }) =>
      _FakeRelease(
        textBytes: textOverride ?? text,
        layoutBytes: layoutOverride ?? layout,
        fonts: fontsOverride ?? {1: font1, 2: font2},
      );

  List<IntegrityFailure> run({
    ExpectedManifest? exp,
    _FakeRelease? rel,
    String? anchor,
    int canonical = 2,
  }) =>
      verifyAssetIntegrity(
        expected: exp ?? expected(),
        release: rel ?? release(),
        authoritativeTextSha256: anchor ?? tanzilAnchor,
        canonicalPageCount: canonical,
      );

  group('happy path (the only green state)', () {
    test('all three layers consistent + anchor + count → empty list', () {
      expect(run(), isEmpty);
    });
  });

  group('text integrity', () {
    test('single-byte-flipped text → TextMismatch', () {
      final flipped = Uint8List.fromList(text)..[0] ^= 0x01;
      final result = run(rel: release(textOverride: flipped));
      expect(result.whereType<TextMismatch>(), isNotEmpty);
    });

    test('pinned text != authoritative Tanzil anchor → TextDrift', () {
      // The release self-agrees (text hashes to the pinned digest) but the
      // pinned digest drifts from upstream — caught regardless.
      final result =
          run(anchor: _hex(_bytes('a-different-authoritative-text')));
      expect(result.whereType<TextDrift>(), isNotEmpty);
    });

    test('the hash comparison is exact (an uppercased anchor still drifts)',
        () {
      final result = run(anchor: tanzilAnchor.toUpperCase());
      expect(result.whereType<TextDrift>(), isNotEmpty);
    });
  });

  group('layout integrity', () {
    test('mutated layout bytes → LayoutMismatch', () {
      final result = run(rel: release(layoutOverride: _bytes('TAMPERED')));
      expect(result.whereType<LayoutMismatch>(), isNotEmpty);
    });
  });

  group('font integrity (all pages present and unmodified)', () {
    test('a missing font is never silently skipped → FontMissing(p)', () {
      final result = run(rel: release(fontsOverride: {1: font1}));
      expect(result, contains(const FontMissing(2)));
    });

    test('a modified font → FontMismatch(p)', () {
      final result =
          run(rel: release(fontsOverride: {1: font1, 2: _bytes('TAMPERED')}));
      expect(result, contains(const FontMismatch(2)));
    });

    test('wrong font count → FontCountWrong', () {
      final result = run(
        rel: release(fontsOverride: {1: font1, 2: font2, 3: _bytes('extra')}),
      );
      expect(result, contains(const FontCountWrong(2, 3)));
    });
  });

  group('the Madani 15-line page-count invariant (C-031)', () {
    test('pageCount != canonical → PageCountWrong', () {
      // expected.pageCount is 2 but the canonical edition must be 604.
      final result = run(canonical: 604);
      expect(result, contains(const PageCountWrong(604, 2)));
    });

    test('the font loop is driven by pageCount, not a hardcoded 604', () {
      // A 3-page edition checks exactly 3 fonts (no spurious FontMissing(4..604)).
      final f3 = _bytes('font-page-3');
      final exp = ExpectedManifest(
        pageCount: 3,
        textSha256: _hex(text),
        layoutSha256: _hex(layout),
        fontSha256: {1: _hex(font1), 2: _hex(font2), 3: _hex(f3)},
      );
      final rel = release(fontsOverride: {1: font1, 2: font2, 3: f3});
      final result = run(exp: exp, rel: rel, canonical: 3);
      expect(result, isEmpty);
    });
  });

  group('cross-edition mixing is foreclosed (one mushafId binds one triple)',
      () {
    test('edition-B fonts against edition-A pinned hashes → per-page mismatch',
        () {
      // Edition A is the pinned `expected()`. The release ships a *different*
      // edition's fonts (same count) — every page fails its hash.
      final bFont1 = _bytes('edition-B-font-1');
      final bFont2 = _bytes('edition-B-font-2');
      final result = run(rel: release(fontsOverride: {1: bFont1, 2: bFont2}));
      expect(result, contains(const FontMismatch(1)));
      expect(result, contains(const FontMismatch(2)));
    });
  });

  group('report-collecting (every drift in one pass, never throw-on-first)',
      () {
    test('a flipped text byte AND a missing font both surface', () {
      final result = run(
        rel: release(
          textOverride: _bytes('TAMPERED'),
          fontsOverride: {1: font1}, // page 2 missing
        ),
      );
      expect(result.whereType<TextMismatch>(), isNotEmpty);
      expect(result, contains(const FontMissing(2)));
    });
  });
}
