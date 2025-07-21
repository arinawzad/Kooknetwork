import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../localization/app_localizations.dart'; // Added import for localization

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key, 
    this.initialEmail = '',
    this.resetToken = '',
  });

  final String initialEmail;
  final String resetToken;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  int _currentStep = 0; // 0: Email step, 1: Token step, 2: New password step
  
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialEmail.isNotEmpty) {
      _emailController.text = widget.initialEmail;
    }
    
    if (widget.initialEmail.isNotEmpty && widget.resetToken.isNotEmpty) {
      _tokenController.text = widget.resetToken;
      _currentStep = 2; // Skip to new password step
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _backToLogin() {
    Navigator.of(context).pop();
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
  
  void _checkPasswordsMatch() {
    final newMatch = _passwordController.text == _confirmPasswordController.text;
    if (_passwordsMatch != newMatch) {
      setState(() {
        _passwordsMatch = newMatch;
      });
    }
  }
  
  Future<void> _submitForm() async {
    if (_currentStep == 2) {
      // Check if passwords match before form validation
      _checkPasswordsMatch();
      if (!_passwordsMatch && _confirmPasswordController.text.isNotEmpty) {
        return;
      }
    }
    
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
      
      bool success = false;
      
      switch (_currentStep) {
        case 0: 
          success = await authProvider.forgotPassword(
            email: _emailController.text.trim(),
          );
          if (success) {
            setState(() {
              _currentStep = 1;
            });
          }
          break;
          
        case 1:
          setState(() {
            _currentStep = 2;
          });
          break;
          
        case 2:
          success = await authProvider.resetPassword(
            email: _emailController.text.trim(),
            token: _tokenController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).translate('passwordResetSuccess')),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          break;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);
    // Check if the language is RTL
final isRtl = localizations.locale.languageCode == 'ar' || localizations.locale.languageCode == 'fa';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return LoadingOverlay(
              isLoading: authProvider.isLoading,
              message: localizations.translate('processing'),
              child: Container(
                height: screenHeight,
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
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top icon and title section
                              const Icon(
                                Icons.lock_reset,
                                size: 70,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations.translate('resetPassword'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getStepDescription(localizations),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Main content card
                              Container(
                                padding: const EdgeInsets.all(20),
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
                                child: _buildCurrentStepContent(authProvider, localizations),
                              ),
                              const SizedBox(height: 20),
                              
                              // "Remember your password?" row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    localizations.translate('rememberPassword'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: _backToLogin,
                                    child: Text(
                                      localizations.translate('login'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
  
  String _getStepDescription(AppLocalizations localizations) {
    switch (_currentStep) {
      case 0:
        return localizations.translate('resetEmailStep');
      case 1:
        return localizations.translate('resetTokenStep');
      case 2:
        return localizations.translate('resetPasswordStep');
      default:
        return '';
    }
  }
  
  Widget _buildCurrentStepContent(AuthProvider authProvider, AppLocalizations localizations) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(authProvider, localizations);
      case 1:
        return _buildTokenStep(authProvider, localizations);
      case 2:
        return _buildPasswordStep(authProvider, localizations);
      default:
        return Container();
    }
  }
  
  Widget _buildEmailStep(AuthProvider authProvider, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizations.translate('resetYourPassword'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3949AB),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate('enterRegisteredEmail'),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        
        // Error message
        if (authProvider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
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
        
        // Email field
        CustomTextField(
          label: localizations.translate('email'),
          hint: localizations.translate('enterRegisteredEmail'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.done,
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
        const SizedBox(height: 24),
        
        // Submit button
        CustomButton(
          text: localizations.translate('sendResetLink'),
          onPressed: _submitForm,
          color: const Color(0xFF3949AB),
        ),
      ],
    );
  }
  
  Widget _buildTokenStep(AuthProvider authProvider, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizations.translate('enterResetToken'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3949AB),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate('checkEmailForToken'),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        
        // Error message
        if (authProvider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
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
        
        // Email display
        CustomTextField(
          label: localizations.translate('email'),
          controller: _emailController,
          readOnly: true,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        
        // Token field
        CustomTextField(
          label: localizations.translate('resetToken'),
          hint: localizations.translate('enterTokenFromEmail'),
          controller: _tokenController,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.vpn_key_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.translate('tokenRequired');
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // Continue button
        CustomButton(
          text: localizations.translate('continue'),
          onPressed: _submitForm,
          color: const Color(0xFF3949AB),
        ),
      ],
    );
  }
  
  Widget _buildPasswordStep(AuthProvider authProvider, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizations.translate('createNewPassword'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3949AB),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate('passwordLengthHint'),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        
        // Error message
        if (authProvider.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
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
        
        // Email field (readonly)
        CustomTextField(
          label: localizations.translate('email'),
          controller: _emailController,
          readOnly: true,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        
        // Token field
        CustomTextField(
          label: localizations.translate('resetToken'),
          controller: _tokenController,
          readOnly: widget.resetToken.isNotEmpty,
          prefixIcon: Icons.vpn_key_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.translate('tokenRequired');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // New password field
        CustomTextField(
          label: localizations.translate('newPassword'),
          hint: localizations.translate('enterNewPassword'),
          controller: _passwordController,
          obscureText: !_showPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: _showPassword ? Icons.visibility_off : Icons.visibility,
          onSuffixIconPressed: _togglePasswordVisibility,
          textInputAction: TextInputAction.next,
          onChanged: (value) => _checkPasswordsMatch(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.translate('newPasswordRequired');
            }
            if (value.length < 8) {
              return localizations.translate('passwordMinLength');
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Confirm password field
        CustomTextField(
          label: localizations.translate('confirmNewPassword'),
          hint: localizations.translate('confirmNewPasswordHint'),
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
          onSuffixIconPressed: _toggleConfirmPasswordVisibility,
          onChanged: (value) => _checkPasswordsMatch(),
          errorText: !_passwordsMatch && _confirmPasswordController.text.isNotEmpty 
              ? localizations.translate('passwordsDoNotMatch') 
              : null,
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
        
        // Reset button
        CustomButton(
          text: localizations.translate('resetPassword'),
          onPressed: _submitForm,
          color: const Color(0xFF3949AB),
        ),
      ],
    );
  }
}