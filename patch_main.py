with open('d:/real_invoice/lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import 'package:google_mobile_ads/google_mobile_ads.dart';"
if import_statement not in content:
    content = import_statement + "\n" + content

init_old = """  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();"""
init_new = """  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  Bloc.observer = AppBlocObserver();"""

if "MobileAds.instance.initialize" not in content:
    content = content.replace(init_old, init_new)

with open('d:/real_invoice/lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("main.dart patched")