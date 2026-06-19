import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SystemBridgeService extends ChangeNotifier {
  // Define standard channel names for cross-platform communication
  static const MethodChannel _methodChannel = MethodChannel('com.unicontrol.app/system_bridge');
  static const EventChannel _eventChannel = EventChannel('com.unicontrol.app/system_status');

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Future setup: Subscribing to native event streams could happen here.
    
    _isInitialized = true;
    debugPrint('SystemBridgeService initialized. Ready for native communication.');
    notifyListeners();
  }

  /// Sends a generic command to the native host OS (Windows/Android/Linux/iOS)
  /// 
  /// The [command] is a string identifier for the action you want the native side to perform.
  /// [arguments] can optionally pass data required for the command.
  Future<Map<String, dynamic>> executeNativeCommand(String command, {Map<String, dynamic>? arguments}) async {
    try {
      final Map<dynamic, dynamic>? result = await _methodChannel.invokeMethod('executeCommand', {
        'command': command,
        'arguments': arguments ?? {},
      });
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      debugPrint("Failed to execute native command '$command': '${e.message}'.");
      return {
        'status': 'error',
        'message': e.message ?? 'Unknown platform exception',
      };
    }
  }

  /// Example: Request specific system metrics like CPU/RAM usage from the host OS
  Future<Map<String, dynamic>> getSystemMetrics() async {
    return await executeNativeCommand('getMetrics');
  }

  /// Listen to continuous system status updates streamed from the native platform
  Stream<String> get systemStatusStream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) => event.toString());
  }
}
