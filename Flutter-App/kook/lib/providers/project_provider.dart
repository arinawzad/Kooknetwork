import 'package:flutter/foundation.dart';
import 'dart:developer';

import '../models/project_model.dart';
import '../services/project_service.dart';
import '../utils/token_storage.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ProjectService _projectService = ProjectService();
  final TokenStorage _tokenStorage = TokenStorage();

  // Getters
  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get active projects
  List<Project> get activeProjects => _projects.where((p) => p.isActive).toList();
  
  // Get upcoming projects
  List<Project> get upcomingProjects => _projects.where((p) => !p.isActive).toList();

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

  // Fetch projects
  Future<void> fetchProjects() async {
    _setLoading(true);
    _setError(null);

    try {
      // Get auth token
      final token = await _tokenStorage.getToken();
      
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      // Get projects from API
      _projects = await _projectService.getProjects(token);
      
      _setLoading(false);
    } catch (e) {
      log('Fetch Projects Error: $e');
      _setLoading(false);
      _setError(_parseErrorMessage(e));
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
      return 'Authentication required';
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