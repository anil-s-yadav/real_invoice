import 'dart:math';
import '../../../core/widgets/status_badge.dart';
import '../../documents/domain/document_model.dart';

enum TimeFilterPreset {
  thisMonth('This Month'),
  thisQuarter('This Quarter'),
  thisYear('This Fiscal Year'),
  allTime('All Time'),
  custom('Custom');

  final String label;
  const TimeFilterPreset(this.label);
}

class CashFlowSpot {
  final int monthIndex; // 0 to 11, or day/period index
  final String label;   // e.g. "Jan", "Feb"
  final double billedAmount;
  final double collectedAmount;

  const CashFlowSpot({
    required this.monthIndex,
    required this.label,
    required this.billedAmount,
    required this.collectedAmount,
  });
}

class AgingBucket {
  final String label;       // e.g. "Current", "1-15 Days", "16-30 Days", etc.
  final double totalAmount;
  final int invoiceCount;
  final double percentage;  // 0.0 to 100.0

  const AgingBucket({
    required this.label,
    required this.totalAmount,
    required this.invoiceCount,
    required this.percentage,
  });
}

class OverdueDebtor {
  final String customerName;
  final String? phone;
  final double totalOverdue;
  final int overdueDays;
  final DateTime oldestDueDate;
  final int invoiceCount;

  const OverdueDebtor({
    required this.customerName,
    this.phone,
    required this.totalOverdue,
    required this.overdueDays,
    required this.oldestDueDate,
    required this.invoiceCount,
  });
}

class ProductPerformance {
  final String title;
  final String unit;
  final double totalQuantity;
  final double totalRevenue;
  final double percentage; // % of total sales

  const ProductPerformance({
    required this.title,
    required this.unit,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.percentage,
  });
}

class ClientPerformance {
  final String name;
  final double totalRevenue;
  final int invoiceCount;
  final double balanceDue;
  final double percentage; // % of total sales
  final String reliability; // "Prompt", "Average", "Slow"

  const ClientPerformance({
    required this.name,
    required this.totalRevenue,
    required this.invoiceCount,
    required this.balanceDue,
    required this.percentage,
    required this.reliability,
  });
}

class TaxSlabSummary {
  final double ratePercent; // 0, 5, 12, 18, 28
  final double taxableAmount;
  final double taxAmount;

  const TaxSlabSummary({
    required this.ratePercent,
    required this.taxableAmount,
    required this.taxAmount,
  });
}

class HsnSummary {
  final String hsnCode;
  final int itemCount;
  final double totalQuantity;
  final double taxableAmount;
  final double taxAmount;

  const HsnSummary({
    required this.hsnCode,
    required this.itemCount,
    required this.totalQuantity,
    required this.taxableAmount,
    required this.taxAmount,
  });
}

class QuotationFunnel {
  final int totalQuotations;
  final int acceptedCount;
  final int pendingCount;
  final int lostCount;
  final double winRate;         // %
  final double pipelineValue;   // Total value of pending quotations
  final double wonValue;        // Total value of accepted quotations

  const QuotationFunnel({
    required this.totalQuotations,
    required this.acceptedCount,
    required this.pendingCount,
    required this.lostCount,
    required this.winRate,
    required this.pipelineValue,
    required this.wonValue,
  });
}

class AnalyticsData {
  final TimeFilterPreset preset;
  final DateTime startDate;
  final DateTime endDate;

  // Overview / Cash Flow KPIs
  final double totalInvoiced;
  final double totalCollected;
  final double totalOutstanding;
  final double totalOverdue;
  final int totalInvoiceCount;
  final double averageInvoiceValue;
  final int averageCollectionDays; // DSO

  // Charts data
  final List<CashFlowSpot> cashFlowSpots;
  final Map<String, double> paymentMethodsBreakdown; // "UPI": 50000, "Bank": 30000

  // Receivables & Debt Aging
  final List<AgingBucket> agingBuckets;
  final List<OverdueDebtor> topDebtors;

  // Items & Clients Intelligence
  final List<ProductPerformance> topProducts;
  final List<ClientPerformance> topClients;
  final double top3ClientConcentration; // e.g. 68.5%
  final QuotationFunnel quotationFunnel;

