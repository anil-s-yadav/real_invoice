import 'package:intl/intl.dart';

/// Formatter for currencies with full support for Indian Lakhs/Crores numbering system
class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount, {
    String symbol = '₹',
    bool isIndian = true,
    int decimalDigits = 2,
  }) {
    if (isIndian) {
      // Indian numbering format: ##,##,###.##
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: symbol.isNotEmpty ? '$symbol ' : '',
        decimalDigits: decimalDigits,
      );
      return formatter.format(amount);
    } else {
      // Standard international format: ###,###.##
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: symbol.isNotEmpty ? '$symbol ' : '',
        decimalDigits: decimalDigits,
      );
      return formatter.format(amount);
    }
  }

  /// Compact representation for dashboard cards, e.g. ₹ 1.25L or ₹ 45K
  static String formatCompact(double amount, {String symbol = '₹'}) {
    if (amount >= 10000000) {
      return '$symbol ${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '$symbol ${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '$symbol ${(amount / 1000).toStringAsFixed(1)} k';
    } else {
      return format(amount, symbol: symbol, decimalDigits: 0);
    }
  }

  /// Converts number to words in Indian Rupees (standard Indian invoice requirement)
  static String toWords(
    double amount, {
    String currencyUnit = 'Rupees',
    String subunit = 'Paise',
  }) {
    final intPart = amount.floor();
    final decimalPart = ((amount - intPart) * 100).round();

    final words = _convertToIndianWords(intPart);
    var result = '$currencyUnit $words';

    if (decimalPart > 0) {
      final decimalWords = _convertToIndianWords(decimalPart);
      result += ' and $decimalWords $subunit';
    }

    return '$result Only';
  }

  static String _convertToIndianWords(int n) {
    if (n == 0) return 'Zero';

    const units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];

    String convertLessThanThousand(int num) {
      String current;
      if (num % 100 < 20) {
        current = units[num % 100];
        num ~/= 100;
      } else {
        current = units[num % 10];
        num ~/= 10;
        current = '${tens[num % 10]} $current'.trim();
        num ~/= 10;
      }
      if (num == 0) return current;
      return '${units[num]} Hundred ${current.isNotEmpty ? 'and $current' : ''}'
          .trim();
    }

    var crore = n ~/ 10000000;
    var lakh = (n % 10000000) ~/ 100000;
    var thousand = (n % 100000) ~/ 1000;
    var remainder = n % 1000;

    var result = '';

    if (crore > 0) {
      result += '${convertLessThanThousand(crore)} Crore ';
    }
    if (lakh > 0) {
      result += '${convertLessThanThousand(lakh)} Lakh ';
    }
    if (thousand > 0) {
      result += '${convertLessThanThousand(thousand)} Thousand ';
    }
    if (remainder > 0) {
      result += convertLessThanThousand(remainder);
    }

    return result.trim();
  }
}
