class ProductDetails {
  const new({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.unit = '',
    this.reference = '',
    this.taxes = const [],
    this.taxIds,
  });
  final int id;
  final String name;
  final String barcode;
  final double price;
  final double stock;
  final String unit;
  final String reference;
  final List<String> taxes;

  /// Null means the response did not supply complete tax identities.
  final List<int>? taxIds;
}

class ProductAccess {
  const new({
    this.editName = false,
    this.updatePrice = false,
    this.readReferences = false,
  });
  final bool editName;
  final bool updatePrice;
  final bool readReferences;
}

class ProductDetailsState {
  const new(this.product, this.access);
  final ProductDetails? product;
  final ProductAccess access;
}
