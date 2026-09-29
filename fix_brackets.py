import re

path = 'd:/real_invoice/lib/features/documents/presentation/dummy_templates/premium_modern_dummy.dart'
with open(path, 'r') as f:
    content = f.read()

target = '''          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: buildDummyPaymentDetails(primary: primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/signature.png',
                    width: 80,
                    height: 30,
                  ),
                  Container(width: 100, height: 1.5, color: Colors.black87),
                  const SizedBox(height: 4),
                  buildDummyText('Authorized Signature', color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
        ],
      ),
    );
}'''

replacement = '''          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: buildDummyPaymentDetails(primary: primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/signature.png',
                    width: 80,
                    height: 30,
                  ),
                  Container(width: 100, height: 1.5, color: Colors.black87),
                  const SizedBox(height: 4),
                  buildDummyText('Authorized Signature', color: Colors.grey.shade600),
                ],
              ),
            ],
          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}'''

content = content.replace(target, replacement)
with open(path, 'w') as f:
    f.write(content)

print("Fixed brackets")