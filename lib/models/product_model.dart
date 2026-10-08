class ProductModel {
  final String id;
  final String? categoryId;
  final String? categoryName;

  final String name;
  final String sku;
  final String? barcode;

  final double purchasePrice;
  final double sellingPrice;

  final double stockQuantity;
  final double minimumStock;

  final bool isActive;

  ProductModel({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    required this.sku,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minimumStock,
    required this.isActive,
  });

  factory ProductModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ProductModel(
      id: map['id']?.toString() ?? '',

      categoryId:
          map['category_id']?.toString(),

      categoryName:
          map['categories']?['name']?.toString(),

      name: map['name']?.toString() ?? '',

      sku: map['sku']?.toString() ?? '',

      barcode:
          map['barcode']?.toString(),

      purchasePrice:
          double.tryParse(
                map['purchase_price']?.toString() ?? '0',
              ) ??
              0,

      sellingPrice:
          double.tryParse(
                map['selling_price']?.toString() ?? '0',
              ) ??
              0,

      stockQuantity:
          double.tryParse(
                map['stock_quantity']?.toString() ?? '0',
              ) ??
              0,

      minimumStock:
          double.tryParse(
                map['minimum_stock']?.toString() ?? '0',
              ) ??
              0,

      isActive:
          map['is_active'] == true,
    );
  }
}