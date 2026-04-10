import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: const [
              Spacer(),
              LoginHeader(),
              Spacer(flex: 2),
              LoginButtons(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TODO: Replace with your app logo
        // Image.asset('assets/logo.png', width: 80, height: 80),
        // OR use an Icon/Image.asset for your logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.activeDayBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Track your meals\n& reach your goals',
          textAlign: TextAlign.center,
          style: AppTextStyles.displayTitle.copyWith(
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class LoginButtons extends StatelessWidget {
  const LoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(
          icon: const Icon(Icons.apple, size: 20, color: AppColors.textPrimary),
          text: 'Continue with Apple',
          onPressed: () {
            // TODO: Implement Apple Sign In
          },
        ),
        const SizedBox(height: 12),
        SocialLoginButton(
          icon: Image.asset(
            'assets/google_logo.png',
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.g_mobiledata,
                size: 24,
                color: AppColors.textPrimary,
              );
            },
          ),
          text: 'Continue with Google',
          onPressed: () {
            // TODO: Implement Google Sign In
          },
        ),
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
