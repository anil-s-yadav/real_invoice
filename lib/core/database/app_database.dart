import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('red_invoice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute(DatabaseTables.createBusinessProfiles);
        await db.execute(DatabaseTables.createCustomers);
        await db.execute(DatabaseTables.createProducts);
        await db.execute(DatabaseTables.createDocuments);
        await db.execute(DatabaseTables.createDocumentItems);
        await db.execute(DatabaseTables.createPaymentRecords);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE ${DatabaseTables.businessProfiles} ADD COLUMN defaultInvoiceTemplateId TEXT');
            await db.execute('ALTER TABLE ${DatabaseTables.businessProfiles} ADD COLUMN defaultQuotationTemplateId TEXT');
            await db.execute('ALTER TABLE ${DatabaseTables.businessProfiles} ADD COLUMN defaultReceiptTemplateId TEXT');
            await db.execute('ALTER TABLE ${DatabaseTables.businessProfiles} ADD COLUMN defaultProformaTemplateId TEXT');
            await db.execute('ALTER TABLE ${DatabaseTables.businessProfiles} ADD COLUMN paymentDetailsJson TEXT');
          } catch (_) {
            // Ignore if columns already exist
          }
        }
      },
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
