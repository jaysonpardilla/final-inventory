import 'package:flutter/material.dart';

import '../../domain/entities/supplier.dart';
import '../../domain/usecases/get_suppliers.dart';
import '../../domain/usecases/add_supplier.dart';
import '../../domain/usecases/update_supplier.dart';
import '../../domain/usecases/delete_supplier.dart';
import '../../domain/usecases/get_supplier_by_id.dart';

class SupplierProvider extends ChangeNotifier {
  final GetSuppliers getSuppliers;
  final AddSupplier addSupplier;
  final UpdateSupplier updateSupplier;
  final DeleteSupplier deleteSupplier;
  final GetSupplierById getSupplierById;

  SupplierProvider({
    required this.getSuppliers,
    required this.addSupplier,
    required this.updateSupplier,
    required this.deleteSupplier,
    required this.getSupplierById,
  }) {
    _init();
  }

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Supplier>> getSuppliersStream(String ownerId) {
    return getSuppliers(ownerId);
  }

  void _init() {
    // Initialize if needed
  }

  Future<void> loadSuppliers(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = getSuppliers(ownerId);
      stream.listen((suppliers) {
        _suppliers = suppliers;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load suppliers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSupplier(Supplier supplier) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await addSupplier(supplier);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (id) {
        // Supplier added successfully, stream will update
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editSupplier(Supplier supplier) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateSupplier(supplier);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Supplier updated successfully
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeSupplier(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteSupplier(id);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Supplier deleted successfully
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<Supplier?> fetchSupplierById(String id) async {
    final result = await getSupplierById(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return null;
      },
      (supplier) => supplier,
    );
  }
}