import re

filepath = 'lib/main.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove DevicePreview from runApp
old_runapp = 'runApp(DevicePreview(enabled: kDebugMode, builder: (_) => const InvozRoot()));'
new_runapp = 'runApp(const InvozRoot());'
content = content.replace(old_runapp, new_runapp)

# Swap Firebase and MobileAds initialization just to be safe
old_init = '''  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  Bloc.observer = AppBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);'''

new_init = '''  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("MobileAds init failed: $e");
  }'''

content = content.replace(old_init, new_init)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated main.dart')
