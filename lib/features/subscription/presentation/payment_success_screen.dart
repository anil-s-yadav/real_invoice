import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/subscription_plan_model.dart';
import '../../navigation/main_nav_scaffold.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final SubscriptionPlanModel plan;

  const PaymentSuccessScreen({super.key, required this.plan});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format limits
    final clientsLimit = widget.plan.maxClientsAllowed == -1
        ? 'Unlimited'
        : widget.plan.maxClientsAllowed.toString();
    final docsLimit = widget.plan.maxDocumentsPerDay == -1
        ? 'Unlimited'
        : widget.plan.maxDocumentsPerDay.toString();
    final devicesLimit = widget.plan.maxDevicesAllowed == -1
        ? 'Unlimited'
        : widget.plan.maxDevicesAllowed.toString();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You have successfully unlocked the ${widget.plan.planName} plan. Enjoy your new limits and premium features!',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildLimitCard(
                      isDark: isDark,
                      icon: Icons.people_alt_rounded,
                      title: 'Clients & Items',
                      value: clientsLimit,
                    ),
                    const SizedBox(height: 12),
                    _buildLimitCard(
                      isDark: isDark,
                      icon: Icons.description_rounded,
                      title: 'Daily Documents',
                      value: docsLimit,
                    ),
                    const SizedBox(height: 12),
                    _buildLimitCard(
                      isDark: isDark,
                      icon: Icons.devices_rounded,
                      title: 'Active Devices',
                      value: devicesLimit,
                    ),
                    const SizedBox(height: 12),
                    _buildLimitCard(
                      isDark: isDark,
                      icon: Icons.star_rounded,
                      title: 'Premium Features',
                      value: 'Unlocked',
                      valueColor: AppColors.premiumGold,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () {
                        // Pop everything and go to Home
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const MainNavScaffold(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Using Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildLimitCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
