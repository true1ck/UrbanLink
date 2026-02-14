import '../constants/api_constants.dart';
import 'api_client.dart';

/// User service for profile management
class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getUserProfile,
      requiresAuth: true,
    );

    return response;
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? language,
    String? timezone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (language != null) body['language'] = language;
    if (timezone != null) body['timezone'] = timezone;

    final response = await _apiClient.request(
      method: 'PUT',
      endpoint: ApiConstants.updateUserProfile,
      body: body,
      requiresAuth: true,
    );

    return response;
  }

  /// Get signed URL for avatar upload
  Future<Map<String, dynamic>> getAvatarUploadUrl({
    required String fileType,
  }) async {
    final response = await _apiClient.request(
      method: 'POST',
      endpoint: ApiConstants.getAvatarSignedUrl,
      body: {'file_type': fileType},
      requiresAuth: true,
    );

    return {
      'upload_url': response['upload_url'],
      'key': response['key'],
      'final_url': response['final_url'],
    };
  }

  /// Confirm avatar upload
  Future<void> updateAvatar(String avatarUrl) async {
    await _apiClient.request(
      method: 'PUT',
      endpoint: ApiConstants.updateAvatar,
      body: {'avatar_url': avatarUrl},
      requiresAuth: true,
    );
  }

  /// Get user devices
  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getUserDevices,
      requiresAuth: true,
    );

    final devices = response['devices'] as List?;
    return devices?.cast<Map<String, dynamic>>() ?? [];
  }
}
