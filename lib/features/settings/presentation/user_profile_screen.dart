import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text(
              'Guest User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            const Text(
              'Sign in to sync your data across devices.',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
            AppCard(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_sync,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const Text(
                    'Cloud Sync & Backup',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  const Text(
                    'Login functionality is coming soon. Once available, you will be able to securely backup your invoices and access them from any device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login functionality coming soon!'),
                          ),
                        );
                      },
                      child: const Text('Sign In / Register'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
