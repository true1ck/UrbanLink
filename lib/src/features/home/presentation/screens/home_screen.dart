import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../leads/presentation/screens/submit_lead_screen.dart';
import '../../../leads/presentation/screens/my_leads_screen.dart';
import '../../../refer/presentation/screens/refer_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _recentLeads = [
    {
      'title': 'Sector 45, Gurgaon',
      'date': 'Mar 28, 2024',
      'status': 'PAID',
      'color': Colors.green,
      'icon': Icons.apartment,
    },
    {
      'title': 'Whitefield, Bangalore',
      'date': 'Mar 26, 2024',
      'status': 'VERIFIED',
      'color': Colors.blue,
      'icon': Icons.home,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    final horizontalPadding = isSmallScreen
        ? size.width * 0.05
        : isMediumScreen
            ? size.width * 0.08
            : size.width * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Property Rewards',
          style: AppTheme.headingMedium.copyWith(
            fontSize: isSmallScreen ? 18 : 20,
            color: AppTheme.textPrimary,
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
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? 600 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Limited Time Offer Card
                  _buildOfferCard(isSmallScreen),
                  const SizedBox(height: 16),

                  // Submit a New Lead Button
                  _buildSubmitButton(isSmallScreen),
                  const SizedBox(height: 24),

                  // Stats Row
                  _buildStatsRow(isSmallScreen),
                  const SizedBox(height: 32),

                  // How it works Section
                  _buildHowItWorksSection(isSmallScreen),
                  const SizedBox(height: 32),

                  // Recent Leads Section
                  _buildRecentLeadsSection(isSmallScreen),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildOfferCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Limited Time Offer',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  'Earn ₹100',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 28 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  'For every verified \'To-Let\'\nlead you submit today.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.account_balance_wallet_outlined,
            size: isSmallScreen ? 50 : 60,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmitLeadScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 16 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: Text(
          'Submit a New Lead',
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'LEADS SUBMITTED',
            '24',
            '↑12%',
            Colors.green,
            isSmallScreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'TOTAL EARNINGS',
            '₹2,400',
            null,
            null,
            isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String? change,
    Color? changeColor,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 22 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 8),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works',
          style: AppTheme.headingMedium.copyWith(
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        const SizedBox(height: 16),
        _buildHowItWorksItem(
          Icons.photo_camera,
          'Take Photos',
          'Capture clear photos of \'To-Let\' boards and property exteriors.',
          Colors.blue,
          isSmallScreen,
        ),
        const SizedBox(height: 16),
        _buildHowItWorksItem(
          Icons.edit_note,
          'Add Details',
          'Fill in the location and contact number from the board.',
          Colors.orange,
          isSmallScreen,
        ),
        const SizedBox(height: 16),
        _buildHowItWorksItem(
          Icons.account_balance_wallet,
          'Earn Rewards',
          'Get paid directly to your wallet once the lead is verified.',
          Colors.green,
          isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildHowItWorksItem(
    IconData icon,
    String title,
    String description,
    Color color,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 22 : 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLeadsSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Leads',
              style: AppTheme.headingMedium.copyWith(
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyLeadsScreen(),
                  ),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(_recentLeads.map((lead) => _buildRecentLeadCard(lead, isSmallScreen))),
      ],
    );
  }

  Widget _buildRecentLeadCard(Map<String, dynamic> lead, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              lead['icon'],
              color: AppTheme.textSecondary,
              size: isSmallScreen ? 22 : 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead['title'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lead['date'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
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
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.bar_chart, 'Leads', false),
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
          if (label == 'Leads') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyLeadsScreen()),
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
