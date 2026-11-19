class WorkNote {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String assignedRole; // 'lead', 'developer', 'qa'
  final String authorName;
  final String status; // 'todo', 'in_progress', 'ready_for_qa', 'done'
  final String priority; // 'Rendah', 'Sedang', 'Tinggi', 'Kritis'
  final String gitBranch;
  final String createdAt;

  WorkNote({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.assignedRole,
    required this.authorName,
    required this.status,
    required this.priority,
    required this.gitBranch,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'assigned_role': assignedRole,
      'author_name': authorName,
      'status': status,
      'priority': priority,
      'git_branch': gitBranch,
      'created_at': createdAt,
    };
  }

  factory WorkNote.fromMap(Map<String, dynamic> map) {
    return WorkNote(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Fitur Baru',
      assignedRole: map['assigned_role'] as String? ?? 'developer',
      authorName: map['author_name'] as String? ?? 'Tim IT',
      status: map['status'] as String? ?? 'todo',
      priority: map['priority'] as String? ?? 'Sedang',
      gitBranch: map['git_branch'] as String? ?? 'main',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  WorkNote copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? assignedRole,
    String? authorName,
    String? status,
    String? priority,
    String? gitBranch,
    String? createdAt,
  }) {
    return WorkNote(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      assignedRole: assignedRole ?? this.assignedRole,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      gitBranch: gitBranch ?? this.gitBranch,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

