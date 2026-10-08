import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sale_model.dart';
import '../../repositories/sales_repository.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() =>
      _SalesHistoryScreenState();
}

class _SalesHistoryScreenState
    extends State<SalesHistoryScreen> {
  final repository = SalesRepository();

  List<SaleModel> sales = [];

  bool isLoading = false;

  String search = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      isLoading = true;
    });

    try {
      sales = await repository.getSales();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<SaleModel> get filteredSales {
    if (search.trim().isEmpty) {
      return sales;
    }

    final query = search.toLowerCase();

    return sales.where((sale) {
      return sale.invoiceNumber
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadSales,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration:
                          const InputDecoration(
                        prefixIcon:
                            Icon(Icons.search),
                        hintText:
                            'Search invoice...',
                      ),
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: filteredSales.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 150),
                              Center(
                                child: Text(
                                  'No sales found.',
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              16,
                              0,
                              16,
                              20,
                            ),
                            itemCount:
                                filteredSales.length,
                            itemBuilder:
                                (context, index) {
                              final sale =
                                  filteredSales[
                                      index];

                              return _saleCard(sale);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _saleCard(SaleModel sale) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: const Icon(
            Icons.receipt_long,
          ),
        ),
        title: Text(
          sale.invoiceNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${_formatDate(sale.createdAt)} • ${sale.paymentMethod}',
        ),
        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              '₹${sale.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (sale.dueAmount > 0)
              Text(
                'Due ₹${sale.dueAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}