import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository);

  List<ProductModel> products = [];

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      products =
          await _repository.getProducts();
    } catch (e) {
      errorMessage =
          _cleanError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    required String sku,
    required String barcode,
    required String? categoryId,
    required double purchasePrice,
    required double sellingPrice,
    required double stockQuantity,
    required double minimumStock,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.createProduct(
        name: name,
        sku: sku,
        barcode: barcode,
        categoryId: categoryId,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        stockQuantity: stockQuantity,
        minimumStock: minimumStock,
      );

      await loadProducts();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String sku,
    required String barcode,
    required String? categoryId,
    required double purchasePrice,
    required double sellingPrice,
    required double minimumStock,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.updateProduct(
        id: id,
        name: name,
        sku: sku,
        barcode: barcode,
        categoryId: categoryId,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        minimumStock: minimumStock,
      );

      await loadProducts();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleStatus(
    ProductModel product,
  ) async {
    try {
      await _repository.updateStatus(
        id: product.id,
        isActive: !product.isActive,
      );

      await loadProducts();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateStock({
    required ProductModel product,
    required double quantity,
    required String movementType,
    required String note,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.updateStock(
        product: product,
        quantity: quantity,
        movementType: movementType,
        note: note,
      );

      await loadProducts();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}