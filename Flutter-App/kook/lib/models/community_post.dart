// lib/models/community_post.dart

class CommunityPost {
  final int id;
  final String username;
  final String? userAvatar;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;
  final bool isOfficial;
  final bool isLiked;

  CommunityPost({
    required this.id,
    required this.username,
    this.userAvatar,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    this.isOfficial = false,
    this.isLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      username: json['username'] ?? 'Unknown User',
      userAvatar: json['user_avatar'],
      timeAgo: _formatTimeAgo(json['created_at']),
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isOfficial: json['is_official'] == 1,
      isLiked: json['is_liked'] == 1,
    );
  }

  // Copy with method for updating post
  CommunityPost copyWith({
    int? id,
    String? username,
    String? userAvatar,
    String? timeAgo,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    bool? isOfficial,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isOfficial: isOfficial ?? this.isOfficial,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Helper method to format time
  static String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    DateTime postTime;
    try {
      if (timestamp is String) {
        postTime = DateTime.parse(timestamp);
      } else {
        // Assume it's an integer timestamp
        postTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    } catch (e) {
      return 'Recently';
    }
    
    final difference = DateTime.now().difference(postTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}