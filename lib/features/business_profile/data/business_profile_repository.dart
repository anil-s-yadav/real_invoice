import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/business_profile_model.dart';

class BusinessProfileRepository {
  final AppDatabase _appDatabase;

  BusinessProfileRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<BusinessProfile> getProfile() async {
    final db = await _appDatabase.database;
    final results = await db.query(
      DatabaseTables.businessProfiles,
      where: 'id = ?',
      whereArgs: ['default_profile'],
      limit: 1,
    );

    if (results.isEmpty) {
      const defaultProfile = BusinessProfile();
      await db.insert(
        DatabaseTables.businessProfiles,
        defaultProfile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return defaultProfile;
    }

    return BusinessProfile.fromMap(results.first);
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    final db = await _appDatabase.database;
    await db.insert(
      DatabaseTables.businessProfiles,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
