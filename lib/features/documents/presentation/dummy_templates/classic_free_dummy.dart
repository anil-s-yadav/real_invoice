import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildClassicFreeDummy(DocumentType documentType) {
  const primarySlate = Color(0xFF0F172A); // Slate 900
  const secondarySlate = Color(0xFF475569); // Slate 600
  const mutedSlate = Color(0xFF64748B); // Slate 500
  const borderColor = Color(0xFFE2E8F0); // Slate 200
  const bgLight = Color(0xFFF8FAFC); // Slate 50
  const badgeBg = Color(0xFFF1F5F9); // Slate 100

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icons/applogo.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  buildDummyText('Tesla Inc.', size: 18, bold: true, color: primarySlate),
                  const SizedBox(height: 4),
                  buildDummyText(
                    'teslacom@gmail.com  •  +1 987-654-3210\nRoad no. 397, West City, NY - 10001\nGSTIN: 27AABCU9603R1ZM',
                    color: secondarySlate,
                    size: 9.5,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    documentType.displayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: primarySlate,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: buildDummyText(
                      '# INV-2026-0001',
                      bold: true,
                      size: 11,
                      color: primarySlate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildDummyText('Issue Date: ', size: 10, color: mutedSlate),
                      buildDummyText('28 Sep 2026', size: 10, bold: true, color: primarySlate),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildDummyText('Due Date: ', size: 10, color: mutedSlate),
                      buildDummyText('13 Oct 2026', size: 10, bold: true, color: primarySlate),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Container(height: 1, color: borderColor),
        const SizedBox(height: 18),

        // Bill To & Summary Card Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDummyText('BILLED TO', size: 9, bold: true, color: mutedSlate),
                const SizedBox(height: 4),
                buildDummyText('Georgo graph LTD', size: 13, bold: true, color: primarySlate),
                const SizedBox(height: 2),
                buildDummyText('vajsisi@shjs.com  •  +1 987-654-3210', size: 9.5, color: secondarySlate),
                buildDummyText('742 Evergreen Terrace, Brooklyn, NY 11201', size: 9.5, color: secondarySlate),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildDummyText('TOTAL DUE', size: 8.5, bold: true, color: mutedSlate),
                  const SizedBox(height: 2),
                  buildDummyText('Rs. 1,120.00', size: 15, bold: true, color: primarySlate),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: buildDummyText('DESCRIPTION', bold: true, size: 9, color: secondarySlate),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: buildDummyText('QTY', bold: true, size: 9, color: secondarySlate),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText('UNIT PRICE', bold: true, size: 9, color: secondarySlate),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText('TAX', bold: true, size: 9, color: secondarySlate),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText('AMOUNT', bold: true, size: 9, color: secondarySlate),
                ),
              ),
            ],
          ),
        ),

        // Table Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: badgeBg)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDummyText('Premium Protective Helmet', bold: true, size: 11, color: primarySlate),
                    const SizedBox(height: 2),
                    buildDummyText('Matte finish, ISI certified', size: 9, color: const Color(0xFF94A3B8)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: buildDummyText('1.0', size: 11, color: primarySlate),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText('Rs. 1,000.00', size: 11, color: primarySlate),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText('12.0%', size: 11, color: secondarySlate),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildDummyText('Rs. 1,120.00', bold: true, size: 11, color: primarySlate),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Summary Card
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildDummyText('Subtotal', size: 10.5, color: secondarySlate),
                    buildDummyText('Rs. 1,000.00', size: 10.5, color: primarySlate),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildDummyText('Tax (12%)', size: 10.5, color: secondarySlate),
                    buildDummyText('Rs. 120.00', size: 10.5, color: primarySlate),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: borderColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildDummyText('Total', bold: true, size: 13, color: primarySlate),
                    buildDummyText('Rs. 1,120.00', bold: true, size: 14, color: primarySlate),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Notes & Terms Callout
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: bgLight,
            borderRadius: BorderRadius.all(Radius.circular(6)),
            border: Border(
              left: BorderSide(color: mutedSlate, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDummyText('Notes & Terms', bold: true, size: 9.5, color: primarySlate),
              const SizedBox(height: 2),
              buildDummyText('Thank you for your business! Payment is due as specified above.', size: 9.5, color: secondarySlate),
            ],
          ),
        ),

        const Spacer(),

        // Payment Details & Signature
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: buildDummyPaymentDetails(type: documentType, primary: primarySlate),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/signature.png',
                  width: 80,
                  height: 32,
                ),
                Container(width: 120, height: 1.5, color: const Color(0xFF94A3B8)),
                const SizedBox(height: 4),
                buildDummyText('Authorized Signature', bold: true, color: mutedSlate, size: 9),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
