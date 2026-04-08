// if users not already slected their goals
// users clikc open spalsh screens and see this screen to select their goals

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CaloriesHomeUnset extends StatelessWidget {
  const CaloriesHomeUnset({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.caloriesOrange.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.inputShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Warning icon di kiri
              const Icon(
                Icons.warning_amber_rounded,
                size: 28,
                color: AppColors.caloriesOrange,
              ),
              const SizedBox(width: 12),

              // Dua text sejajar di kanan
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please select your goals to get started!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You are using default calorie target. Tap to update your goals.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
