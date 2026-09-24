import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../documents/domain/document_model.dart';
import '../data/invoice_settings_repository.dart';

class InvoiceNumberingScreen extends StatefulWidget {
  const InvoiceNumberingScreen({super.key});

  @override
  State<InvoiceNumberingScreen> createState() => _InvoiceNumberingScreenState();
}

class _InvoiceNumberingScreenState extends State<InvoiceNumberingScreen> {
  final _settingsRepo = InvoiceSettingsRepository();
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _invoicePrefixController;
  late TextEditingController _quotationPrefixController;
  late TextEditingController _receiptPrefixController;
  late TextEditingController _proformaPrefixController;

  bool _includeYear = true;
  int _paddingDigits = 4;

  @override
  void initState() {
    super.initState();
    _invoicePrefixController = TextEditingController(text: 'INV-');
    _quotationPrefixController = TextEditingController(text: 'EST-');
    _receiptPrefixController = TextEditingController(text: 'REC-');
    _proformaPrefixController = TextEditingController(text: 'PRO-');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final invPrefix = await _settingsRepo.getPrefixForType(
      DocumentType.invoice,
    );
    final estPrefix = await _settingsRepo.getPrefixForType(
      DocumentType.quotation,
    );
    final recPrefix = await _settingsRepo.getPrefixForType(
      DocumentType.receipt,
    );
    final proPrefix = await _settingsRepo.getPrefixForType(
      DocumentType.proforma,
    );
    final incYear = await _settingsRepo.getIncludeYear();
    final padding = await _settingsRepo.getPaddingDigits();

    if (mounted) {
      setState(() {
        _invoicePrefixController.text = invPrefix;
        _quotationPrefixController.text = estPrefix;
        _receiptPrefixController.text = recPrefix;
        _proformaPrefixController.text = proPrefix;
        _includeYear = incYear;
        _paddingDigits = padding;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _invoicePrefixController.dispose();
    _quotationPrefixController.dispose();
    _receiptPrefixController.dispose();
    _proformaPrefixController.dispose();
    super.dispose();
  }

  String _formatPreviewNumber(String prefix) {
    final yearPart = _includeYear ? '${DateTime.now().year}-' : '';
    final numberPart = 1.toString().padLeft(_paddingDigits, '0');
    return '$prefix$yearPart$numberPart';
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    await _settingsRepo.setPrefixForType(
      DocumentType.invoice,
      _invoicePrefixController.text.trim().isEmpty
          ? 'INV-'
          : _invoicePrefixController.text.trim(),
    );
    await _settingsRepo.setPrefixForType(
      DocumentType.quotation,
      _quotationPrefixController.text.trim().isEmpty
          ? 'EST-'
          : _quotationPrefixController.text.trim(),
    );
    await _settingsRepo.setPrefixForType(
      DocumentType.receipt,
      _receiptPrefixController.text.trim().isEmpty
          ? 'REC-'
          : _receiptPrefixController.text.trim(),
    );
    await _settingsRepo.setPrefixForType(
      DocumentType.proforma,
      _proformaPrefixController.text.trim().isEmpty
          ? 'PRO-'
          : _proformaPrefixController.text.trim(),
    );
    await _settingsRepo.setIncludeYear(_includeYear);
    await _settingsRepo.setPaddingDigits(_paddingDigits);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numbering formats saved successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Numbering')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice Numbering',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Live Preview Card
            _buildSectionHeader('SAMPLE DOCUMENT NUMBER'),
            _buildLivePreviewCard(),
            const SizedBox(height: 20),

            // Prefixes Section
            _buildSectionHeader('DOCUMENT PREFIXES'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildPrefixInputRow(
                    title: 'Invoice Prefix',
                    controller: _invoicePrefixController,
                    hint: 'INV-',
                    color: AppColors.primary,
                    icon: Icons.receipt_long_outlined,
                  ),
                  _buildDivider(),
                  _buildPrefixInputRow(
                    title: 'Quotation Prefix',
                    controller: _quotationPrefixController,
                    hint: 'EST-',
                    color: Colors.indigo,
                    icon: Icons.request_quote_outlined,
                  ),
                  _buildDivider(),
                  _buildPrefixInputRow(
                    title: 'Receipt Prefix',
                    controller: _receiptPrefixController,
                    hint: 'REC-',
                    color: Colors.teal,
                    icon: Icons.receipt_outlined,
                  ),
                  _buildDivider(),
                  _buildPrefixInputRow(
                    title: 'Proforma Prefix',
                    controller: _proformaPrefixController,
                    hint: 'PRO-',
                    color: Colors.deepPurple,
                    icon: Icons.description_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Formatting Section
            _buildSectionHeader('FORMATTING & SEQUENCE'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Include Current Year',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'e.g. INV-2026-0001 instead of INV-0001',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _includeYear,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _includeYear = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number Length (Padding)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Choose the number of minimum zero-padded digits',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [3, 4, 5].map((digits) {
                            final isSelected = _paddingDigits == digits;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: digits < 5 ? 8 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _paddingDigits = digits);
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$digits Digits\n(${1.toString().padLeft(digits, '0')})',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : _textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Action
            AppButton(
              label: 'Save Numbering Settings',
              isLoading: _isSaving,
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NEXT INVOICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: AppColors.statusPaidText,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatPreviewNumber(_invoicePrefixController.text),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: (_isDark ? AppColors.darkBorder : AppColors.border)
                .withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSubPreview(
                  'Quotation',
                  _formatPreviewNumber(_quotationPrefixController.text),
                ),
              ),
              Expanded(
                child: _buildSubPreview(
                  'Receipt',
                  _formatPreviewNumber(_receiptPrefixController.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubPreview(String title, String number) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          number,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPrefixInputRow({
    required String title,
    required TextEditingController controller,
    required String hint,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: _textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            height: 40,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.5),
      indent: 56,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