  // Tax & GST Compliance
  final double totalTaxableValue;
  final double totalTaxCollected;
  final List<TaxSlabSummary> taxSlabs;
  final double localTaxAmount;      // CGST + SGST (intra-state)
  final double interstateTaxAmount; // IGST (inter-state)
  final List<HsnSummary> hsnSummaries;
  final double totalDiscountsGiven;
  final double totalShippingBilled;

  const AnalyticsData({
    required this.preset,
    required this.startDate,
    required this.endDate,
    required this.totalInvoiced,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.totalOverdue,
    required this.totalInvoiceCount,
    required this.averageInvoiceValue,
    required this.averageCollectionDays,
    required this.cashFlowSpots,
    required this.paymentMethodsBreakdown,
    required this.agingBuckets,
    required this.topDebtors,
    required this.topProducts,
    required this.topClients,
    required this.top3ClientConcentration,
    required this.quotationFunnel,
    required this.totalTaxableValue,
    required this.totalTaxCollected,
    required this.taxSlabs,
    required this.localTaxAmount,
    required this.interstateTaxAmount,
    required this.hsnSummaries,
    required this.totalDiscountsGiven,
    required this.totalShippingBilled,
  });

  /// Factory computer to build AnalyticsData from documents and date range
  factory AnalyticsData.compute({
    required List<DocumentModel> allDocuments,
    required TimeFilterPreset preset,
    required DateTime startDate,
    required DateTime endDate,
    String? businessGstin,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter invoices in the selected period (by issueDate)
    final invoicesInPeriod = allDocuments.where((doc) {
      if (doc.docType != DocumentType.invoice && doc.docType != DocumentType.receipt) {
        return false;
      }
      return !doc.issueDate.isBefore(startDate) && !doc.issueDate.isAfter(endDate);
    }).toList();

    // Quotations in period
    final quotationsInPeriod = allDocuments.where((doc) {
      return doc.docType == DocumentType.quotation &&
          !doc.issueDate.isBefore(startDate) &&
          !doc.issueDate.isAfter(endDate);
    }).toList();

    // 1. Overview KPIs
    double totalInvoiced = 0.0;
    double totalOutstanding = 0.0;
    double totalOverdue = 0.0;
    double totalDiscountsGiven = 0.0;
    double totalShippingBilled = 0.0;
    double totalTaxableValue = 0.0;
    double totalTaxCollected = 0.0;

    for (final doc in invoicesInPeriod) {
      totalInvoiced += doc.totalAmount;
      totalOutstanding += doc.balanceDue;
      if (doc.calculatedStatus == DocumentStatus.overdue ||
          (doc.balanceDue > 0 && doc.dueDate.isBefore(today))) {
        totalOverdue += doc.balanceDue;
      }
      totalDiscountsGiven += (doc.itemDiscountsTotal + doc.overallDiscountAmount);
      totalShippingBilled += doc.shippingCharges;
      totalTaxableValue += doc.taxableAmount;
      totalTaxCollected += doc.totalTaxAmount;
    }

    final totalInvoiceCount = invoicesInPeriod.length;
    final averageInvoiceValue = totalInvoiceCount > 0 ? totalInvoiced / totalInvoiceCount : 0.0;

    // 2. Cash Collected (Actual payments received inside the date window)
    double totalCollected = 0.0;
    final Map<String, double> paymentMethodsBreakdown = {};
    final List<int> daysToCollectList = [];

    // Monthly data spots for 12 months of the active year (or period)
    final billedMonthly = List.generate(12, (_) => 0.0);
    final collectedMonthly = List.generate(12, (_) => 0.0);

    for (final doc in allDocuments) {
      if (doc.docType == DocumentType.invoice || doc.docType == DocumentType.receipt) {
        // Track billed monthly for the target year
        if (doc.issueDate.year == endDate.year) {
          billedMonthly[doc.issueDate.month - 1] += doc.totalAmount;
        }

        // Process payments
        for (final payment in doc.payments) {
          if (!payment.paymentDate.isBefore(startDate) && !payment.paymentDate.isAfter(endDate)) {
            totalCollected += payment.amount;
            final method = payment.paymentMethod.isNotEmpty ? payment.paymentMethod : 'Other';
            paymentMethodsBreakdown[method] = (paymentMethodsBreakdown[method] ?? 0.0) + payment.amount;

            // Track DSO
            final daysDiff = payment.paymentDate.difference(doc.issueDate).inDays;
            if (daysDiff >= 0) {
              daysToCollectList.add(daysDiff);
            }
          }

          if (payment.paymentDate.year == endDate.year) {
            collectedMonthly[payment.paymentDate.month - 1] += payment.amount;
          }
        }
      }
    }

    // Default if no payments in period but invoices exist
    if (totalCollected == 0 && invoicesInPeriod.isNotEmpty) {
      for (final doc in invoicesInPeriod) {
        totalCollected += doc.totalPaid;
      }
    }

    final averageCollectionDays = daysToCollectList.isNotEmpty
        ? (daysToCollectList.reduce((a, b) => a + b) / daysToCollectList.length).round()
        : 14;

    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final cashFlowSpots = List.generate(12, (index) {
      return CashFlowSpot(
        monthIndex: index,
        label: monthNames[index],
        billedAmount: billedMonthly[index],
        collectedAmount: collectedMonthly[index],
      );
    });

    // 3. Receivables & Aging Buckets (across all active unpaid invoices)
    double bucketCurrent = 0.0;
    int countCurrent = 0;
    double bucket1To15 = 0.0;
    int count1To15 = 0;
    double bucket16To30 = 0.0;
    int count16To30 = 0;
    double bucket31To60 = 0.0;
    int count31To60 = 0;
    double bucket60Plus = 0.0;
    int count60Plus = 0;

    final Map<String, List<DocumentModel>> clientOverdueMap = {};

    for (final doc in allDocuments) {
      if ((doc.docType == DocumentType.invoice || doc.docType == DocumentType.proforma) &&
          doc.balanceDue > 0 &&
          doc.status != DocumentStatus.cancelled) {
        final daysPastDue = today.difference(DateTime(doc.dueDate.year, doc.dueDate.month, doc.dueDate.day)).inDays;

        if (daysPastDue <= 0) {
          bucketCurrent += doc.balanceDue;
          countCurrent++;
        } else if (daysPastDue <= 15) {
          bucket1To15 += doc.balanceDue;
          count1To15++;
        } else if (daysPastDue <= 30) {
          bucket16To30 += doc.balanceDue;
          count16To30++;
        } else if (daysPastDue <= 60) {
          bucket31To60 += doc.balanceDue;
          count31To60++;
        } else {
          bucket60Plus += doc.balanceDue;
          count60Plus++;
        }

        if (daysPastDue > 0) {
          final clientName = doc.customerSnapshot?.name ?? 'Unknown Customer';
          clientOverdueMap.putIfAbsent(clientName, () => []).add(doc);
        }
      }
    }

    final allAgingTotal = bucketCurrent + bucket1To15 + bucket16To30 + bucket31To60 + bucket60Plus;
    double pct(double val) => allAgingTotal > 0 ? (val / allAgingTotal * 100.0) : 0.0;

    final agingBuckets = [
      AgingBucket(label: 'Not Due (Current)', totalAmount: bucketCurrent, invoiceCount: countCurrent, percentage: pct(bucketCurrent)),
      AgingBucket(label: '1–15 Days Overdue', totalAmount: bucket1To15, invoiceCount: count1To15, percentage: pct(bucket1To15)),
      AgingBucket(label: '16–30 Days Overdue', totalAmount: bucket16To30, invoiceCount: count16To30, percentage: pct(bucket16To30)),
      AgingBucket(label: '31–60 Days Overdue', totalAmount: bucket31To60, invoiceCount: count31To60, percentage: pct(bucket31To60)),
      AgingBucket(label: '60+ Days (Critical)', totalAmount: bucket60Plus, invoiceCount: count60Plus, percentage: pct(bucket60Plus)),
    ];

    // Top Debtors
    final List<OverdueDebtor> topDebtors = [];
    clientOverdueMap.forEach((name, docs) {
      double overdueSum = 0;
      DateTime oldest = today;
      String? phone;
      for (final d in docs) {
        overdueSum += d.balanceDue;
        if (d.dueDate.isBefore(oldest)) oldest = d.dueDate;
        if (phone == null && d.customerSnapshot?.phone != null) {
          phone = d.customerSnapshot?.phone;
        }
      }
      final days = max(0, today.difference(oldest).inDays);
      topDebtors.add(OverdueDebtor(
        customerName: name,
        phone: phone,
        totalOverdue: overdueSum,
        overdueDays: days,
        oldestDueDate: oldest,
        invoiceCount: docs.length,
      ));
    });
    topDebtors.sort((a, b) => b.totalOverdue.compareTo(a.totalOverdue));

    // 4. Products / Services Intelligence
    final Map<String, ProductPerformance> productMap = {};
    for (final doc in invoicesInPeriod) {
      for (final item in doc.items) {
        final key = item.title.trim().toLowerCase();
        final existing = productMap[key];
        final addedRevenue = item.lineTotal;
        final addedQty = item.quantity;
        if (existing == null) {
          productMap[key] = ProductPerformance(
            title: item.title,
            unit: item.unit,
            totalQuantity: addedQty,
            totalRevenue: addedRevenue,
            percentage: 0.0,
          );
        } else {
          productMap[key] = ProductPerformance(
            title: existing.title,
            unit: existing.unit,
            totalQuantity: existing.totalQuantity + addedQty,
            totalRevenue: existing.totalRevenue + addedRevenue,
            percentage: 0.0,
          );
        }
      }
    }

    final sortedProducts = productMap.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final topProducts = sortedProducts.take(5).map((p) {
      final percentage = totalInvoiced > 0 ? (p.totalRevenue / totalInvoiced * 100.0) : 0.0;
      return ProductPerformance(
        title: p.title,
        unit: p.unit,
        totalQuantity: p.totalQuantity,
        totalRevenue: p.totalRevenue,
        percentage: percentage,
      );
    }).toList();

    // 5. Clients Intelligence
    final Map<String, ClientPerformance> clientMap = {};
    for (final doc in invoicesInPeriod) {
      final name = doc.customerSnapshot?.name ?? 'Unknown Customer';
      final existing = clientMap[name];
      if (existing == null) {
        clientMap[name] = ClientPerformance(
          name: name,
          totalRevenue: doc.totalAmount,
          invoiceCount: 1,
          balanceDue: doc.balanceDue,
          percentage: 0.0,
          reliability: doc.balanceDue <= 0 ? 'Prompt' : (doc.dueDate.isBefore(today) ? 'Slow' : 'Average'),
        );
      } else {
        clientMap[name] = ClientPerformance(
          name: name,
          totalRevenue: existing.totalRevenue + doc.totalAmount,
          invoiceCount: existing.invoiceCount + 1,
          balanceDue: existing.balanceDue + doc.balanceDue,
          percentage: 0.0,
          reliability: existing.reliability,
        );
      }
    }

    final sortedClients = clientMap.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final topClients = sortedClients.take(5).map((c) {
      final percentage = totalInvoiced > 0 ? (c.totalRevenue / totalInvoiced * 100.0) : 0.0;
      return ClientPerformance(
        name: c.name,
        totalRevenue: c.totalRevenue,
        invoiceCount: c.invoiceCount,
        balanceDue: c.balanceDue,
        percentage: percentage,
        reliability: c.reliability,
      );
    }).toList();

    double top3Sum = 0.0;
    for (int i = 0; i < min(3, topClients.length); i++) {
      top3Sum += topClients[i].totalRevenue;
    }
    final top3ClientConcentration = totalInvoiced > 0 ? (top3Sum / totalInvoiced * 100.0) : 0.0;

    // 6. Quotation Funnel
    int quoteAccepted = 0;
    int quotePending = 0;
    int quoteLost = 0;
    double pipelineVal = 0.0;
    double wonVal = 0.0;

    for (final q in quotationsInPeriod) {
      if (q.status == DocumentStatus.accepted) {
        quoteAccepted++;
        wonVal += q.totalAmount;
      } else if (q.status == DocumentStatus.cancelled) {
        quoteLost++;
      } else {
        quotePending++;
        pipelineVal += q.totalAmount;
      }
    }

    final totalQuotes = quotationsInPeriod.length;
    final winRate = totalQuotes > 0 ? (quoteAccepted / totalQuotes * 100.0) : 0.0;

    final quotationFunnel = QuotationFunnel(
      totalQuotations: totalQuotes,
      acceptedCount: quoteAccepted,
      pendingCount: quotePending,
      lostCount: quoteLost,
      winRate: winRate,
      pipelineValue: pipelineVal,
      wonValue: wonVal,
    );

    // 7. Tax & GST Slab Distribution
    final Map<double, double> slabTaxable = {0.0: 0.0, 5.0: 0.0, 12.0: 0.0, 18.0: 0.0, 28.0: 0.0};
    final Map<double, double> slabTax = {0.0: 0.0, 5.0: 0.0, 12.0: 0.0, 18.0: 0.0, 28.0: 0.0};
    final Map<String, HsnSummary> hsnMap = {};

    double localTax = 0.0;
    double interstateTax = 0.0;
    final businessStateCode = (businessGstin != null && businessGstin.length >= 2)
        ? businessGstin.substring(0, 2)
        : null;

    for (final doc in invoicesInPeriod) {
      final customerGstin = doc.customerSnapshot?.gstin;
      final customerStateCode = (customerGstin != null && customerGstin.length >= 2)
          ? customerGstin.substring(0, 2)
          : null;

      final isInterstate = businessStateCode != null &&
          customerStateCode != null &&
          businessStateCode != customerStateCode;

      if (isInterstate) {
        interstateTax += doc.totalTaxAmount;
      } else {
        localTax += doc.totalTaxAmount;
      }

      for (final item in doc.items) {
        // Slab matching
        final rate = item.taxPercent;
        double matchedSlab = 18.0;
        if (rate <= 0) {
          matchedSlab = 0.0;
        } else if (rate <= 6) {
          matchedSlab = 5.0;
        } else if (rate <= 14) {
          matchedSlab = 12.0;
        } else if (rate <= 20) {
          matchedSlab = 18.0;
        } else {
          matchedSlab = 28.0;
        }

        slabTaxable[matchedSlab] = (slabTaxable[matchedSlab] ?? 0.0) + item.taxableAmount;
        slabTax[matchedSlab] = (slabTax[matchedSlab] ?? 0.0) + item.taxAmount;

        // HSN / SAC summary
        final hsnCode = item.hsnSacCode?.trim().isNotEmpty == true ? item.hsnSacCode!.trim() : 'General';
        final existingHsn = hsnMap[hsnCode];
        if (existingHsn == null) {
          hsnMap[hsnCode] = HsnSummary(
            hsnCode: hsnCode,
            itemCount: 1,
            totalQuantity: item.quantity,
            taxableAmount: item.taxableAmount,
            taxAmount: item.taxAmount,
          );
        } else {
          hsnMap[hsnCode] = HsnSummary(
            hsnCode: hsnCode,
            itemCount: existingHsn.itemCount + 1,
            totalQuantity: existingHsn.totalQuantity + item.quantity,
            taxableAmount: existingHsn.taxableAmount + item.taxableAmount,
            taxAmount: existingHsn.taxAmount + item.taxAmount,
          );
        }
      }
    }

    final taxSlabs = slabTaxable.keys.map((slab) {
      return TaxSlabSummary(
        ratePercent: slab,
        taxableAmount: slabTaxable[slab] ?? 0.0,
        taxAmount: slabTax[slab] ?? 0.0,
      );
    }).toList();

    final hsnSummaries = hsnMap.values.toList()
      ..sort((a, b) => b.taxableAmount.compareTo(a.taxableAmount));

    return AnalyticsData(
      preset: preset,
      startDate: startDate,
      endDate: endDate,
      totalInvoiced: totalInvoiced,
      totalCollected: totalCollected,
      totalOutstanding: totalOutstanding,
      totalOverdue: totalOverdue,
      totalInvoiceCount: totalInvoiceCount,
      averageInvoiceValue: averageInvoiceValue,
      averageCollectionDays: averageCollectionDays,
      cashFlowSpots: cashFlowSpots,
      paymentMethodsBreakdown: paymentMethodsBreakdown,
      agingBuckets: agingBuckets,
      topDebtors: topDebtors,
      topProducts: topProducts,
      topClients: topClients,
      top3ClientConcentration: top3ClientConcentration,
      quotationFunnel: quotationFunnel,
      totalTaxableValue: totalTaxableValue,
      totalTaxCollected: totalTaxCollected,
      taxSlabs: taxSlabs,
      localTaxAmount: localTax,
      interstateTaxAmount: interstateTax,
      hsnSummaries: hsnSummaries,
      totalDiscountsGiven: totalDiscountsGiven,
      totalShippingBilled: totalShippingBilled,
    );
  }
}
