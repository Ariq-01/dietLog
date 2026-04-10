/// Daily nutrition stats for calories and macros tracking.
/// All fields are final — data comes from ViewModel/Repository.
class DailyStats {
  // Calories
  final int caloriesFood;
  final int caloriesExercise;
  final int caloriesRemaining;
  final int caloriesTarget;

  // Macros
  final int carbsCurrent;
  final int carbsTarget;
  final int proteinCurrent;
  final int proteinTarget;
  final int fatCurrent;
  final int fatTarget;

  const DailyStats({
    this.caloriesFood = 0,
    this.caloriesExercise = 0,
    required this.caloriesRemaining,
    this.caloriesTarget = 2000,
    this.carbsCurrent = 0,
    this.carbsTarget = 250,
    this.proteinCurrent = 0,
    this.proteinTarget = 125,
    this.fatCurrent = 0,
    this.fatTarget = 56,
  });

  /// Factory for empty/default stats
  factory DailyStats.empty() => const DailyStats(
        caloriesRemaining: 2000,
      );
}
