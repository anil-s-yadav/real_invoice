import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def replace_footer(template_content, signature_height):
    # This matches the end of the Spacer(), through the Payment Details & Signature Row
    pattern = r"pw\.Spacer\(\),\s*// Payment Details & Signature\s*pw\.Row\(\s*mainAxisAlignment: pw\.MainAxisAlignment\.spaceBetween,\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*pw\.Expanded\(\s*child: _buildPaymentDetails\([\s\S]*?primaryColor: primaryColor,\s*\),\s*\),\s*pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*if \(stampBytes != null && doc\.showStamp\)\s*pw\.Padding\(\s*padding: const pw\.EdgeInsets\.only\(right: 20\),\s*child: pw\.Column\([\s\S]*?pw\.Text\(\s*'Company Stamp',\s*style: pw\.TextStyle\([\s\S]*?\),\s*\),\s*\]\s*\),\s*\),\s*if \(signatureBytes != null && doc\.showSignature\)\s*pw\.Column\([\s\S]*?pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\([\s\S]*?\),\s*\),\s*\]\s*\),\s*\]\s*\),\s*\]\s*\),"
    
    # We will replace it with a layout that forces Expanded around BOTH sections to prevent silent layout dropping
    replacement = f'''pw.Spacer(),
      // Payment Details & Signature
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            flex: 3,
            child: _buildPaymentDetails(
              doc,
              payments,
              profile,
              primaryColor: primaryColor,
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (stampBytes != null && doc.showStamp)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 20),
                    child: pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(stampBytes), height: {signature_height}),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 120,
                          child: pw.Divider(color: primaryColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          \\'Company Stamp\\',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (signatureBytes != null && doc.showSignature)
                  pw.Column(
                    children: [
                      pw.Image(pw.MemoryImage(signatureBytes), height: {signature_height}),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        width: 120,
                        child: pw.Divider(color: primaryColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        \\'Authorized Signature\\',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),'''
    
    # Actually, we can't do string replace safely on all three templates at once unless the regex is perfect.
    # Let's just do a manual Python replace using known landmarks.
    pass

import sys
sys.exit(0)
