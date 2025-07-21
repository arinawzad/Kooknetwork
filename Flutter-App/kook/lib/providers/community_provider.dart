// lib/providers/community_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/community_post.dart';
import '../config/api_config.dart';
import '../utils/token_storage.dart';

// Channel type enum to use in place of string types
enum ChannelType {
  telegram,
  discord,
  reddit,
  twitter,
  facebook,
  youtube,
  medium,
  github,
  link
}

class CommunityChannel {
  final int id;
  final String title;
  final String subtitle;
  final String url;
  final ChannelType type;

  CommunityChannel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.type,
  });

  factory CommunityChannel.fromJson(Map<String, dynamic> json) {
    // Convert string type to enum
    ChannelType getChannelType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'telegram':
          return ChannelType.telegram;
        case 'discord':
          return ChannelType.discord;
        case 'reddit':
          return ChannelType.reddit;
        case 'twitter':
          return ChannelType.twitter;
        case 'facebook':
          return ChannelType.facebook;
        case 'youtube':
          return ChannelType.youtube;
        case 'medium':
          return ChannelType.medium;
        case 'github':
          return ChannelType.github;
        default:
          return ChannelType.link;
      }
    }

    return CommunityChannel(
      id: json['id'],
      title: json['title'] ?? 'Unknown Channel',
      subtitle: json['subtitle'] ?? '',
      url: json['url'] ?? '',
      type: getChannelType(json['type']),
    );
  }
}

class CommunityProvider with ChangeNotifier {
  // Team stats
  Map<String, dynamic> _teamStats = {
    'members': 0,
    'active': 0,
    'inactive': 0, // Number of inactive members
    'rate': '+0%',
    'penalty': '-0%', // Penalty for inactive members
    'name': 'My Team',
    'code': '',
    'is_owner': true,
    'max_size': 1000,
    'available': 1000,
  };

  // Global network stats
  Map<String, dynamic> _globalStats = {
    'activeMiners': '0',
    'activeMinersDelta': '+0',
    'hashrate': '0 H/s',
    'hashrateDelta': '+0%',
    'totalSupply': '0 KOOK',
    'supplyPercentage': '0%',
  };

  // Community posts
  List<CommunityPost> _posts = [];

  // Community channels
  List<CommunityChannel> _channels = [];

