import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/payment_detail_model.dart';
import 'package:uuid/uuid.dart';

class PaymentDetailRepository {
  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _paymentsRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('payment_profiles');
  }

  Future<List<PaymentDetail>> getAllPayments({bool forceSync = false}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      try {
        querySnapshot = await _paymentsRef.get(GetOptions(source: forceSync ? Source.server : Source.cache));
        if (querySnapshot.docs.isEmpty && !forceSync) {
          querySnapshot = await _paymentsRef.get(const GetOptions(source: Source.server));
        }
      } catch (_) {
        if (forceSync) rethrow;
        querySnapshot = await _paymentsRef.get(const GetOptions(source: Source.server));
      }
      
      return querySnapshot.docs.map((doc) => PaymentDetail.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error getting payments: ');
      if (forceSync) rethrow;
      return [];
    }
  }

  Future<void> savePayment(PaymentDetail payment) async {
    final paymentToSave = payment.id.isEmpty
        ? PaymentDetail(
            id: const Uuid().v4(),
            type: payment.type,
            title: payment.title,
            details: payment.details,
            extra: payment.extra,
          )
        : payment;

    await _paymentsRef.doc(paymentToSave.id).set(
      paymentToSave.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> deletePayment(String id) async {
    await _paymentsRef.doc(id).delete();
  }
}
