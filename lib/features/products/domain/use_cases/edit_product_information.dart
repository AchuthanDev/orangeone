import 'package:orange_one/features/products/domain/entities/product_details.dart';
import 'package:orange_one/features/products/domain/entities/product_tax.dart';
import 'package:orange_one/features/products/domain/repositories/product_details_repository.dart';

class EditProductInformation {
  const new(this.repository);
  final ProductDetailsRepository repository;

  static String validateName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) throw const FormatException('Product name is required.');
    if (name.length > 200 || name.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
      throw const FormatException('Use a product name of 1–200 characters.');
    }
    return name;
  }

  Future<ProductDetails> call(
    ProductDetails product,
    String name, {
    List<int>? taxIds,
    List<ProductTax> allowedTaxes = const [],
  }) {
    final validName = validateName(name);
    if (product.id <= 0) throw const FormatException('Invalid product.');
    if (taxIds != null &&
        (taxIds.toSet().length != taxIds.length ||
            taxIds.any((id) => !allowedTaxes.any((tax) => tax.id == id)))) {
      throw const FormatException('Select an available company tax.');
    }
    return repository.updateInformation(product.id, validName, taxIds: taxIds);
  }
}
