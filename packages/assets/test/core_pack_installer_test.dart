// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:assets/assets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_setup.dart';

class _FakeSource implements BundledAssetSource {
  _FakeSource(this.bytesByName);
  final Map<String, Uint8List> bytesByName;

  @override
  Future<Uint8List> load(String assetName) async {
    final bytes = bytesByName[assetName];
    if (bytes == null) throw StateError('missing bundled asset: $assetName');
    return bytes;
  }
}

class _RecordingBuilder implements ReferenceDbBuilder {
  _RecordingBuilder(this.log);
  final List<String> log;
  Map<String, Uint8List>? built;

  @override
  Future<void> build(Map<String, Uint8List> verifiedBundledBytes) async {
    log.add('build');
    built = verifiedBundledBytes;
  }
}

class _RecordingStamp implements CoreVerifiedStamp {
  _RecordingStamp(this.log);
  final List<String> log;

  @override
  Future<void> markVerified() async => log.add('stamp');
}

void main() {
  useOfflineTestPolicy();

  Uint8List bytes(String s) => Uint8List.fromList(utf8.encode(s));

  // A tiny manifest whose digests match the fake source's bytes.
  final files = {
    'quran-uthmani.db': bytes('the-text'),
    'layout-qul.json': bytes('the-layout'),
    'QCF_P001.ttf': bytes('font-1'),
  };
  CorePackManifest manifestFor(Map<String, Uint8List> source) =>
      CorePackManifest(
        pack: 'core',
        tag: 'core-v1.0.0',
        mushafId: 'kfgqpc_hafs_madani_v2',
        files: [
          for (final e in files.entries)
            ManifestEntry(
              name: e.key,
              sha256: sha256OfBytes(source[e.key] ?? e.value),
              bytes: e.value.length,
              source: 'x',
              license: 'y',
            ),
        ],
      );

  CoreReferenceInstaller installer(
    Map<String, Uint8List> source,
    List<String> log,
  ) =>
      CoreReferenceInstaller(
        source: _FakeSource(source),
        manifest: manifestFor(files),
        referenceDbBuilder: _RecordingBuilder(log),
        stamp: _RecordingStamp(log),
      );

  test('verifies EVERY file, then builds, then stamps LAST → ready', () async {
    final log = <String>[];
    final result = await installer(Map.of(files), log).installCorePack();
    expect(result, isA<CoreReady>());
    // Build precedes stamp, and both come only after all verification.
    expect(log, ['build', 'stamp']);
  });

  test('the builder receives every verified file', () async {
    final log = <String>[];
    final builder = _RecordingBuilder(log);
    await CoreReferenceInstaller(
      source: _FakeSource(Map.of(files)),
      manifest: manifestFor(files),
      referenceDbBuilder: builder,
      stamp: _RecordingStamp(log),
    ).installCorePack();
    expect(builder.built!.keys, files.keys);
  });

  test(
      'a tampered file short-circuits: IntegrityFailure, nothing built/stamped',
      () async {
    final log = <String>[];
    final tampered = Map.of(files)..['layout-qul.json'] = bytes('TAMPERED');
    final result = await installer(tampered, log).installCorePack();
    expect(result, isA<CoreIntegrityFailure>());
    expect((result as CoreIntegrityFailure).fileName, 'layout-qul.json');
    expect(log, isEmpty, reason: 'stamp must never precede full verification');
  });

  test('a missing bundled file is an integrity failure (fail-closed)',
      () async {
    final log = <String>[];
    final missing = Map.of(files)..remove('QCF_P001.ttf');
    final result = await installer(missing, log).installCorePack();
    expect(result, isA<CoreIntegrityFailure>());
    expect((result as CoreIntegrityFailure).fileName, 'QCF_P001.ttf');
    expect(log, isEmpty);
  });
}
