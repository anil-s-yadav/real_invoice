import re

filepath = 'lib/features/home/presentation/home_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_logic = '''          if (maxDocs != -1) {
            final today = DateTime.now();
            int todayCount = docState.documents.where((d) =>
              d.createdAt.year == today.year &&
              d.createdAt.month == today.month &&
              d.createdAt.day == today.day
            ).length;'''

new_logic = '''          if (maxDocs != -1) {
            final today = DateTime.now();
            int todayCount = 0;
            if (docState is DocumentLoaded) {
              todayCount = docState.documents.where((d) =>
                d.createdAt.year == today.year &&
                d.createdAt.month == today.month &&
                d.createdAt.day == today.day
              ).length;
            }'''

content = content.replace(old_logic, new_logic)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated home')
