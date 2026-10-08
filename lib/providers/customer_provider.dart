import 'package:flutter/foundation.dart';

import '../models/customer_model.dart';
import '../repositories/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerProvider(this._repository);

  List<CustomerModel> customers = [];

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Future<void> loadCustomers() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      customers = await _repository.getCustomers();
    } catch (e) {
      errorMessage = _cleanError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.createCustomer(
        name: name,
        phone: phone,
        email: email,
        address: address,
      );

      await loadCustomers();

      return true;
    } catch (e) {
      errorMessage = _cleanError(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      await _repository.updateCustomer(
        id: id,
        name: name,
        phone: phone,
        email: email,
        address: address,
      );

      await loadCustomers();

      return true;
    } catch (e) {
      errorMessage = _cleanError(e);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleStatus(
    CustomerModel customer,
  ) async {
    try {
      errorMessage = null;

      await _repository.updateStatus(
        id: customer.id,
        isActive: !customer.isActive,
      );

      await loadCustomers();

      return true;
    } catch (e) {
      errorMessage = _cleanError(e);

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