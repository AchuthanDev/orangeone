import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/features/products/domain/entities/product_details.dart';

abstract final class ProductDetailsModel {
  static ProductDetails parse(Map<String, dynamic> json, String barcode) {
    final id = json['id'];
    final name = json['name'];
    final price = json['price'];
    final stock = json['stock_quantity'];
    if (id is! int ||
        id <= 0 ||
        name is! String ||
        name.trim().isEmpty ||
        json['barcode'] != barcode ||
        price is! num ||
        !price.isFinite ||
        stock is! num ||
        !stock.isFinite) {
      throw invalidResponse;
    }
    final taxes = <String>[];
    final taxIds = <int>[];
    var completeIds = true;
    final rawTaxes = json['taxes'];
    if (rawTaxes != null && rawTaxes != false) {
      if (rawTaxes is! List) throw invalidResponse;
      for (final tax in rawTaxes) {
        if (tax is! Map<String, dynamic> ||
            tax['name'] is! String ||
            tax['amount'] is! num ||
            !(tax['amount'] as num).isFinite ||
            tax['amount_type'] is! String) {
          throw invalidResponse;
        }
        final amount = tax['amount'] as num;
        final taxId = tax['id'];
        if (taxId is int && taxId > 0) {
          taxIds.add(taxId);
        } else {
          completeIds = false;
        }
        taxes.add(
          tax['amount_type'] == 'percent'
              ? '${tax['name']} ($amount%)'
              : tax['name'] as String,
        );
      }
    }
    return ProductDetails(
      id: id,
      name: name,
      barcode: barcode,
      price: price.toDouble(),
      stock: stock.toDouble(),
      unit: _text(json['uom']),
      reference: _text(json['default_code']),
      taxes: List.unmodifiable(taxes),
      taxIds: rawTaxes is List && completeIds
          ? List.unmodifiable(taxIds)
          : null,
    );
  }

  static String _text(Object? value) {
    if (value == null || value == false) return '';
    if (value is! String) throw invalidResponse;
    return value;
  }
}
