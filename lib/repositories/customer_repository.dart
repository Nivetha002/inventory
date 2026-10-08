import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer_model.dart';

class CustomerRepository {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<CustomerModel>> getCustomers() async {
    final response = await _supabase
        .from('customers')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => CustomerModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> createCustomer({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    await _supabase.from('customers').insert({
      'name': name.trim(),
      'phone': phone.trim().isEmpty
          ? null
          : phone.trim(),
      'email': email.trim().isEmpty
          ? null
          : email.trim(),
      'address': address.trim().isEmpty
          ? null
          : address.trim(),
    });
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    await _supabase.from('customers').update({
      'name': name.trim(),
      'phone': phone.trim().isEmpty
          ? null
          : phone.trim(),
      'email': email.trim().isEmpty
          ? null
          : email.trim(),
      'address': address.trim().isEmpty
          ? null
          : address.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> updateStatus({
    required String id,
    required bool isActive,
  }) async {
    await _supabase.from('customers').update({
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}