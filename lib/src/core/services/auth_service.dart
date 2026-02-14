import '../constants/api_constants.dart';
import 'api_client.dart';
import 'storage_service.dart';
import 'device_service.dart';

/// Authentication service for OTP-based login
class AuthService {
  final ApiClient _apiClient;
  final StorageService _storage;
  final DeviceService _deviceService;

  AuthService(this._apiClient, this._storage, this._deviceService);

  /// Send OTP to phone number
  /// Returns true if OTP was sent successfully
  Future<bool> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    final response = await _apiClient.request(
      method: 'POST',
      endpoint: ApiConstants.sendOtp,
      body: {
        'phone_number': phoneNumber,
        'country_code': countryCode,
      },
      useAuthService: true,
      requiresAuth: false,
    );

    final ok = response['ok'] as bool?;
    if (ok != true) {
      throw ApiException('Invalid OTP response', 500);
    }

    // Save phone number for later use
    await _storage.savePhoneNumber(phoneNumber);

    return true;
  }

  /// Verify OTP and get authentication tokens
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    // Get device ID and info for multi-device tracking
    final deviceId = await _deviceService.getDeviceId();
    final deviceInfo = await _deviceService.getDeviceInfo();
    
    // Add FCM token if available (for push notifications)
    final fcmToken = await _deviceService.getFcmToken();
    if (fcmToken != null) {
      deviceInfo['fcm_token'] = fcmToken;
    }

    print('[AUTH_SERVICE] Verifying OTP with device_id: $deviceId');
    print('[AUTH_SERVICE] Device info: ${deviceInfo['platform']} ${deviceInfo['model']}');

    final response = await _apiClient.request(
      method: 'POST',
      endpoint: ApiConstants.verifyOtp,
      body: {
        'phone_number': phoneNumber,
        'code': otp,
        'device_id': deviceId,        // Required for multi-device support
        'device_info': deviceInfo,    // Required for device tracking
      },
      useAuthService: true,
      requiresAuth: false,
    );

    // Extract tokens and user info
    final accessToken = response['access_token'] as String?;
    final refreshToken = response['refresh_token'] as String?;
    final user = response['user'] as Map<String, dynamic>?;
    final userId = user?['id'] as String?;

    if (accessToken == null || refreshToken == null || userId == null) {
      throw ApiException('Invalid authentication response', 500);
    }

    // Save tokens and user ID
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _storage.saveUserId(userId);

    print('[AUTH_SERVICE] Login successful - userId: $userId');
    print('[AUTH_SERVICE] Active devices: ${response['active_devices_count']}');

    return {
      'user_id': userId,
      'is_new_user': response['is_new_account'] ?? false,
      'needs_profile': response['needs_profile'] ?? false,
      'is_new_device': response['is_new_device'] ?? false,
      'active_devices_count': response['active_devices_count'] ?? 1,
      'user': user,
    };
  }

  /// Verify if current token is valid
  Future<bool> verifyToken() async {
    try {
      await _apiClient.request(
        method: 'GET',
        endpoint: ApiConstants.verifyToken,
        useAuthService: true,
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    await _apiClient.refreshAccessToken();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate tokens on server
      await _apiClient.request(
        method: 'POST',
        endpoint: ApiConstants.logout,
        useAuthService: true,
        requiresAuth: true,
      );
    } catch (e) {
      // Continue with local logout even if server call fails
    } finally {
      // Clear all local data
      await _storage.clearAll();
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _storage.isLoggedIn();
  }
}
