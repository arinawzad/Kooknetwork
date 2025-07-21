import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/password/forgot'),
        body: json.encode(data),
        headers: ApiConfig.getHeaders(),
      );

      // Log the raw response for debugging
      log('Forgot Password Response Status Code: ${response.statusCode}');
      log('Forgot Password Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to send password reset link');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to send password reset link with status ${response.statusCode}');
      }
    } catch (e) {
      log('Forgot Password Error: $e');
      throw Exception(e.toString());
    }
  }

  // Reset password with token
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/password/reset'),
        body: json.encode(data),
        headers: ApiConfig.getHeaders(),
      );

      // Log the raw response for debugging
      log('Reset Password Response Status Code: ${response.statusCode}');
      log('Reset Password Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to reset password');
        }
      } else {
        // Handle validation errors
        if (responseBody.containsKey('errors') && responseBody['errors'] is Map) {
          final errorsMap = responseBody['errors'] as Map;
          if (errorsMap.isNotEmpty) {
            final firstErrorKey = errorsMap.keys.first;
            final firstErrorList = errorsMap[firstErrorKey];
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              throw Exception(firstErrorList.first);
            }
          }
        }
        
        // General error handling
        throw Exception(responseBody['message'] ?? 'Failed to reset password with status ${response.statusCode}');
      }
    } catch (e) {
      log('Reset Password Error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> loginData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        body: json.encode(loginData),
        headers: ApiConfig.getHeaders(),
      );

      // Log the raw response for debugging
      log('Login Response Status Code: ${response.statusCode}');
      log('Login Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return {
            'token': responseBody['token'],
            'user': responseBody['user'],
          };
        } else {
          throw Exception(responseBody['message'] ?? 'Login failed');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Login failed with status ${response.statusCode}');
      }
    } catch (e) {
      log('Login Error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> registrationData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        body: json.encode(registrationData),
        headers: ApiConfig.getHeaders(),
      );

      // Log the raw response for debugging
      log('Register Response Status Code: ${response.statusCode}');
      log('Register Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return {
            'token': responseBody['token'],
            'user': responseBody['user'],
          };
        } else {
          throw Exception(responseBody['message'] ?? 'Registration failed');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Registration failed with status ${response.statusCode}');
      }
    } catch (e) {
      log('Registration Error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.userUrl),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('User Profile Response Status Code: ${response.statusCode}');
      log('User Profile Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody['user'];
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to fetch user profile');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to fetch user profile with status ${response.statusCode}');
      }
    } catch (e) {
      log('Get User Profile Error: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.logoutUrl),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('Logout Response Status Code: ${response.statusCode}');
      log('Logout Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] != 'success') {
          throw Exception(responseBody['message'] ?? 'Logout failed');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Logout failed with status ${response.statusCode}');
      }
    } catch (e) {
      log('Logout Error: $e');
      throw Exception(e.toString());
    }
  }
  
  // Update profile - handles name changes
  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/profile'),
        body: json.encode(data),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('Update Profile Response Status Code: ${response.statusCode}');
      log('Update Profile Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to update profile');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to update profile with status ${response.statusCode}');
      }
    } catch (e) {
      log('Update Profile Error: $e');
      throw Exception(e.toString());
    }
  }

  // Update email with password verification
  Future<Map<String, dynamic>> updateEmail(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/email'),
        body: json.encode(data),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('Update Email Response Status Code: ${response.statusCode}');
      log('Update Email Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to update email');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to update email with status ${response.statusCode}');
      }
    } catch (e) {
      log('Update Email Error: $e');
      throw Exception(e.toString());
    }
  }

  // Update password
  Future<Map<String, dynamic>> updatePassword(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/password'),
        body: json.encode(data),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('Update Password Response Status Code: ${response.statusCode}');
      log('Update Password Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to update password');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to update password with status ${response.statusCode}');
      }
    } catch (e) {
      log('Update Password Error: $e');
      throw Exception(e.toString());
    }
  }

  // Resend email verification
  Future<Map<String, dynamic>> resendVerificationEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/email/verification-notification'),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('Resend Verification Email Response Status Code: ${response.statusCode}');
      log('Resend Verification Email Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success') {
          return responseBody;
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to resend verification email');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to resend verification email with status ${response.statusCode}');
      }
    } catch (e) {
      log('Resend Verification Email Error: $e');
      throw Exception(e.toString());
    }
  }
}