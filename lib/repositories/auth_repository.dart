import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Current logged-in user
  User? get currentUser => _supabase.auth.currentUser;

  // Current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Login
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final email = await _supabase.rpc(
      'get_login_email',
      params: {
        'p_username': username.trim(),
      },
    );

    if (email == null) {
      throw AuthException(
        'Username not found or account is inactive.',
      );
    }

    return await _supabase.auth.signInWithPassword(
      email: email as String,
      password: password,
    );
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Get user profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  // Listen to authentication changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}