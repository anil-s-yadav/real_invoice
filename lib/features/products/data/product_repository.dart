import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  static const String _activeProfileKey = 'active_profile_id';

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<String> _getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey) ?? 'default_profile';
  }

  Future<CollectionReference<Map<String, dynamic>>> _getProductsRef() async {
    final companyId = await _getCompanyId();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('companies')
        .doc(companyId)
        .collection('products');
  }

  Future<List<ProductItem>> getAllProducts() async {
    try {
      final ref = await _getProductsRef();
      final querySnapshot = await ref.orderBy('title').get();
      return querySnapshot.docs.map((doc) => ProductItem.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<List<ProductItem>> searchProducts(String query) async {
    final products = await getAllProducts();
    if (query.isEmpty) return products;
    
    final q = query.toLowerCase();
    return products.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false) ||
          (p.hsnSacCode?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<ProductItem?> getProductById(String id) async {
    final ref = await _getProductsRef();
    final doc = await ref.doc(id).get();
    if (!doc.exists) return null;
    return ProductItem.fromMap(doc.data()!);
  }

  Future<void> saveProduct(ProductItem product) async {
    final ref = await _getProductsRef();
    final productToSave = product.id.isEmpty
        ? product.copyWith(id: const Uuid().v4())
        : product;

    await ref.doc(productToSave.id).set(
      productToSave.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteProduct(String id) async {
    final ref = await _getProductsRef();
    await ref.doc(id).delete();
  }
}
