import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# For Free Classic
pattern1 = r"(child: _buildPaymentDetails\([\s\S]*?\),\s*),\s*pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*if \(stampBytes != null"
replacement1 = r"""\1
            pw.Expanded(
              flex: 4,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (stampBytes != null"""
content = re.sub(pattern1, replacement1, content)

# We need to also close the pw.Expanded bracket.
# It ends with:
#                         pw.Text('Authorized Signature', style: ...),
#                       ],
#                     ),
#                 ],
#               ),
#           ],
#         ),

pattern2 = r"(pw\.Text\([\s\S]*?'Authorized Signature'[\s\S]*?\),\s*],\s*\),\s*],\s*\)),\s*],\s*\),"
replacement2 = r"\1,\n            ),\n          ],\n        ),"
content = re.sub(pattern2, replacement2, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
