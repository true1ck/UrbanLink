import '../constants/api_constants.dart';
import 'api_client.dart';

/// Metadata service for public data (no auth required)
class MetadataService {
  final ApiClient _apiClient;

  MetadataService(this._apiClient);

  /// Get property types
  Future<List<Map<String, dynamic>>> getPropertyTypes() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getPropertyTypes,
      requiresAuth: false,
    );

    final types = response['property_types'] as List?;
    return types?.cast<Map<String, dynamic>>() ?? [];
  }

  /// Get partner tiers
  Future<List<Map<String, dynamic>>> getPartnerTiers() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getPartnerTiers,
      requiresAuth: false,
    );

    final tiers = response['tiers'] as List?;
    return tiers?.cast<Map<String, dynamic>>() ?? [];
  }

  /// Get lead statuses
  Future<List<Map<String, dynamic>>> getLeadStatuses() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getLeadStatuses,
      requiresAuth: false,
    );

    final statuses = response['statuses'] as List?;
    return statuses?.cast<Map<String, dynamic>>() ?? [];
  }
}
