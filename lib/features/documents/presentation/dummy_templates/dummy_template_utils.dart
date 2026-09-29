import 'package:flutter/material.dart';
import 'package:invoz/features/documents/domain/document_model.dart';

Widget buildDummyText(
  String text, {
  double size = 10,
  bool bold = false,
  Color color = Colors.black87,
  TextAlign align = TextAlign.left,
}) {
  return Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: size,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
      height: 1.2,
    ),
  );
}

Widget buildDummyPaymentDetails({
  Color primary = Colors.black87,
  DocumentType? type,
}) {
  if (type == DocumentType.receipt) return const SizedBox();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.qr_code_2, size: 50, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          buildDummyText(
            'Scan to Pay',
            size: 8,
            bold: true,
            color: Colors.grey.shade700,
          ),
        ],
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDummyText(
              'PAYMENT DETAILS',
              bold: true,
              size: 10,
              color: primary,
            ),
            const SizedBox(height: 6),
            buildDummyText(
              'UPI (PhonePe): merchant@okaxis',
              bold: true,
              size: 10,
            ),
            const SizedBox(height: 4),
            buildDummyText('Bank: HDFC Bank', bold: true, size: 10),
            const SizedBox(height: 1),
            buildDummyText('A/C: 50200012345678', size: 10),
            buildDummyText(
              'IFSC: HDFC0001234',
              size: 9,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    ],
  );
}
