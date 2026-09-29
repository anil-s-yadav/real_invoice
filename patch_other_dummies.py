import re

def update_file(path, is_premium):
    with open(path, 'r') as f:
        content = f.read()
    
    # We want to replace from 'Row(' to the end of the file or just the bottom row
    # The bottom row has crossAxisAlignment: CrossAxisAlignment.end,
    # It contains Icon(Icons.qr_code_2... and Image.asset('assets/icons/signature.png'...

    # Find the Notes / Terms part
    notes_pattern = r"buildDummyText\('Notes / Terms:', bold: true, size: 10\),\s*buildDummyText\('Thank you for your business!', color: Colors\.grey\.shade600\),\s*const Spacer\(\),"
    
    # Actually, we can just replace everything after 'const Spacer(),' up to the end of the file.
    parts = content.split('const Spacer(),')
    if len(parts) == 2:
        primary_color = 'primary' if is_premium else 'Colors.grey.shade600'
        new_bottom = f'''
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: buildDummyPaymentDetails(primary: {primary_color}),
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
}}
'''
        with open(path, 'w') as f:
            f.write(parts[0] + 'const Spacer(),' + new_bottom)
        print(f"Updated {path}")
    else:
        print(f"Could not find Spacer in {path}")

update_file('d:/real_invoice/lib/features/documents/presentation/dummy_templates/classic_free_dummy.dart', False)
update_file('d:/real_invoice/lib/features/documents/presentation/dummy_templates/premium_modern_dummy.dart', True)