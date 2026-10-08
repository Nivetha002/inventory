import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';

class ProductManagementScreen
    extends StatefulWidget {
  const ProductManagementScreen({
    super.key,
  });

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends State<ProductManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      await context
          .read<CategoryProvider>()
          .loadCategories();

      if (!mounted) return;

      await context
          .read<ProductProvider>()
          .loadProducts();
    });

    _searchController.addListener(() {
      setState(() {
        _search =
            _searchController.text
                .trim()
                .toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filtered(
    List<ProductModel> products,
  ) {
    if (_search.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name
              .toLowerCase()
              .contains(_search) ||
          product.sku
              .toLowerCase()
              .contains(_search) ||
          (product.barcode ?? '')
              .toLowerCase()
              .contains(_search) ||
          (product.categoryName ?? '')
              .toLowerCase()
              .contains(_search);
    }).toList();
  }

  void _showProductDialog({
    ProductModel? product,
  }) {
    final nameController =
        TextEditingController(
      text: product?.name ?? '',
    );

    final skuController =
        TextEditingController(
      text: product?.sku ?? '',
    );

    final barcodeController =
        TextEditingController(
      text: product?.barcode ?? '',
    );

    final purchaseController =
        TextEditingController(
      text:
          product?.purchasePrice
                  .toString() ??
              '',
    );

    final sellingController =
        TextEditingController(
      text:
          product?.sellingPrice
                  .toString() ??
              '',
    );

    final stockController =
        TextEditingController(
      text:
          product?.stockQuantity
                  .toString() ??
              '0',
    );

    final minimumStockController =
        TextEditingController(
      text:
          product?.minimumStock
                  .toString() ??
              '0',
    );

    String? selectedCategory =
        product?.categoryId;

    final isEdit = product != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final categories =
                context
                    .read<CategoryProvider>()
                    .categories
                    .where(
                      (category) =>
                          category.isActive ||
                          category.id ==
                              selectedCategory,
                    )
                    .toList();

            return AlertDialog(
              title: Text(
                isEdit
                    ? 'Edit Product'
                    : 'Add Product',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextField(
                        controller:
                            nameController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Product Name',
                          prefixIcon: Icon(
                            Icons.inventory_2_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller:
                            skuController,
                        decoration:
                            const InputDecoration(
                          labelText: 'SKU',
                          prefixIcon: Icon(
                            Icons.qr_code_2_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller:
                            barcodeController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Barcode (optional)',
                          prefixIcon: Icon(
                            Icons.barcode_reader,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String?>(
                        initialValue:
                            selectedCategory,
                        decoration:
                            const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<
                              String?>(
                            value: null,
                            child: Text(
                              'No Category',
                            ),
                          ),
                          ...categories.map(
                            (category) =>
                                DropdownMenuItem<
                                    String?>(
                              value:
                                  category.id,
                              child: Text(
                                category.name,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategory =
                                value;
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller:
                            purchaseController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Purchase Price',
                          prefixText: '₹ ',
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller:
                            sellingController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Selling Price',
                          prefixText: '₹ ',
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (!isEdit)
                        TextField(
                          controller:
                              stockController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Opening Stock',
                            prefixText: 'Qty: ',
                          ),
                        ),

                      if (!isEdit)
                        const SizedBox(
                          height: 14,
                        ),

                      TextField(
                        controller:
                            minimumStockController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Minimum Stock',
                          prefixText: 'Qty: ',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name =
                        nameController.text
                            .trim();

                    final sku =
                        skuController.text
                            .trim();

                    final barcode =
                        barcodeController.text
                            .trim();

                    final purchasePrice =
                        double.tryParse(
                              purchaseController
                                  .text
                                  .trim(),
                            ) ??
                            0;

                    final sellingPrice =
                        double.tryParse(
                              sellingController
                                  .text
                                  .trim(),
                            ) ??
                            0;

                    final stock =
                        double.tryParse(
                              stockController
                                  .text
                                  .trim(),
                            ) ??
                            0;

                    final minimumStock =
                        double.tryParse(
                              minimumStockController
                                  .text
                                  .trim(),
                            ) ??
                            0;

                    if (name.isEmpty ||
                        sku.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Product name and SKU are required.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (sellingPrice < 0 ||
                        purchasePrice < 0 ||
                        stock < 0 ||
                        minimumStock < 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Values cannot be negative.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (sellingPrice <
                        purchasePrice) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selling price should not be lower than purchase price.',
                          ),
                        ),
                      );
                      return;
                    }

                    final provider =
                        context
                            .read<
                                ProductProvider>();

                    final bool success;

                    if (isEdit) {
                      success =
                          await provider
                              .updateProduct(
                        id: product.id,
                        name: name,
                        sku: sku,
                        barcode: barcode,
                        categoryId:
                            selectedCategory,
                        purchasePrice:
                            purchasePrice,
                        sellingPrice:
                            sellingPrice,
                        minimumStock:
                            minimumStock,
                      );
                    } else {
                      success =
                          await provider
                              .createProduct(
                        name: name,
                        sku: sku,
                        barcode: barcode,
                        categoryId:
                            selectedCategory,
                        purchasePrice:
                            purchasePrice,
                        sellingPrice:
                            sellingPrice,
                        stockQuantity: stock,
                        minimumStock:
                            minimumStock,
                      );
                    }

                    if (!mounted) return;

                    Navigator.pop(
                      dialogContext,
                    );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? isEdit
                                  ? 'Product updated.'
                                  : 'Product created.'
                              : provider
                                      .errorMessage ??
                                  'Something went wrong.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isEdit
                        ? 'Save'
                        : 'Create',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStockDialog(
    ProductModel product,
  ) {
    final quantityController =
        TextEditingController();

    final noteController =
        TextEditingController();

    String movementType = 'IN';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Update Stock',
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    '${product.name}\nCurrent Stock: ${product.stockQuantity}',
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        movementType,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Movement Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'IN',
                        child: Text(
                          'Stock In',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'OUT',
                        child: Text(
                          'Stock Out',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ADJUSTMENT',
                        child: Text(
                          'Set Stock',
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null)
                        return;

                      setDialogState(() {
                        movementType =
                            value;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller:
                        quantityController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        InputDecoration(
                      labelText:
                          movementType ==
                                  'ADJUSTMENT'
                              ? 'New Stock Quantity'
                              : 'Quantity',
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller:
                        noteController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Note (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                    dialogContext,
                  ),
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final quantity =
                        double.tryParse(
                              quantityController
                                  .text
                                  .trim(),
                            ) ??
                            0;

                    if (quantity < 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Quantity cannot be negative.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (movementType !=
                            'ADJUSTMENT' &&
                        quantity == 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a quantity.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (movementType ==
                            'OUT' &&
                        quantity >
                            product
                                .stockQuantity) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Insufficient stock.',
                          ),
                        ),
                      );
                      return;
                    }

                    final provider =
                        context
                            .read<
                                ProductProvider>();

                    final success =
                        await provider
                            .updateStock(
                      product: product,
                      quantity: quantity,
                      movementType:
                          movementType,
                      note: noteController
                          .text,
                    );

                    if (!mounted) return;

                    Navigator.pop(
                      dialogContext,
                    );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Stock updated successfully.'
                              : provider
                                      .errorMessage ??
                                  'Unable to update stock.',
                        ),
                      ),
                    );
                  },
                  child:
                      const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmStatus(
    ProductModel product,
  ) {
    final action = product.isActive
        ? 'Deactivate'
        : 'Activate';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$action Product?'),
          content: Text(
            'Are you sure you want to ${action.toLowerCase()} "${product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                dialogContext,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                final provider =
                    context
                        .read<
                            ProductProvider>();

                final success =
                    await provider
                        .toggleStatus(
                  product,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Product ${action.toLowerCase()}d.'
                          : provider
                                  .errorMessage ??
                              'Unable to update product.',
                    ),
                  ),
                );
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  Widget _productCard(
    ProductModel product,
  ) {
    final lowStock =
        product.stockQuantity <=
            product.minimumStock &&
        product.isActive;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(
            lowStock
                ? Icons.warning_amber_outlined
                : Icons.inventory_2_outlined,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'SKU: ${product.sku}',
            ),
            Text(
              product.categoryName ??
                  'No Category',
            ),
            const SizedBox(height: 4),
            Text(
              '₹${product.sellingPrice.toStringAsFixed(2)} • Stock: ${product.stockQuantity}',
            ),
            if (lowStock)
              const Text(
                'Low Stock',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing:
            PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showProductDialog(
                product: product,
              );
            }

            if (value == 'stock') {
              _showStockDialog(
                product,
              );
            }

            if (value == 'status') {
              _confirmStatus(
                product,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'stock',
              child: Text(
                'Update Stock',
              ),
            ),
            PopupMenuItem(
              value: 'status',
              child: Text(
                product.isActive
                    ? 'Deactivate'
                    : 'Activate',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Products'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showProductDialog();
        },
        icon: const Icon(Icons.add),
        label:
            const Text('Add Product'),
      ),
      body: Consumer<ProductProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final products =
              _filtered(
            provider.products,
          );

          return RefreshIndicator(
            onRefresh:
                provider.loadProducts,
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [
                TextField(
                  controller:
                      _searchController,
                  decoration:
                      InputDecoration(
                    hintText:
                        'Search products...',
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                        _search.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();
                                },
                                icon:
                                    const Icon(
                                  Icons.clear,
                                ),
                              )
                            : null,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                if (products.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top: 80,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .inventory_2_outlined,
                          size: 60,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'No products found',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...products.map(
                    _productCard,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}