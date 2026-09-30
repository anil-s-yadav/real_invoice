with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

fields_old = """  final bool isWelcomeOffer;
  final DateTime createdAt;
  final int maxCompaniesAllowed;"""
fields_new = """  final bool isWelcomeOffer;
  final DateTime createdAt;
  final int maxCompaniesAllowed;
  final int maxClientsAllowed;
  final int maxItemsAllowed;
  final int maxDocumentsPerDay;
  final int maxDevicesAllowed;
  final bool isAdFree;
  final bool hasPremiumTemplates;"""
content = content.replace(fields_old, fields_new)

constructor_old = """    this.isWelcomeOffer = false,
    required this.createdAt,
    this.maxCompaniesAllowed = 1,
  });"""
constructor_new = """    this.isWelcomeOffer = false,
    required this.createdAt,
    this.maxCompaniesAllowed = 1,
    this.maxClientsAllowed = 3,
    this.maxItemsAllowed = 3,
    this.maxDocumentsPerDay = 5,
    this.maxDevicesAllowed = 1,
    this.isAdFree = false,
    this.hasPremiumTemplates = false,
  });"""
content = content.replace(constructor_old, constructor_new)

tomap_old = """        'maxCompaniesAllowed': maxCompaniesAllowed,
      };"""
tomap_new = """        'maxCompaniesAllowed': maxCompaniesAllowed,
        'maxClientsAllowed': maxClientsAllowed,
        'maxItemsAllowed': maxItemsAllowed,
        'maxDocumentsPerDay': maxDocumentsPerDay,
        'maxDevicesAllowed': maxDevicesAllowed,
        'isAdFree': isAdFree,
        'hasPremiumTemplates': hasPremiumTemplates,
      };"""
content = content.replace(tomap_old, tomap_new)

frommap_old = """      maxCompaniesAllowed: map['maxCompaniesAllowed'] ?? 1,
    );"""
frommap_new = """      maxCompaniesAllowed: map['maxCompaniesAllowed'] ?? 1,
      maxClientsAllowed: map['maxClientsAllowed'] ?? 3,
      maxItemsAllowed: map['maxItemsAllowed'] ?? 3,
      maxDocumentsPerDay: map['maxDocumentsPerDay'] ?? 5,
      maxDevicesAllowed: map['maxDevicesAllowed'] ?? 1,
      isAdFree: map['isAdFree'] ?? false,
      hasPremiumTemplates: map['hasPremiumTemplates'] ?? false,
    );"""
content = content.replace(frommap_old, frommap_new)

defaultfree_old = """      expiryDate: null, // Lifetime free
      autoRenew: false,
      isWelcomeOffer: false,
      createdAt: now,
    );"""
defaultfree_new = """      expiryDate: null, // Lifetime free
      autoRenew: false,
      isWelcomeOffer: false,
      createdAt: now,
      maxCompaniesAllowed: 1,
      maxClientsAllowed: 3,
      maxItemsAllowed: 3,
      maxDocumentsPerDay: 5,
      maxDevicesAllowed: 1,
      isAdFree: false,
      hasPremiumTemplates: false,
    );"""
content = content.replace(defaultfree_old, defaultfree_new)

with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("SubscriptionPlanModel updated with all limits")