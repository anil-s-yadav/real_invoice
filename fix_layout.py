import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# We currently have this in Classic/Premium:
#           pw.Expanded(
#             child: _buildPaymentDetails(...),
#           ),
#           pw.Expanded(
#             flex: 4,
#             child: pw.Row(
#               mainAxisAlignment: pw.MainAxisAlignment.end,
#               crossAxisAlignment: pw.CrossAxisAlignment.end,
#               children: [

# Let's fix Classic and Premium:
pattern = r"pw\.Expanded\(\s*child: _buildPaymentDetails\([\s\S]*?primaryColor: primaryColor,\s*\),\s*\),\s*pw\.Expanded\(\s*flex: 4,\s*child: pw\.Row\(\s*mainAxisAlignment: pw\.MainAxisAlignment\.end,\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \["

replacement = r"""pw.Expanded(
            child: _buildPaymentDetails(
              doc,
              payments,
              profile,
              primaryColor: primaryColor,
            ),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: ["""

content = re.sub(pattern, replacement, content)

# Now we need to remove the closing parenthesis of the Expanded wrapper.
# In Classic:
classic_sig = r"pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(\s*fontSize: 9,\s*fontWeight: pw\.FontWeight\.bold,\s*color: mutedColor,\s*\),\s*\),\s*],\s*\),\s*],\s*\),\s*\),"
classic_sig_repl = r"""pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),"""
content = re.sub(classic_sig, classic_sig_repl, content)

# Premium:
premium_sig = r"pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(\s*fontSize: 10,\s*color: primaryColor,\s*fontWeight: pw\.FontWeight\.bold,\s*\),\s*\),\s*],\s*\),\s*],\s*\),\s*\),"
premium_sig_repl = r"""pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),"""
content = re.sub(premium_sig, premium_sig_repl, content)

# For Elegant, we had wrapped the inner pw.Row with Expanded.
elegant_pattern = r"pw\.Expanded\(\s*flex: 4,\s*child: pw\.Row\(\s*mainAxisAlignment: pw\.MainAxisAlignment\.end,\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*if \(stampBytes != null && doc\.showStamp\)"
elegant_repl = r"""pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (stampBytes != null && doc.showStamp)"""
content = re.sub(elegant_pattern, elegant_repl, content)

elegant_sig = r"pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(fontSize: 10, color: primaryColor\),\s*\),\s*],\s*\),\s*],\s*\),\s*\),"
elegant_sig_repl = r"""pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    ),
                  ],
                ),
            ],
          ),"""
content = re.sub(elegant_sig, elegant_sig_repl, content)


# Now, shrink the widths of Stamp and Signature from 120/150 to 100 to ensure they fit!
content = content.replace("width: 150,", "width: 100,")
content = content.replace("width: 120,", "width: 100,")
# Also reduce padding slightly
content = content.replace("padding: const pw.EdgeInsets.only(right: 20)", "padding: const pw.EdgeInsets.only(right: 12)")

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
