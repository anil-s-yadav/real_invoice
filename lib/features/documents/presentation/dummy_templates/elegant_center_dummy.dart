import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildElegantCenterDummy(DocumentType documentType) {
  final primary = const Color(0xFF0D47A1);
  final lightBlue = const Color(0xFFD6E4F0);

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primary.withAlpha(50), width: 1),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    'assets/icons/applogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Villa Contentezza',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                color: primary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 10, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            buildDummyText('Via Tammaricella 128', color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Icon(Icons.phone, size: 10, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            buildDummyText('+1 345-67-890', color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Icon(Icons.email, size: 10, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            buildDummyText(
              'info@villacontentezza.com',
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
            Icon(Icons.language, size: 10, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            buildDummyText('villacontentezza.com', color: Colors.grey.shade600),
          ],
        ),
        const SizedBox(height: 12),
        Container(height: 1.5, color: lightBlue),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDummyText('Paid By', color: primary, bold: true, size: 11),
                const SizedBox(height: 6),
                buildDummyText('John Doe', size: 11),
                const SizedBox(height: 6),
                buildDummyText('john.doe@example.com', size: 11),
              ],
            ),
            Text(
              documentType.displayName.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                color: primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyText(
                    'Booking Details',
                    color: primary,
                    bold: true,
                    size: 11,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: buildDummyText('Check-in', size: 11),
                      ),
                      buildDummyText('Apr 25, 2026', size: 11),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: buildDummyText('Check-out', size: 11),
                      ),
                      buildDummyText('May 2, 2026', size: 11),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: buildDummyText(
                        'Receipt #',
                        color: primary,
                        bold: true,
                        size: 11,
                      ),
                    ),
                    buildDummyText('REC-2026-001', size: 11),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: buildDummyText(
                        'Receipt Date',
                        color: primary,
                        bold: true,
                        size: 11,
                      ),
                    ),
                    buildDummyText('Apr 25, 2026', size: 11),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Table
        Container(
          decoration: BoxDecoration(border: Border.all(color: primary)),
          child: Column(
            children: [
              Container(
                color: primary,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildDummyText(
                        'Quantity',
                        color: Colors.white,
                        bold: true,
                        size: 10,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: buildDummyText(
                        'Description',
                        color: Colors.white,
                        bold: true,
                        size: 10,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          'Unit Price',
                          color: Colors.white,
                          bold: true,
                          size: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          'Amount',
                          color: Colors.white,
                          bold: true,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('7.00', size: 11),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: buildDummyText(
                        'Nights in apartment Lido',
                        size: 11,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.00', size: 11),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.00*', size: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('28.00', size: 11),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: buildDummyText('Breakfast', size: 11),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.00', size: 11),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.00*', size: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('1.00', size: 11),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: buildDummyText('Airport pick-up', size: 11),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.00', size: 11),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.00*', size: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: primary),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: const SizedBox()),
                    Expanded(
                      flex: 2,
                      child: buildDummyText('Subtotal', size: 11),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.05', size: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: const SizedBox()),
                    Expanded(flex: 2, child: buildDummyText('Tax', size: 11)),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText('.95', size: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: primary),
              Container(
                color: lightBlue,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: const SizedBox()),
                    Expanded(
                      flex: 2,
                      child: buildDummyText(
                        'Total',
                        color: primary,
                        bold: true,
                        size: 12,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: buildDummyText(
                          '.00',
                          color: primary,
                          bold: true,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: buildDummyText('*Tax: 7.50%', color: Colors.grey.shade600),
        ),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDummyText('Notes', color: primary, bold: true, size: 11),
                  const SizedBox(height: 4),
                  buildDummyText(
                    'Thank you for staying with us. We look forward to your next visit :)',
                    size: 11,
                  ),
                  const SizedBox(height: 16),
                  buildDummyPaymentDetails(
                    type: documentType,
                    primary: primary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/signature.png',
                  width: 80,
                  height: 30,
                ),
                Container(width: 130, height: 1.5, color: primary),
                const SizedBox(height: 4),
                buildDummyText(
                  'Authorized Signature',
                  color: primary,
                  size: 11,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
