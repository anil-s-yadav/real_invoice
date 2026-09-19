import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_invoice/core/theme/theme_cubit.dart';
import 'package:real_invoice/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RedInvoice App smoke test with BLoC and Theming', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RedInvoiceRoot());

    // Pump frames to render widget tree without hanging on animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Onboarding Screen is rendered
    expect(find.text('Regional Settings'), findsOneWidget);
    // Verify Next action button is present (it might be an icon, or just check 'Skip')
    expect(find.text('Skip'), findsOneWidget);
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
