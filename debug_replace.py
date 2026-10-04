import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# The blocks look like this:
#             pw.Expanded(
#               flex: 3,
#               child: _buildPaymentDetails(
#                 doc,
#                 payments,
#                 profile,
#                 primaryColor: primaryColor,
#               ),
#             ),
#             pw.Row(
#               crossAxisAlignment: pw.CrossAxisAlignment.end,
#               children: [

pattern = r"pw\.Expanded\(\s*flex: 3,\s*child: _buildPaymentDetails\([\s\S]*?primaryColor: primaryColor,\s*\),\s*\),\s*pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \["

replacement = r"""pw.Expanded(
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
                children: ["""

content = re.sub(pattern, replacement, content)

# Now close the Expanded. The previous closing was:
#                         pw.Text(
#                           'Authorized Signature',
#                           style: pw.TextStyle(fontSize: 10, color: primaryColor),
#                         ),
#                       ],
#                     ),
#                 ],
#               ),
#           ],
#         ),
#
# But wait, we need to carefully find the end of the inner pw.Row!
# It's better to just do a string replacement.
