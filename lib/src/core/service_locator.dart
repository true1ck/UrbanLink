import 'services/storage_service.dart';
import 'services/api_client.dart';
import 'services/device_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/leads_service.dart';
import 'services/wallet_service.dart';
import 'services/referrals_service.dart';
import 'services/notifications_service.dart';
import 'services/metadata_service.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Core services
  late final StorageService _storageService;
  late final ApiClient _apiClient;
  late final DeviceService _deviceService;

  // Feature services
  late final AuthService _authService;
  late final UserService _userService;
  late final LeadsService _leadsService;
  late final WalletService _walletService;
  late final ReferralsService _referralsService;
  late final NotificationsService _notificationsService;
  late final MetadataService _metadataService;

  bool _initialized = false;

  /// Initialize all services
  Future<void> init() async {
    if (_initialized) return;

    // Initialize storage first
    _storageService = StorageService();
    await _storageService.init();

    // Initialize API client and device service
    _apiClient = ApiClient(_storageService);
    _deviceService = DeviceService(_storageService);

    // Initialize feature services
    _authService = AuthService(_apiClient, _storageService, _deviceService);
    _userService = UserService(_apiClient);
    _leadsService = LeadsService(_apiClient);
    _walletService = WalletService(_apiClient);
    _referralsService = ReferralsService(_apiClient);
    _notificationsService = NotificationsService(_apiClient);
    _metadataService = MetadataService(_apiClient);

    _initialized = true;
  }

  // Getters for services
  StorageService get storage {
    _checkInitialized();
    return _storageService;
  }

  ApiClient get apiClient {
    _checkInitialized();
    return _apiClient;
  }

  DeviceService get device {
    _checkInitialized();
    return _deviceService;
  }

  AuthService get auth {
    _checkInitialized();
    return _authService;
  }

  UserService get user {
    _checkInitialized();
    return _userService;
  }

  LeadsService get leads {
    _checkInitialized();
    return _leadsService;
  }

  WalletService get wallet {
    _checkInitialized();
    return _walletService;
  }

  ReferralsService get referrals {
    _checkInitialized();
    return _referralsService;
  }

  NotificationsService get notifications {
    _checkInitialized();
    return _notificationsService;
  }

  MetadataService get metadata {
    _checkInitialized();
    return _metadataService;
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw Exception('ServiceLocator not initialized. Call init() first.');
    }
  }

  /// Dispose all services
  void dispose() {
    if (_initialized) {
      _apiClient.dispose();
      _initialized = false;
    }
  }
}
