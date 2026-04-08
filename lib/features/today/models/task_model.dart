/// A single work item assigned to a client.
class Task {
  final String clientName;
  final String description;
  final int durationMinutes;
  final bool isCompleted;

  const Task({
    required this.clientName,
    required this.description,
    required this.durationMinutes,
    this.isCompleted = false,
  });

  Task copyWith({
    String? clientName,
    String? description,
    int? durationMinutes,
    bool? isCompleted,
  }) =>
      Task(
        clientName: clientName ?? this.clientName,
        description: description ?? this.description,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

/// A named time-of-day group that holds a list of [Task]s.
class TaskSection {
  final String title;
  final String emoji;
  final List<Task> tasks;

  const TaskSection({
    required this.title,
    required this.emoji,
    required this.tasks,
  });
}
