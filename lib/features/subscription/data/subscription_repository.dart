import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/subscription_plan_model.dart';

class SubscriptionRepository {
  static const String _cachedPlanKey = 'cached_active_subscription_plan';

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _currentSubRef {
    final uid = _userId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('subscription')
        .doc('current');
  }

  CollectionReference<Map<String, dynamic>>? get _planHistoryRef {
    final uid = _userId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plan_history');
  }

  /// Get the current active plan with offline cache fallback
  Future<SubscriptionPlanModel> getCurrentPlan() async {
    try {
      final ref = _currentSubRef;
      if (ref != null) {
        final doc = await ref.get();
        if (doc.exists && doc.data() != null) {
          final plan = SubscriptionPlanModel.fromMap(doc.data()!, doc.id);
          await _cachePlan(plan);
          return plan;
        }
      }
    } catch (_) {
      // Offline fallback
    }

    final cached = await _getCachedPlan();
    if (cached != null) return cached;

    return SubscriptionPlanModel.defaultFree();
  }

  /// Real-time stream of the current active plan
  Stream<SubscriptionPlanModel> currentPlanStream() {
    final ref = _currentSubRef;
    if (ref == null) {
      return Stream.value(SubscriptionPlanModel.defaultFree());
    }

    return ref.snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final plan = SubscriptionPlanModel.fromMap(doc.data()!, doc.id);
        _cachePlan(plan);
        return plan;
      }
      return SubscriptionPlanModel.defaultFree();
    });
  }

  /// Fetch full plan history list
  Future<List<SubscriptionPlanModel>> getPlanHistory() async {
    try {
      final ref = _planHistoryRef;
      if (ref != null) {
        final query =
            await ref.orderBy('createdAt', descending: true).get();
        if (query.docs.isNotEmpty) {
          return query.docs
              .map((d) => SubscriptionPlanModel.fromMap(d.data(), d.id))
              .toList();
        }
      }
    } catch (_) {}

    final current = await getCurrentPlan();
    return [current];
  }

  /// Real-time stream of plan history from Firestore
  Stream<List<SubscriptionPlanModel>> planHistoryStream() {
    final ref = _planHistoryRef;
    if (ref == null) {
      return Stream.value([SubscriptionPlanModel.defaultFree()]);
    }

    return ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => SubscriptionPlanModel.fromMap(doc.data(), doc.id))
            .toList();
      }
      return [SubscriptionPlanModel.defaultFree()];
    });
  }

  /// Save or upgrade subscription plan and record into Firestore history
  Future<void> saveOrUpgradePlan(SubscriptionPlanModel plan) async {
    await _cachePlan(plan);

    final currentRef = _currentSubRef;
    final historyRef = _planHistoryRef;

    if (currentRef != null && historyRef != null) {
      try {
        final data = plan.toMap();
        // Update current plan document
        await currentRef.set(data, SetOptions(merge: true));

        // Add to plan history subcollection
        await historyRef.doc(plan.transactionId).set(data);
      } catch (e) {
        // Will be uploaded once online
      }
    }
  }

  /// Toggle Auto-Renewal in Firestore
  Future<void> toggleAutoRenew(bool enabled) async {
    final current = await getCurrentPlan();
    final updated = current.copyWith(autoRenew: enabled);
    await saveOrUpgradePlan(updated);
  }

  /// Cancel current active plan
  Future<void> cancelPlan() async {
    final current = await getCurrentPlan();
    final updated = current.copyWith(
      status: 'Cancelled',
      autoRenew: false,
    );
    await saveOrUpgradePlan(updated);
  }

  // Local SharedPreferences Cache
  Future<void> _cachePlan(SubscriptionPlanModel plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Store basic fields in JSON
      final jsonMap = {
        'id': plan.id,
        'planName': plan.planName,
        'price': plan.price,
        'durationMonths': plan.durationMonths,
        'discountPercentage': plan.discountPercentage,
        'discountAmount': plan.discountAmount,
        'gstAmount': plan.gstAmount,
        'finalAmount': plan.finalAmount,
        'status': plan.status,
        'transactionId': plan.transactionId,
        'paymentMethod': plan.paymentMethod,
        'startDate': plan.startDate.toIso8601String(),
        'expiryDate': plan.expiryDate?.toIso8601String(),
        'autoRenew': plan.autoRenew,
        'isWelcomeOffer': plan.isWelcomeOffer,
        'createdAt': plan.createdAt.toIso8601String(),
      };
      await prefs.setString(_cachedPlanKey, jsonEncode(jsonMap));
    } catch (_) {}
  }

  Future<SubscriptionPlanModel?> _getCachedPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cachedPlanKey);
      if (str != null && str.isNotEmpty) {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return SubscriptionPlanModel.fromMap(map);
      }
    } catch (_) {}
    return null;
  }
}
