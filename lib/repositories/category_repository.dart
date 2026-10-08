import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';

class CategoryRepository {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select()
        .order('name');

    return (response as List)
        .map(
          (item) => CategoryModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required String description,
  }) async {
    await _supabase.from('categories').insert({
      'name': name.trim(),
      'description': description.trim(),
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String description,
  }) async {
    await _supabase
        .from('categories')
        .update({
          'name': name.trim(),
          'description': description.trim(),
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
        .from('categories')
        .update({
          'is_active': isActive,
          'updated_at':
              DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}