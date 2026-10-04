with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    
start_idx = -1
for i, line in enumerate(lines):
    if "static pw.Widget _buildPaymentDetails" in line:
        start_idx = i
        break

if start_idx != -1:
    for i in range(start_idx, start_idx + 100):
        if i < len(lines):
            print(lines[i], end='')
