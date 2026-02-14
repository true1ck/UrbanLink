import 'package:flutter/material.dart';
import '../../../../core/service_locator.dart';
import '../../../../core/services/api_client.dart';

/// Example screen showing how to use backend services
/// This demonstrates best practices for API integration
class ExampleApiUsageScreen extends StatefulWidget {
  const ExampleApiUsageScreen({super.key});

  @override
  State<ExampleApiUsageScreen> createState() => _ExampleApiUsageScreenState();
}

class _ExampleApiUsageScreenState extends State<ExampleApiUsageScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  List<dynamic> _leads = [];
  Map<String, dynamic>? _wallet;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load all data from backend
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load user profile
      await _loadUserProfile();
      
      // Load leads
      await _loadLeads();
      
      // Load wallet
      await _loadWallet();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Example: Get user profile
  Future<void> _loadUserProfile() async {
    try {
      final userService = ServiceLocator().user;
      final profile = await userService.getProfile();
      
      setState(() {
        _userData = profile;
      });
      
      print('User loaded: ${profile['name']}');
    } on ApiException catch (e) {
      print('API Error: ${e.message}');
      rethrow;
    }
  }

  /// Example: Get leads list
  Future<void> _loadLeads() async {
    try {
      final leadsService = ServiceLocator().leads;
      final response = await leadsService.getLeads(
        page: 1,
        limit: 10,
      );
      
      setState(() {
        _leads = response['leads'] ?? [];
      });
      
      print('Loaded ${_leads.length} leads');
    } on ApiException catch (e) {
      print('API Error: ${e.message}');
      rethrow;
    }
  }

  /// Example: Get wallet balance
  Future<void> _loadWallet() async {
    try {
      final walletService = ServiceLocator().wallet;
      final wallet = await walletService.getWallet();
      
      setState(() {
        _wallet = wallet;
      });
      
      print('Wallet balance: ₹${wallet['balance']}');
    } on ApiException catch (e) {
      print('API Error: ${e.message}');
      rethrow;
    }
  }

  /// Example: Create a new lead
  Future<void> _createLead() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final leadsService = ServiceLocator().leads;
      final lead = await leadsService.createLead(
        customerName: 'John Doe',
        customerPhone: '9876543210',
        propertyType: 'apartment',
        location: 'Mumbai, Maharashtra',
        budget: '50-75 Lakhs',
        notes: 'Looking for 2BHK near metro station',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lead created: ${lead['id']}'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload leads
      await _loadLeads();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Example: Update user profile
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = ServiceLocator().user;
      await userService.updateProfile(
        name: 'Updated Name',
        email: 'newemail@example.com',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload profile
      await _loadUserProfile();
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Example: Logout
  Future<void> _logout() async {
    try {
      await ServiceLocator().auth.logout();
      
      if (!mounted) return;
      
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Usage Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // User Profile Section
                      if (_userData != null) ...[
                        const Text(
                          'User Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${_userData!['name']}'),
                                Text('Phone: ${_userData!['phone_number']}'),
                                Text('Email: ${_userData!['email'] ?? 'N/A'}'),
                                if (_userData!['tier'] != null)
                                  Text('Tier: ${_userData!['tier']['name']}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('Update Profile'),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Wallet Section
                      if (_wallet != null) ...[
                        const Text(
                          'Wallet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Balance: ₹${_wallet!['balance']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Total Earnings: ₹${_wallet!['total_earnings']}'),
                                Text('Pending: ₹${_wallet!['pending_amount']}'),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Leads Section
                      const Text(
                        'Leads',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _createLead,
                        child: const Text('Create New Lead'),
                      ),
                      const SizedBox(height: 8),
                      if (_leads.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No leads yet'),
                          ),
                        )
                      else
                        ..._leads.map((lead) => Card(
                              child: ListTile(
                                title: Text(lead['customer_name'] ?? 'N/A'),
                                subtitle: Text(lead['location'] ?? 'N/A'),
                                trailing: Chip(
                                  label: Text(lead['status'] ?? 'N/A'),
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }
}
