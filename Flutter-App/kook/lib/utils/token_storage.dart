import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _teamKey = 'team_data';

  // Save auth token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Save user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    
    // Also save team data separately if available
    if (user.team != null) {
      await prefs.setString(_teamKey, json.encode(user.team!.toJson()));
    }
  }

  // Get user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      try {
        final jsonData = json.decode(userData);
        
        // Check if we have team data saved separately
        final teamData = prefs.getString(_teamKey);
        if (teamData != null && jsonData['team'] == null) {
          // Add team data to user json before creating the user object
          jsonData['team'] = json.decode(teamData);
        }
        
        return User.fromJson(jsonData);
      } catch (e) {
        print('Error parsing saved user data: $e');
        return null;
      }
    }
    
    return null;
  }

  // Get just team data
  Future<Team?> getTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final teamData = prefs.getString(_teamKey);
    
    if (teamData != null) {
      try {
        return Team.fromJson(json.decode(teamData));
      } catch (e) {
        print('Error parsing saved team data: $e');
        return null;
      }
    }
    
    return null;
  }

  // Clear all auth data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_teamKey);
  }

  // For backward compatibility and compatibility with encryption implementation
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}