class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? billingAddress;
  final String? shippingAddress;
  final String? gstin;
  final String? notes;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.billingAddress,
    this.shippingAddress,
    this.gstin,
    this.notes,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? billingAddress,
    String? shippingAddress,
    String? gstin,
    String? notes,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      gstin: gstin ?? this.gstin,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'billingAddress': billingAddress,
      'shippingAddress': shippingAddress,
      'gstin': gstin,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      billingAddress: map['billingAddress'] as String?,
      shippingAddress: map['shippingAddress'] as String?,
      gstin: map['gstin'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
