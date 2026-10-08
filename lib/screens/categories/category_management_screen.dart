import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoryManagementScreen
    extends StatefulWidget {
  const CategoryManagementScreen({
    super.key,
  });

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends State<CategoryManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      context
          .read<CategoryProvider>()
          .loadCategories();
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

  List<CategoryModel> _filtered(
    List<CategoryModel> categories,
  ) {
    if (_search.isEmpty) {
      return categories;
    }

    return categories.where((category) {
      return category.name
              .toLowerCase()
              .contains(_search) ||
          category.description
              .toLowerCase()
              .contains(_search);
    }).toList();
  }

  void _showCategoryDialog({
    CategoryModel? category,
  }) {
    final nameController =
        TextEditingController(
      text: category?.name ?? '',
    );

    final descriptionController =
        TextEditingController(
      text: category?.description ?? '',
    );

    final isEdit = category != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit
                ? 'Edit Category'
                : 'Add Category',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon:
                      Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller:
                    descriptionController,
                maxLines: 2,
                decoration:
                    const InputDecoration(
                  labelText: 'Description',
                  prefixIcon:
                      Icon(Icons.description_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name =
                    nameController.text.trim();

                final description =
                    descriptionController.text
                        .trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Category name is required.',
                      ),
                    ),
                  );
                  return;
                }

                final provider =
                    context.read<CategoryProvider>();

                final bool success;

                if (isEdit) {
                  success =
                      await provider.updateCategory(
                    id: category.id,
                    name: name,
                    description: description,
                  );
                } else {
                  success =
                      await provider.createCategory(
                    name: name,
                    description: description,
                  );
                }

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? isEdit
                              ? 'Category updated.'
                              : 'Category created.'
                          : provider.errorMessage ??
                              'Something went wrong.',
                    ),
                  ),
                );
              },
              child: Text(
                isEdit ? 'Save' : 'Create',
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmStatus(
    CategoryModel category,
  ) {
    final action = category.isActive
        ? 'Deactivate'
        : 'Activate';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$action Category?'),
          content: Text(
            'Are you sure you want to ${action.toLowerCase()} "${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final provider =
                    context.read<CategoryProvider>();

                final success =
                    await provider.toggleStatus(
                  category,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Category ${action.toLowerCase()}d.'
                          : provider.errorMessage ??
                              'Unable to update category.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showCategoryDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final categories =
              _filtered(provider.categories);

          return RefreshIndicator(
            onRefresh:
                provider.loadCategories,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller:
                      _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search categories...',
                    prefixIcon:
                        const Icon(Icons.search),
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
                const SizedBox(height: 20),
                if (categories.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 60,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...categories.map(
                    (category) => Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            category.name[0]
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(
                          category.name,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            Text(
                          category
                                  .description
                                  .isEmpty
                              ? category.isActive
                                  ? 'Active'
                                  : 'Inactive'
                              : category
                                  .description,
                        ),
                        trailing:
                            PopupMenuButton<String>(
                          onSelected:
                              (value) {
                            if (value ==
                                'edit') {
                              _showCategoryDialog(
                                category:
                                    category,
                              );
                            }

                            if (value ==
                                'status') {
                              _confirmStatus(
                                category,
                              );
                            }
                          },
                          itemBuilder:
                              (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text(
                                'Edit',
                              ),
                            ),
                            PopupMenuItem(
                              value: 'status',
                              child: Text(
                                category.isActive
                                    ? 'Deactivate'
                                    : 'Activate',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}