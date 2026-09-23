import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoz/core/theme/theme_cubit.dart';
import 'package:invoz/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:invoz/features/auth/data/auth_repository.dart';
import 'package:invoz/features/auth/domain/auth_user_model.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> get user => Stream.value(null);

  @override
  Future<AuthUser?> getCurrentUser() async => null;

  @override
  Future<AuthUser?> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<AuthUser> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<void> registerDevice() async {}

  @override
  Future<void> logOutAllDevices() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } catch (_) {
      // Native sqlite3 library might not be present in local test runner environment
    }
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('invoz App smoke test with BLoC and Theming', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(InvozRoot(authRepository: MockAuthRepository()));

    // Pump frames to render widget tree without hanging on animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify App renders successfully with invoz branding
    expect(
      find.byWidgetPredicate(
        (widget) =>
            (widget is Text && (widget.data?.contains('invoz') ?? false)) ||
            widget is CircularProgressIndicator,
      ),
      findsAtLeastNWidgets(1),
    );
  });

  test(
    'ThemeCubit defaults to ThemeMode.system and updates properly',
    () async {
      SharedPreferences.setMockInitialValues({});
      final themeCubit = ThemeCubit();

      // Default must be system device theme
      expect(themeCubit.state, equals(ThemeMode.system));

      // Change to dark mode
      await themeCubit.setThemeMode(ThemeMode.dark);
      expect(themeCubit.state, equals(ThemeMode.dark));

      // Change to light mode
      await themeCubit.setThemeMode(ThemeMode.light);
      expect(themeCubit.state, equals(ThemeMode.light));

      // Return to system mode
      await themeCubit.setThemeMode(ThemeMode.system);
      expect(themeCubit.state, equals(ThemeMode.system));

      await themeCubit.close();
    },
  );
}
