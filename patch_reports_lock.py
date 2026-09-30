with open('d:/real_invoice/lib/features/reports/presentation/reports_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Imports
text = text.replace("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../subscription/bloc/subscription_bloc.dart';\nimport '../../subscription/presentation/subscription_screen.dart';")

# Body wrapper
old_body = """      body: BlocBuilder<ReportsBloc, ReportsState>("""

new_body = """      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, subState) {
          final hasAnalytics = subState.plan?.hasAnalytics ?? false;
          if (!hasAnalytics) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Premium Analytics Locked',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upgrade to Pro or Gold to unlock comprehensive financial insights, cash flow trends, and smart business reports.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return BlocBuilder<ReportsBloc, ReportsState>("""

text = text.replace(old_body, new_body)

# Add closing bracket for the BlocBuilder<SubscriptionBloc>
old_end = """              ],
            );
          }
        },
      ),
    );
  }
}"""
new_end = """              ],
            );
          }
        },
      );
        }
      ),
    );
  }
}"""
text = text.replace(old_end, new_end)

with open('d:/real_invoice/lib/features/reports/presentation/reports_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("ReportsScreen locked behind premium")