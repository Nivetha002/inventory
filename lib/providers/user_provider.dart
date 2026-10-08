import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository;

  UserProvider(this._repository);

  List<UserModel> users = [];

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  // --------------------------------------------------
  // LOAD USERS
  // --------------------------------------------------

  Future<void> loadUsers() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      users = await _repository.getUsers();
    } catch (e) {
      errorMessage = 'Unable to load users.';
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  // --------------------------------------------------
  // CREATE USER
  // --------------------------------------------------

  Future<bool> createUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.createUser(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
        role: role,
      );

      await loadUsers();

      return true;
    } catch (e) {
      errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '');

      return false;
    } finally {
      isSaving = false;

      notifyListeners();
    }
  }

  // --------------------------------------------------
  // UPDATE USER
  // --------------------------------------------------

  Future<bool> updateUser({
    required String userId,
    required String fullName,
    required String username,
    required String role,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.updateUser(
        userId: userId,
        fullName: fullName,
        username: username,
        role: role,
      );

      await loadUsers();

      return true;
    } catch (e) {
      errorMessage = 'Unable to update user.';

      return false;
    } finally {
      isSaving = false;

      notifyListeners();
    }
  }

  // --------------------------------------------------
  // ACTIVATE / DEACTIVATE
  // --------------------------------------------------

  Future<bool> toggleUserStatus(
    UserModel user,
  ) async {
    try {
      errorMessage = null;

      await _repository.updateUserStatus(
        userId: user.id,
        isActive: !user.isActive,
      );

      await loadUsers();

      return true;
    } catch (e) {
      errorMessage = 'Unable to update user status.';

      notifyListeners();

      return false;
    }
  }
}