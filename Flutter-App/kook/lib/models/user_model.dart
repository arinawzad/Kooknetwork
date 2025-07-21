class User {
  final int id;
  final String name;
  final String email;
  final String createdAt;
  final String updatedAt;
  final double? kookBalance;
  final double? miningRate;
  final String? lastActiveAt;
  final int? teamId;
  final bool isTeamOwner;
  final Team? team;
  final bool emailVerified;
  final String? emailVerifiedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.kookBalance,
    this.miningRate,
    this.lastActiveAt,
    this.teamId,
    this.isTeamOwner = false,
    this.team,
    this.emailVerified = false,
    this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper function to safely convert to int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      
      // Handle balance with flexible parsing
      kookBalance: parseDouble(json['balance'] ?? json['kook_balance']),
      
      // Handle mining rate with flexible parsing
      miningRate: parseDouble(json['mining_rate']),
      
      lastActiveAt: json['last_active_at'],
      
      // Handle team ID with flexible parsing
teamId: json['team'] != null ? parseInt(json['team']['id']) : parseInt(json['team_id']),
      
      isTeamOwner: json['is_team_owner'] ?? false,
      
      // Handle team creation safely
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
      
      // Handle email verification
      emailVerified: json['email_verified_at'] != null,
      emailVerifiedAt: json['email_verified_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'balance': kookBalance,
      'mining_rate': miningRate,
      'last_active_at': lastActiveAt,
      'team_id': teamId,
      'is_team_owner': isTeamOwner,
      'team': team?.toJson(),
      'email_verified_at': emailVerifiedAt,
    };
  }
  
  // Add copyWith method for easy model updates
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? createdAt,
    String? updatedAt,
    double? kookBalance,
    double? miningRate,
    String? lastActiveAt,
    int? teamId,
    bool? isTeamOwner,
    Team? team,
    bool? emailVerified,
    String? emailVerifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kookBalance: kookBalance ?? this.kookBalance,
      miningRate: miningRate ?? this.miningRate,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      teamId: teamId ?? this.teamId,
      isTeamOwner: isTeamOwner ?? this.isTeamOwner,
      team: team ?? this.team,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }
}

class Team {
  final int id;
  final String name;
  final String code;
  final int ownerId;
  final int memberCount;
  final int activeCount;
  final double miningRate;
  final double totalMined;
  final String createdAt;
  final String updatedAt;

  Team({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    required this.memberCount,
    required this.activeCount,
    required this.miningRate,
    required this.totalMined,
    required this.createdAt,
    required this.updatedAt,
  });

 factory Team.fromJson(Map<String, dynamic> json) {
  // Helper function to safely convert to double
  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }
  
  // Helper function to safely convert to int
  int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  return Team(
    id: parseInt(json['id']),
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    ownerId: parseInt(json['owner_id']),
    memberCount: parseInt(json['members_count'] ?? json['member_count'] ?? 0),
    activeCount: parseInt(json['active_count'] ?? 0),
    miningRate: parseDouble(json['mining_rate']),
    totalMined: parseDouble(json['total_mined'] ?? 0),
    createdAt: json['created_at'] ?? '',
    updatedAt: json['updated_at'] ?? '',
  );
}
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'owner_id': ownerId,
      'member_count': memberCount,
      'active_count': activeCount,
      'mining_rate': miningRate,
      'total_mined': totalMined,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  
  // Add copyWith method for easy model updates
  Team copyWith({
    int? id,
    String? name,
    String? code,
    int? ownerId,
    int? memberCount,
    int? activeCount,
    double? miningRate,
    double? totalMined,
    String? createdAt,
    String? updatedAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      ownerId: ownerId ?? this.ownerId,
      memberCount: memberCount ?? this.memberCount,
      activeCount: activeCount ?? this.activeCount,
      miningRate: miningRate ?? this.miningRate,
      totalMined: totalMined ?? this.totalMined,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}