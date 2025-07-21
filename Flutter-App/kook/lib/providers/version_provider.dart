// lib/providers/version_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VersionInfo {
  final String currentVersion;
  final String minimumVersion;
  final String latestVersion;
  final bool needsUpdate;
  final bool hasNewVersion;
  final String? updateUrl;
  final String? updateMessage;
  final bool forceUpdate;

  VersionInfo({
    required this.currentVersion,
    required this.minimumVersion,
    required this.latestVersion,
    required this.needsUpdate,
    required this.hasNewVersion,
    this.updateUrl,
    this.updateMessage,
    required this.forceUpdate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      currentVersion: json['current_version'],
      minimumVersion: json['minimum_version'],
      latestVersion: json['latest_version'],
      needsUpdate: json['needs_update'] ?? false,
      hasNewVersion: json['has_new_version'] ?? false,
      updateUrl: json['update_url'],
      updateMessage: json['update_message'],
      forceUpdate: json['force_update'] ?? false,
    );
  }
}

class VersionProvider extends ChangeNotifier {
  VersionInfo? _versionInfo;
  bool _isLoading = false;
  String? _error;

  VersionInfo? get versionInfo => _versionInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get needsUpdate => _versionInfo?.needsUpdate ?? false;
  bool get hasNewVersion => _versionInfo?.hasNewVersion ?? false;
  bool get forceUpdate => _versionInfo?.forceUpdate ?? false;

  // Check if app needs update
  Future<bool> checkVersion() async {
    try {
      _isLoading = true;
      // Don't call notifyListeners() here as it might be in build phase
      
      // Use static version
      const currentVersion = '1.0.0';
      final platform = _getPlatform();
      
      final response = await http.get(
        Uri.parse('https://example.com/api/version/check?current_version=$currentVersion&platform=$platform'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == true && data['data'] != null) {
          _versionInfo = VersionInfo.fromJson(data['data']);
          _isLoading = false;
          notifyListeners();
          return _versionInfo?.needsUpdate ?? false;
        } else {
          _error = 'Invalid response format';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error checking version: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get platform helper
  String _getPlatform() {
    // Use dart:io to check platform directly
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }

  // Open app store to update
  Future<bool> openUpdateUrl(String? url) async {
    if (url == null) return false;
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _error = 'Could not launch update URL';
      notifyListeners();
      return false;
    }
  }
}