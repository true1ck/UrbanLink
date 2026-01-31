import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../refer/presentation/screens/refer_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class MyLeadsScreen extends StatefulWidget {
  const MyLeadsScreen({super.key});

  @override
  State<MyLeadsScreen> createState() => _MyLeadsScreenState();
}

class _MyLeadsScreenState extends State<MyLeadsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _leads = [
    {
      'title': 'Sector 45, Gurgaon',
      'date': 'Mar 28, 2024',
      'status': 'PAID',
      'color': Colors.green,
      'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=200&h=200&fit=crop',
    },
    {
      'title': 'Whitefield, Bangalore',
      'date': 'Mar 26, 2024',
      'status': 'VERIFIED',
      'color': Colors.blue,
      'image': 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=200&h=200&fit=crop',
    },
    {
      'title': 'Powai, Mumbai',
      'date': 'Mar 25, 2024',
      'status': 'SUBMITTED',
      'color': Colors.orange,
      'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=200&h=200&fit=crop',
    },
    {
      'title': 'Koramangala, Bangalore',
      'date': 'Mar 23, 2024',
      'status': 'REJECTED',
      'color': Colors.red,
      'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=200&h=200&fit=crop',
    },
    {
      'title': 'Indiranagar, Bangalore',
      'date': 'Mar 22, 2024',
      'status': 'SUBMITTED',
      'color': Colors.orange,
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=200&h=200&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Leads',
          style: AppTheme.headingLarge.copyWith(
            fontSize: isSmallScreen ? 24 : 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.textPrimary),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('All', null),
                const SizedBox(width: 8),
                _buildFilterChip('Paid', Colors.green),
                const SizedBox(width: 8),
                _buildFilterChip('Verified', Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip('Submitted', Colors.orange),
                const SizedBox(width: 8),
                _buildFilterChip('Rejected', Colors.red),
              ],
            ),
          ),

          // Leads List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _getFilteredLeads().length,
              itemBuilder: (context, index) {
                final lead = _getFilteredLeads()[index];
                return _buildLeadCard(lead, isSmallScreen);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  List<Map<String, dynamic>> _getFilteredLeads() {
    if (_selectedFilter == 'All') return _leads;
    return _leads.where((lead) => lead['status'] == _selectedFilter.toUpperCase()).toList();
  }

  Widget _buildFilterChip(String label, Color? color) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppTheme.primaryBlue) : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Property Image
          Container(
            width: isSmallScreen ? 70 : 80,
            height: isSmallScreen ? 70 : 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(lead['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Lead Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        lead['title'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lead['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lead['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: lead['color'],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  lead['date'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', false),
              _buildNavItem(Icons.bar_chart, 'Leads', true),
              _buildNavItem(Icons.share_outlined, 'Refer', false),
              _buildNavItem(Icons.account_balance_wallet_outlined, 'Earnings', false),
              _buildNavItem(Icons.person_outline, 'Profile', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          if (label == 'Home') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (label == 'Refer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ReferScreen()),
            );
          } else if (label == 'Earnings') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EarningsScreen()),
            );
          } else if (label == 'Profile') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
