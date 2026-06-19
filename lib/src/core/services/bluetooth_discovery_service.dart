import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/discovered_device.dart';

class BluetoothDiscoveryService extends ChangeNotifier {
  final List<DiscoveredDevice> _devices = [];
  List<DiscoveredDevice> get devices => List.unmodifiable(_devices);

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Timer? _cleanupTimer;
  bool _isScanning = false;

  bool get isScanning => _isScanning;

  Future<void> initialize() async {
    // Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint("Bluetooth is not supported on this device.");
      return;
    }

    // Start a periodic cleanup task
    _startCleanupTask();
  }

  /// Starts scanning for nearby UniControl devices over Bluetooth LE
  Future<void> startScanning() async {
    if (_isScanning) return;

    // Check if Bluetooth is turned ON
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      debugPrint("Bluetooth is turned off.");
      return;
    }

    _isScanning = true;
    notifyListeners();

    // Listen to the scan results stream
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // You can filter by a specific UUID or name if you configure your app to advertise one
        // For now, we grab the advertisement name or default to 'Unknown Bluetooth Device'
        final String deviceName = r.advertisementData.advName.isNotEmpty 
            ? r.advertisementData.advName 
            : 'Unknown Bluetooth Device';
        
        // Skip devices with absolutely no name to avoid clutter
        if (deviceName == 'Unknown Bluetooth Device') continue;

        _addOrUpdateDevice(
          id: r.device.remoteId.str, // The MAC address or unique iOS UUID
          name: deviceName,
          os: 'Unknown', // Bluetooth scanning doesn't natively expose the OS
          macAddress: r.device.remoteId.str,
        );
      }
    });

    // Start the hardware scan
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      continuousUpdates: true, // Keep getting updates if signal strength changes
    );

    // Stop scanning after the timeout
    FlutterBluePlus.isScanning.listen((isScanning) {
      if (!isScanning && _isScanning) {
        _isScanning = false;
        notifyListeners();
      }
    });
  }

  /// Stops the current Bluetooth scan
  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  void _addOrUpdateDevice({
    required String id,
    required String name,
    required String os,
    required String macAddress,
  }) {
    final index = _devices.indexWhere((d) => d.id == id);
    final now = DateTime.now();

    if (index >= 0) {
      // Device already exists, update its last seen time
      _devices[index] = _devices[index].copyWith(
        name: name,
        lastSeen: now,
      );
    } else {
      // New device found via Bluetooth
      _devices.add(DiscoveredDevice(
        id: id,
        name: name,
        os: os,
        ipAddress: 'BLE: $macAddress', // Use the IP field to show it's a Bluetooth MAC
        lastSeen: now,
      ));
    }
    notifyListeners();
  }

  void _startCleanupTask() {
    // Remove devices that haven't been seen in 20 seconds
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      final beforeCount = _devices.length;
      
      _devices.removeWhere(
          (d) => now.difference(d.lastSeen) > const Duration(seconds: 20));
      
      if (_devices.length != beforeCount) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _cleanupTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
