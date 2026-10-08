import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({
    super.key,
  });

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends State<CustomerManagementScreen> {
  final searchController = TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> get filteredCustomers {
    final provider = context.read<CustomerProvider>();

    if (searchText.trim().isEmpty) {
      return provider.customers;
    }

    final query = searchText.toLowerCase();

    return provider.customers.where((customer) {
      return customer.name
              .toLowerCase()
              .contains(query) ||
          customer.phone
              .toLowerCase()
              .contains(query) ||
          customer.email
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.customers.isEmpty) {
            return Center(
              child: Text(provider.errorMessage!),
            );
          }

          final customers = filteredCustomers;

          return RefreshIndicator(
            onRefresh: provider.loadCustomers,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Search customer...',
                      prefixIcon:
                          const Icon(Icons.search),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();

                                    setState(() {
                                      searchText = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                  ),
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
                  child: customers.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 150),
                            Center(
                              child: Text(
                                'No customers found.',
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                100,
                              ),
                          itemCount: customers.length,
                          itemBuilder:
                              (context, index) {
                            final customer =
                                customers[index];

                            return _customerCard(
                              customer,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _customerCard(
    CustomerModel customer,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            customer.name.isEmpty
                ? '?'
                : customer.name[0].toUpperCase(),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (customer.phone.isNotEmpty)
              Text(customer.phone),
            Text(
              'Purchases: ₹${customer.totalPurchases.toStringAsFixed(2)}',
            ),
            if (customer.outstandingBalance > 0)
              Text(
                'Due: ₹${customer.outstandingBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showCustomerDialog(
                customer: customer,
              );
            } else if (value == 'status') {
              _toggleStatus(customer);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'status',
              child: Text(
                customer.isActive
                    ? 'Deactivate'
                    : 'Activate',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomerDialog({
  CustomerModel? customer,
}) async {
  final isEdit = customer != null;

  final nameController = TextEditingController(
    text: customer?.name ?? '',
  );

  final phoneController = TextEditingController(
    text: customer?.phone ?? '',
  );

  final emailController = TextEditingController(
    text: customer?.email ?? '',
  );

  final addressController = TextEditingController(
    text: customer?.address ?? '',
  );

  final formKey = GlobalKey<FormState>();

  try {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit ? 'Edit Customer' : 'Add Customer',
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Enter customer name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          bool success;

                          if (isEdit) {
                            success =
                                await provider.updateCustomer(
                              id: customer.id,
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              email: emailController.text.trim(),
                              address: addressController.text.trim(),
                            );
                          } else {
                            success =
                                await provider.createCustomer(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              email: emailController.text.trim(),
                              address: addressController.text.trim(),
                            );
                          }

                          if (!dialogContext.mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEdit
                                      ? 'Customer updated'
                                      : 'Customer created',
                                ),
                              ),
                            );
                          }
                        },
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update' : 'Create',
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  } finally {
    // Dispose only after showDialog has completely finished.
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
  }
}
  Future<void> _toggleStatus(
    CustomerModel customer,
  ) async {
    final action = customer.isActive
        ? 'deactivate'
        : 'activate';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${action[0].toUpperCase()}${action.substring(1)} Customer',
          ),
          content: Text(
            'Are you sure you want to $action ${customer.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await context
        .read<CustomerProvider>()
        .toggleStatus(customer);
  }
}