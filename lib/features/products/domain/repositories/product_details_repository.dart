import 'package:orange_one/features/products/domain/entities/product_details.dart';
import 'package:orange_one/features/products/domain/entities/product_tax.dart';

abstract interface class ProductDetailsRepository {
  Future<ProductDetailsState> load(String barcode);
  Future<void> updateName(int id, String name);
  Future<ProductDetails> updatePrice(int id, double price);
  Future<List<ProductTax>> loadTaxes();
  Future<ProductDetails> updateInformation(
    int id,
    String name, {
    List<int>? taxIds,
  });
}
