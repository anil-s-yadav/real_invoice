import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Change text
content = content.replace("'Stamp',", "'Company Stamp',")

# 2. Free Classic & Premium Modern:
# They have pw.Expanded(child: _buildPaymentDetails(...)), pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
# I will replace pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [ 
# with pw.Expanded(flex: 4, child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, crossAxisAlignment: pw.CrossAxisAlignment.end, children: [

pattern = r"(\s*)pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*if \(stampBytes != null && doc\.showStamp\)"
replacement = r"""\1pw.Expanded(
\1  flex: 4,
\1  child: pw.Row(
\1    mainAxisAlignment: pw.MainAxisAlignment.end,
\1    crossAxisAlignment: pw.CrossAxisAlignment.end,
\1    children: [
\1      if (stampBytes != null && doc.showStamp)"""
content = re.sub(pattern, replacement, content)

# 3. Close the expanded correctly.
# The closure is after the Authorized signature text block.
#                         pw.Text(
#                           'Authorized Signature',
#                           style: pw.TextStyle(
#                             fontSize: 9,
#                             fontWeight: pw.FontWeight.bold,
#                             color: mutedColor,
#                           ),
#                         ),
#                       ],
#                     ),
#                 ],
#               ),
#           ],
#         ),

# We just need to add a ), after the inner pw.Row closes.
# It's at the end of ], \n ), \n ], \n ), \n ], \n ),
# A much safer way is to just do a string replace on the exact Authorized Signature blocks:
# Classic:
classic_sig = r"pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(\s*fontSize: 9,\s*fontWeight: pw\.FontWeight\.bold,\s*color: mutedColor,\s*\),\s*\),\s*],\s*\),\s*],\s*\),"
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
          ),
        ),"""
content = re.sub(classic_sig, classic_sig_repl, content)

# Premium:
premium_sig = r"pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(\s*fontSize: 10,\s*color: primaryColor,\s*fontWeight: pw\.FontWeight\.bold,\s*\),\s*\),\s*],\s*\),\s*],\s*\),"
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
          ),
        ),"""
content = re.sub(premium_sig, premium_sig_repl, content)

# Elegant:
elegant_sig = r"pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(fontSize: 10, color: primaryColor\),\s*\),\s*],\s*\),\s*],\s*\),"
elegant_sig_repl = r"""pw.Text(
                      'Authorized Signature',
                      style: pw.TextStyle(fontSize: 10, color: primaryColor),
                    ),
                  ],
                ),
            ],
          ),
        ),"""
content = re.sub(elegant_sig, elegant_sig_repl, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
