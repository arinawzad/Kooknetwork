// lib/models/community_channel.dart

import 'package:flutter/material.dart';

class CommunityChannel {
  final int id;
  final String title;
  final String subtitle;
  final String url;
  final IconData icon;
  final Color color;

  CommunityChannel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.icon,
    required this.color,
  });

  factory CommunityChannel.fromJson(Map<String, dynamic> json) {
    // Map channel type to icon and color
    IconData getIconForType(String type) {
      switch (type.toLowerCase()) {
        case 'telegram':
          return Icons.telegram;
        case 'discord':
          return Icons.discord;
        case 'reddit':
          return Icons.reddit;
        case 'twitter':
          return Icons.send;
        case 'facebook':
          return Icons.facebook;
        case 'youtube':
          return Icons.play_circle;
        case 'medium':
          return Icons.article;
        case 'github':
          return Icons.code;
        default:
          return Icons.link;
      }
    }

    Color getColorForType(String type) {
      switch (type.toLowerCase()) {
        case 'telegram':
          return const Color(0xFF0088CC);
        case 'discord':
          return const Color(0xFF5865F2);
        case 'reddit':
          return const Color(0xFFFF4500);
        case 'twitter':
          return const Color(0xFF1DA1F2);
        case 'facebook':
          return const Color(0xFF1877F2);
        case 'youtube':
          return const Color(0xFFFF0000);
        case 'medium':
          return const Color(0xFF000000);
        case 'github':
          return const Color(0xFF333333);
        default:
          return Colors.indigo;
      }
    }

    final type = json['type'] ?? 'link';

    return CommunityChannel(
      id: json['id'],
      title: json['title'] ?? 'Unknown Channel',
      subtitle: json['subtitle'] ?? '',
      url: json['url'] ?? '',
      icon: getIconForType(type),
      color: getColorForType(type),
    );
  }
}