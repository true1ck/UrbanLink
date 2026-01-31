import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import 'my_leads_screen.dart';

class SubmitLeadScreen extends StatefulWidget {
  const SubmitLeadScreen({super.key});

  @override
  State<SubmitLeadScreen> createState() => _SubmitLeadScreenState();
}

class _SubmitLeadScreenState extends State<SubmitLeadScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  
  XFile? _propertyFacadePhoto;
  XFile? _toLetBoardPhoto;
  String? _photoError;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentStep == 0 ? 'Add Property Photos' : 
          _currentStep == 1 ? 'Location Capture' :
          _currentStep == 2 ? 'Property Details' : 'Review',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.textPrimary,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textSecondary),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(isSmallScreen),
          
          // Content
          Expanded(
            child: _buildStepContent(isSmallScreen),
          ),
          
          // Bottom Button
          _buildBottomButton(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStepCircle(0, 'Photos', isSmallScreen),
          _buildProgressLine(0),
          _buildStepCircle(1, 'Location', isSmallScreen),
          _buildProgressLine(1),
          _buildStepCircle(2, 'Details', isSmallScreen),
          _buildProgressLine(2),
          _buildStepCircle(3, 'Review', isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isSmallScreen) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? AppTheme.primaryBlue
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive || isCompleted ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = step < _currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 28),
        color: isCompleted ? AppTheme.primaryBlue : Colors.grey[200],
      ),
    );
  }

  Widget _buildStepContent(bool isSmallScreen) {
    switch (_currentStep) {
      case 0:
        return _buildPhotosStep(isSmallScreen);
      case 1:
        return _buildLocationStep(isSmallScreen);
      case 2:
        return _buildDetailsStep(isSmallScreen);
      case 3:
        return _buildReviewStep(isSmallScreen);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhotosStep(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Capture Evidence',
            style: AppTheme.headingLarge.copyWith(
              fontSize: isSmallScreen ? 26 : 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clear photos speed up your reward verification.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          const SizedBox(height: 24),

          // Pro Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PRO-TIP: AVOID DIRECT GLARE ON BOARDS',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Photo Error Message
          if (_photoError != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photo is too blurry.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade900,
                          ),
                        ),
                        Text(
                          'Please ensure text is readable.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _photoError = null;
                        _propertyFacadePhoto = null;
                        _toLetBoardPhoto = null;
                      });
                    },
                    child: Text(
                      'Redo',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Required Photos Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Required Photos',
                style: AppTheme.headingMedium.copyWith(
                  fontSize: isSmallScreen ? 15 : 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(_propertyFacadePhoto != null ? 1 : 0) + (_toLetBoardPhoto != null ? 1 : 0)}/2 ADDED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photo Upload Cards
          Row(
            children: [
              Expanded(
                child: _buildPhotoUploadCard(
                  title: 'Property Facade',
                  subtitle: 'Wide angle',
                  icon: Icons.camera_alt,
                  photo: _propertyFacadePhoto,
                  onTap: () => _pickImage(true),
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPhotoUploadCard(
                  title: 'To-Let Board',
                  subtitle: 'Close up',
                  icon: Icons.center_focus_strong,
                  photo: _toLetBoardPhoto,
                  onTap: () => _pickImage(false),
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Additional Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Details',
                        style: AppTheme.headingMedium.copyWith(
                          fontSize: isSmallScreen ? 14 : 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'House numbers, nearby landmarks, etc.',
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryBlue,
                  onPressed: () {
                    // TODO: Add more photos
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quality Check Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 20,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI-assisted quality check will run automatically upon upload.',
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: isSmallScreen ? 12 : 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required XFile? photo,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isSmallScreen ? 160 : 180,
        decoration: BoxDecoration(
          color: photo != null ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: photo != null ? Colors.green : Colors.grey[300]!,
            width: 2,
            style: photo != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (photo != null)
              Icon(Icons.check_circle, color: Colors.green, size: 40)
            else
              Icon(icon, color: AppTheme.primaryBlue, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(bool isSmallScreen) {
    final size = MediaQuery.of(context).size;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    // Responsive sizing
    final horizontalPadding = isSmallScreen
        ? size.width * 0.06
        : isMediumScreen
            ? size.width * 0.08
            : size.width * 0.1;

    final mapHeight = isSmallScreen
        ? size.height * 0.25
        : isMediumScreen
            ? size.height * 0.28
            : size.height * 0.3;

    final verticalSpacing = size.height * 0.02;
    final fontSize = isSmallScreen ? size.width * 0.037 : 14.0;
    final labelFontSize = isSmallScreen ? 11.0 : 12.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalSpacing,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 600 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Preview
              Container(
                height: mapHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Map placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                      child: Container(
                        color: const Color(0xFFB8D4E8),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryBlue,
                                  size: isSmallScreen ? 28 : 36,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 10 : 12,
                                  vertical: isSmallScreen ? 4 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'APPLE MAPS',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 9 : 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),

              // Location detected
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location,
                        size: iconSize,
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Flexible(
                        child: Text(
                          'Location detected automatically',
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: fontSize,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Edit location
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12,
                        vertical: isSmallScreen ? 4 : 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Edit location',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing * 1.2),

              // City Dropdown
              Text(
                'CITY',
                style: AppTheme.labelText.copyWith(
                  fontSize: labelFontSize,
                  color: AppTheme.textSecondary,
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
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 14 : 16,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  hint: Text(
                    'Select City',
                    style: AppTheme.inputText.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: fontSize,
                    ),
                  ),
                  style: AppTheme.inputText.copyWith(fontSize: fontSize),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  items: ['Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad']
                      .map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ))
                      .toList(),
                  onChanged: (value) {
                    // TODO: Handle city selection
                  },
                ),
              ),
              SizedBox(height: verticalSpacing * 1.2),

              // Locality/Area Input
              Text(
                'LOCALITY / AREA',
                style: AppTheme.labelText.copyWith(
                  fontSize: labelFontSize,
                  color: AppTheme.textSecondary,
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
                child: TextField(
                  style: AppTheme.inputText.copyWith(fontSize: fontSize),
                  decoration: InputDecoration(
                    hintText: 'e.g., MG Road',
                    hintStyle: AppTheme.inputText.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: fontSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 14 : 16,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 1.2),

              // Info message
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade100,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: iconSize,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 12),
                    Expanded(
                      child: Text(
                        'Accurate location helps faster verification and payout.',
                        style: TextStyle(
                          fontSize: fontSize * 0.93,
                          color: Colors.blue.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep(bool isSmallScreen) {
    final size = MediaQuery.of(context).size;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    // Responsive sizing
    final horizontalPadding = isSmallScreen
        ? size.width * 0.06
        : isMediumScreen
            ? size.width * 0.08
            : size.width * 0.1;

    final verticalSpacing = size.height * 0.02;
    final fontSize = isSmallScreen ? size.width * 0.037 : 14.0;
    final headingFontSize = isSmallScreen ? size.width * 0.04 : 16.0;
    final labelFontSize = isSmallScreen ? 11.0 : 12.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalSpacing,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 600 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Property Details',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: isSmallScreen ? 26 : 30,
                ),
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                'Step 3 of 4: Classify the lead',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: fontSize,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),

              // Purpose Section
              _buildSectionHeader(
                'Purpose',
                'Why is this needed?',
                isSmallScreen,
                fontSize,
                headingFontSize,
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
              _buildPurposeToggle(isSmallScreen, fontSize),
              SizedBox(height: verticalSpacing * 1.5),

              // Property Type Section
              _buildSectionHeader(
                'Property Type',
                'Help me choose',
                isSmallScreen,
                fontSize,
                headingFontSize,
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
              _buildPropertyTypeGrid(isSmallScreen, fontSize),
              SizedBox(height: verticalSpacing * 1.5),

              // Dynamic content based on property type
              _buildDynamicPropertyFields(isSmallScreen, fontSize, headingFontSize, verticalSpacing),

              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String linkText,
    bool isSmallScreen,
    double fontSize,
    double headingFontSize,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // TODO: Show help dialog
          },
          icon: Icon(
            Icons.help_outline,
            size: isSmallScreen ? 16 : 18,
          ),
          label: Text(
            linkText,
            style: TextStyle(fontSize: fontSize * 0.93),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 12,
              vertical: isSmallScreen ? 4 : 8,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  String _selectedPurpose = 'Rent';
  String _selectedPropertyType = 'Flat';
  String _selectedBHK = '2 BHK';
  int _numberOfFlats = 1;

  Widget _buildPurposeToggle(bool isSmallScreen, double fontSize) {
    return Row(
      children: [
        Expanded(
          child: _buildToggleButton(
            'Rent',
            _selectedPurpose == 'Rent',
            () => setState(() => _selectedPurpose = 'Rent'),
            isSmallScreen,
            fontSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToggleButton(
            'Sale',
            _selectedPurpose == 'Sale',
            () => setState(() => _selectedPurpose = 'Sale'),
            isSmallScreen,
            fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
    bool isSmallScreen,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 14 : 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTypeGrid(bool isSmallScreen, double fontSize) {
    final types = [
      {'name': 'Flat', 'icon': Icons.apartment, 'color': Colors.blue},
      {'name': 'House', 'icon': Icons.home, 'color': Colors.orange},
      {'name': 'PG / Hostel', 'icon': Icons.bed, 'color': Colors.purple},
      {'name': 'Commercial', 'icon': Icons.store, 'color': Colors.green},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isSmallScreen ? 1.1 : 1.2,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = _selectedPropertyType == type['name'];
        return _buildPropertyTypeCard(
          type['name'] as String,
          type['icon'] as IconData,
          type['color'] as Color,
          isSelected,
          isSmallScreen,
          fontSize,
        );
      },
    );
  }

  Widget _buildPropertyTypeCard(
    String name,
    IconData icon,
    Color color,
    bool isSelected,
    bool isSmallScreen,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPropertyType = name),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 28 : 32,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicPropertyFields(
    bool isSmallScreen,
    double fontSize,
    double headingFontSize,
    double verticalSpacing,
  ) {
    if (_selectedPropertyType == 'Flat') {
      return _buildFlatFields(isSmallScreen, fontSize, headingFontSize, verticalSpacing);
    } else if (_selectedPropertyType == 'House') {
      return _buildHouseFields(isSmallScreen, fontSize, headingFontSize, verticalSpacing);
    } else if (_selectedPropertyType == 'PG / Hostel') {
      return _buildPGFields(isSmallScreen, fontSize, headingFontSize, verticalSpacing);
    } else if (_selectedPropertyType == 'Commercial') {
      return _buildCommercialFields(isSmallScreen, fontSize, headingFontSize, verticalSpacing);
    }
    return const SizedBox();
  }

  Widget _buildFlatFields(bool isSmallScreen, double fontSize, double headingFontSize, double verticalSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BHK Configuration
        Text(
          'BHK Configuration',
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1 BHK', '2 BHK', '3 BHK', '4+ BHK'].map((bhk) {
            final isSelected = _selectedBHK == bhk;
            return GestureDetector(
              onTap: () => setState(() => _selectedBHK = bhk),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 18 : 24,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  bhk,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: verticalSpacing * 1.5),

        // Units available
        Text(
          'Units available',
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 6),
        Text(
          'In this building',
          style: TextStyle(
            fontSize: fontSize * 0.9,
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.apartment, color: AppTheme.primaryBlue, size: isSmallScreen ? 20 : 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Number of flats',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_numberOfFlats > 1) {
                    setState(() => _numberOfFlats--);
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: AppTheme.textSecondary,
              ),
              Text(
                '$_numberOfFlats',
                style: TextStyle(
                  fontSize: fontSize * 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _numberOfFlats++),
                icon: const Icon(Icons.add_circle),
                color: AppTheme.primaryBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHouseFields(bool isSmallScreen, double fontSize, double headingFontSize, double verticalSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BHK Configuration',
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['1 BHK', '2 BHK', '3 BHK', '4+ BHK'].map((bhk) {
            final isSelected = _selectedBHK == bhk;
            return GestureDetector(
              onTap: () => setState(() => _selectedBHK = bhk),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 18 : 24,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  bhk,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPGFields(bool isSmallScreen, double fontSize, double headingFontSize, double verticalSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rooms or beds available',
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: AppTheme.inputText.copyWith(fontSize: fontSize),
            decoration: InputDecoration(
              hintText: 'Enter quantity',
              hintStyle: AppTheme.inputText.copyWith(
                color: AppTheme.textTertiary,
                fontSize: fontSize,
              ),
              prefixIcon: Icon(Icons.bed, size: isSmallScreen ? 20 : 24),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 14 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 10),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Approximate count is fine',
              style: TextStyle(
                fontSize: fontSize * 0.9,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommercialFields(bool isSmallScreen, double fontSize, double headingFontSize, double verticalSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Space Type
        Text(
          'Space Type',
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 14 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
            hint: Text(
              'Select type',
              style: AppTheme.inputText.copyWith(
                color: AppTheme.textTertiary,
                fontSize: fontSize,
              ),
            ),
            items: ['Office', 'Shop', 'Warehouse', 'Showroom']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
        ),
        SizedBox(height: verticalSpacing * 1.5),

        // Approximate Area
        Text(
          'Approximate Area',
          style: AppTheme.headingMedium.copyWith(
            fontSize: headingFontSize,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: AppTheme.inputText.copyWith(fontSize: fontSize),
            decoration: InputDecoration(
              hintText: 'Enter area size',
              hintStyle: AppTheme.inputText.copyWith(
                color: AppTheme.textTertiary,
                fontSize: fontSize,
              ),
              suffixText: 'sq ft',
              suffixStyle: TextStyle(
                fontSize: fontSize,
                color: AppTheme.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 14 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildReviewStep(bool isSmallScreen) {
    final size = MediaQuery.of(context).size;
    final isMediumScreen = size.width >= 600 && size.width < 1024;
    final isLargeScreen = size.width >= 1024;

    final horizontalPadding = isSmallScreen
        ? size.width * 0.06
        : isMediumScreen
            ? size.width * 0.08
            : size.width * 0.1;

    final verticalSpacing = size.height * 0.02;
    final fontSize = isSmallScreen ? size.width * 0.037 : 14.0;
    final headingFontSize = isSmallScreen ? size.width * 0.04 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalSpacing,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 600 : double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Step 4: Final Review',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: isSmallScreen ? 24 : 28,
                ),
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                'Please verify all information before submitting your lead.',
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: fontSize,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),

              // Photos Section
              _buildReviewSection(
                'Photos (4)',
                Icons.edit,
                isSmallScreen,
                fontSize,
                headingFontSize,
                child: SizedBox(
                  height: isSmallScreen ? 80 : 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        width: isSmallScreen ? 80 : 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=200&h=200&fit=crop',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 1.2),

              // Property Location
              _buildReviewSection(
                'PROPERTY LOCATION',
                Icons.edit,
                isSmallScreen,
                fontSize,
                headingFontSize,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1248 Oakwood Ave, Austin, TX 78704',
                      style: TextStyle(
                        fontSize: headingFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    Container(
                      height: isSmallScreen ? 120 : 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8D4E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          color: AppTheme.primaryBlue,
                          size: isSmallScreen ? 32 : 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing * 1.2),

              // Property Details
              _buildReviewSection(
                'PROPERTY DETAILS',
                Icons.edit,
                isSmallScreen,
                fontSize,
                headingFontSize,
                child: Column(
                  children: [
                    _buildDetailRow('Property Type', 'Apartment (2BHK)', fontSize),
                    const SizedBox(height: 12),
                    _buildDetailRow('Monthly Rent', '\$1,850/mo', fontSize),
                    const SizedBox(height: 12),
                    _buildDetailRow('Availability', 'Immediate', fontSize),
                    const SizedBox(height: 12),
                    _buildDetailRow('Commission Rate', '5% of Rent', fontSize),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing * 1.2),

              // Payout Details
              _buildReviewSection(
                'PAYOUT DETAILS',
                Icons.edit,
                isSmallScreen,
                fontSize,
                headingFontSize,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: isSmallScreen ? 18 : 20,
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'UPI ID for Reward',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹100',
                          style: TextStyle(
                            fontSize: headingFontSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'user@upi',
                      style: TextStyle(
                        fontSize: headingFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Instant payout upon verification',
                          style: TextStyle(
                            fontSize: fontSize * 0.9,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),

              // Declarations
              Text(
                'Declarations',
                style: AppTheme.headingMedium.copyWith(
                  fontSize: headingFontSize,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: isSmallScreen ? 10 : 12),
              _buildCheckbox(
                'I declare that all information provided is accurate and truthful.',
                fontSize,
              ),
              const SizedBox(height: 12),
              _buildCheckbox(
                'I confirm the UPI ID provided above is correct for receiving my ₹100 reward.',
                fontSize,
              ),
              const SizedBox(height: 12),
              _buildCheckbox(
                'I agree to the Terms of Service and Privacy Policy.',
                fontSize,
              ),
              SizedBox(height: verticalSpacing * 1.5),

              // Info Banner
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Colors.blue.shade700,
                      size: isSmallScreen ? 18 : 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verified leads receive ₹100 within 24-48 hours.',
                        style: TextStyle(
                          fontSize: fontSize * 0.93,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection(
    String title,
    IconData editIcon,
    bool isSmallScreen,
    double fontSize,
    double headingFontSize, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize * 0.85,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate back to edit
              },
              icon: Icon(editIcon, size: 16),
              label: Text(
                'Edit',
                style: TextStyle(fontSize: fontSize * 0.93),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  bool _declaration1 = false;
  bool _declaration2 = false;
  bool _declaration3 = false;

  Widget _buildCheckbox(String text, double fontSize) {
    bool isChecked = false;
    if (text.contains('accurate')) isChecked = _declaration1;
    if (text.contains('UPI')) isChecked = _declaration2;
    if (text.contains('Terms')) isChecked = _declaration3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              if (text.contains('accurate')) _declaration1 = value ?? false;
              if (text.contains('UPI')) _declaration2 = value ?? false;
              if (text.contains('Terms')) _declaration3 = value ?? false;
            });
          },
          activeColor: AppTheme.primaryBlue,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(bool isSmallScreen) {
    bool canProceed = false;
    
    if (_currentStep == 0) {
      canProceed = _propertyFacadePhoto != null && _toLetBoardPhoto != null;
    } else if (_currentStep == 3) {
      canProceed = _declaration1 && _declaration2 && _declaration3;
    } else {
      canProceed = true;
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 52 : 56,
        child: ElevatedButton(
          onPressed: canProceed ? _nextStep : null,
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
                _currentStep == 3 ? 'Submit Lead' : 'Next',
                style: AppTheme.buttonText.copyWith(
                  fontSize: isSmallScreen ? 15 : 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(bool isPropertyFacade) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isPropertyFacade) {
            _propertyFacadePhoto = image;
          } else {
            _toLetBoardPhoto = image;
          }
          _photoError = null;
        });

        // Simulate quality check
        await Future.delayed(const Duration(seconds: 1));
        
        // Randomly show error for demo (remove in production)
        // if (DateTime.now().second % 3 == 0) {
        //   setState(() {
        //     _photoError = 'Quality check failed';
        //   });
        // }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Submit lead and navigate to My Leads
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyLeadsScreen(),
        ),
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Tips'),
        content: const Text(
          '• Ensure good lighting\n'
          '• Keep text readable\n'
          '• Avoid glare and shadows\n'
          '• Take photos from straight angle\n'
          '• Include full board in frame',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}


