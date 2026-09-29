import re

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'r') as f:
    content = f.read()

# Replace the whole header up to 'const SizedBox(height: 16),'
target_regex = r'// Header.*?const SizedBox\(height: 16\),'

new_header = '''// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 32,
                  height: 32,
                  color: primary.withAlpha(20),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset('assets/icons/applogo.png', fit: BoxFit.contain, color: primary),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Villa Contentezza',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  color: primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),'''

content = re.sub(target_regex, new_header, content, flags=re.DOTALL)

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'w') as f:
    f.write(content)

print("Updated dummy layout correctly this time!")