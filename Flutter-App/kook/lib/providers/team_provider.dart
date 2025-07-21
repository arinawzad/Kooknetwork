// lib/providers/team_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class TeamMember {
  final int id;
  final String name;
  final bool isActive;
  final double miningRate;
  final String joinedAt;
  final String? lastActive;
  final bool isOwner;

  TeamMember({
    required this.id,
    required this.name,
    required this.isActive,
    required this.miningRate, 
    required this.joinedAt,
    this.lastActive,
    this.isOwner = false,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      isActive: json['is_active'] ?? false,
      miningRate: (json['mining_rate'] ?? 0.0).toDouble(),
      joinedAt: json['joined_at'] ?? 'Unknown',
      lastActive: json['last_active'],
      isOwner: json['name']?.toString().contains('(Team Owner)') ?? false,
    );
  }
}

class TeamProvider with ChangeNotifier {
  List<TeamMember> _teamMembers = [];
  bool _isLoading = false;
  String? _error;
  bool _isTeamOwner = false;

  List<TeamMember> get teamMembers => _teamMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTeamOwner => _isTeamOwner;

  // Stats getters
  int get totalMembers => _teamMembers.length;
  int get activeMembers => _teamMembers.where((member) => member.isActive).length;
  int get inactiveMembers => _teamMembers.where((member) => !member.isActive).length;

  // Find the current user in the team members list
  TeamMember? get currentUser {
    try {
      return _teamMembers.firstWhere((member) => member.name.contains('(You)'));
    } catch (e) {
      return null;
    }
  }

  // Find the team owner in the team members list
  TeamMember? get teamOwner {
    try {
      return _teamMembers.firstWhere((member) => member.isOwner || member.name.contains('(Team Owner)'));
    } catch (e) {
      // If there's no explicit team owner, the current user might be the owner
      return currentUser;
    }
  }

  Future<void> fetchTeamMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/team/members'),
        headers: ApiConfig.getHeaders(token: token),
      );

      debugPrint('Team members API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> membersList = responseData['data'];
          _teamMembers = membersList.map((json) => TeamMember.fromJson(json)).toList();
          
          // Check if user is team owner
          _isTeamOwner = responseData['is_owner'] ?? false;
        } else {
          _teamMembers = [];
        }
      } else if (response.statusCode == 404) {
        // API endpoint might not exist yet, use fallback sample data
        _teamMembers = _getSampleTeamMembers();
      } else {
        // Other error, use sample data but log the error
        debugPrint('Error fetching team members: ${response.statusCode}');
        _teamMembers = _getSampleTeamMembers();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching team members: $_error');
      
      // Use sample data if API fails
      _teamMembers = _getSampleTeamMembers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sample data for when API is not available
  List<TeamMember> _getSampleTeamMembers() {
    return [
      TeamMember(
        id: 1, 
        name: 'You (Team Owner)',
        isActive: true,
        miningRate: 1.14,
        joinedAt: '2 weeks ago',
        lastActive: 'Now',
        isOwner: true,
      ),
      TeamMember(
        id: 2, 
        name: 'Alex Smith',
        isActive: true,
        miningRate: 1.02,
        joinedAt: '1 week ago',
        lastActive: '2 hours ago',
      ),
      TeamMember(
        id: 3, 
        name: 'Jane Doe',
        isActive: false,
        miningRate: 1.0,
        joinedAt: '3 days ago',
        lastActive: '2 days ago',
      ),
    ];
  }
}