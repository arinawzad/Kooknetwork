// lib/models/task.dart

enum TaskActionType {
  url,      // External link (Telegram, Twitter, etc.)
  video,    // Watch video
  inApp,    // In-app action
  simple    // Simple toggle task
}

class Task {
  final int id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final double reward;
  final bool isCompleted;
  final TaskActionType actionType;
  final String? actionData; // URL, video link, or other data needed for the action
  final String? verificationCode; // Optional verification code for admin use

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.reward,
    required this.isCompleted,
    required this.actionType,
    this.actionData,
    this.verificationCode,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Parse task action type from string
    TaskActionType parseActionType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'url':
          return TaskActionType.url;
        case 'video':
          return TaskActionType.video;
        case 'in_app':
          return TaskActionType.inApp;
        case 'simple':
          return TaskActionType.simple;
        default:
          return TaskActionType.simple;
      }
    }

    // Handle different types of completion status values
    bool parseCompletionStatus(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    // Debug parsing
    // print('Parsing task: ${json['title']} with status: ${json['is_completed']}');

    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date']) 
          : DateTime.now().add(const Duration(days: 7)),
      reward: json['reward'] != null 
          ? double.parse(json['reward'].toString()) 
          : 0.0,
      isCompleted: parseCompletionStatus(json['is_completed']),  // Use the helper function
      actionType: parseActionType(json['action_type']),
      actionData: json['action_data'],
      verificationCode: json['verification_code'],
    );
  }

  // Create a copy of this Task with updated fields
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    double? reward,
    bool? isCompleted,
    TaskActionType? actionType,
    String? actionData,
    String? verificationCode,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }
}