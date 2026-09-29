import 'package:flutter/material.dart';
import '../../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget buildClassicFreeDummy(DocumentType documentType) {

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/applogo.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 8),
                    buildDummyText('Tesla Inc.', size: 14, bold: true),
                    buildDummyText(
                      'teslacom@gmail.com\n9876543210\nRoad no. 397, near weastern railways city, Ghatkopar USA - 1087221.\nGSTIN: HE837HDKUEJ33',
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildDummyText(
                      documentType.displayName.toUpperCase(),
                      size: 22,
                      bold: true,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(height: 4),
                    buildDummyText('# INV-2026-0001', bold: true, size: 11),
                    buildDummyText('Date: 28 Sep 2026', size: 10),
                    buildDummyText('Due: 13 Oct 2026', size: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          buildDummyText('BILL TO:', size: 10, bold: true, color: Colors.grey.shade500),
          buildDummyText('Georgo graph LTD', size: 12, bold: true),
          buildDummyText(
            'vajsisi@shjs.com\n9876543210\nHE wants personal loan for your help and more than 400070',
          ),
          const SizedBox(height: 24),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: buildDummyText('Item', bold: true)),
                Expanded(flex: 1, child: buildDummyText('Qty', bold: true)),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText('Price', bold: true),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText('Tax', bold: true),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText('Total', bold: true),
                  ),
                ),
              ],
            ),
          ),
          // Table Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: buildDummyText('Helmate')),
                Expanded(flex: 1, child: buildDummyText('1.0')),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText('Rs. 1,000.00'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText('12.0%'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: buildDummyText('Rs. 1,120.00'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 180,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [buildDummyText('Subtotal'), buildDummyText('Rs. 1,000.00')],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [buildDummyText('Tax'), buildDummyText('Rs. 120.00')],
                  ),
                  const Divider(color: Colors.black, thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildDummyText('Total', bold: true, size: 14),
                      buildDummyText('Rs. 1,120.00', bold: true, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          buildDummyText('Notes / Terms:', bold: true, size: 10),
          buildDummyText('Thank you for your business!', color: Colors.grey.shade600),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: buildDummyPaymentDetails(type: documentType, primary: Colors.grey.shade600),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/signature.png',
                    width: 80,
                    height: 30,
                  ),
                  Container(width: 100, height: 1.5, color: Colors.black87),
                  const SizedBox(height: 4),
                  buildDummyText('Authorized Signature', color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
        ],
      ),
    );
}
