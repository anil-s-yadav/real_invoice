with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

start_index = -1
for i, line in enumerate(lines):
    if "_showDateRangePicker" in line and "Future<void>" in line:
        start_index = i
        break

if start_index != -1:
    print("".join(lines[start_index:start_index+50]))