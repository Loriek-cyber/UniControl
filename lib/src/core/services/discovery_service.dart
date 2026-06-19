import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/discovered_device.dart';

class DiscoveryService extends ChangeNotifier {
  static const int _port = 8888;
  static const String _magicHeader = 'UNICONTROL_HELLO';

  final List<DiscoveredDevice> _devices = [];
  List<DiscoveredDevice> get devices => List.unmodifiable(_devices);

  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;

  late final String _deviceId;
  late final String _deviceName;
  late final String _deviceOs;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _deviceId = const Uuid().v4();
    await _loadDeviceInfo();

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
      _socket?.broadcastEnabled = true;
      _socket?.listen(_handleDatagram);

      _startBroadcasting();
      _startCleanupTask();
      _isInitialized = true;
      debugPrint('DiscoveryService initialized on port $_port');
    } catch (e) {
      debugPrint('Failed to bind UDP socket: $e');
    }
  }

  Future<void> _loadDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    _deviceOs = Platform.operatingSystem;

    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        _deviceName = '${info.brand} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        _deviceName = info.name;
      } else if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        _deviceName = info.computerName;
      } else if (Platform.isMacOS) {
        final info = await deviceInfo.macOsInfo;
        _deviceName = info.computerName;
      } else if (Platform.isLinux) {
        final info = await deviceInfo.linuxInfo;
        _deviceName = info.prettyName;
      } else {
        _deviceName = 'Unknown Device';
      }
    } catch (e) {
      _deviceName = 'Device';
    }
  }

  void _startBroadcasting() {
    _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _broadcastPresence();
    });
  }

  void _broadcastPresence() {
    if (_socket == null) return;
    final message = '$_magicHeader|$_deviceId|$_deviceName|$_deviceOs';
    final data = utf8.encode(message);

    try {
      // 255.255.255.255 is the local broadcast address
      _socket?.send(data, InternetAddress('255.255.255.255'), _port);
    } catch (e) {
      debugPrint('Error broadcasting: $e');
    }
  }

  void _handleDatagram(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _socket?.receive();
      if (datagram == null) return;

      final message = utf8.decode(datagram.data);
      if (message.startsWith(_magicHeader)) {
        final parts = message.split('|');
        if (parts.length >= 4) {
          final id = parts[1];
          final name = parts[2];
          final os = parts[3];
          final ip = datagram.address.address;

          // Don't add ourselves
          if (id == _deviceId) return;

          _addOrUpdateDevice(id, name, os, ip);
        }
      }
    }
  }

  void _addOrUpdateDevice(String id, String name, String os, String ip) {
    final index = _devices.indexWhere((d) => d.id == id);
    final now = DateTime.now();

    if (index >= 0) {
      _devices[index] = _devices[index].copyWith(
        name: name,
        os: os,
        ipAddress: ip,
        lastSeen: now,
      );
    } else {
      _devices.add(DiscoveredDevice(
        id: id,
        name: name,
        os: os,
        ipAddress: ip,
        lastSeen: now,
      ));
    }
    notifyListeners();
  }

  void _startCleanupTask() {
    // Remove devices that haven't been seen in 10 seconds
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      final beforeCount = _devices.length;
      _devices.removeWhere(
          (d) => now.difference(d.lastSeen) > const Duration(seconds: 10));
      
      if (_devices.length != beforeCount) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    _socket?.close();
    super.dispose();
  }
}
