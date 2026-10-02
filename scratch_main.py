import re

filepath = 'lib/main.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

old_settings = '''      // Explicitly enable offline persistence and unlimited cache size
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );'''

new_settings = '''      try {
        // Explicitly enable offline persistence and unlimited cache size
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        debugPrint("Firestore settings failed: $e");
      }'''

content = content.replace(old_settings, new_settings)
with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated main.dart')
