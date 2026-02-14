import '../constants/api_constants.dart';
import 'api_client.dart';

/// Notifications service for managing user notifications
class NotificationsService {
  final ApiClient _apiClient;

  NotificationsService(this._apiClient);

  /// Get notifications
  Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? limit,
    bool? unreadOnly,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (unreadOnly != null) queryParams['unread_only'] = unreadOnly.toString();

    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getNotifications,
      queryParams: queryParams,
      requiresAuth: true,
    );

    return response;
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final endpoint = ApiConstants.markAsRead.replaceAll(':id', notificationId);
    
    await _apiClient.request(
      method: 'PUT',
      endpoint: endpoint,
      requiresAuth: true,
    );
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _apiClient.request(
      method: 'PUT',
      endpoint: ApiConstants.markAllAsRead,
      requiresAuth: true,
    );
  }
}
