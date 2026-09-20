import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize SQLite FFI for desktop platforms and test environments
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const RedInvoiceRoot());
}

class RedInvoiceRoot extends StatelessWidget {
  const RedInvoiceRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),
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
                SubscriptionBloc()..add(const CheckSubscriptionStatusEvent()),
          ),
          BlocProvider(
            create: (ctx) =>
                ReportsBloc(documentRepository: ctx.read<DocumentRepository>()),
          ),
          BlocProvider(create: (_) => OnboardingCubit()),
        ],
        child: const RedInvoiceApp(),
      ),
    );
  }
}

class RedInvoiceApp extends StatelessWidget {
  const RedInvoiceApp({super.key});

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
                  homeWidget = const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (authState is Authenticated) {
                  homeWidget = hasCompletedOnboarding
                      ? const MainNavScaffold()
                      : const OnboardingScreen();
                } else {
                  homeWidget = const SignInScreen();
                }

                return MaterialApp(
                  title: 'RedInvoice',
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
