with open('d:/real_invoice/lib/features/home/presentation/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import '../../ads/ad_banner_widget.dart';"
if import_statement not in content:
    content = import_statement + "\n" + content

body_old = """                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Premium Welcome Offer Banner"""

body_new = """                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: AdBannerWidget(),
                    ),
                    // Premium Welcome Offer Banner"""

content = content.replace(body_old, body_new)

with open('d:/real_invoice/lib/features/home/presentation/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("home_screen.dart patched with AdBannerWidget")