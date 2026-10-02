import re

filepath = 'lib/main.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# I will replace the void main() function.
old_main_start = 'void main() async {'
old_main_end = 'runApp(const InvozRoot());\n}'

new_main = '''import 'dart:ui'; // Added for PlatformDispatcher

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Dart errors and show them on screen instead of crashing silently
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("FlutterError: ${details.exception}");
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("PlatformError: $error");
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "App Error:\n${details.exception}\n\nStacktrace:\n${details.stack}",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  };

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
  }
  
  try {
    // Explicitly enable offline persistence and unlimited cache size
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firestore settings failed: $e");
  }
  
  runApp(const InvozRoot());
}'''

start_idx = content.find(old_main_start)
end_idx = content.find(old_main_end) + len(old_main_end)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + new_main + content[end_idx:]
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Added ErrorWidget and global error handlers")
else:
    print("Could not find main() to replace")
