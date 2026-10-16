/// Read-only product information; the API does not supply a currency code.
class Product {
  const new({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stockQuantity,
    this.unit = '',
    this.reference = '',
  });

  final int id;
  final String name;
  final String barcode;
  final double price;
  final double stockQuantity;
  final String unit;
  final String reference;
}
