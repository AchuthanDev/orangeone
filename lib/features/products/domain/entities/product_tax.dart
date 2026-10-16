/// A sale tax offered by the current POS company's reference catalogue.
class ProductTax {
  const new({required this.id, required this.label});
  final int id;
  final String label;
}
