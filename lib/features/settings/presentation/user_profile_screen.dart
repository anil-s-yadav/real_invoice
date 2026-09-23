import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/domain/auth_user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          AuthUser? user;
          if (state is Authenticated) {
            user = state.user;
          }

          final String displayName = user?.displayName ?? 'Guest User';
          final String email =
              user?.email ?? 'Sign in to sync your data across devices.';
          final String? photoUrl = user?.photoUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              children: [
                // Profile Avatar with CachedNetworkImage
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: photoUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  email,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.xxl),

                // Account Info Card
                if (user != null)
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        _buildInfoRow(
                            Icons.person_outline, 'Name', displayName),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.email_outlined, 'Email', email),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.fingerprint, 'User ID', user.id),
                      ],
                    ),
                  ),

                const SizedBox(height: AppDimensions.lg),

                // Device Management Card
                if (user != null)
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.devices, color: AppColors.primary),
                            SizedBox(width: 12),
                            Text(
                              'Device Management',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        const Text(
                          'Manage the devices logged into your account.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .collection('devices')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            
                            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text('No devices found.', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                              );
                            }

                            final devices = snapshot.data!.docs;

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: devices.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final data = devices[index].data() as Map<String, dynamic>;
                                
                                // Format device model name nicely
                                String modelName = data['deviceModel'] as String? ?? 'Unknown Device';
                                
                                final platform = data['platform'] as String? ?? '';
                                final platformIcon = platform.toLowerCase() == 'ios' 
                                    ? Icons.phone_iphone
                                    : Icons.android;

                                // Format timestamp
                                String lastActiveStr = 'Unknown';
                                if (data['lastActive'] != null) {
                                  try {
                                    final dt = (data['lastActive'] as Timestamp).toDate();
                                    lastActiveStr = DateFormat('MMM d, yyyy - h:mm a').format(dt);
                                  } catch (_) {}
                                }

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.canvas,
                                    child: Icon(platformIcon, color: AppColors.textPrimary, size: 20),
                                  ),
                                  title: Text(
                                    modelName,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Last active: $lastActiveStr',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showLogOutAllDevicesConfirmation(context),
                            icon: const Icon(Icons.logout, color: Colors.orange),
                            label: const Text('Log Out All Devices', style: TextStyle(color: Colors.orange)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orange),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppDimensions.lg),

                // Cloud Sync Card
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
                        'Your business profile, invoices, products, and customers will automatically sync with the cloud to keep them safe.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      if (user != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showLogoutConfirmation(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red.withValues(alpha: 0.1),
                              foregroundColor: Colors.red,
                              elevation: 0,
                            ),
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const SignOutRequestedEvent());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLogOutAllDevicesConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out All Devices'),
        content: const Text(
            'This will sign you out from all devices currently logged into your account. Are you sure you want to proceed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogOutAllDevicesRequestedEvent());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Log Out All'),
          ),
        ],
      ),
    );
  }
}
