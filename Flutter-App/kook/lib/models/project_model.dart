class Project {
  final int id;
  final String name;
  final String status;
  final double progress;
  final String? dueDate;
  final String priority;
  final int? tasks;
  final int? completedTasks;
  final bool isActive;
  final List<String>? team;

  Project({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    this.dueDate,
    required this.priority,
    this.tasks,
    this.completedTasks,
    required this.isActive,
    this.team,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function to safely convert to int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Parse team members if available
    List<String>? team;
    if (json['team'] is List) {
      team = (json['team'] as List).map((e) => e.toString()).toList();
    }

    return Project(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      status: json['status'] ?? 'Planned',
      progress: parseDouble(json['progress'] ?? 0.0),
      dueDate: json['due_date'],
      priority: json['priority'] ?? 'Medium',
      tasks: parseInt(json['tasks']),
      completedTasks: parseInt(json['completed_tasks']),
      isActive: json['is_active'] ?? false,
      team: team,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'progress': progress,
      'due_date': dueDate,
      'priority': priority,
      'tasks': tasks,
      'completed_tasks': completedTasks,
      'is_active': isActive,
      'team': team,
    };
  }
}