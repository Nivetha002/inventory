import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider(this._repository);

  List<CategoryModel> categories = [];

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Future<void> loadCategories() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      categories =
          await _repository.getCategories();
    } catch (e) {
      errorMessage =
          'Unable to load categories.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    required String description,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.createCategory(
        name: name,
        description: description,
      );

      await loadCategories();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.updateCategory(
        id: id,
        name: name,
        description: description,
      );

      await loadCategories();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleStatus(
    CategoryModel category,
  ) async {
    try {
      errorMessage = null;

      await _repository.updateStatus(
        id: category.id,
        isActive: !category.isActive,
      );

      await loadCategories();

      return true;
    } catch (e) {
      errorMessage =
          _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }
}