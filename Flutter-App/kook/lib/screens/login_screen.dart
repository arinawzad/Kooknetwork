import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../localization/app_localizations.dart';
import 'register_screen.dart';
import 'Forgot_Screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      final navigator = Navigator.of(context);
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
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
  
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenHeight < 600 || screenWidth < 350;
    
    final localizations = AppLocalizations.of(context);
    final isRtl = localizations.locale.languageCode == 'ar' || localizations.locale.languageCode == 'fa';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('login')),
          backgroundColor: const Color(0xFF3949AB),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _showLanguageSelector,
              tooltip: localizations.translate('selectLanguage'),
            ),
          ],
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              message: localizations.translate('loggingIn'),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3949AB), // Indigo
                      Color(0xFF5E35B1), // Deep Purple
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom - kToolbarHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16.0 : 24.0, 
                          vertical: isSmallScreen ? 12.0 : 24.0
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // App Logo and Name section (smaller for small screens)
                              Column(
                                children: [
                                  SizedBox(height: isSmallScreen ? 10 : 20),
                                  Icon(
                                    Icons.monetization_on,
                                    size: isSmallScreen ? 50 : 70,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: isSmallScreen ? 5 : 10),
                                  Text(
                                    localizations.translate('appName'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 28 : 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 2 : 5),
                                  Text(
                                    localizations.translate('appTagline'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallScreen ? 10 : 20),
                              
                              // Login Card
                              Container(
                                padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      localizations.translate('welcomeBack'),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF3949AB),
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4 : 8),
                                    Text(
                                      localizations.translate('signInToContinue'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 12 : 20),
                                    
                                    // Error message if any
                                    if (authProvider.errorMessage != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: TextStyle(color: Colors.red.shade700),
                                        ),
                                      ),
                                    
                                    if (authProvider.errorMessage != null)
                                      SizedBox(height: isSmallScreen ? 12 : 20),
                                    
                                    // Email Field
                                    CustomTextField(
                                      label: localizations.translate('email'),
                                      hint: localizations.translate('enterYourEmail'),
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email_outlined,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return localizations.translate('emailRequired');
                                        }
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                          return localizations.translate('invalidEmail');
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: isSmallScreen ? 12 : 16),
                                    
                                    // Password Field
                                    CustomTextField(
                                      label: localizations.translate('password'),
                                      hint: localizations.translate('enterYourPassword'),
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: _showPassword ? Icons.visibility_off : Icons.visibility,
                                      onSuffixIconPressed: _togglePasswordVisibility,
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return localizations.translate('passwordRequired');
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: isSmallScreen ? 15 : 20),
                                    
                                    // Login Button
                                    CustomButton(
                                      text: localizations.translate('login'),
                                      onPressed: _login,
                                      color: const Color(0xFF3949AB),
                                    ),

                                    // Forgot Password Link
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isSmallScreen ? 4 : 8,
                                            horizontal: isSmallScreen ? 8 : 12,
                                          ),
                                        ),
                                        child: Text(
                                          localizations.translate('forgotPassword'),
                                          style: const TextStyle(
                                            color: Color(0xFF3949AB),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Register Link
                              Padding(
                                padding: EdgeInsets.only(
                                  top: isSmallScreen ? 10 : 16, 
                                  bottom: isSmallScreen ? 5 : 10
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      localizations.translate('noAccount'),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isSmallScreen ? 4 : 8,
                                          horizontal: isSmallScreen ? 8 : 12,
                                        ),
                                      ),
                                      child: Text(
                                        localizations.translate('register'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}