import 'package:equatable/equatable.dart';

class SubTask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final String status; // TODO, IN_PROGRESS, COMPLETED
  final String priority; // LOW, MEDIUM, HIGH
  final String category; // WORK, PERSONAL, HR_COMPLIANCE, MEETING, OTHER
  final DateTime? dueDate;
  final DateTime? completedAt;
  final bool isCompleted;
  final List<SubTask> subtasks;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.category = 'WORK',
    this.dueDate,
    this.completedAt,
    this.isCompleted = false,
    this.subtasks = const [],
  });

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year && dueDate!.month == now.month && dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final dueDayStart = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDayStart.isBefore(todayStart);
  }

  bool get isUpcoming {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dueDate!.isAfter(todayEnd);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? category,
    DateTime? dueDate,
    DateTime? completedAt,
    bool? isCompleted,
    List<SubTask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] ?? 'TODO';
    final completedBool = json['isCompleted'] ?? (statusStr == 'COMPLETED');

    final subtasksList = (json['subtasks'] as List<dynamic>?)
            ?.map((s) => SubTask.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return Task(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: statusStr,
      priority: json['priority'] ?? 'MEDIUM',
      category: json['category'] ?? 'WORK',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
      isCompleted: completedBool,
      subtasks: subtasksList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'category': category,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, status, isCompleted, priority, category, dueDate, subtasks];
}
