import 'dart:io';


class ApiConfig {
  // Base URL - change this to your Laravel API server
  // For emulator use 10.0.2.2 instead of localhost
  static const String baseUrl = 'https://example.com/api';
  
  // Auth endpoints
  static const String loginUrl = '$baseUrl/login';
  static const String registerUrl = '$baseUrl/register';
  static const String logoutUrl = '$baseUrl/logout';
  static const String userUrl = '$baseUrl/user';
  
  // Version-related endpoints
  static const String versionCheckUrl = '$baseUrl/version/check';
  
  // App version (update this manually when releasing new versions)
  static const String appVersion = '1.0.0';
  
  // App platform
  static String get platform {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }
  
  // Request headers
  static Map<String, String> getHeaders({String? token}) {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}