class PaymentDetail {
  final String id;
  final String type; // 'Bank' or 'UPI'
  final String title;
  final String details; // Account number or UPI ID
  final String? extra; // IFSC code (for Bank)

  const PaymentDetail({
    required this.id,
    required this.type,
    required this.title,
    required this.details,
    this.extra,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'details': details,
      'extra': extra,
    };
  }

  factory PaymentDetail.fromMap(Map<String, dynamic> map) {
    return PaymentDetail(
      id: map['id'] ?? '',
      type: map['type'] ?? 'Bank',
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      extra: map['extra'],
    );
  }
}
