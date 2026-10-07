import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

init_block = r"""  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }"""

new_init_block = r"""  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  try {
    final notificationService = LocalNotificationService();
    await notificationService.init();
    await notificationService.scheduleDailyReminders();
  } catch (e) {
    debugPrint("Local Notifications init failed: $e");
  }"""

content = content.replace(init_block, new_init_block)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
