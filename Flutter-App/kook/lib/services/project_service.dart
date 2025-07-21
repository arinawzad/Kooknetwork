import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/project_model.dart';

class ProjectService {
  Future<List<Project>> getProjects(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/projects'),
        headers: ApiConfig.getHeaders(token: token),
      );

      // Log the raw response for debugging
      log('Get Projects Response Status Code: ${response.statusCode}');
      log('Get Projects Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseBody = json.decode(response.body);

      // Check for successful status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Validate response structure
        if (responseBody['status'] == 'success' && responseBody['data'] != null) {
          final List<dynamic> projectsJson = responseBody['data'];
          return projectsJson.map((json) => Project.fromJson(json)).toList();
        } else {
          throw Exception(responseBody['message'] ?? 'Failed to fetch projects');
        }
      } else {
        // Handle error responses
        throw Exception(responseBody['message'] ?? 'Failed to fetch projects with status ${response.statusCode}');
      }
    } catch (e) {
      log('Get Projects Error: $e');
      // Return fallback data if API fails
      return _getFallbackProjects();
    }
  }

  // Fallback projects to show when API fails
  List<Project> _getFallbackProjects() {
    // Active project
    final Project activeProject = Project(
      id: 1,
      name: 'App Development (iOS & Android)',
      status: 'In Progress',
      progress: 0.8,
      dueDate: '2025-04-30',
      priority: 'High',
      tasks: 30,
      completedTasks: 24,
      isActive: true,
    );
    
    // Future projects (coming soon)
    final List<String> upcomingProjects = [
      'KYC Verification System',
      'Wallet Integration',
      'Mainnet Launch',
      'Token Listing on Exchange',
      'Smart Contract Deployment',
      'Ecosystem Expansion',
    ];

    List<Project> projects = [activeProject];
    
    // Add upcoming projects
    for (int i = 0; i < upcomingProjects.length; i++) {
      projects.add(
        Project(
          id: i + 2,
          name: upcomingProjects[i],
          status: 'Planned',
          progress: 0.0,
          dueDate: null,
          priority: 'Medium',
          tasks: null,
          completedTasks: null,
          isActive: false,
        )
      );
    }
    
    return projects;
  }
}