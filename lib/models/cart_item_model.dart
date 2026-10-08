import 'product_model.dart';

class CartItemModel {
  final ProductModel product;

  double quantity;
  double discount;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.discount = 0,
  });

  double get grossTotal =>
      product.sellingPrice * quantity;

  double get total =>
      grossTotal - discount;
}