import re

with open('lib/features/documents/presentation/pdf_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add to _showDocumentSettings
toggles = r"""                  SwitchListTile(
                    title: Text(
                      'Show Signature',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Include business signature on PDF',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    value: _document.showSignature,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) {
                      setStateSheet(() {
                        _document = _document.copyWith(showSignature: val);
                      });
                      setState(() {});
                      context.read<DocumentBloc>().add(SaveDocumentEvent(_document));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      'Show Stamp',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Include business stamp on PDF',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    value: _document.showStamp,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) {
                      setStateSheet(() {
                        _document = _document.copyWith(showStamp: val);
                      });
                      setState(() {});
                      context.read<DocumentBloc>().add(SaveDocumentEvent(_document));
                    },
                  ),
                  const Divider(height: 1),"""

content = content.replace("const Divider(),\n                  const SizedBox(height: AppDimensions.xl),", f"const Divider(height: 1),\n{toggles}\n                  const SizedBox(height: AppDimensions.xl),")

# Replace activeThumbColor with activeTrackColor in existing toggle to be safe
content = content.replace("activeThumbColor: AppColors.primary,", "activeTrackColor: AppColors.primary,")

with open('lib/features/documents/presentation/pdf_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
