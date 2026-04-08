import '../models/task_model.dart';

/// Sample data matching the design reference.
final List<TaskSection> mockTaskSections = [
  const TaskSection(
    title: 'Morning',
    emoji: '✨',
    tasks: [
      Task(
        clientName: '@coinbase',
        description: 'design user registration process',
        durationMinutes: 50,
      ),
      Task(
        clientName: '@apple',
        description:
            'review and provide feedback on the wireframes for the new design concept',
        durationMinutes: 45,
      ),
      Task(
        clientName: '@shopify',
        description: 'mood board for the ecommerce template',
        durationMinutes: 30,
      ),
    ],
  ),
  const TaskSection(
    title: 'Afternoon',
    emoji: '☀️',
    tasks: [
      Task(
        clientName: '@apple',
        description: 'finalize color palette and typography',
        durationMinutes: 25,
      ),
      Task(
        clientName: '@insurance',
        description: 'analyze user feedback and suggest improvements',
        durationMinutes: 60,
      ),
      Task(
        clientName: '@shopify',
        description: 'evaluate two potential website layouts',
        durationMinutes: 45,
      ),
    ],
  ),
  const TaskSection(
    title: 'Evening',
    emoji: '🌙',
    tasks: [
      Task(
        clientName: '@coinbase',
        description: 'identify user pain points and propose solutions',
        durationMinutes: 45,
      ),
    ],
  ),
];
