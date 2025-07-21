import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../localization/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Main colors
    final primaryColor = isDarkMode ? Colors.deepPurple.shade300 : Colors.deepPurple;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('editProfile'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          
          if (user == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }
          
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade100,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                                icon: Icon(
                                  Icons.camera_alt_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  // TODO: Implement profile picture update
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(localizations.translate('profilePictureUpdateSoon')),
                                      backgroundColor: primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // User name
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User email
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        context: context,
                        icon: Icons.person_outline,
                        label: localizations.translate('profile'),
                        index: 0,
                        isSelected: _currentIndex == 0,
                        primaryColor: primaryColor,
                        textColor: textColor,
                      ),
                      _buildTabButton(
                        context: context,
                        icon: Icons.email_outlined,
                        label: localizations.translate('email'),
                        index: 1,
                        isSelected: _currentIndex == 1,
                        primaryColor: primaryColor,
                        textColor: textColor,
                      ),
                      _buildTabButton(
                        context: context,
                        icon: Icons.lock_outline,
                        label: localizations.translate('password'),
                        index: 2,
                        isSelected: _currentIndex == 2,
                        primaryColor: primaryColor,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: [
                      // Profile Tab
                      _buildProfileTab(context, authProvider, user, isDarkMode, primaryColor, cardColor, textColor, localizations),
                      
                      // Email Tab
                      _buildEmailTab(context, authProvider, user, isDarkMode, primaryColor, cardColor, textColor, localizations),
                      
                      // Password Tab
                      _buildPasswordTab(context, authProvider, isDarkMode, primaryColor, cardColor, textColor, localizations),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTabButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required Color primaryColor,
    required Color textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : textColor.withOpacity(0.5),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : textColor.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(
    BuildContext context,
    AuthProvider authProvider,
    dynamic user,
    bool isDarkMode,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    AppLocalizations localizations
  ) {
    final nameController = TextEditingController(text: user.name);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('updateYourProfile'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Name Field
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('fullName'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: localizations.translate('enterName'),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      icon: Icon(Icons.person_outline, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Update Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Only proceed if name changed
                if (nameController.text != user.name) {
                  final success = await authProvider.updateProfile({
                    'name': nameController.text,
                  });
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.translate('profileUpdatedSuccess')),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                localizations.translate('updateProfile'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTab(
    BuildContext context,
    AuthProvider authProvider,
    dynamic user,
    bool isDarkMode,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    AppLocalizations localizations
  ) {
    final emailController = TextEditingController(text: user.email);
    final currentPasswordController = TextEditingController();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('updateEmailAddress'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Email Status Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: user.emailVerified 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: user.emailVerified ? Colors.green : Colors.amber,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      user.emailVerified ? Icons.verified : Icons.warning_amber_rounded,
                      color: user.emailVerified ? Colors.green : Colors.amber,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.emailVerified 
                          ? localizations.translate('emailVerified') 
                          : localizations.translate('emailNotVerified'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: user.emailVerified ? Colors.green : Colors.amber,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (!user.emailVerified) ...[
                  const SizedBox(height: 12),
                  Text(
                    localizations.translate('pleaseVerifyEmail'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await authProvider.resendVerificationEmail();
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.translate('verificationEmailSent')),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        localizations.translate('resendVerificationEmail'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Email Field
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('emailAddress'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: localizations.translate('enterEmail'),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      icon: Icon(Icons.email_outlined, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Current Password for Email Change
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('currentPassword'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: localizations.translate('enterCurrentPassword'),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      icon: Icon(Icons.lock_outline, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, top: 6),
            child: Text(
              localizations.translate('securityEnterCurrentPassword'),
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Update Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (currentPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('pleaseEnterCurrentPassword')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }
                
                if (emailController.text != user.email) {
                  final success = await authProvider.updateEmail(
                    emailController.text,
                    currentPasswordController.text,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(localizations.translate('emailUpdatedVerify')),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    currentPasswordController.clear();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                localizations.translate('updateEmail'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTab(
    BuildContext context,
    AuthProvider authProvider,
    bool isDarkMode,
    Color primaryColor,
    Color cardColor,
    Color textColor,
    AppLocalizations localizations
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('changePassword'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Info Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.blue.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade300,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.translate('passwordSecurityInfo'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Current Password
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('currentPassword'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: localizations.translate('enterCurrentPassword'),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      icon: Icon(Icons.lock_outline, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // New Password
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('newPassword'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: localizations.translate('enterNewPassword'),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      icon: Icon(Icons.lock, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, top: 6),
            child: Text(
              localizations.translate('passwordMinLength'),
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Confirm New Password
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('confirmNewPassword'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: localizations.translate('reenterNewPassword'),
                      hintStyle: TextStyle(
                        color: textColor.withOpacity(0.4),
                        fontSize: 16,
                      ),
                      icon: Icon(Icons.lock, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Update Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Validate inputs
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('fillAllFields')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }
                
                if (newPasswordController.text.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('passwordMinLength')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }
                
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('passwordsDoNotMatch')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }
                
                final success = await authProvider.updatePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('passwordUpdatedSuccess')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  // Clear fields after successful update
                  currentPasswordController.clear();
                  newPasswordController.clear();
                  confirmPasswordController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Text(
                localizations.translate('updatePassword'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}