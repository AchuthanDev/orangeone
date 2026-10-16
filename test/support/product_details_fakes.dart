import 'dart:async';

import 'package:orange_one/features/products/domain/entities/product_details.dart';
import 'package:orange_one/features/products/domain/entities/product_tax.dart';
import 'package:orange_one/features/products/domain/repositories/product_details_repository.dart';

const detailsFixture = ProductDetails(
  id: 10,
  name: 'Aachi Fish Fry Masala',
  barcode: '0010101010',
  price: 100,
  stock: 48,
  unit: 'Units',
);

class FakeDetailsRepository implements ProductDetailsRepository {
  ProductDetails? product = detailsFixture;
  ProductAccess access = const ProductAccess(
    editName: true,
    updatePrice: true,
    readReferences: true,
  );
  List<ProductTax> taxes = const [ProductTax(id: 1, label: 'VAT (15%)')];
  List<int>? writtenTaxIds;
  Object? referencesError;
  @override
  Future<List<ProductTax>> loadTaxes() async {
    if (referencesError != null) {
      Error.throwWithStackTrace(referencesError!, StackTrace.current);
    }
    return taxes;
  }

  @override
  Future<ProductDetails> updateInformation(
    int id,
    String name, {
    List<int>? taxIds,
  }) async {
    writes++;
    writtenTaxIds = taxIds;
    if (writeError != null) {
      Error.throwWithStackTrace(writeError!, StackTrace.current);
    }
    if (pendingWrite != null) return await pendingWrite!.future;
    final previous = product!;
    return product = ProductDetails(
      id: previous.id,
      name: name,
      barcode: previous.barcode,
      price: previous.price,
      stock: previous.stock,
      unit: previous.unit,
      reference: previous.reference,
      taxes: taxIds == null
          ? previous.taxes
          : taxes
                .where((tax) => taxIds.contains(tax.id))
                .map((tax) => tax.label)
                .toList(),
      taxIds: taxIds ?? previous.taxIds,
    );
  }

  Object? error;
  Completer<ProductDetailsState>? pending;
  int loads = 0;
  int writes = 0;
  Object? writeError;
  Completer<ProductDetails>? pendingWrite;
  @override
  Future<ProductDetailsState> load(String barcode) async {
    loads++;
    if (error != null) Error.throwWithStackTrace(error!, StackTrace.current);
    if (pending != null) return await pending!.future;
    return ProductDetailsState(product, access);
  }

  @override
  Future<void> updateName(int id, String name) async {
    writes++;
  }

  @override
  Future<ProductDetails> updatePrice(int id, double price) async {
    writes++;
    if (writeError != null) {
      Error.throwWithStackTrace(writeError!, StackTrace.current);
    }
    if (pendingWrite != null) return await pendingWrite!.future;
    final previous = product!;
    return product = ProductDetails(
      id: previous.id,
      name: previous.name,
      barcode: previous.barcode,
      price: price,
      stock: previous.stock,
      unit: previous.unit,
      reference: previous.reference,
      taxes: previous.taxes,
      taxIds: previous.taxIds,
    );
  }
}
