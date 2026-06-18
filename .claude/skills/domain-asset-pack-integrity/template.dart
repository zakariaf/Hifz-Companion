// template.dart — copy-paste scaffold for the offline asset-pack contract.
//
// Skill: domain-asset-pack-integrity
// Governing docs:
//   docs/engineering/09-asset-packs-and-offline-integrity.md  §§1–6
//   docs/PRD.md §11.1 + §11.1.1, C1, R1, R2, R3
//   docs/engineering/01-architecture-overview.md §§3.1, 6
//
// AMENDED 2026-06-18 (tech-decision-log #5/#8): the CORE muṣḥaf is BUNDLED in the
// signed app binary (Tanzil text + unmodified KFGQPC QCF V2 fonts + QUL layout),
// verified by a BUILD-TIME SHA-256 manifest — there is NO core download. The
// `PackDownloader` below is for OPTIONAL packs only (reciter audio, alt-muṣḥaf).
// The bundled core is loaded via the asset bundle and re-verified at first load
// with the SAME SHA-256 primitive before the reference DB is built.
//
// THIS FILE LIVES ONLY IN /assets — the single module permitted to import a
// networking package (CI-enforced banned-import lint). Do NOT import dio / http /
// dart:io HttpClient anywhere else. The verified bytes that leave here belong to
// eng-persistence-single-write-path (reference DB) and domain-immutable-quran-
// rendering (glyph rendering); this scaffold stops at "verified bytes ready for
// the reference DB."

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart'; // SHA-256 + startChunkedConversion
import 'package:convert/convert.dart'; // AccumulatorSink<Digest>
import 'package:dio/dio.dart'; // the ONLY networking import in the whole app
import 'package:flutter/services.dart' show rootBundle; // bundled-core assets
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ── 1. Pinned OPTIONAL-pack identity — compile-time constants, never a runtime
// lookup. (The core is bundled, so these coordinates are for optional packs:
// reciter audio, alt-muṣḥaf.) §1: exact GitHub immutable-Release tag baked into
// the binary, NEVER `latest`.
class PackCoordinates {
  // TODO: set to the public open-source data repo (itself a form of waqf).
  static const repo = 'hifz-companion/quran-assets';

