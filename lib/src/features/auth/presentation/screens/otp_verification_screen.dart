import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  int _remainingSeconds = 45;
  bool _canResend = false;

  // Developer mode: OTP "0000" will work for testing
  static const String DEV_OTP = "000000";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 45;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendOTP() {
    if (_canResend) {
      // TODO: Implement actual OTP resend logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully!')),
      );
      _startTimer();
    }
  }

  void _verifyOTP() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    // Developer mode: Accept "000000" as valid OTP
    if (otp == DEV_OTP) {
      _navigateToHome();
      return;
    }

    // TODO: Implement actual OTP verification with backend
    // For now, just show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verifying OTP: $otp')),
    );
    
    // Simulate verification
    Future.delayed(const Duration(seconds: 1), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final horizontalPadding = isSmallScreen ? size.width * 0.06 : size.width * 0.15;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width >= 1024 ? 480 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),

                // Title
                Text(
                  'Enter verification code',
                  style: AppTheme.headingLarge.copyWith(
                    fontSize: isSmallScreen ? size.width * 0.07 : 32,
                  ),
                ),
                SizedBox(height: size.height * 0.015),

                // Subtitle
                RichText(
                  text: TextSpan(
                    style: AppTheme.bodyMedium.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    children: [
                      const TextSpan(text: "We've sent a 6-digit code to "),
                      TextSpan(
                        text: '+91 ${widget.phoneNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // OTP Input Boxes
                _buildOTPInputs(isSmallScreen),
                SizedBox(height: size.height * 0.03),

                // Resend Timer
                _buildResendSection(isSmallScreen),
                SizedBox(height: size.height * 0.02),

                // Change Phone Number
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Change phone number',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.05),

                // Verify Button
                _buildVerifyButton(isSmallScreen),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPInputs(bool isSmallScreen) {
    final boxSize = isSmallScreen ? 48.0 : 56.0;
    final fontSize = isSmallScreen ? 24.0 : 28.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _otpControllers[index].text.isNotEmpty
                  ? AppTheme.primaryBlue
                  : AppTheme.inputBorder,
              width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTheme.inputText.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.access_time,
          size: isSmallScreen ? 16 : 18,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          _canResend
              ? 'Resend OTP'
              : 'Resend OTP in ${_remainingSeconds.toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
          style: AppTheme.bodyMedium.copyWith(
            fontSize: isSmallScreen ? 13 : 15,
            color: _canResend ? AppTheme.primaryBlue : AppTheme.textSecondary,
            fontWeight: _canResend ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        if (_canResend)
          TextButton(
            onPressed: _resendOTP,
            child: Text(
              'Resend',
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerifyButton(bool isSmallScreen) {
    final otp = _otpControllers.map((c) => c.text).join();
    final isComplete = otp.length == 6;

    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 50 : 56,
      child: ElevatedButton(
        onPressed: isComplete ? _verifyOTP : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verify & Continue',
              style: AppTheme.buttonText.copyWith(
                fontSize: isSmallScreen ? 15 : 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
