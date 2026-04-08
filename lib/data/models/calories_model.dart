class CaloriesModel {
  final int food;
  final int exercise;
  final int remaining;
  final int goal;

  const CaloriesModel({
    required this.food,
    required this.exercise,
    required this.remaining,
    required this.goal,
  });

  factory CaloriesModel.initial() {
    return const CaloriesModel(
      food: 0,
      exercise: 0,
      remaining: 0,
      goal: 0,
    );
  }

  CaloriesModel copyWith({
    int? food,
    int? exercise,
    int? remaining,
    int? goal,
  }) {
    return CaloriesModel(
      food: food ?? this.food,
      exercise: exercise ?? this.exercise,
      remaining: remaining ?? this.remaining,
      goal: goal ?? this.goal,
    );
  }

  @override
  String toString() =>
      'CaloriesModel(food: $food, exercise: $exercise, remaining: $remaining, goal: $goal)';
}
