class MacrosModel {
  final int carbs;
  final int carbsGoal;
  final int protein;
  final int proteinGoal;
  final int fat;
  final int fatGoal;

  const MacrosModel({
    required this.carbs,
    required this.carbsGoal,
    required this.protein,
    required this.proteinGoal,
    required this.fat,
    required this.fatGoal,
  });

  factory MacrosModel.initial() {
    return const MacrosModel(
      carbs: 0,
      carbsGoal: 0,
      protein: 0,
      proteinGoal: 0,
      fat: 0,
      fatGoal: 0,
    );
  }

  MacrosModel copyWith({
    int? carbs,
    int? carbsGoal,
    int? protein,
    int? proteinGoal,
    int? fat,
    int? fatGoal,
  }) {
    return MacrosModel(
      carbs: carbs ?? this.carbs,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      protein: protein ?? this.protein,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      fat: fat ?? this.fat,
      fatGoal: fatGoal ?? this.fatGoal,
    );
  }

  @override
  String toString() =>
      'MacrosModel(carbs: $carbs/$carbsGoal, protein: $protein/$proteinGoal, fat: $fat/$fatGoal)';
}
