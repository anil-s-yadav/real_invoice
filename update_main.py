import re

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_line = "import 'core/services/local_notification_service.dart';\n"
if "import 'core/services/local_notification_service.dart';" not in content:
    content = content.replace("import 'core/theme/theme_cubit.dart';", "import 'core/theme/theme_cubit.dart';\n" + import_line)

init_block = r'''  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: ");
  }'''

new_init_block = r'''  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: ");
  }
  
  try {
    final notificationService = LocalNotificationService();
    await notificationService.init();
    await notificationService.scheduleDailyReminders();
  } catch (e) {
    debugPrint("Local Notifications init failed: ");
  }'''

content = content.replace(init_block, new_init_block)

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(content)
