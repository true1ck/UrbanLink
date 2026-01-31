import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length == 10;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOTP() {
    if (_isButtonEnabled) {
      // TODO: Implement OTP sending logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    // Responsive padding
    final horizontalPadding = isSmallScreen
        ? size.width * 0.06 // 6% on mobile
        : isMediumScreen
            ? size.width * 0.15 // 15% on tablet
            : size.width * 0.25; // 25% on desktop

    // Responsive spacing
    final logoSize = isSmallScreen ? size.width * 0.18 : 72.0;
    final iconSize = isSmallScreen ? logoSize * 0.55 : 40.0;
    final verticalSpacing = size.height * 0.04;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 480 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: verticalSpacing),

                  // Logo
                  _buildLogo(logoSize, iconSize),
                  SizedBox(height: verticalSpacing * 0.8),

                  // Platform Title
                  Text(
                    'VERIFIED PROPERTY LEADS PLATFORM',
                    style: AppTheme.headingMedium.copyWith(
                      fontSize: isSmallScreen ? 11 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verticalSpacing * 0.4),

                  // Main Heading
                  Text(
                    'Login with Phone Number',
                    style: AppTheme.headingLarge.copyWith(
                      fontSize: isSmallScreen
                          ? size.width * 0.065
                          : isMediumScreen
                              ? 32
                              : 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verticalSpacing * 0.3),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? size.width * 0.02 : 0,
                    ),
                    child: Text(
                      'Earn by referring verified To-Let leads and\nhelping people find homes.',
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Phone Input
                  _buildPhoneInput(context, isSmallScreen),
                  SizedBox(height: verticalSpacing * 0.6),

                  // Send OTP Button
                  _buildSendOTPButton(context, isSmallScreen),
                  SizedBox(height: verticalSpacing * 0.4),

                  // Privacy Notice
                  _buildPrivacyNotice(context, isSmallScreen),
                  SizedBox(height: verticalSpacing * 1.5),

                  // Footer Links
                  _buildFooterLinks(context, isSmallScreen),
                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(double size, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.iconBackground,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Icon(
        Icons.home_rounded,
        size: iconSize,
        color: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = isSmallScreen ? screenWidth * 0.04 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOBILE NUMBER',
          style: AppTheme.labelText.copyWith(
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Country Code
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        'https://flagcdn.com/w40/in.png',
                        width: isSmallScreen ? 20 : 24,
                        height: isSmallScreen ? 15 : 18,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isSmallScreen ? 20 : 24,
                            height: isSmallScreen ? 15 : 18,
                            color: Colors.grey[300],
                            child: Icon(Icons.flag, size: isSmallScreen ? 10 : 12),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      '+91',
                      style: AppTheme.inputText.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: isSmallScreen ? 20 : 24,
                color: AppTheme.inputBorder,
              ),
              // Phone Number Input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: AppTheme.inputText.copyWith(fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: '98765 43210',
                    hintStyle: AppTheme.inputText.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: fontSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSendOTPButton(BuildContext context, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = isSmallScreen ? screenWidth * 0.04 : 16.0;
    final buttonHeight = isSmallScreen ? 50.0 : 56.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _isButtonEnabled ? _sendOTP : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14 : 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: isSmallScreen ? 18 : 20),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'Send OTP',
              style: AppTheme.buttonText.copyWith(fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice(BuildContext context, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = isSmallScreen ? screenWidth * 0.032 : 13.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user,
          size: isSmallScreen ? 14 : 16,
          color: AppTheme.primaryBlue,
        ),
        SizedBox(width: isSmallScreen ? 4 : 6),
        Flexible(
          child: Text(
            'Your data is encrypted and kept private',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.primaryBlue,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = isSmallScreen ? screenWidth * 0.032 : 13.0;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Navigate to Terms & Conditions
          },
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
              vertical: 4,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Terms & Conditions',
            style: AppTheme.bodySmall.copyWith(fontSize: fontSize),
          ),
        ),
        Text('•', style: AppTheme.bodySmall.copyWith(fontSize: fontSize)),
        TextButton(
          onPressed: () {
            // TODO: Navigate to Privacy Policy
          },
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 8,
              vertical: 4,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Privacy Policy',
            style: AppTheme.bodySmall.copyWith(fontSize: fontSize),
          ),
        ),
      ],
    );
  }
}
