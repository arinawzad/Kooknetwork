import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/loading_widget.dart';
import '../tabs/edit_profile_screen.dart';
import '../tabs/project_status_screen.dart';
import '../localization/app_localizations.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.logout();
    
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }
  
  void _navigateToProjectStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectStatusScreen(),
      ),
    );
  }
  
  void _showTermsAndPolicy() {
    final localizations = AppLocalizations.of(context);
    
    Future<void> _launchUrl() async {
      final Uri url = Uri.parse('https://example.com/');
      try {
        if (!await url_launcher.launchUrl(url)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.translate('cannotOpenWebsite')),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('cannotOpenWebsite')),
            ),
          );
        }
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('termsAndPolicy')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('termsAndPolicyText'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              Text(
                localizations.translate('about'),
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.translate('aboutDescription'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              Text(
                localizations.translate('support'),
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.translate('supportText'),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _launchUrl,
                child: Text(
                  localizations.translate('websiteLink'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close')),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.translate('selectLanguage')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languageProvider.supportedLanguages.map((language) {
              final isSelected = languageProvider.locale.languageCode == language['locale'].languageCode;
              
              return ListTile(
                title: Text(language['name']),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.indigo) : null,
                onTap: () {
                  Navigator.pop(dialogContext);
                  
                  if (language['locale'].languageCode != languageProvider.locale.languageCode) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations.translate('languageChanged')} ${language['name']}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    
                    languageProvider.setLocale(language['locale']);
                    
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        final navigator = Navigator.of(context);
                        navigator.pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations.translate('cancel')),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final localizations = AppLocalizations.of(context);
    final isRtl = localizations.locale.languageCode == 'ar' || localizations.locale.languageCode == 'fa';
    final size = MediaQuery.of(context).size;
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.user;
            
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top curved container with profile info
                    Container(
                      height: size.height * 0.35,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode 
                              ? [Colors.deepPurple.shade900, Colors.indigo.shade800]
                              : [Colors.indigo.shade600, Colors.deepPurple.shade500],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.logout, color: Colors.white),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(localizations.translate('logout')),
                                          content: Text(localizations.translate('logoutConfirmation')),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(localizations.translate('cancel')),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _logout();
                                              },
                                              child: Text(
                                                localizations.translate('logout'),
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Hero(
                              tag: 'profile-image',
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        colors: [Colors.indigo.shade300, Colors.deepPurple.shade300],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _navigateToEditProfile,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Settings Cards
                          _buildSettingsCard(context),
                          
                          const SizedBox(height: 16),
                          
                          // Theme Card
                          _buildThemeCard(context),
                                                    
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final localizations = AppLocalizations.of(context);
    
    return Card(
      elevation: 5,
      shadowColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings, color: Colors.indigo),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.translate('settings'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildAnimatedSettingTile(
              title: localizations.translate('editProfile'),
              icon: Icons.person_outline,
              onTap: _navigateToEditProfile,
            ),
            _buildAnimatedSettingTile(
              title: localizations.translate('projectStatus'),
              icon: Icons.bar_chart_rounded,
              onTap: _navigateToProjectStatus,
            ),
            _buildAnimatedSettingTile(
              title: localizations.translate('language'),
              icon: Icons.translate,
              onTap: _showLanguageSelector,
            ),
            _buildAnimatedSettingTile(
              title: localizations.translate('termsAndPolicy'),
              icon: Icons.description_outlined,
              onTap: _showTermsAndPolicy,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final localizations = AppLocalizations.of(context);
    
    return Card(
      elevation: 5,
      shadowColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : themeProvider.themeMode == ThemeMode.light
                              ? Icons.light_mode
                              : Icons.brightness_auto,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.translate('themeMode'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Theme selection options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeOption(
                  context,
                  ThemeMode.system,
                  Icons.brightness_auto,
                  localizations.translate('system'),
                ),
                _buildThemeOption(
                  context,
                  ThemeMode.light,
                  Icons.light_mode,
                  localizations.translate('light'),
                ),
                _buildThemeOption(
                  context,
                  ThemeMode.dark,
                  Icons.dark_mode,
                  localizations.translate('dark'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeOption(BuildContext context, ThemeMode mode, IconData icon, String label) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isSelected = themeProvider.themeMode == mode;
    
    return GestureDetector(
      onTap: () => themeProvider.setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.indigo
              : isDarkMode 
                  ? Colors.grey.shade800 
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] 
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.white 
                  : isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : isDarkMode ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedSettingTile({
    required String title, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.indigo,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.grey.shade700,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}