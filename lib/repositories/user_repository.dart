import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --------------------------------------------------
  // GET USERS
  // --------------------------------------------------

  Future<List<UserModel>> getUsers() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => UserModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // --------------------------------------------------
  // CREATE USER
  // --------------------------------------------------

  Future<void> createUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _supabase.functions.invoke(
      'create-user',
      body: {
        'fullName': fullName.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
      },
    );

    if (response.status != 201) {
      final data = response.data;

      final message = data is Map
          ? data['error']?.toString()
          : null;

      throw Exception(
        message ?? 'Unable to create user.',
      );
    }
  }

  // --------------------------------------------------
  // UPDATE USER
  // --------------------------------------------------

  Future<void> updateUser({
    required String userId,
    required String fullName,
    required String username,
    required String role,
  }) async {
    await _supabase
        .from('profiles')
        .update({
          'full_name': fullName.trim(),
          'username': username.trim(),
          'role': role,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  // --------------------------------------------------
  // ACTIVATE / DEACTIVATE USER
  // --------------------------------------------------

  Future<void> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    await _supabase
        .from('profiles')
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }
}