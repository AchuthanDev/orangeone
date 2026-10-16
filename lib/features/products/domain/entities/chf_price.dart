/// CHF accounting amounts use hundredths, not cash-only five-cent rounding.
class ChfPrice {
  const new _(this.minorUnits);
  final int minorUnits;

  static ChfPrice parse(String raw) {
    final value = raw.trim();
    if (!RegExp(r'^\d+(?:[.,]\d{1,2})?$').hasMatch(value)) {
      throw const FormatException(
        'Enter a valid price with up to 2 decimal places, e.g. 100.00.',
      );
    }
    final parts = value.replaceAll(',', '.').split('.');
    final fraction = parts.length == 1 ? '00' : parts[1].padRight(2, '0');
    final cents = int.tryParse('${parts[0]}$fraction');
    // Preserve exact integer hundredths on both Dart VM and web runtimes.
    if (cents == null || cents < 0 || cents > 9007199254740991) {
      throw const FormatException(
        'This price is too large to store accurately.',
      );
    }
    final price = ChfPrice._(cents);
    if (price.asDouble.toStringAsFixed(2) != price.formatted) {
      throw const FormatException(
        'This price is too large to store accurately.',
      );
    }
    return price;
  }

  String get formatted =>
      '${minorUnits ~/ 100}.${(minorUnits % 100).toString().padLeft(2, '0')}';
  double get asDouble => double.parse(formatted);
}
