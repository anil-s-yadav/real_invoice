import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/business_profile_model.dart';
import 'package:uuid/uuid.dart';

class BusinessProfileRepository {
  final AppDatabase _appDatabase;
  static const String _activeProfileKey = 'active_profile_id';

  BusinessProfileRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<String> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey) ?? 'default_profile';
  }

  Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, id);
  }

  Future<BusinessProfile> getProfile([String? id]) async {
    if (id != null && id.isEmpty) {
      return const BusinessProfile(id: '');
    }
    
    final targetId = id ?? await getActiveProfileId();
    final db = await _appDatabase.database;
    final results = await db.query(
      DatabaseTables.businessProfiles,
      where: 'id = ?',
      whereArgs: [targetId],
      limit: 1,
    );

    if (results.isEmpty) {
      final newProfile = BusinessProfile(id: targetId);
      await db.insert(
        DatabaseTables.businessProfiles,
        newProfile.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return newProfile;
    }

    return BusinessProfile.fromMap(results.first);
  }

  Future<List<BusinessProfile>> getAllProfiles() async {
    final db = await _appDatabase.database;
    final results = await db.query(DatabaseTables.businessProfiles);
    return results.map((e) => BusinessProfile.fromMap(e)).toList();
  }

  Future<BusinessProfile> saveProfile(BusinessProfile profile) async {
    final db = await _appDatabase.database;
    // If ID is empty, generate a new one
    final profileToSave = profile.id.isEmpty 
        ? profile.copyWith(id: const Uuid().v4()) 
        : profile;
        
    await db.insert(
      DatabaseTables.businessProfiles,
      profileToSave.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return profileToSave;
  }

  Future<void> deleteProfile(String id) async {
    final db = await _appDatabase.database;
    await db.delete(
      DatabaseTables.businessProfiles,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // If we deleted the active profile, reset to default
    final activeId = await getActiveProfileId();
    if (activeId == id) {
      await setActiveProfileId('default_profile');
    }
  }
}
