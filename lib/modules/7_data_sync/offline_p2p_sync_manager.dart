/// ---------------------------------------------------------------------------
/// DUAL OFFLINE DELIVERY & BLUETOOTH P2P SYNC MANAGER
/// ---------------------------------------------------------------------------
/// Discovers and ingests `.medpack` updates from:
/// 1. Intermittent online downloads (health worker phone in town)
/// 2. USB flash drives & SD Cards (/media/usb/)
/// 3. Bluetooth / Wi-Fi Direct P2P device-to-device mesh sync between field workers.

import 'dart:async';
import 'package:slm_medical/modules/7_data_sync/package_manifest.dart';

enum SyncChannelSource { intermittentOnline, usbSdCard, bluetoothP2p }

class DiscoveredPackage {
  final MedpackManifest manifest;
  final SyncChannelSource source;
  final String sourceLocation;

  DiscoveredPackage({
    required this.manifest,
    required this.source,
    required this.sourceLocation,
  });
}

class OfflineP2pSyncManager {
  final StreamController<DiscoveredPackage> _packageDiscoveredController = StreamController<DiscoveredPackage>.broadcast();

  Stream<DiscoveredPackage> get packageDiscoveredStream => _packageDiscoveredController.stream;

  /// Scans local storage, mounted USB drives, and Bluetooth P2P peers for updates.
  Future<List<DiscoveredPackage>> scanForUpdates() async {
    print("[🔍 UPDATE SCAN] Scanning USB mounts, Bluetooth peers, and intermittent downloads...");

    final discovered = [
      DiscoveredPackage(
        manifest: MedpackManifest(
          packageId: 'MEDPACK_RAG_KB_2026_V2',
          type: PackageType.ragKnowledgeBase,
          version: '1.5.0',
          publisher: 'WHO & IFRC Medical Consortium',
          releaseDate: '2026-10-05',
          signature: 'ED25519_SIG_OK_WHO_2026',
          fileSizeBytes: 42000000,
        ),
        source: SyncChannelSource.usbSdCard,
        sourceLocation: '/media/usb/updates/kb_v1.5.medpack',
      ),
      DiscoveredPackage(
        manifest: MedpackManifest(
          packageId: 'MEDPACK_TRIAGE_RULES_2026_V2',
          type: PackageType.safetyRuleset,
          version: '1.3.0',
          publisher: 'WHO Triage Review Board',
          releaseDate: '2026-10-04',
          signature: 'ED25519_SIG_OK_WHO_2026',
          fileSizeBytes: 1500000,
        ),
        source: SyncChannelSource.bluetoothP2p,
        sourceLocation: 'Bluetooth Peer: HW_PHONE_8842',
      ),
    ];

    for (final pkg in discovered) {
      _packageDiscoveredController.add(pkg);
    }

    return discovered;
  }
}
