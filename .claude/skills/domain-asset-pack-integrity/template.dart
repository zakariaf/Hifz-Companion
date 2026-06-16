// template.dart — copy-paste scaffold for the offline asset-pack contract.
//
// Skill: domain-asset-pack-integrity
// Governing docs:
//   docs/engineering/09-asset-packs-and-offline-integrity.md  §§1–6
//   docs/PRD.md §11.1 + §11.1.1, C1, R1, R2, R3
//   docs/engineering/01-architecture-overview.md §§3.1, 6
//
// THIS FILE LIVES ONLY IN /assets — the single module permitted to import a
// networking package (CI-enforced banned-import lint). Do NOT import dio / http /
// dart:io HttpClient anywhere else. The verified bytes that leave here belong to
// eng-persistence-single-write-path (reference DB) and domain-immutable-quran-
// rendering (glyph rendering); this scaffold stops at "verified bytes in documents."

import 'dart:io';

import 'package:crypto/crypto.dart'; // SHA-256 + startChunkedConversion
import 'package:convert/convert.dart'; // AccumulatorSink<Digest>
import 'package:dio/dio.dart'; // the ONLY networking import in the whole app
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ── 1. Pinned pack identity — compile-time constants, never a runtime lookup ──
// §1: exact GitHub immutable-Release tag baked into the binary, NEVER `latest`.
class PackCoordinates {
  // TODO: set to the public open-source data repo (itself a form of waqf).
  static const repo = 'hifz-companion/quran-assets';

  // TODO: pin the EXACT release tag. The pinned tag and the pinned SHA-256
  // manifest move together, atomically, only when the app binary updates.
  static const pinnedTag = 'core-v1.0.0'; // EXACT — never 'latest'

  // GitHub immutable-release asset URL:
  //   github.com/<repo>/releases/download/<tag>/<file>
  static Uri assetUrl(String fileName) => Uri.parse(
        'https://github.com/$repo/releases/download/$pinnedTag/$fileName',
      );
}

// ── 2. The pinned manifest — its expected digests come from the SIGNED BINARY ──
// §3: the independent trust channel is the app the user installed, NEVER a
// sidecar SHA256SUMS. §1: record source + license per file so one run proves the
// muṣḥaf is simultaneously intact (R1) AND lawfully redistributed (R2).
class ManifestEntry {
  const ManifestEntry({
    required this.name,
    required this.sha256, // lowercase hex, baked into the binary
    required this.bytes,
    required this.source, // e.g. 'tanzil.net', 'qul.tarteel.ai', 'kfgqpc'
    required this.license, // surfaced in-app for attribution (R2)
  });
  final String name;
  final String sha256;
  final int bytes;
  final String source;
  final String license;
}

class EmbeddedManifest {
  // TODO: generate from the reproducible pack build; one entry per file —
  // core text, QUL layout, mutashābihāt, and all 604 QCF_P###.ttf fonts.
  static const core = <ManifestEntry>[
    // ManifestEntry(name: 'quran-uthmani.db', sha256: '9f86d0…', bytes: 3211264,
    //   source: 'tanzil.net', license: 'verbatim+attribution'),
    // … through QCF_P604.ttf …
  ];
}

// ── 3. The quarantined downloader — plain GET, NO identifiers ──────────────────
// §2: no auth, cookies, custom User-Agent, query params, or beacon. Download to
// temp; the caller MUST verify before any byte is treated as Quran.
class PackDownloader {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10), // large reciter packs, slow links
    headers: const {}, // NO interceptors attaching auth/cookies/fingerprint
  ));

  /// Downloads one file to a temp `.part`. Returns the temp File on 200.
  /// UNVERIFIED — never read as Quran until §4 passes.
  Future<File> fetchToTemp(
    String fileName, {
    required CancelToken cancel,
    void Function(int received, int total)? onProgress,
  }) async {
    final tmpDir = await getTemporaryDirectory();
    final tmp = File(p.join(tmpDir.path, '$fileName.part'));

    await _dio.downloadUri(
      PackCoordinates.assetUrl(fileName), // pinned exact-tag public URL only
      tmp.path,
      cancelToken: cancel,
      onReceiveProgress: onProgress,
      options: Options(
        followRedirects: true, // GitHub → objects.githubusercontent.com
        receiveDataWhenStatusError: false,
      ),
      // §5: TLS 1.2+/1.3 via the platform trust store. Do NOT install a
      // badCertificateCallback that returns true and do NOT pin GitHub's cert.
    );
    return tmp; // UNVERIFIED — §4 decides.
  }
}

// ── 4. Chunked SHA-256 + the fail-closed state machine ────────────────────────
// §3: stream through startChunkedConversion so a hundreds-of-MB pack never loads
// fully into memory. NEVER readAsBytes. SHA-256 only (no MD5/SHA-1).
Future<String> sha256OfFile(File file) async {
  final output = AccumulatorSink<Digest>();
  final input = sha256.startChunkedConversion(output);
  await for (final chunk in file.openRead()) {
    input.add(chunk); // streamed, bounded memory
  }
  input.close();
  return output.events.single.toString(); // lowercase hex digest
}

/// Integrity, not a secret — exact string equality on the canonical hex form.
bool digestMatches(String actual, String expected) => actual == expected;

/// The TOTAL fail-closed state machine for one file:
///   match → promote · mismatch → re-fetch ONCE · still mismatch → REFUSE.
/// Returns the verified temp File, or null to fail-closed (refuse to render).
Future<File?> verifyOnce(
  PackDownloader downloader,
  ManifestEntry entry, {
  required CancelToken cancel,
}) async {
  final tmp = await downloader.fetchToTemp(entry.name, cancel: cancel);
  if (digestMatches(await sha256OfFile(tmp), entry.sha256)) return tmp;

  // Mismatch (or truncated/missing read) → delete and re-fetch EXACTLY once.
  await tmp.delete();
  final retry = await downloader.fetchToTemp(entry.name, cancel: cancel);
  if (digestMatches(await sha256OfFile(retry), entry.sha256)) return retry;

  // Still mismatch → FAIL-CLOSED. No soft path, no unbounded retry.
  await retry.delete();
  return null; // caller refuses to render Quran text
}

