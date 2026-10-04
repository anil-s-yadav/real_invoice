import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# I will find 'pw.Spacer(),' up to 'return [' for the next builder, and rewrite the footer block.
# Wait, let's just find the exact block and replace it using substrings.

# We need to replace:
#           pw.Expanded(
#             child: _buildPaymentDetails(
#               doc,
#               payments,
#               profile,
#               primaryColor: primaryColor,
#             ),
#           ),
#           pw.Row(
#             crossAxisAlignment: pw.CrossAxisAlignment.end,
#             children: [
#               if (stampBytes != null && doc.showStamp)

pattern = r"(pw\.Expanded\(\s*child: _buildPaymentDetails\([\s\S]*?primaryColor: primaryColor,\s*\),\s*\),\s*)pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*(if \(stampBytes != null && doc\.showStamp\))"

replacement = r"""\1pw.Expanded(
            flex: 4,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                \2"""

content = re.sub(pattern, replacement, content)

# And now we need to close the pw.Expanded( by adding ), after the inner pw.Row closes.
# The inner pw.Row ends precisely here:
#                       pw.Text(
#                         'Authorized Signature',
#                         ...
#                       ),
#                     ],
#                   ),
#               ],
#             ),
#           ],
#         ),

pattern2 = r"(pw\.Text\([\s\S]*?'Authorized Signature'[\s\S]*?\),\s*],\s*\),\s*],\s*\)),(\s*],\s*\),)"
replacement2 = r"\1,\n          ),\2"
content = re.sub(pattern2, replacement2, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
