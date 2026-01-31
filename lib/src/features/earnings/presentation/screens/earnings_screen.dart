import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../leads/presentation/screens/my_leads_screen.dart';
import '../../../refer/presentation/screens/refer_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final TextEditingController _upiController = TextEditingController(text: 'yourname@bank');
  
  final List<Map<String, dynamic>> _paymentHistory = [
    {
      'title': 'Payout Transferred',
      'date': 'Mar 28, 2024',
      'id': '829103',
      'amount': '+₹1,200',
      'status': 'PAID',
      'color': Colors.green,
      'icon': Icons.check_circle,
    },
    {
      'title': 'Withdrawal Request',
      'date': 'Mar 30, 2024',
      'id': '829551',
      'amount': '₹800',
      'status': 'PENDING',
      'color': Colors.orange,
      'icon': Icons.access_time,
    },
    {
      'title': 'Payout Transferred',
      'date': 'Mar 22, 2024',
      'id': '828892',
      'amount': '+₹1,450',
      'status': 'PAID',
      'color': Colors.green,
      'icon': Icons.check_circle,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Earnings & Payouts',
          style: AppTheme.headingMedium.copyWith(
            fontSize: isSmallScreen ? 18 : 20,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.textPrimary),
            onPressed: () {
              // TODO: Show help
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
                  
                  // Total Balance Card
                  _buildBalanceCard(isSmallScreen),
                  const SizedBox(height: 24),

                  // Payment Method Section
                  _buildPaymentMethodSection(isSmallScreen),
                  const SizedBox(height: 24),

                  // Payment History Section
                  _buildPaymentHistorySection(isSmallScreen),
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

  Widget _buildBalanceCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹3,450.00',
            style: TextStyle(
              fontSize: isSmallScreen ? 40 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Withdraw to bank
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 40 : 50,
                vertical: isSmallScreen ? 14 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Withdraw to Bank',
              style: TextStyle(
                fontSize: isSmallScreen ? 15 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          const SizedBox(height: 16),
          
          // UPI ID Label
          Text(
            'UPI ID',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // UPI Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _upiController,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 14 : 16,
                  vertical: isSmallScreen ? 14 : 16,
                ),
                suffixIcon: Icon(
                  Icons.account_balance,
                  color: Colors.grey[400],
                  size: isSmallScreen ? 20 : 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Verify & Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Verify and save UPI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: AppTheme.primaryBlue,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Verify & Save',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Info Text
          Text(
            'Payouts are processed within 24-48 hours of lead verification.',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment History',
              style: AppTheme.headingMedium.copyWith(
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show filter
              },
              child: Text(
                'Filter',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Payment History Items
        ...(_paymentHistory.map((payment) => _buildPaymentHistoryItem(payment, isSmallScreen))),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(Map<String, dynamic> payment, bool isSmallScreen) {
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
          // Status Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: payment['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              payment['icon'],
              color: payment['color'],
              size: isSmallScreen ? 20 : 22,
            ),
          ),
          const SizedBox(width: 14),
          
          // Payment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['title'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment['date']} • ID: ${payment['id']}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Amount and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment['amount'],
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 17,
                  fontWeight: FontWeight.bold,
                  color: payment['status'] == 'PAID' ? Colors.green : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: payment['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment['status'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: payment['color'],
                  ),
                ),
              ),
            ],
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
              _buildNavItem(Icons.bar_chart, 'Leads', false),
              _buildNavItem(Icons.share_outlined, 'Refer', false),
              _buildNavItem(Icons.account_balance_wallet, 'Earnings', true),
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
          } else if (label == 'Leads') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyLeadsScreen()),
            );
          } else if (label == 'Refer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ReferScreen()),
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

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }
}
