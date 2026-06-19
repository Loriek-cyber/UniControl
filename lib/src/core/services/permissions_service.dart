import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  /// Checks if all necessary network/discovery permissions are granted
  static Future<bool> checkPermissions() async {
    if (kIsWeb) return true;
    
    if (Platform.isAndroid) {
      // For network discovery and getting WiFi info
      final locationStatus = await Permission.locationWhenInUse.status;
      // Android 13+ might use nearbyWifiDevices for local network operations
      final nearbyStatus = await Permission.nearbyWifiDevices.status;
      
      return locationStatus.isGranted || nearbyStatus.isGranted;
    } 
    
    // iOS handles local network prompts automatically, and desktop platforms don't need runtime permissions.
    return true;
  }

  /// Requests the required permissions
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    
    if (Platform.isAndroid) {
      bool isGranted = false;
      
      // Request location (often needed for older Android WiFi discovery)
      final locationStatus = await Permission.locationWhenInUse.request();
      if (locationStatus.isGranted) {
        isGranted = true;
      }
      
      // Request nearby wifi (for Android 13+)
      final nearbyStatus = await Permission.nearbyWifiDevices.request();
      if (nearbyStatus.isGranted) {
        isGranted = true;
      }
      
      return isGranted;
    }
    
    // For iOS and Windows, nothing to explicitly request via permission_handler for basic UDP.
    return true;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
