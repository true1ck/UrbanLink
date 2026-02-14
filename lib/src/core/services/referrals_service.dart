import '../constants/api_constants.dart';
import 'api_client.dart';

/// Referrals service for managing referral program
class ReferralsService {
  final ApiClient _apiClient;

  ReferralsService(this._apiClient);

  /// Get referral list
  Future<Map<String, dynamic>> getReferrals({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getReferrals,
      queryParams: queryParams,
      requiresAuth: true,
    );

    return response;
  }

  /// Get referral statistics
  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getReferralStats,
      requiresAuth: true,
    );

    return response;
  }
}
