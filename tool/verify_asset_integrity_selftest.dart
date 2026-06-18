// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

// Self-test for the build-time checksum gate's pure core (tool/src/
// verify_asset_integrity.dart). Drives verifyAssetIntegrity with an in-memory
// fake ReleaseManifest — no real assets, no network — and asserts each drift
// type is detected and the all-consistent case passes. Run as a `dart run`
// regression guard (the repo's tool pattern); exits non-zero on any failure.
//
// The CI gate over the REAL bundled assets + the real authoritative Tanzil hash
// is E05-T10's remaining half (asset-blocked); this proves the verifier logic.

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'src/verify_asset_integrity.dart';

int _failures = 0;

void _check(String name, bool ok) {
  if (!ok) {
    stderr.writeln('FAIL: $name');
    _failures++;
  }
}

String _hex(Uint8List b) => sha256.convert(b).toString();
Uint8List _bytes(String s) => Uint8List.fromList(s.codeUnits);

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
  final text = _bytes('the-uthmani-text');
  final layout = _bytes('the-qul-layout');
  final font1 = _bytes('font-1');
  final font2 = _bytes('font-2');
  final tanzilHash = _hex(text);

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
    String? tanzil,
    int canonical = 2,
  }) =>
      verifyAssetIntegrity(
        expected: exp ?? expected(),
        release: rel ?? release(),
        authoritativeTextSha256: tanzil ?? tanzilHash,
        canonicalPageCount: canonical,
      );

  // 1. All consistent → no failures.
  _check('consistent assets pass', run().isEmpty);

  // 2. Tampered text bytes → TextMismatch.
  _check(
    'tampered text → TextMismatch',
    run(rel: release(textOverride: _bytes('TAMPERED')))
        .any((f) => f is TextMismatch),
  );

  // 3. Pinned text != authoritative Tanzil hash → TextDrift.
  _check(
    'pinned text != authoritative → TextDrift',
    run(tanzil: _hex(_bytes('different-authoritative')))
        .any((f) => f is TextDrift),
  );

  // 4. Tampered layout → LayoutMismatch.
  _check(
    'tampered layout → LayoutMismatch',
    run(rel: release(layoutOverride: _bytes('TAMPERED')))
        .any((f) => f is LayoutMismatch),
  );

  // 5. Missing font → FontMissing(page).
  _check(
    'missing font → FontMissing(2)',
    run(rel: release(fontsOverride: {1: font1})).contains(const FontMissing(2)),
  );

  // 6. Tampered font → FontMismatch(page).
  _check(
    'tampered font → FontMismatch(2)',
    run(rel: release(fontsOverride: {1: font1, 2: _bytes('TAMPERED')}))
        .contains(const FontMismatch(2)),
  );

  // 7. Wrong font count → FontCountWrong.
  _check(
    'extra font → FontCountWrong(2, 3)',
    run(rel: release(fontsOverride: {1: font1, 2: font2, 3: _bytes('extra')}))
        .contains(const FontCountWrong(2, 3)),
  );

  // 8. Wrong page count → PageCountWrong.
  _check(
    'pageCount != canonical → PageCountWrong(604, 2)',
    run(canonical: 604).contains(const PageCountWrong(604, 2)),
  );

  // 9. Report-collecting: two independent drifts both surface.
  final multi = run(
    rel: release(
      textOverride: _bytes('TAMPERED'),
      layoutOverride: _bytes('TAMPERED'),
    ),
  );
  _check(
    'collects every drift (text + layout)',
    multi.any((f) => f is TextMismatch) &&
        multi.any((f) => f is LayoutMismatch),
  );

  if (_failures > 0) {
    stderr.writeln(
      'verify_asset_integrity selftest: $_failures check(s) failed.',
    );
    exitCode = 1;
  } else {
    stdout.writeln('verify_asset_integrity selftest: all checks passed.');
  }
}
