/// API Configuration Constants
class ApiConstants {
  // Base URLs
  // Using 10.0.2.2 for Android emulator to access host machine's localhost
  static const String authBaseUrl = 'http://10.0.2.2:3000';
  static const String backendBaseUrl = 'http://10.0.2.2:3200';
  
  // Auth Endpoints
  static const String sendOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyToken = '/auth/verify';
  
  // User Endpoints
  static const String getUserProfile = '/users/me';
  static const String updateUserProfile = '/users/me';
  static const String getUserDevices = '/users/devices';
  static const String getAvatarSignedUrl = '/users/avatar/sign';
  static const String updateAvatar = '/users/avatar';
  
  // Leads Endpoints
  static const String getLeads = '/leads';
  static const String createLead = '/leads';
  static const String getLeadById = '/leads/:id';
  static const String updateLead = '/leads/:id';
  static const String deleteLead = '/leads/:id';
  static const String getLeadStats = '/leads/stats';
  
  // Wallet Endpoints
  static const String getWallet = '/wallet';
  static const String getTransactions = '/wallet/transactions';
  static const String getWithdrawals = '/wallet/withdrawals';
  static const String requestWithdrawal = '/wallet/withdraw';
  
  // Referrals Endpoints
  static const String getReferrals = '/referrals';
  static const String getReferralStats = '/referrals/stats';
  
  // Notifications Endpoints
  static const String getNotifications = '/notifications';
  static const String markAsRead = '/notifications/:id/read';
  static const String markAllAsRead = '/notifications/read-all';
  
  // Metadata Endpoints (Public)
  static const String getPropertyTypes = '/metadata/property-types';
  static const String getPartnerTiers = '/metadata/partner-tiers';
  static const String getLeadStatuses = '/metadata/lead-statuses';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
