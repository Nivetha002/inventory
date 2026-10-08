import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../providers/billing_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() =>
      _BillingScreenState();
}

class _BillingScreenState
    extends State<BillingScreen> {
  final searchController = TextEditingController();
  final paidController = TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<ProductProvider>()
          .loadProducts();

      context
          .read<CustomerProvider>()
          .loadCustomers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    paidController.dispose();
    super.dispose();
  }

  List<ProductModel> _filteredProducts(
    List<ProductModel> products,
  ) {
    if (searchText.trim().isEmpty) {
      return products
          .where((product) => product.isActive)
          .toList();
    }

    final query = searchText.toLowerCase();

    return products.where((product) {
      return product.isActive &&
          (
            product.name
                .toLowerCase()
                .contains(query) ||
            product.sku
                .toLowerCase()
                .contains(query) ||
            (product.barcode ?? '')
                .toLowerCase()
                .contains(query)
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return _desktopLayout();
          }

          return _mobileLayout();
        },
      ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _productSection(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: _cartSection(),
        ),
      ],
    );
  }

 Widget _mobileLayout() {
  return Column(
    children: [
      Expanded(
        flex: 4,
        child: _productSection(),
      ),

      const Divider(height: 1),

      Expanded(
        flex: 6,
        child: _cartSection(),
      ),
    ],
  );
}
  Widget _productSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final products =
            _filteredProducts(provider.products);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText:
                      'Search product / SKU / barcode',
                  prefixIcon:
                      const Icon(Icons.search),
                  suffixIcon:
                      searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchController
                                    .clear();

                                setState(() {
                                  searchText = '';
                                });
                              },
                              icon:
                                  const Icon(Icons.clear),
                            )
                          : null,
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),

            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child:
                          Text('No products found.'),
                    )
                  : GridView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260,
                        childAspectRatio: 1.25,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder:
                          (context, index) {
                        return _productCard(
                          products[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _productCard(
    ProductModel product,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: product.stockQuantity > 0
            ? () {
                context
                    .read<BillingProvider>()
                    .addProduct(product);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                product.sku,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              Text(
                '₹${product.sellingPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                product.stockQuantity > 0
                    ? 'Stock: ${product.stockQuantity}'
                    : 'OUT OF STOCK',
                style: TextStyle(
                  color:
                      product.stockQuantity > 0
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartSection() {
    return Consumer<BillingProvider>(
      builder: (context, billing, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ),
              child: Row(
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (billing.cart.isNotEmpty)
                    TextButton(
                      onPressed: billing.clearCart,
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),

            Expanded(
              child: billing.cart.isEmpty
                  ? const Center(
                      child: Text(
                        'Add products to cart',
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: billing.cart.length,
                      itemBuilder:
                          (context, index) {
                        final item =
                            billing.cart[index];

                        return Card(
                          margin:
                              const EdgeInsets.only(
                            bottom: 8,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        item.product
                                            .name,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                      Text(
                                        '₹${item.product.sellingPrice.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    billing
                                        .decreaseQuantity(
                                      index,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                  ),
                                ),

                                Text(
                                  item.quantity
                                      .toStringAsFixed(
                                    0,
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    billing
                                        .increaseQuantity(
                                      index,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                  ),
                                ),

                                SizedBox(
                                  width: 75,
                                  child: Text(
                                    '₹${item.total.toStringAsFixed(2)}',
                                    textAlign:
                                        TextAlign.right,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

           Flexible(
  child: SingleChildScrollView(
    child: _billingSummary(billing),
  ),
),
          ],
        );
      },
    );
  }

  Widget _billingSummary(
    BillingProvider billing,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(
            'Subtotal',
            billing.subtotal,
          ),
          _summaryRow(
            'Discount',
            billing.discount,
          ),
          _summaryRow(
            'Tax',
            billing.tax,
          ),

          const Divider(),

          _summaryRow(
            'Total',
            billing.total,
            bold: true,
          ),

          const SizedBox(height: 12),

          _customerDropdown(),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue:
                billing.paymentMethod,
            decoration:
                const InputDecoration(
              labelText: 'Payment Method',
            ),
            items: const [
              DropdownMenuItem(
                value: 'CASH',
                child: Text('Cash'),
              ),
              DropdownMenuItem(
                value: 'UPI',
                child: Text('UPI'),
              ),
              DropdownMenuItem(
                value: 'CARD',
                child: Text('Card'),
              ),
              DropdownMenuItem(
                value: 'CREDIT',
                child: Text('Credit'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                billing.setPaymentMethod(value);
              }
            },
          ),

          const SizedBox(height: 10),

          TextField(
            controller: paidController,
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Paid Amount',
              prefixText: '₹ ',
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          if (billing.errorMessage != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                billing.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: billing.isSaving
                  ? null
                  : () => _completeSale(billing),
              icon: const Icon(
                Icons.point_of_sale,
              ),
              label: billing.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Complete Sale',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerDropdown() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final activeCustomers =
            provider.customers
                .where((c) => c.isActive)
                .toList();

        return DropdownButtonFormField<String?>(
          initialValue: context
              .read<BillingProvider>()
              .selectedCustomer
              ?.id,
          decoration: const InputDecoration(
            labelText: 'Customer',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Walk-in Customer'),
            ),
            ...activeCustomers.map(
              (customer) {
                return DropdownMenuItem<String?>(
                  value: customer.id,
                  child: Text(customer.name),
                );
              },
            ),
          ],
          onChanged: (value) {
            final customer =
                activeCustomers.cast<CustomerModel?>()
                    .firstWhere(
                      (item) =>
                          item?.id == value,
                      orElse: () => null,
                    );

            context
                .read<BillingProvider>()
                .selectCustomer(customer);
          },
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    double value, {
    bool bold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: bold ? 18 : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSale(
    BillingProvider billing,
  ) async {
    final paid =
        double.tryParse(
              paidController.text.trim(),
            ) ??
            0;

    final success =
        await billing.completeSale(
      paidAmount: paid,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      paidController.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Sale completed successfully.',
          ),
        ),
      );

      context
          .read<ProductProvider>()
          .loadProducts();

      context
          .read<CustomerProvider>()
          .loadCustomers();
    }
  }
}