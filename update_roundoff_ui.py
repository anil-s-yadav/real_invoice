import re

with open('lib/features/documents/presentation/document_editor_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _enableRoundOff state variable
content = content.replace(
    'bool _includePaymentDetails = false;',
    'bool _includePaymentDetails = false;\n  bool _enableRoundOff = true;'
)

# 2. Initialize in initState
content = content.replace(
    '_includePaymentDetails = doc?.includePaymentDetails ?? true;',
    '_includePaymentDetails = doc?.includePaymentDetails ?? true;\n    _enableRoundOff = doc?.enableRoundOff ?? true;'
)

# 3. Add to _buildDocument()
content = content.replace(
    'includePaymentDetails: \\',
    'enableRoundOff: _enableRoundOff,\n      includePaymentDetails: \\'
)
content = content.replace(
    'includePaymentDetails:',
    'enableRoundOff: _enableRoundOff,\n        includePaymentDetails:'
)

# 4. Fix computed getters
getters_pattern = r"double get _rawTotal => \(_subtotal - _overallDiscountAmount\) \+ _taxTotal;\n\s*double get _roundOff => \(_rawTotal\.roundToDouble\(\) - _rawTotal\);\n\s*double get _finalTotal => _rawTotal \+ _roundOff;"
getters_replacement = r"double get _rawTotal => (_subtotal - _overallDiscountAmount) + _taxTotal;\n  double get _calculatedRoundOff => (_rawTotal.roundToDouble() - _rawTotal);\n  double get _roundOff => _enableRoundOff ? _calculatedRoundOff : 0.0;\n  double get _finalTotal => _rawTotal + _roundOff;"
content = re.sub(getters_pattern, getters_replacement, content)

# 5. Replace UI
ui_pattern = r"if \(_roundOff != 0\) \.\.\.\[\s*const SizedBox\(height: 12\),\s*_buildSummaryRow\(\s*'Round Off',\s*_roundOff > 0\s*\?\s*'\+ \$\{CurrencyFormatter\.format\(_roundOff\)\}'\s*:\s*CurrencyFormatter\.format\(_roundOff\),\s*\),\s*\],"
ui_replacement = r"""if (_calculatedRoundOff != 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Round Off',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 24,
                      child: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: _enableRoundOff,
                          onChanged: (val) {
                            setState(() => _enableRoundOff = val);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _calculatedRoundOff > 0
                      ? '+ '
                      : CurrencyFormatter.format(_calculatedRoundOff),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],"""
content = re.sub(ui_pattern, ui_replacement, content)

with open('lib/features/documents/presentation/document_editor_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
