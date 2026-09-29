import re

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'r') as f:
    content = f.read()

old_header = '''          // Header
          Center(child: Image.asset('assets/icons/applogo.png', width: 60, height: 60, color: primary)),
          const SizedBox(height: 8),
          Text('Villa Contentezza', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, color: primary, fontWeight: FontWeight.w400)),'''

new_header = '''          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 48,
                  height: 48,
                  color: primary.withAlpha(20),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/icons/applogo.png', width: 32, height: 32, fit: BoxFit.contain, color: primary),
                ),
              ),
              const SizedBox(width: 16),
              Text('Villa Contentezza', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, color: primary, fontWeight: FontWeight.w400)),
            ],
          ),'''

content = content.replace(old_header, new_header)

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'w') as f:
    f.write(content)

print("Updated dummy layout")