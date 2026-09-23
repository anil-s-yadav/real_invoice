import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/customer_model.dart';
import 'package:uuid/uuid.dart';

class CustomerRepository {
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

  Future<CollectionReference<Map<String, dynamic>>> _getCustomersRef() async {
    final companyId = await _getCompanyId();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('companies')
        .doc(companyId)
        .collection('customers');
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      final ref = await _getCustomersRef();
      final querySnapshot = await ref.orderBy('name').get();
      return querySnapshot.docs.map((doc) => Customer.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting customers: $e');
      return [];
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final customers = await getAllCustomers();
    if (query.isEmpty) return customers;
    
    final q = query.toLowerCase();
    return customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          (c.phone?.toLowerCase().contains(q) ?? false) ||
          (c.email?.toLowerCase().contains(q) ?? false) ||
          (c.gstin?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<Customer> saveCustomer(Customer customer) async {
    final ref = await _getCustomersRef();
    final customerToSave = customer.id.isEmpty
        ? customer.copyWith(id: const Uuid().v4())
        : customer;

    await ref.doc(customerToSave.id).set(
      customerToSave.toMap(),
      SetOptions(merge: true),
    );

    return customerToSave;
  }

  Future<void> deleteCustomer(String id) async {
    final ref = await _getCustomersRef();
    await ref.doc(id).delete();
  }
}
