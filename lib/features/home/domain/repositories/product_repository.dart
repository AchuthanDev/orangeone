import 'package:orange_one/features/home/domain/entities/product.dart';

abstract interface class ProductRepository {
  /// Null means the authoritative backend found no matching POS product.
  Future<Product?> findByBarcode(String barcode);
}
