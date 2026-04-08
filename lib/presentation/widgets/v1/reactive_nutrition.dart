import 'package:bitelog/presentation/viewmodels/v1/nutrition_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReactiveNutrition extends StatelessWidget {
  const ReactiveNutrition({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionViewmodel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            Text("Calories: ${vm.calories}"),
            Text('Carbs: ${vm.carbs}'),
            Text('Protein: ${vm.protein}'),
            Text('Fat: ${vm.fat}'),
          ],
        );
      },
    );
  }
}