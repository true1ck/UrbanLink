import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';

/// Service for managing device identification and information
class DeviceService {
  final StorageService _storage;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  DeviceService(this._storage);
  
  /// Get or generate persistent device ID
  /// This ID is stored locally and persists across app restarts
  Future<String> getDeviceId() async {
    String? deviceId = _storage.getDeviceId();
    if (deviceId == null || deviceId.isEmpty) {
      // Generate new UUID for this device
      deviceId = const Uuid().v4();
      await _storage.saveDeviceId(deviceId);
      print('[DEVICE_SERVICE] Generated new device ID: $deviceId');
    } else {
      print('[DEVICE_SERVICE] Using existing device ID: $deviceId');
    }
    return deviceId;
  }
  
  /// Collect comprehensive device information for backend
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'os_version': 'Android ${androidInfo.version.release}',
          'app_version': packageInfo.version,
          'language_code': Platform.localeName.split('_').first,
          'timezone': DateTime.now().timeZoneName,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.utsname.machine,
          'os_version': 'iOS ${iosInfo.systemVersion}',
          'app_version': packageInfo.version,
          'language_code': Platform.localeName.split('_').first,
          'timezone': DateTime.now().timeZoneName,
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'platform': 'windows',
          'model': windowsInfo.computerName,
          'os_version': 'Windows ${windowsInfo.majorVersion}.${windowsInfo.minorVersion}',
          'app_version': packageInfo.version,
          'language_code': Platform.localeName.split('_').first,
          'timezone': DateTime.now().timeZoneName,
        };
      }
      
      // Fallback for other platforms
      return {
        'platform': 'unknown',
        'app_version': packageInfo.version,
        'language_code': Platform.localeName.split('_').first,
        'timezone': DateTime.now().timeZoneName,
      };
    } catch (e) {
      print('[DEVICE_SERVICE] Error collecting device info: $e');
      // Return minimal info on error
      return {
        'platform': Platform.operatingSystem,
        'app_version': '1.0.0',
      };
    }
  }
  
  /// Get FCM token for push notifications
  /// Returns null if Firebase is not configured
  Future<String?> getFcmToken() async {
    try {
      // TODO: Uncomment when Firebase is configured
      // import 'package:firebase_messaging/firebase_messaging.dart';
      // final fcmToken = await FirebaseMessaging.instance.getToken();
      // print('[DEVICE_SERVICE] FCM token: ${fcmToken?.substring(0, 20)}...');
      // return fcmToken;
      
      print('[DEVICE_SERVICE] FCM not configured, skipping token');
      return null;
    } catch (e) {
      print('[DEVICE_SERVICE] FCM token not available: $e');
      return null;
    }
  }
}
