import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for managing tokens and user data
class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userNameKey = 'user_name';
  static const String _deviceIdKey = 'device_id';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  // User Data Management
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    await _prefs.setString(_phoneNumberKey, phoneNumber);
  }

  String? getPhoneNumber() {
    return _prefs.getString(_phoneNumberKey);
  }

  Future<void> saveUserName(String userName) async {
    await _prefs.setString(_userNameKey, userName);
  }

  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  // Device ID Management
  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(_deviceIdKey, deviceId);
  }

  String? getDeviceId() {
    return _prefs.getString(_deviceIdKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final accessToken = getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Clear all user data (logout)
  Future<void> clearAll() async {
    // Preserve device ID across logouts
    final deviceId = getDeviceId();
    await _prefs.clear();
    if (deviceId != null) {
      await saveDeviceId(deviceId);
    }
  }
}
