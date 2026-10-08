import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductRepository {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<ProductModel>> getProducts() async {
    final response = await _supabase
        .from('products')
        .select(
          '*, categories(name)',
        )
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => ProductModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> createProduct({
    required String name,
    required String sku,
    required String barcode,
    required String? categoryId,
    required double purchasePrice,
    required double sellingPrice,
    required double stockQuantity,
    required double minimumStock,
  }) async {
    final response =
        await _supabase
            .from('products')
            .insert({
      'name': name.trim(),
      'sku': sku.trim(),
      'barcode': barcode.trim().isEmpty
          ? null
          : barcode.trim(),
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'minimum_stock': minimumStock,
    })
            .select()
            .single();

    final productId =
        response['id'].toString();

    if (stockQuantity > 0) {
      await _supabase
          .from('stock_movements')
          .insert({
        'product_id': productId,
        'quantity': stockQuantity,
        'movement_type': 'IN',
        'note': 'Opening stock',
        'created_by':
            _supabase.auth.currentUser?.id,
      });
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String sku,
    required String barcode,
    required String? categoryId,
    required double purchasePrice,
    required double sellingPrice,
    required double minimumStock,
  }) async {
    await _supabase
        .from('products')
        .update({
      'name': name.trim(),
      'sku': sku.trim(),
      'barcode': barcode.trim().isEmpty
          ? null
          : barcode.trim(),
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'minimum_stock': minimumStock,
      'updated_at':
          DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }

  Future<void> updateStatus({
    required String id,
    required bool isActive,
  }) async {
    await _supabase
        .from('products')
        .update({
      'is_active': isActive,
      'updated_at':
          DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }

  Future<void> updateStock({
    required ProductModel product,
    required double quantity,
    required String movementType,
    required String note,
  }) async {
    double newStock =
        product.stockQuantity;

    if (movementType == 'IN') {
      newStock += quantity;
    } else if (movementType == 'OUT') {
      newStock -= quantity;
    } else {
      newStock = quantity;
    }

    if (newStock < 0) {
      throw Exception(
        'Stock cannot be negative.',
      );
    }

    await _supabase
        .from('products')
        .update({
      'stock_quantity': newStock,
      'updated_at':
          DateTime.now().toIso8601String(),
    })
        .eq('id', product.id);

    await _supabase
        .from('stock_movements')
        .insert({
      'product_id': product.id,
      'quantity': quantity,
      'movement_type': movementType,
      'note': note.trim().isEmpty
          ? null
          : note.trim(),
      'created_by':
          _supabase.auth.currentUser?.id,
    });
  }
}