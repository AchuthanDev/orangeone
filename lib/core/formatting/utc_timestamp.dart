/// Parses timezone-qualified ISO timestamps or confirmed Odoo naive UTC values.
/// Rejects calendar overflow rather than DateTime.parse's normalization.
DateTime parseUtcTimestamp(String value, {bool allowOdooUtc = false}) {
  final source =
      allowOdooUtc &&
          RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$').hasMatch(value)
      ? '${value.replaceFirst(' ', 'T')}Z'
      : value;
  final parts = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})'
    r'(?:\.\d{1,6})?(?:Z|([+-])(\d{2}):(\d{2}))$',
  ).firstMatch(source);
  if (parts == null) throw const FormatException('Invalid UTC timestamp');
  final values = [for (var i = 1; i <= 6; i++) int.parse(parts.group(i)!)];
  final calendar = DateTime.utc(
    values[0],
    values[1],
    values[2],
    values[3],
    values[4],
    values[5],
  );
  if (calendar.year != values[0] ||
      calendar.month != values[1] ||
      calendar.day != values[2] ||
      calendar.hour != values[3] ||
      calendar.minute != values[4] ||
      calendar.second != values[5] ||
      (parts.group(8) != null && int.parse(parts.group(8)!) > 23) ||
      (parts.group(9) != null && int.parse(parts.group(9)!) > 59)) {
    throw const FormatException('Invalid UTC timestamp');
  }
  return DateTime.parse(source).toUtc();
}