  // TODO: pin the EXACT release tag of the OPTIONAL pack. The pinned tag and the
  // pinned SHA-256 manifest move together, atomically, only when the binary updates.
  static const pinnedTag = 'reciter-husary-v1.0.0'; // EXACT — never 'latest'

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

/// Hash a BUNDLED asset (the core ships inside the binary). The core files are
/// each small enough to load via the asset bundle; we still stream the bytes
/// through the same chunked SHA-256 so the primitive is identical to the
/// download path. NEVER used for a multi-hundred-MB optional pack.
Future<String> sha256OfBundledAsset(String assetKey) async {
  final ByteData data = await rootBundle.load(assetKey);
  final output = AccumulatorSink<Digest>();
  final input = sha256.startChunkedConversion(output);
  input.add(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  input.close();
  return output.events.single.toString(); // lowercase hex digest
}

/// Integrity, not a secret — exact string equality on the canonical hex form.
bool digestMatches(String actual, String expected) => actual == expected;

/// The TOTAL fail-closed state machine for one DOWNLOADED (optional-pack) file:
///   match → promote · mismatch → re-fetch ONCE · still mismatch → REFUSE.
/// Returns the verified temp File, or null to fail-closed (refuse to render).
/// (The bundled core cannot be re-fetched — see CoreReferenceInstaller below.)
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

// ── 5. First-launch core setup — load BUNDLED → verify → build DB (NO network) ─
// AMENDED: the core is bundled, so there is no download/promote. Load each
// bundled asset, re-verify it against the embedded build-time manifest, then
// build the reference DB. A bundled byte cannot be re-fetched, so a mismatch
// fails closed at once (the build-time gate makes such a mismatch a build
// failure long before ship). No partially-trusted state is ever observable.
sealed class CoreSetupResult {
  const CoreSetupResult();
  const factory CoreSetupResult.ready() = _Ready;
  const factory CoreSetupResult.integrityFailure(String file) = _IntegrityFailure;
}

class _Ready extends CoreSetupResult {
  const _Ready();
}

class _IntegrityFailure extends CoreSetupResult {
  const _IntegrityFailure(this.file);
  final String file;
}

class CoreReferenceInstaller {
  const CoreReferenceInstaller();

  /// The bundled-asset key for one manifest entry, e.g. 'assets/quran/<name>'.
  String _assetKey(ManifestEntry entry) => 'assets/quran/${entry.name}';

  Future<CoreSetupResult> prepareCore() async {
    for (final entry in EmbeddedManifest.core) {
      final actual = await sha256OfBundledAsset(_assetKey(entry));
      if (!digestMatches(actual, entry.sha256)) {
        // FAIL-CLOSED. Unfetchable bundled byte → corrupted install.
        return CoreSetupResult.integrityFailure(entry.name);
      }
    }
    // Only now, with EVERY bundled file verified, build the reference DB.
    // TODO: hand off to eng-persistence-single-write-path to build the Drift
    //       reference DB from the bundled assets, then stamp the verified time.
    //   await _buildReferenceDb(EmbeddedManifest.core);
    //   await _appMeta.set('text_checksum_verified_at', DateTime.now().toUtc());
    return const CoreSetupResult.ready();
  }
}

// Optional packs (reciter audio, alt-muṣḥaf) reuse the download path: for each
// manifest entry call `verifyOnce(downloader, entry, cancel: cancel)`; a null
// result means fail-closed (refuse). Promote verified temp files into
// getApplicationDocumentsDirectory() before use.

// ── 6. First-launch setup controller — calm, RTL, non-blaming states ──────────
// AMENDED: the core needs NO network, so it has no awaitingDownload state — only
// a brief preparing/ready/integrityFailure. (An OPTIONAL pack requested offline
// uses awaitingDownload/downloadInterrupted — model that in the audio feature.)
// PRD §12.1, R3: never scolded. Copy is gen_l10n-localized for fa/ckb/ar,
// type.body / color.text.secondary, no exclamation marks; surface the
// airplane-mode proof here (see ux-privacy-trust-surface).
enum CoreSetupPhase {
  idle,
  preparingMushaf, // brief, silent — bundled, no network
  ready, // the muṣḥaf is available offline from first launch
  coreIntegrityFailure, // calm honest error + reinstall — NEVER a degraded render
}

class CoreSetupState {
  const CoreSetupState({required this.phase, this.failedFile});
  final CoreSetupPhase phase;
  final String? failedFile;

  CoreSetupState copyWith({CoreSetupPhase? phase, String? failedFile}) =>
      CoreSetupState(
        phase: phase ?? this.phase,
        failedFile: failedFile ?? this.failedFile,
      );
}

// Riverpod 3.x Notifier (NOT the banned StateNotifier — Decision log #2).
class CoreSetupController extends Notifier<CoreSetupState> {
  @override
  CoreSetupState build() => const CoreSetupState(phase: CoreSetupPhase.idle);

  Future<void> start() async {
    state = state.copyWith(phase: CoreSetupPhase.preparingMushaf);
    final result = await const CoreReferenceInstaller().prepareCore();
    switch (result) {
      case _Ready():
        state = state.copyWith(phase: CoreSetupPhase.ready);
      case _IntegrityFailure(:final file):
        state = state.copyWith(
          phase: CoreSetupPhase.coreIntegrityFailure,
          failedFile: file,
        );
    }
  }

  /// Retry is always offered (never a dead end); re-runs the verified pipeline.
  Future<void> retry() => start();
}

// TODO: wire DI via Riverpod providers (app composition root). No global
// singletons; the installer/downloader are injected, never reached globally.
final coreSetupProvider =
    NotifierProvider<CoreSetupController, CoreSetupState>(CoreSetupController.new);

// Optional-pack downloader DI (used by the audio feature, not at first launch).
final packDownloaderProvider = Provider((ref) => PackDownloader());

// ── UI note (build the screen in the onboarding feature, not here) ────────────
// Wrap the setup screen in Directionality(textDirection: TextDirection.rtl) for
// fa/ckb/ar; render all copy via AppLocalizations (gen_l10n), with Material 3
// calm styling (type.body / color.text.secondary) and no exclamation marks. The
// coreIntegrityFailure state shows a calm honest message + reinstall guidance —
// it MUST NOT fall back to any degraded render of Quran text. See
// ux-privacy-trust-surface for the exact copy and the airplane-mode proof line.
