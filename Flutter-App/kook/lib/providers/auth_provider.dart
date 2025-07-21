import 'package:flutter/foundation.dart';
import 'dart:developer';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Private method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Private method to set error message
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Forgot Password method
  Future<bool> forgotPassword({
    required String email,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final data = {
        'email': email,
      };

      // Attempt to send password reset link
      final response = await _authService.forgotPassword(data);

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to send reset link');
      }

      _setLoading(false);
      return true;
    } catch (e) {
      log('Forgot Password Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Reset Password method
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final data = {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      // Attempt to reset password
      final response = await _authService.resetPassword(data);

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to reset password');
      }

      _setLoading(false);
      return true;
    } catch (e) {
      log('Reset Password Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Login method
  Future<bool> login({
    required String email, 
    required String password
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final loginData = {
        'email': email,
        'password': password,
      };

      // Attempt login
      final response = await _authService.login(loginData);

      // Extract user and token
      final token = response['token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw Exception('Invalid login response');
      }

      // Save token
      await _tokenStorage.saveToken(token);

      // Create user from response
      _user = User.fromJson(userData);

      // Save user data
      await _tokenStorage.saveUser(_user!);

      _setLoading(false);
      return true;
    } catch (e) {
      log('Login Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String name,
    required String email, 
    required String password,
    required String passwordConfirmation,
    String? teamCode,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final registerData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      // Add team code if provided
      if (teamCode != null && teamCode.isNotEmpty) {
        registerData['team_code'] = teamCode;
      }

      // Attempt registration
      final response = await _authService.register(registerData);

      // Extract user and token
      final token = response['token'];
      final userData = response['user'];

      if (token == null || userData == null) {
        throw Exception('Invalid registration response');
      }

      // Save token
      await _tokenStorage.saveToken(token);

      // Create user from response
      _user = User.fromJson(userData);

      // Save user data
      await _tokenStorage.saveUser(_user!);

      _setLoading(false);
      return true;
    } catch (e) {
      log('Registration Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Check authentication status
  Future<bool> checkAuth() async {
    _setLoading(true);

    try {
      // Try to get stored token
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        _setLoading(false);
        return false;
      }

      // Try to get cached user
      final cachedUser = await _tokenStorage.getUser();
      if (cachedUser != null) {
        _user = cachedUser;
      }

      // Fetch latest user profile
      try {
        final userData = await _authService.getUserProfile(token);
        _user = User.fromJson(userData);
        await _tokenStorage.saveUser(_user!);
      } catch (e) {
        // If server fetch fails but we have cached data, still consider user logged in
        if (_user == null) {
          rethrow;
        }
      }

      _setLoading(false);
      return true;
    } catch (e) {
      log('Auth Check Error: $e');
      // Clear token and user on failure
      await _tokenStorage.clearAll();
      _user = null;
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Logout method
  Future<bool> logout() async {
    _setLoading(true);

    try {
      // Get current token
      final token = await _tokenStorage.getToken();
      
      if (token != null) {
        // Attempt server logout
        await _authService.logout(token);
      }

      // Clear local data
      await _tokenStorage.clearAll();
      _user = null;

      _setLoading(false);
      return true;
    } catch (e) {
      log('Logout Error: $e');
      // Even if server logout fails, clear local data
      await _tokenStorage.clearAll();
      _user = null;
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return true;
    }
  }
  
  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Send update request
      final response = await _authService.updateProfile(token, data);
      
      // Update local user
      if (response['status'] == 'success' && response['user'] != null) {
        _user = User.fromJson(response['user']);
        await _tokenStorage.saveUser(_user!);
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      log('Profile Update Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Update user email
  Future<bool> updateEmail(String email, String currentPassword) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Prepare data
      final data = {
        'email': email,
        'password': currentPassword
      };
      
      // Send update request
      final response = await _authService.updateEmail(token, data);
      
      // Update local user
      if (response['status'] == 'success' && response['user'] != null) {
        _user = User.fromJson(response['user']);
        await _tokenStorage.saveUser(_user!);
      } else {
        throw Exception(response['message'] ?? 'Failed to update email');
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      log('Email Update Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Update user password
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Prepare data
      final data = {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword
      };
      
      // Send update request
      final response = await _authService.updatePassword(token, data);
      
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to update password');
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      log('Password Update Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Resend email verification
  Future<bool> resendVerificationEmail() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Send request
      final response = await _authService.resendVerificationEmail(token);
      
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to resend verification email');
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      log('Resend Verification Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
      return false;
    }
  }

  // Error parsing helper
  String _parseErrorMessage(Object error) {
    String errorMessage = error.toString();

    // Remove verbose error prefixes
    if (errorMessage.contains('Exception: ')) {
      errorMessage = errorMessage.replaceFirst('Exception: ', '');
    }

    // Handle specific error scenarios
    if (errorMessage.contains('type cast') || 
        errorMessage.contains('Invalid data')) {
      return 'Invalid data received from server';
    }

    if (errorMessage.contains('401') || 
        errorMessage.contains('Unauthorized')) {
      return 'Invalid credentials';
    }

    if (errorMessage.contains('network') || 
        errorMessage.contains('connection')) {
      return 'Network error. Please check your connection';
    }

    // Fallback error message
    return errorMessage.isNotEmpty 
      ? errorMessage 
      : 'An unexpected error occurred';
  }
}