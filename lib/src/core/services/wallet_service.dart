import '../constants/api_constants.dart';
import 'api_client.dart';

/// Wallet service for managing earnings and transactions
class WalletService {
  final ApiClient _apiClient;

  WalletService(this._apiClient);

  /// Get wallet balance and info
  Future<Map<String, dynamic>> getWallet() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getWallet,
      requiresAuth: true,
    );

    return response;
  }

  /// Get transaction history
  Future<Map<String, dynamic>> getTransactions({
    int? page,
    int? limit,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getTransactions,
      queryParams: queryParams,
      requiresAuth: true,
    );

    return response;
  }

  /// Get withdrawal history
  Future<Map<String, dynamic>> getWithdrawals({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getWithdrawals,
      queryParams: queryParams,
      requiresAuth: true,
    );

    return response;
  }

  /// Request withdrawal
  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String method,
    Map<String, dynamic>? bankDetails,
    Map<String, dynamic>? upiDetails,
  }) async {
    final body = {
      'amount': amount,
      'method': method,
    };

    if (bankDetails != null) body['bank_details'] = bankDetails;
    if (upiDetails != null) body['upi_details'] = upiDetails;

    final response = await _apiClient.request(
      method: 'POST',
      endpoint: ApiConstants.requestWithdrawal,
      body: body,
      requiresAuth: true,
    );

    return response;
  }
}