// ── 5. The sequenced install — download → verify → promote → build DB ─────────
// §2: no partially-trusted state is ever observable. Only a fully-verified pack
// is promoted into app-documents (the irreplaceable offline copy).
sealed class CorePackResult {
  const CorePackResult();
  const factory CorePackResult.ready() = _Ready;
  const factory CorePackResult.integrityFailure(String file) = _IntegrityFailure;
}

class _Ready extends CorePackResult {
  const _Ready();
}

class _IntegrityFailure extends CorePackResult {
  const _IntegrityFailure(this.file);
  final String file;
}

class CorePackInstaller {
  CorePackInstaller(this._downloader);
  final PackDownloader _downloader;

  Future<CorePackResult> installCorePack({required CancelToken cancel}) async {
    final verified = <String, File>{};

    for (final entry in EmbeddedManifest.core) {
      final ok = await verifyOnce(_downloader, entry, cancel: cancel);
      if (ok == null) {
        return CorePackResult.integrityFailure(entry.name); // FAIL-CLOSED
      }
      verified[entry.name] = ok;
    }

    // Only now, with EVERY file verified, promote into app-documents.
    final docs = await getApplicationDocumentsDirectory();
    // TODO: move each verified temp file into `docs` as the canonical copy,
    //       then hand off to eng-persistence-single-write-path to build the
    //       Drift reference DB, then stamp text_checksum_verified_at.
    //   await _promoteToDocuments(verified, docs);
    //   await _buildReferenceDb(verified);
    //   await _appMeta.set('text_checksum_verified_at', DateTime.now().toUtc());
    return const CorePackResult.ready();
  }
}

// ── 6. Onboarding download controller — calm, RTL, non-blaming states ─────────
// §2 state table + PRD §12.1, R3: offline-at-first-run is explained once, never
// scolded. Copy is gen_l10n-localized for fa/ckb/ar, type.body / color.text
// .secondary, no exclamation marks; surface the airplane-mode proof here
// (see ux-privacy-trust-surface).
enum DownloadPhase {
  idle,
  awaitingFirstDownload, // offline at first run — "one-time download needed" + Retry
  downloading, // show progress; cancellable
  downloadInterrupted, // resume/retry; the .part is discarded
  verifying, // brief "re-checking" state on a first-attempt mismatch
  ready, // the single network moment is over — offline forever
  integrityFailure, // calm honest error + Retry — NEVER a degraded render
}

class DownloadState {
  const DownloadState({
    required this.phase,
    this.received = 0,
    this.total = 0,
    this.failedFile,
  });
  final DownloadPhase phase;
  final int received;
  final int total;
  final String? failedFile;

  DownloadState copyWith({
    DownloadPhase? phase,
    int? received,
    int? total,
    String? failedFile,
  }) =>
      DownloadState(
        phase: phase ?? this.phase,
        received: received ?? this.received,
        total: total ?? this.total,
        failedFile: failedFile ?? this.failedFile,
      );
}

class CorePackDownloadController extends StateNotifier<DownloadState> {
  CorePackDownloadController(this._installer)
      : super(const DownloadState(phase: DownloadPhase.idle));

  final CorePackInstaller _installer;
  CancelToken _cancel = CancelToken();

  Future<void> start() async {
    _cancel = CancelToken();
    state = state.copyWith(phase: DownloadPhase.downloading);
    try {
      final result = await _installer.installCorePack(cancel: _cancel);
      switch (result) {
        case _Ready():
          state = state.copyWith(phase: DownloadPhase.ready);
        case _IntegrityFailure(:final file):
          state = state.copyWith(
            phase: DownloadPhase.integrityFailure,
            failedFile: file,
          );
      }
    } on DioException catch (e) {
      // TODO: distinguish "no connectivity at first run" → awaitingFirstDownload
      //       from an interrupted transfer → downloadInterrupted. Both are calm.
      final offline = e.type == DioExceptionType.connectionError;
      state = state.copyWith(
        phase: offline
            ? DownloadPhase.awaitingFirstDownload
            : DownloadPhase.downloadInterrupted,
      );
    }
  }

  void cancel() => _cancel.cancel();

  /// Retry is always offered (never a dead end); re-runs the verified pipeline.
  Future<void> retry() => start();
}

// TODO: wire DI via Riverpod providers (app composition root). No global
// singletons; the downloader/installer are injected, never reached globally.
final _downloaderProvider = Provider((ref) => PackDownloader());
final _installerProvider =
    Provider((ref) => CorePackInstaller(ref.watch(_downloaderProvider)));
final corePackDownloadProvider =
    StateNotifierProvider<CorePackDownloadController, DownloadState>(
  (ref) => CorePackDownloadController(ref.watch(_installerProvider)),
);

// ── UI note (build the screen in the onboarding feature, not here) ────────────
// Wrap the download screen in Directionality(textDirection: TextDirection.rtl)
// for fa/ckb/ar; render all copy via AppLocalizations (gen_l10n), with
// Material 3 calm styling (type.body / color.text.secondary), localized numerals
// for the progress percentage, and no exclamation marks. The integrityFailure
// state shows a calm honest message + Retry — it MUST NOT fall back to any
// degraded render of Quran text. See ux-privacy-trust-surface for the exact copy
// and the airplane-mode proof line.
