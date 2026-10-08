import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../repositories/sales_repository.dart';

class BillingProvider extends ChangeNotifier {
  final SalesRepository _repository;

  BillingProvider(this._repository);

  final List<CartItemModel> cart = [];

  bool isSaving = false;
  String? errorMessage;

  CustomerModel? selectedCustomer;

  String paymentMethod = 'CASH';

  double get subtotal {
    return cart.fold(
      0,
      (sum, item) => sum + item.grossTotal,
    );
  }

  double get discount {
    return cart.fold(
      0,
      (sum, item) => sum + item.discount,
    );
  }

  double get tax => 0;

  double get total {
    return subtotal - discount + tax;
  }

  double get totalQuantity {
    return cart.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  void addProduct(ProductModel product) {
    if (!product.isActive) {
      errorMessage =
          '${product.name} is inactive.';
      notifyListeners();
      return;
    }

    if (product.stockQuantity <= 0) {
      errorMessage =
          '${product.name} is out of stock.';
      notifyListeners();
      return;
    }

    final index = cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      final item = cart[index];

      if (item.quantity + 1 >
          product.stockQuantity) {
        errorMessage =
            'Only ${product.stockQuantity} available.';
        notifyListeners();
        return;
      }

      item.quantity++;
    } else {
      cart.add(
        CartItemModel(
          product: product,
        ),
      );
    }

    errorMessage = null;
    notifyListeners();
  }

  void increaseQuantity(int index) {
    final item = cart[index];

    if (item.quantity + 1 >
        item.product.stockQuantity) {
      errorMessage =
          'Maximum stock reached.';
      notifyListeners();
      return;
    }

    item.quantity++;

    notifyListeners();
  }

  void decreaseQuantity(int index) {
    final item = cart[index];

    if (item.quantity <= 1) {
      cart.removeAt(index);
    } else {
      item.quantity--;
    }

    notifyListeners();
  }

  void removeItem(int index) {
    cart.removeAt(index);
    notifyListeners();
  }

  void updateItemDiscount(
    int index,
    double value,
  ) {
    final item = cart[index];

    final maxDiscount =
        item.product.sellingPrice *
        item.quantity;

    item.discount =
        value.clamp(0, maxDiscount);

    notifyListeners();
  }

  void selectCustomer(CustomerModel? customer) {
    selectedCustomer = customer;
    notifyListeners();
  }

  void setPaymentMethod(String value) {
    paymentMethod = value;
    notifyListeners();
  }

  Future<bool> completeSale({
    required double paidAmount,
  }) async {
    if (cart.isEmpty) {
      errorMessage = 'Cart is empty.';
      notifyListeners();
      return false;
    }

    if (paidAmount < 0) {
      errorMessage =
          'Paid amount cannot be negative.';
      notifyListeners();
      return false;
    }

    if (paymentMethod != 'CREDIT' &&
        paidAmount < total) {
      errorMessage =
          'Paid amount is less than total.';
      notifyListeners();
      return false;
    }

   if (paymentMethod == 'CREDIT' &&
    selectedCustomer == null) {
      errorMessage =
          'Select a customer for credit sale.';
      notifyListeners();
      return false;
    }

    final double dueAmount =
        paymentMethod == 'CREDIT'
            ? (total - paidAmount)
                .clamp(0.0, total)
                .toDouble()
            : 0.0;

    try {
      isSaving = true;
      errorMessage = null;
      notifyListeners();

      final invoiceNumber =
          _generateInvoiceNumber();

      await _repository.createSale(
        invoiceNumber: invoiceNumber,
        customerId: selectedCustomer?.id,
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        total: total,
        paymentMethod: paymentMethod,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        items: List.from(cart),
      );

      clearCart();

      return true;
    } catch (e) {
      errorMessage =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    selectedCustomer = null;
    paymentMethod = 'CASH';
    errorMessage = null;

    notifyListeners();
  }

  String _generateInvoiceNumber() {
    final now = DateTime.now();

    return 'INV-${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }
}