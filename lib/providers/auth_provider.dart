import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository);

  User? user;
  Map<String, dynamic>? profile;

  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => user != null;

  String? get role => profile?['role'];

  bool get isActive => profile?['is_active'] ?? false;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await _authRepository.login(
        username: username,
        password: password,
      );

      user = response.user;

      if (user == null) {
        errorMessage = 'Login failed.';
        return false;
      }

      profile = await _authRepository.getProfile(user!.id);

      if (profile == null) {
        errorMessage = 'User profile not found.';
        await logout();
        return false;
      }

      if (!isActive) {
        errorMessage = 'Your account is inactive.';
        await logout();
        return false;
      }

      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();

    user = null;
    profile = null;
    errorMessage = null;

    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    try {
      final currentUser = _authRepository.currentUser;

      if (currentUser == null) {
        user = null;
        profile = null;
        notifyListeners();
        return;
      }

      user = currentUser;

      profile = await _authRepository.getProfile(currentUser.id);

      if (profile == null || !isActive) {
        await logout();
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Unable to load user session.';
      notifyListeners();
    }
  }
}