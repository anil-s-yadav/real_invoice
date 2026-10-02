import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/business_profile/bloc/business_profile_bloc.dart';
import 'features/business_profile/bloc/business_profile_event.dart';
import 'features/business_profile/data/business_profile_repository.dart';
import 'features/customers/bloc/customer_bloc.dart';
import 'features/customers/bloc/customer_event.dart';
import 'features/customers/data/customer_repository.dart';
import 'features/documents/bloc/document_bloc.dart';
import 'features/documents/bloc/document_event.dart';
import 'features/documents/data/document_repository.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/bloc/home_event.dart';
import 'features/navigation/main_nav_scaffold.dart';
import 'features/products/bloc/product_bloc.dart';
import 'features/products/bloc/product_event.dart';
import 'features/products/data/product_repository.dart';
import 'features/reports/bloc/reports_bloc.dart';
import 'features/subscriptions/bloc/subscription_bloc.dart';
import 'features/onboarding/bloc/onboarding_cubit.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:ui'; // Added for PlatformDispatcher

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Dart errors and show them on screen instead of crashing silently
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("FlutterError: ${details.exception}");
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("PlatformError: $error");
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "App Error:\n${details.exception}\n\nStacktrace:\n${details.stack}",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  };

  Bloc.observer = AppBlocObserver();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  // Fire-and-forget: don't await MobileAds init so native crash won't block app
  try {
    MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("MobileAds init failed: $e");
  }

  try {
    // Explicitly enable offline persistence and unlimited cache size
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firestore settings failed: $e");
  }

  runApp(const InvozRoot());
}

class InvozRoot extends StatelessWidget {
  final AuthRepository? authRepository;

  const InvozRoot({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => authRepository ?? FirebaseAuthRepository(),
        ),
        RepositoryProvider(create: (_) => BusinessProfileRepository()),
        RepositoryProvider(create: (_) => CustomerRepository()),
        RepositoryProvider(create: (_) => ProductRepository()),
        RepositoryProvider(create: (_) => DocumentRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (ctx) => BusinessProfileBloc(
              repository: ctx.read<BusinessProfileRepository>(),
            )..add(const LoadBusinessProfileEvent()),
          ),
          BlocProvider(
            create: (ctx) =>
                CustomerBloc(repository: ctx.read<CustomerRepository>())
                  ..add(const LoadCustomersEvent()),
          ),
          BlocProvider(
            create: (ctx) =>
                ProductBloc(repository: ctx.read<ProductRepository>())
                  ..add(const LoadProductsEvent()),
          ),
          BlocProvider(
            create: (ctx) =>
                DocumentBloc(repository: ctx.read<DocumentRepository>())
                  ..add(const LoadDocumentsEvent()),
          ),
          BlocProvider(
            create: (ctx) => HomeBloc(
              documentRepository: ctx.read<DocumentRepository>(),
              businessProfileRepository: ctx.read<BusinessProfileRepository>(),
            )..add(const LoadHomeDataEvent()),
          ),
          BlocProvider(
            create: (ctx) =>
                AuthBloc(authRepository: ctx.read<AuthRepository>())
                  ..add(const AppStartedEvent()),
          ),
          BlocProvider(
            create: (_) =>
                SubscriptionBloc()..add(const ObserveSubscriptionEvent()),
          ),
          BlocProvider(
            create: (ctx) =>
                ReportsBloc(documentRepository: ctx.read<DocumentRepository>()),
          ),
          BlocProvider(create: (_) => OnboardingCubit()),
        ],
        child: const InvozApp(),
      ),
    );
  }
}

class InvozApp extends StatelessWidget {
  const InvozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return BlocBuilder<OnboardingCubit, bool>(
              builder: (context, hasCompletedOnboarding) {
                Widget homeWidget;
                if (authState is AuthInitial || authState is AuthLoading) {
                  homeWidget = Scaffold(
                    backgroundColor: themeMode == ThemeMode.dark
                        ? const Color(0xFF0F172A)
                        : Colors.white,
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/applogo.png',
                            width: 140,
                            height: 140,
                          ),
                          const SizedBox(height: 32),
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F46E5), // Indigo / AppColors.primary
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Setting up your workspace...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: themeMode == ThemeMode.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (authState is Authenticated) {
                  homeWidget = hasCompletedOnboarding
                      ? const MainNavScaffold()
                      : const OnboardingScreen();
                } else {
                  homeWidget = const SignInScreen();
                }

                return MaterialApp(
                  title: 'invoz',
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  home: homeWidget,
                );
              },
            );
          },
        );
      },
    );
  }
}
