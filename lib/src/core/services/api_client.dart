import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'storage_service.dart';

/// HTTP Client wrapper with authentication and error handling
class ApiClient {
  final StorageService _storage;
  final http.Client _client = http.Client();
  bool _isRefreshing = false;  // Prevent multiple simultaneous refreshes

  ApiClient(this._storage);

  /// Make authenticated request to backend service
  Future<Map<String, dynamic>> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool useAuthService = false,
    bool requiresAuth = true,
    int retryCount = 0,  // Track retry attempts
  }) async {
    final baseUrl = useAuthService 
        ? ApiConstants.authBaseUrl 
        : ApiConstants.backendBaseUrl;
    
    // Build URL with query parameters
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    // Build headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add authorization header if required
    if (requiresAuth) {
      final accessToken = _storage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw ApiException('Not authenticated', 401);
      }
      headers['Authorization'] = 'Bearer $accessToken';
    }

    // Make request
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(uri, headers: headers)
              .timeout(ApiConstants.receiveTimeout);
          break;
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConstants.receiveTimeout);
          break;
        case 'PUT':
          response = await _client.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConstants.receiveTimeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers)
              .timeout(ApiConstants.receiveTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method', 400);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}', 0);
    }

    // Handle response with automatic token refresh
    return _handleResponse(
      response,
      method: method,
      endpoint: endpoint,
      body: body,
      queryParams: queryParams,
      useAuthService: useAuthService,
      requiresAuth: requiresAuth,
      retryCount: retryCount,
    );
  }

  /// Handle HTTP response and errors with automatic token refresh
  Future<Map<String, dynamic>> _handleResponse(
    http.Response response, {
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    required bool useAuthService,
    required bool requiresAuth,
    required int retryCount,
  }) async {
    final statusCode = response.statusCode;
    
    // Try to parse response body
    Map<String, dynamic>? data;
    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      // If JSON parsing fails, wrap the raw response
      data = {'message': response.body};
    }

    // Handle success responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      return data ?? {};
    }

    // Handle 401 Unauthorized - Try to refresh token
    if (statusCode == 401 && requiresAuth && retryCount == 0) {
      try {
        print('[API_CLIENT] 401 Unauthorized - Attempting token refresh');
        await refreshAccessToken();
        print('[API_CLIENT] Token refreshed successfully - Retrying request');
        
        // Retry the original request with new token
        return await request(
          method: method,
          endpoint: endpoint,
          body: body,
          queryParams: queryParams,
          useAuthService: useAuthService,
          requiresAuth: requiresAuth,
          retryCount: 1,  // Prevent infinite loop
        );
      } catch (refreshError) {
        print('[API_CLIENT] Token refresh failed: $refreshError');
        // Clear tokens and force re-login
        await _storage.clearTokens();
        throw ApiException('Session expired. Please login again.', 401);
      }
    }

    // Handle error responses
    final errorMessage = data?['error'] ?? 
                        data?['message'] ?? 
                        'Request failed with status $statusCode';
    
    throw ApiException(errorMessage, statusCode);
  }

  /// Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      print('[API_CLIENT] Token refresh already in progress, waiting...');
      // Wait for ongoing refresh to complete
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw ApiException('No refresh token available', 401);
      }

      print('[API_CLIENT] Refreshing access token...');
      final response = await request(
        method: 'POST',
        endpoint: ApiConstants.refreshToken,
        body: {'refresh_token': refreshToken},
        useAuthService: true,
        requiresAuth: false,
        retryCount: 1,  // Don't retry refresh endpoint
      );

      final newAccessToken = response['access_token'] as String?;
      final newRefreshToken = response['refresh_token'] as String?;

      if (newAccessToken != null && newRefreshToken != null) {
        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        print('[API_CLIENT] Tokens refreshed and saved successfully');
      } else {
        throw ApiException('Invalid token refresh response', 401);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
}
