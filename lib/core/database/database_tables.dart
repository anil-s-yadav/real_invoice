class DatabaseTables {
  DatabaseTables._();

  static const String businessProfiles = 'business_profiles';
  static const String customers = 'customers';
  static const String products = 'products';
  static const String documents = 'documents';
  static const String documentItems = 'document_items';
  static const String paymentRecords = 'payment_records';

  static const String createBusinessProfiles = '''
    CREATE TABLE IF NOT EXISTS $businessProfiles (
      id TEXT PRIMARY KEY,
      businessName TEXT NOT NULL,
      logoPath TEXT,
      phone TEXT,
      email TEXT,
      address TEXT,
      website TEXT,
      gstin TEXT,
      pan TEXT,
      bankName TEXT,
      accountNumber TEXT,
      ifscCode TEXT,
      upiId TEXT,
      signaturePath TEXT,
    stampPath TEXT,
      defaultTerms TEXT,
      defaultNotes TEXT,
      currencyCode TEXT,
      currencySymbol TEXT,
      defaultInvoiceTemplateId TEXT,
      defaultQuotationTemplateId TEXT,
      defaultReceiptTemplateId TEXT,
      defaultProformaTemplateId TEXT,
      paymentDetailsJson TEXT
    );
  ''';

  static const String createCustomers = '''
    CREATE TABLE IF NOT EXISTS $customers (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      billingAddress TEXT,
      shippingAddress TEXT,
      gstin TEXT,
      notes TEXT,
      createdAt TEXT NOT NULL
    );
  ''';

  static const String createProducts = '''
    CREATE TABLE IF NOT EXISTS $products (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      unitPrice REAL NOT NULL,
      unit TEXT NOT NULL,
      defaultTaxPercent REAL NOT NULL,
      hsnSacCode TEXT,
      createdAt TEXT NOT NULL
    );
  ''';

  static const String createDocuments = '''
    CREATE TABLE IF NOT EXISTS $documents (
      id TEXT PRIMARY KEY,
      docNumber TEXT NOT NULL,
      docType TEXT NOT NULL,
      customerId TEXT,
      customerSnapshot TEXT,
      issueDate TEXT NOT NULL,
      dueDate TEXT NOT NULL,
      status TEXT NOT NULL,
      overallDiscountValue REAL NOT NULL,
      overallDiscountType TEXT NOT NULL,
      templateId TEXT NOT NULL,
      poNumber TEXT,
      subject TEXT,
      shippingCharges REAL NOT NULL DEFAULT 0.0,
      includePaymentDetails INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      terms TEXT,
      relatedDocId TEXT,
      subtotal REAL NOT NULL,
      taxAmount REAL NOT NULL,
      roundOff REAL NOT NULL,
      totalAmount REAL NOT NULL,
      amountPaid REAL NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    );
  ''';

  static const String createDocumentItems = '''
    CREATE TABLE IF NOT EXISTS $documentItems (
      id TEXT PRIMARY KEY,
      documentId TEXT NOT NULL,
      productId TEXT,
      title TEXT NOT NULL,
      description TEXT,
      quantity REAL NOT NULL,
      unit TEXT NOT NULL,
      unitPrice REAL NOT NULL,
      discountPercent REAL NOT NULL,
      taxPercent REAL NOT NULL,
      hsnSacCode TEXT,
      lineTotal REAL NOT NULL,
      FOREIGN KEY (documentId) REFERENCES $documents(id) ON DELETE CASCADE
    );
  ''';

  static const String createPaymentRecords = '''
    CREATE TABLE IF NOT EXISTS $paymentRecords (
      id TEXT PRIMARY KEY,
      documentId TEXT NOT NULL,
      paymentDate TEXT NOT NULL,
      amount REAL NOT NULL,
      paymentMethod TEXT NOT NULL,
      referenceNumber TEXT,
      notes TEXT,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (documentId) REFERENCES $documents(id) ON DELETE CASCADE
    );
  ''';
}
