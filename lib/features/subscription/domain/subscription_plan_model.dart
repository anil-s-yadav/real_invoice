import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlanModel {
  final String id;
  final String planName;
  final double price;
  final int durationMonths;
  final double discountPercentage;
  final double discountAmount;
  final double gstAmount;
  final double finalAmount;
  final String status; // 'Active', 'Expired', 'Cancelled'
  final String transactionId;
  final String paymentMethod;
  final DateTime startDate;
  final DateTime? expiryDate;
  final bool autoRenew;
  final bool isWelcomeOffer;
  final DateTime createdAt;

  const SubscriptionPlanModel({
    required this.id,
    required this.planName,
    required this.price,
    required this.durationMonths,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.gstAmount = 0.0,
    required this.finalAmount,
    this.status = 'Active',
    required this.transactionId,
    this.paymentMethod = 'UPI',
    required this.startDate,
    this.expiryDate,
    this.autoRenew = true,
    this.isWelcomeOffer = false,
    required this.createdAt,
  });

  bool get isFree => planName.trim().toLowerCase() == 'free';
  bool get isActive => status.trim().toLowerCase() == 'active';

  int get daysRemaining {
    if (expiryDate == null) return 0;
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  factory SubscriptionPlanModel.defaultFree() {
    final now = DateTime.now();
    return SubscriptionPlanModel(
      id: 'plan_free_tier',
      planName: 'Free',
      price: 0.0,
      durationMonths: 12,
      discountPercentage: 0.0,
      discountAmount: 0.0,
      gstAmount: 0.0,
      finalAmount: 0.0,
      status: 'Active',
      transactionId: 'TXN_FREE_STARTER',
      paymentMethod: 'Free Activation',
      startDate: now,
      expiryDate: null, // Lifetime free
      autoRenew: false,
      isWelcomeOffer: false,
      createdAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planName': planName,
      'price': price,
      'durationMonths': durationMonths,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'gstAmount': gstAmount,
      'finalAmount': finalAmount,
      'status': status,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate':
          expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'autoRenew': autoRenew,
      'isWelcomeOffer': isWelcomeOffer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SubscriptionPlanModel.fromMap(
    Map<String, dynamic> map, [
    String? docId,
  ]) {
    DateTime parseTimestamp(dynamic val, DateTime fallback) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    DateTime? parseNullableTimestamp(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final now = DateTime.now();

    return SubscriptionPlanModel(
      id: docId ?? (map['id'] as String? ?? 'sub_${now.millisecondsSinceEpoch}'),
      planName: map['planName'] as String? ?? 'Free',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      durationMonths: (map['durationMonths'] as num?)?.toInt() ?? 12,
      discountPercentage:
          (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (map['gstAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (map['finalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Active',
      transactionId: map['transactionId'] as String? ?? 'TXN_LOCAL',
      paymentMethod: map['paymentMethod'] as String? ?? 'UPI',
      startDate: parseTimestamp(map['startDate'], now),
      expiryDate: parseNullableTimestamp(map['expiryDate']),
      autoRenew: map['autoRenew'] as bool? ?? true,
      isWelcomeOffer: map['isWelcomeOffer'] as bool? ?? false,
      createdAt: parseTimestamp(map['createdAt'], now),
    );
  }

  SubscriptionPlanModel copyWith({
    String? id,
    String? planName,
    double? price,
    int? durationMonths,
    double? discountPercentage,
    double? discountAmount,
    double? gstAmount,
    double? finalAmount,
    String? status,
    String? transactionId,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? expiryDate,
    bool? autoRenew,
    bool? isWelcomeOffer,
    DateTime? createdAt,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      durationMonths: durationMonths ?? this.durationMonths,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      gstAmount: gstAmount ?? this.gstAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      autoRenew: autoRenew ?? this.autoRenew,
      isWelcomeOffer: isWelcomeOffer ?? this.isWelcomeOffer,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
