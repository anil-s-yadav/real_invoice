import re

with open('lib/features/customers/presentation/customer_editor_sheet.dart', 'r') as f:
    content = f.read()

# Add controllers
content = content.replace('late final TextEditingController _gstinController;', 'late final TextEditingController _gstinController;\n  late final TextEditingController _cinController;\n  late final TextEditingController _contactPersonController;\n  late final TextEditingController _websiteController;')

# Init controllers
init_pattern = r"_gstinController = TextEditingController\(text: widget\.initialCustomer\?\.gstin\);"
replacement = "_gstinController = TextEditingController(text: widget.initialCustomer?.gstin);\n    _cinController = TextEditingController(text: widget.initialCustomer?.cin);\n    _contactPersonController = TextEditingController(text: widget.initialCustomer?.contactPerson);\n    _websiteController = TextEditingController(text: widget.initialCustomer?.website);"
content = re.sub(init_pattern, replacement, content)

# Dispose controllers
disp_pattern = r"_gstinController\.dispose\(\);"
replacement = "_gstinController.dispose();\n    _cinController.dispose();\n    _contactPersonController.dispose();\n    _websiteController.dispose();"
content = re.sub(disp_pattern, replacement, content)

# Add to Customer model in save
save_pattern = r"gstin: _gstinController\.text\.trim\(\)\.isEmpty\s*\?\s*null\s*:\s*_gstinController\.text\.trim\(\),"
replacement = "gstin: _gstinController.text.trim().isEmpty ? null : _gstinController.text.trim(),\n      cin: _cinController.text.trim().isEmpty ? null : _cinController.text.trim(),\n      contactPerson: _contactPersonController.text.trim().isEmpty ? null : _contactPersonController.text.trim(),\n      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),"
content = re.sub(save_pattern, replacement, content)

# UI additions
ui_pattern = r"CustomTextField\(\s*controller: _notesController,[\s\S]*?\),"
ui_replacement = """CustomTextField(
                controller: _notesController,
                label: 'Notes / Payment Terms (Optional)',
                icon: Icons.note_alt_outlined,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Additional Optional Details', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contactPersonController,
                label: 'Contact Person Name (Optional)',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cinController,
                label: 'CIN (Optional)',
                icon: Icons.business_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _websiteController,
                label: 'Website (Optional)',
                icon: Icons.language_outlined,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
              ),"""
content = re.sub(ui_pattern, ui_replacement, content)

with open('lib/features/customers/presentation/customer_editor_sheet.dart', 'w') as f:
    f.write(content)
