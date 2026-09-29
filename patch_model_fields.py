with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add maxCompaniesAllowed to fields
fields_old = """  final bool autoRenew;
  final bool isWelcomeOffer;
  final DateTime createdAt;"""

fields_new = """  final bool autoRenew;
  final bool isWelcomeOffer;
  final DateTime createdAt;
  final int maxCompaniesAllowed;"""
content = content.replace(fields_old, fields_new)

# Add to constructor
constructor_old = """    this.autoRenew = true,
    this.isWelcomeOffer = false,
    required this.createdAt,
  });"""

constructor_new = """    this.autoRenew = true,
    this.isWelcomeOffer = false,
    required this.createdAt,
    this.maxCompaniesAllowed = 1,
  });"""
content = content.replace(constructor_old, constructor_new)

# Remove the getter
getter = """  int get maxCompaniesAllowed {
    if (isFree) return 1;
    if (planName.toLowerCase().contains('pro')) return 5;
    return 50;
  }"""
content = content.replace(getter, "")

# Add to toMap
tomap_old = """        'isWelcomeOffer': isWelcomeOffer,
        'createdAt': Timestamp.fromDate(createdAt),
      };"""
tomap_new = """        'isWelcomeOffer': isWelcomeOffer,
        'createdAt': Timestamp.fromDate(createdAt),
        'maxCompaniesAllowed': maxCompaniesAllowed,
      };"""
content = content.replace(tomap_old, tomap_new)

# Add to fromMap
frommap_old = """      isWelcomeOffer: map['isWelcomeOffer'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );"""
frommap_new = """      isWelcomeOffer: map['isWelcomeOffer'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxCompaniesAllowed: map['maxCompaniesAllowed'] ?? 1,
    );"""
content = content.replace(frommap_old, frommap_new)

with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("SubscriptionPlanModel updated")