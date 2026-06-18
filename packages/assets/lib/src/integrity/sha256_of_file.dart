// SPDX-FileCopyrightText: 2026 Zakaria Fatahi and Hifz Companion contributors
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:crypto/crypto.dart';

/// The SHA-256 of [file], streamed through `startChunkedConversion` so a
/// hundreds-of-MB pack never loads fully into memory (engineering 09 §3).
///
/// **Never** `readAsBytes` — that would OOM a low-end Android device on a large
/// reciter pack. Returns the canonical **lower-case hex** digest. A missing or
/// unreadable file throws a [FileSystemException]; the verifier (verifyAndPromote)
/// treats that as a mismatch (fail-closed), never an uncaught crash.
Future<String> sha256OfFile(File file) async {
  final sink = _DigestSink();
  final input = sha256.startChunkedConversion(sink);
  await for (final chunk in file.openRead()) {
    input.add(chunk);
  }
  input.close();
  return sink.digest.toString();
}

/// A one-shot `Sink<Digest>` capturing the final digest from
/// `startChunkedConversion` — a tiny local stand-in for `convert`'s
/// `AccumulatorSink`, so chunked hashing adds no third-party dependency.
class _DigestSink implements Sink<Digest> {
  late Digest digest;

  @override
  void add(Digest data) => digest = data;

  @override
  void close() {}
}

/// The SHA-256 of in-memory [bytes] (lower-case hex). Used for **bundled-core**
/// assets, which `rootBundle.load` already holds in memory — a one-shot
/// `sha256.convert` is correct and clearer than chunking there (chunking earns
/// its keep only on a large downloaded pack; see [sha256OfFile]).
String sha256OfBytes(List<int> bytes) => sha256.convert(bytes).toString();

/// Exact equality on the canonical lower-case hex digest. Integrity, not a
/// secret, so a constant-time compare is unnecessary (engineering 09 §3).
bool digestMatches(String actual, String expected) => actual == expected;
