import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item_model.dart';
import '../models/sale_model.dart';

class SalesRepository {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<String> createSale({
    required String invoiceNumber,
    required String? customerId,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required String paymentMethod,
    required double paidAmount,
    required double dueAmount,
    required List<CartItemModel> items,
  }) async {
    final userId =
        _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Please login again.');
    }

    // Create sale
    final saleResponse = await _supabase
        .from('sales')
        .insert({
          'invoice_number': invoiceNumber,
          'customer_id': customerId,
          'subtotal': subtotal,
          'discount': discount,
          'tax': tax,
          'total': total,
          'payment_method': paymentMethod,
          'paid_amount': paidAmount,
          'due_amount': dueAmount,
          'created_by': userId,
        })
        .select()
        .single();

    final saleId = saleResponse['id'].toString();

    try {
      for (final item in items) {
        // Check latest stock
        final product = await _supabase
            .from('products')
            .select('stock_quantity')
            .eq('id', item.product.id)
            .single();

        final currentStock =
            double.tryParse(
                  product['stock_quantity']
                      .toString(),
                ) ??
                0;

        if (currentStock < item.quantity) {
          throw Exception(
            'Insufficient stock for ${item.product.name}.',
          );
        }

        final newStock =
            currentStock - item.quantity;

        // Update stock
        await _supabase
            .from('products')
            .update({
              'stock_quantity': newStock,
              'updated_at':
                  DateTime.now().toIso8601String(),
            })
            .eq('id', item.product.id);

        // Stock movement
        await _supabase
            .from('stock_movements')
            .insert({
          'product_id': item.product.id,
          'quantity': item.quantity,
          'movement_type': 'OUT',
          'note':
              'Sale $invoiceNumber',
          'created_by': userId,
        });

        // Sale item
        await _supabase
            .from('sale_items')
            .insert({
          'sale_id': saleId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'sku': item.product.sku,
          'quantity': item.quantity,
          'unit_price':
              item.product.sellingPrice,
          'discount': item.discount,
          'total': item.total,
        });
      }

      // Update customer summary
      if (customerId != null) {
        final customer = await _supabase
            .from('customers')
            .select(
              'total_purchases, outstanding_balance',
            )
            .eq('id', customerId)
            .single();

        final oldPurchases =
            double.tryParse(
                  customer['total_purchases']
                      .toString(),
                ) ??
                0;

        final oldBalance =
            double.tryParse(
                  customer['outstanding_balance']
                      .toString(),
                ) ??
                0;

        await _supabase
            .from('customers')
            .update({
          'total_purchases':
              oldPurchases + total,
          'outstanding_balance':
              oldBalance + dueAmount,
          'updated_at':
              DateTime.now().toIso8601String(),
        }).eq('id', customerId);
      }

      return saleId;
    } catch (e) {
      // MVP implementation.
      // Production version should move the entire
      // operation into one PostgreSQL RPC transaction.
      rethrow;
    }
  }

  Future<List<SaleModel>> getSales() async {
    final response = await _supabase
        .from('sales')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => SaleModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}