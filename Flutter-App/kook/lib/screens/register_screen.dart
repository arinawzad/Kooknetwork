import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../localization/app_localizations.dart'; // Added localization import
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _teamCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _teamCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final localizations = AppLocalizations.of(context);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        teamCode: _teamCodeController.text.trim(),
      );

      if (success && mounted) {
        // Navigate to home screen
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

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    // Handle RTL for Arabic and Persian
    final isRtl = localizations.locale.languageCode == 'ar' || localizations.locale.languageCode == 'fa';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('register')),
          backgroundColor: Colors.indigo,
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              message: localizations.translate('processing'),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            localizations.translate('joinToday'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.translate('fillDetailsCreateAccount'),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),

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
                            const SizedBox(height: 20),

                          // Name Field
                          CustomTextField(
                            label: localizations.translate('fullName'),
                            hint: localizations.translate('enterFullName'),
                            controller: _nameController,
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate('nameRequired');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

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
                          const SizedBox(height: 16),

                          // Team Code Field
                          CustomTextField(
                            label: localizations.translate('teamCodeOptional'),
                            hint: localizations.translate('enterTeamCode'),
                            controller: _teamCodeController,
                            prefixIcon: Icons.people_outline,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              // Team code is optional, but if provided should be 8 characters
                              if (value != null && value.isNotEmpty && value.length != 8) {
                                return localizations.translate('teamCodeLength');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          
                          // Team Code Explanation
                          Text(
                            localizations.translate('teamCodeExplanation'),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Password Field
                          CustomTextField(
                            label: localizations.translate('password'),
                            hint: localizations.translate('enterYourPassword'),
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _showPassword ? Icons.visibility_off : Icons.visibility,
                            onSuffixIconPressed: _togglePasswordVisibility,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate('passwordRequired');
                              }
                              if (value.length < 8) {
                                return localizations.translate('passwordMinLength');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          CustomTextField(
                            label: localizations.translate('confirmPassword'),
                            hint: localizations.translate('confirmPasswordHint'),
                            controller: _confirmPasswordController,
                            obscureText: !_showConfirmPassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            onSuffixIconPressed: _toggleConfirmPasswordVisibility,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate('confirmPasswordRequired');
                              }
                              if (value != _passwordController.text) {
                                return localizations.translate('passwordsDoNotMatch');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          CustomButton(
                            text: localizations.translate('createAccount'),
                            onPressed: _register,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 16),

                          // Terms & Conditions
                          Text(
                            localizations.translate('termsConditionsAgreement'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
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