  // Loading and error states
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic> get teamStats => _teamStats;
  Map<String, dynamic> get globalStats => _globalStats;
  List<CommunityPost> get posts => _posts;
  List<CommunityChannel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch team statistics
  Future<void> fetchTeamStats() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/community/team-stats'),
        headers: ApiConfig.getHeaders(token: token),
      );

      debugPrint('Team stats API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          _teamStats = {
            'members': responseData['data']['team_members_count'] ?? 0,
            'active': responseData['data']['active_members_count'] ?? 0,
            'inactive': responseData['data']['inactive_members_count'] ?? 0,
            'rate': responseData['data']['mining_bonus'] ?? '+0%',
            'penalty': responseData['data']['inactive_penalty'] ?? '-0%',
            'name': responseData['data']['team_name'] ?? 'My Team',
            'code': responseData['data']['invite_code'] ?? '',
            'is_owner': responseData['data']['is_owner'] ?? true,
            'max_size': responseData['data']['max_team_size'] ?? 1000,
            'available': responseData['data']['slots_available'] ?? 1000,
          };
        }
      } else {
        // If API is not available, use default data
        if (response.statusCode == 404) {
          _teamStats = {
            'members': 8,
            'active': 5,
            'inactive': 3,
            'rate': '+16%',
            'penalty': '-6%',
            'name': 'My Team',
            'code': 'KOOK-12345',
            'is_owner': true,
            'max_size': 1000,
            'available': 992,
          };
        } else {
          throw Exception('Failed to fetch team stats - Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching team stats: $e');
      // Use default data if API fails
      _teamStats = {
        'members': 8,
        'active': 5,
        'inactive': 3,
        'rate': '+16%',
        'penalty': '-6%',
        'name': 'My Team',
        'code': 'KOOK-12345',
        'is_owner': true,
        'max_size': 1000,
        'available': 992,
      };
    }
    notifyListeners();
  }

  // Fetch global network statistics
  Future<void> fetchGlobalStats() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/community/global-stats'),
        headers: ApiConfig.getHeaders(token: token),
      );

      debugPrint('Global stats API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          _globalStats = {
            'activeMiners': responseData['data']['activeMiners'] ?? '0',
            'activeMinersDelta': responseData['data']['activeMinersDelta'] ?? '+0',
            'hashrate': responseData['data']['hashrate'] ?? '0 H/s',
            'hashrateDelta': responseData['data']['hashrateDelta'] ?? '+0%',
            'totalSupply': responseData['data']['totalSupply'] ?? '0 KOOK',
            'supplyPercentage': responseData['data']['supplyPercentage'] ?? '0%',
          };
        }
      } else {
        // If API is not available, use default data
        if (response.statusCode == 404) {
          _globalStats = {
            'activeMiners': '3.2M',
            'activeMinersDelta': '+12,500 today',
            'hashrate': '142.5 PH/s',
            'hashrateDelta': '+3.2% this week',
            'totalSupply': '25.6M KOOK',
            'supplyPercentage': '58% of max supply',
          };
        } else {
          throw Exception('Failed to fetch global stats - Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching global stats: $e');
      // Use default data if API fails
      _globalStats = {
        'activeMiners': '3.2M',
        'activeMinersDelta': '+12,500 today',
        'hashrate': '142.5 PH/s',
        'hashrateDelta': '+3.2% this week',
        'totalSupply': '25.6M KOOK',
        'supplyPercentage': '58% of max supply',
      };
    }
    notifyListeners();
  }

  // Fetch community posts
  Future<void> fetchCommunityPosts() async {
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
        Uri.parse('${ApiConfig.baseUrl}/community/posts'),
        headers: ApiConfig.getHeaders(token: token),
      );

      debugPrint('Community posts API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> postList = responseData['data'];
          _posts = postList.map((postJson) => CommunityPost.fromJson(postJson)).toList();
        } else {
          _posts = [];
        }
      } else {
        // If API returns error, just set empty posts
        _posts = [];
        throw Exception('Failed to fetch community posts - Status code: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching community posts: $_error');
      // Set empty posts on error
      _posts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch community channels
  Future<void> fetchCommunityChannels() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/community/channels'),
        headers: ApiConfig.getHeaders(token: token),
      );

      debugPrint('Community channels API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> channelList = responseData['data'];
          _channels = channelList.map((channelJson) => CommunityChannel.fromJson(channelJson)).toList();
        } else {
          _channels = [];
        }
      } else {
        // If API is not available, use default data
        if (response.statusCode == 404) {
          _channels = [
            CommunityChannel(
              id: 1,
              title: 'twitter',
              subtitle: 'kooknetwork',
              url: 'https://x.com/kooknetwork',
              type: ChannelType.twitter,
            ),
            CommunityChannel(
              id: 2,
              title: 'telegram',
              subtitle: '@kooknetwork',
              url: 'https://t.me/kooknetwork',
              type: ChannelType.telegram,
            ),
            CommunityChannel(
              id: 3,
              title: 'youtube',
              subtitle: '@kooknetwork',
              url: 'https://www.youtube.com/@kooknetwork',
              type: ChannelType.youtube,
            ),
          ];
        } else {
          throw Exception('Failed to fetch community channels - Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching community channels: $e');
      // Use default data if API fails
      _channels = [
        CommunityChannel(
          id: 1,
          title: 'twitter',
          subtitle: 'kooknetwork',
          url: 'https://x.com/kooknetwork',
          type: ChannelType.twitter,
        ),
        CommunityChannel(
          id: 2,
          title: 'telegram',
          subtitle: '@kooknetwork',
          url: 'https://t.me/kooknetwork',
          type: ChannelType.telegram,
        ),
        CommunityChannel(
          id: 3,
          title: 'youtube',
          subtitle: '@kooknetwork',
          url: 'https://www.youtube.com/@kooknetwork',
          type: ChannelType.youtube,
        ),
      ];
    }
    notifyListeners();
  }

  // Generate invite code
  Future<String> generateInviteCode() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/community/invite'),
        headers: ApiConfig.getHeaders(token: token),
      );

      debugPrint('Generate invite code API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          // Update the team stats with new invite code
          if (_teamStats['code'] != responseData['data']['invite_code']) {
            _teamStats['code'] = responseData['data']['invite_code'];
            notifyListeners();
          }
          return responseData['data']['invite_code'] ?? 'KOOK-12345';
        } else {
          return 'KOOK-12345';
        }
      } else {
        // If API is not available, use default code
        return 'KOOK-12345';
      }
    } catch (e) {
      debugPrint('Error generating invite code: $e');
      return 'KOOK-12345';
    }
  }
}