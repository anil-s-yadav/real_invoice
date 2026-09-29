import 'package:flutter/material.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_model.dart';

class DummyTemplateWidget extends StatelessWidget {
  final String templateId;
  final DocumentType documentType;

  const DummyTemplateWidget({
    super.key,
    required this.templateId,
    this.documentType = DocumentType.invoice,
  });

  @override
  Widget build(BuildContext context) {
    if (templateId == TemplateRegistry.premiumModern) {
      return _buildPremiumModern();
    }
    return _buildClassicFree();
  }

  Widget _buildClassicFree() {
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
                    _text('Tesla Inc.', size: 14, bold: true),
                    _text(
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
                    _text(
                      documentType.displayName.toUpperCase(),
                      size: 22,
                      bold: true,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(height: 4),
                    _text('# INV-2026-0001', bold: true, size: 11),
                    _text('Date: 28 Sep 2026', size: 10),
                    _text('Due: 13 Oct 2026', size: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _text('BILL TO:', size: 10, bold: true, color: Colors.grey.shade500),
          _text('Georgo graph LTD', size: 12, bold: true),
          _text(
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
                Expanded(flex: 3, child: _text('Item', bold: true)),
                Expanded(flex: 1, child: _text('Qty', bold: true)),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _text('Price', bold: true),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _text('Tax', bold: true),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _text('Total', bold: true),
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
                Expanded(flex: 3, child: _text('Helmate')),
                Expanded(flex: 1, child: _text('1.0')),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _text('Rs. 1,000.00'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _text('12.0%'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _text('Rs. 1,120.00'),
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
                    children: [_text('Subtotal'), _text('Rs. 1,000.00')],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_text('Tax'), _text('Rs. 120.00')],
                  ),
                  const Divider(color: Colors.black, thickness: 1.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _text('Total', bold: true, size: 14),
                      _text('Rs. 1,120.00', bold: true, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _text('Notes / Terms:', bold: true, size: 10),
          _text('Thank you for your business!', color: Colors.grey.shade600),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.qr_code_2, size: 50, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _text(
                      'Payment Details',
                      bold: true,
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                    _text(
                      'Bank: Bank hsj\nA/C No: 73836368\nIFSC: hsiwiwi\nUPI: bsjske',
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
                  Container(width: 100, height: 1.5, color: Colors.black87),
                  const SizedBox(height: 4),
                  _text('Authorized Signature', color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumModern() {
    final primary = const Color(0xFF2563EB); // Modern Pro Blue
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _text(
                        documentType.displayName.toUpperCase(),
                        size: 24,
                        bold: true,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      _text('# INV-2026-0001', color: Colors.white, size: 11),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _text('Issue Date: 28 Sep 2026', color: Colors.white70),
                      _text('Due Date: 13 Oct 2026', color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _text(
                              'FROM:',
                              size: 10,
                              bold: true,
                              color: primary,
                            ),
                            const SizedBox(height: 4),
                            Image.asset(
                              'assets/icons/applogo.png',
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(height: 4),
                            _text('Tesla Inc.', size: 12, bold: true),
                            _text(
                              'teslacom@gmail.com\n9876543210\nRoad no. 397, near weastern railways city, Ghatkopar USA\n- 1087221.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _text(
                              'BILL TO:',
                              size: 10,
                              bold: true,
                              color: primary,
                            ),
                            const SizedBox(height: 4),
                            _text('Georgo graph LTD', size: 12, bold: true),
                            _text(
                              'vajsisi@shjs.com\n9876543210\nHE wants personal loan for your help and more than\n400070',
                              align: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(color: primary),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _text('Item', bold: true, color: Colors.white),
                        ),
                        Expanded(
                          flex: 1,
                          child: _text('Qty', bold: true, color: Colors.white),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _text(
                              'Price',
                              bold: true,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _text(
                              'Tax',
                              bold: true,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _text(
                              'Total',
                              bold: true,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _text('Helmate')),
                        Expanded(flex: 1, child: _text('1.0')),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _text('Rs. 1,000.00'),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _text('12.0%'),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _text('Rs. 1,120.00'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _text('Subtotal'),
                              _text('Rs. 1,000.00'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [_text('Tax'), _text('Rs. 120.00')],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _text(
                                'Total',
                                bold: true,
                                size: 14,
                                color: primary,
                              ),
                              _text(
                                'Rs. 1,120.00',
                                bold: true,
                                size: 14,
                                color: primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        left: BorderSide(color: primary, width: 3),
                      ),
                    ),
                    child: _text('Thank you for your business!'),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.qr_code_2, size: 50, color: Colors.black),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _text(
                              'Payment Details',
                              bold: true,
                              size: 10,
                              color: primary,
                            ),
                            _text(
                              'Bank: Bank hsj\nA/C No: 73836368\nIFSC: hsiwiwi\nUPI: bsjske',
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
                          _text('Authorized Signature', color: primary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _text(
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
}
