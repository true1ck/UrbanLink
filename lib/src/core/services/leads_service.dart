import '../constants/api_constants.dart';
import 'api_client.dart';

/// Leads service for managing property leads
class LeadsService {
  final ApiClient _apiClient;

  LeadsService(this._apiClient);

  /// Get all leads with optional filters
  Future<Map<String, dynamic>> getLeads({
    int? page,
    int? limit,
    String? status,
    String? propertyType,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (status != null) queryParams['status'] = status;
    if (propertyType != null) queryParams['property_type'] = propertyType;

    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getLeads,
      queryParams: queryParams,
      requiresAuth: true,
    );

    return response;
  }

  /// Create a new lead
  Future<Map<String, dynamic>> createLead({
    required String customerName,
    required String customerPhone,
    required String propertyType,
    required String location,
    String? customerEmail,
    String? budget,
    String? notes,
    List<String>? mediaUrls,
  }) async {
    final body = <String, dynamic>{
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'property_type': propertyType,
      'location': location,
    };

    if (customerEmail != null) body['customer_email'] = customerEmail;
    if (budget != null) body['budget'] = budget;
    if (notes != null) body['notes'] = notes;
    if (mediaUrls != null && mediaUrls.isNotEmpty) {
      body['media_urls'] = mediaUrls;
    }

    final response = await _apiClient.request(
      method: 'POST',
      endpoint: ApiConstants.createLead,
      body: body,
      requiresAuth: true,
    );

    return response;
  }

  /// Get lead by ID
  Future<Map<String, dynamic>> getLeadById(String leadId) async {
    final endpoint = ApiConstants.getLeadById.replaceAll(':id', leadId);
    
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: endpoint,
      requiresAuth: true,
    );

    return response;
  }

  /// Update lead
  Future<Map<String, dynamic>> updateLead({
    required String leadId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? location,
    String? budget,
    String? notes,
  }) async {
    final endpoint = ApiConstants.updateLead.replaceAll(':id', leadId);
    final body = <String, dynamic>{};

    if (customerName != null) body['customer_name'] = customerName;
    if (customerPhone != null) body['customer_phone'] = customerPhone;
    if (customerEmail != null) body['customer_email'] = customerEmail;
    if (location != null) body['location'] = location;
    if (budget != null) body['budget'] = budget;
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      requiresAuth: true,
    );

    return response;
  }

  /// Delete lead
  Future<void> deleteLead(String leadId) async {
    final endpoint = ApiConstants.deleteLead.replaceAll(':id', leadId);
    
    await _apiClient.request(
      method: 'DELETE',
      endpoint: endpoint,
      requiresAuth: true,
    );
  }

  /// Get lead statistics
  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.request(
      method: 'GET',
      endpoint: ApiConstants.getLeadStats,
      requiresAuth: true,
    );

    return response;
  }
}
