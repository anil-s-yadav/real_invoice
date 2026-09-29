import re

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'r') as f:
    content = f.read()

# Let's find everything from 'const Spacer(),' to the end of the file
target = re.search(r'          const Spacer\(\),.*', content, re.DOTALL).group(0)

new_bottom = '''          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDummyText('Notes', color: primary, bold: true, size: 11),
                    const SizedBox(height: 4),
                    buildDummyText('Thank you for staying with us. We look forward to your next visit :)', size: 11),
                    const SizedBox(height: 16),
                    buildDummyPaymentDetails(primary: primary),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/signature.png', width: 80, height: 30),
                  Container(width: 130, height: 1.5, color: primary),
                  const SizedBox(height: 4),
                  buildDummyText('Authorized Signature', color: primary, size: 11),
                ],
              ),
            ],
          ),
        ],
      ),
    );
}
'''

content = content.replace(target, new_bottom)

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'w') as f:
    f.write(content)

print("Fixed syntax")