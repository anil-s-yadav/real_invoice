import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/customer_model.dart';

class CustomerRepository {
  final AppDatabase _appDatabase;

  CustomerRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<Customer>> getAllCustomers() async {
    final db = await _appDatabase.database;
    final results = await db.query(
      DatabaseTables.customers,
      orderBy: 'name ASC',
    );
    return results.map((map) => Customer.fromMap(map)).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _appDatabase.database;
    final q = '%$query%';
    final results = await db.query(
      DatabaseTables.customers,
      where: 'name LIKE ? OR phone LIKE ? OR email LIKE ? OR gstin LIKE ?',
      whereArgs: [q, q, q, q],
      orderBy: 'name ASC',
    );
    return results.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomerById(String id) async {
    final db = await _appDatabase.database;
    final results = await db.query(
      DatabaseTables.customers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Customer.fromMap(results.first);
  }

  Future<void> saveCustomer(Customer customer) async {
    final db = await _appDatabase.database;
    await db.insert(
      DatabaseTables.customers,
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCustomer(String id) async {
    final db = await _appDatabase.database;
    await db.delete(DatabaseTables.customers, where: 'id = ?', whereArgs: [id]);
  }
}
