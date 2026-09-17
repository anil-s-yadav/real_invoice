import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePrefKey = 'user_theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themePrefKey);
      if (savedMode != null) {
        switch (savedMode) {
          case 'light':
            emit(ThemeMode.light);
            break;
          case 'dark':
            emit(ThemeMode.dark);
            break;
          case 'system':
          default:
            emit(ThemeMode.system);
            break;
        }
      }
    } catch (_) {
      // Default to system on any error
      emit(ThemeMode.system);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await prefs.setString(_themePrefKey, modeStr);
    } catch (_) {}
  }
}
