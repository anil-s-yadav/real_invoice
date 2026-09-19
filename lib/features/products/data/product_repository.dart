import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../domain/product_model.dart';

class ProductRepository {
  final AppDatabase _appDatabase;

  ProductRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<ProductItem>> getAllProducts() async {
    final db = await _appDatabase.database;
    final results = await db.query(
      DatabaseTables.products,
      orderBy: 'title ASC',
    );
    return results.map((map) => ProductItem.fromMap(map)).toList();
  }

  Future<List<ProductItem>> searchProducts(String query) async {
    final db = await _appDatabase.database;
    final q = '%$query%';
    final results = await db.query(
      DatabaseTables.products,
      where: 'title LIKE ? OR description LIKE ? OR hsnSacCode LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'title ASC',
    );
    return results.map((map) => ProductItem.fromMap(map)).toList();
  }

  Future<ProductItem?> getProductById(String id) async {
    final db = await _appDatabase.database;
    final results = await db.query(
      DatabaseTables.products,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ProductItem.fromMap(results.first);
  }

  Future<void> saveProduct(ProductItem product) async {
    final db = await _appDatabase.database;
    await db.insert(
      DatabaseTables.products,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await _appDatabase.database;
    await db.delete(DatabaseTables.products, where: 'id = ?', whereArgs: [id]);
  }
}
