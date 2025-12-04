import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_product_by_id.dart';

class ProductProvider extends ChangeNotifier {
  final GetProducts getProducts;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;
  final GetProductById getProductById;

  ProductProvider({
    required this.getProducts,
    required this.addProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.getProductById,
  }) {
    _init();
  }

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Product>> get productsStream => getProducts('');

  void _init() {
    // Initialize if needed
  }

  Future<void> loadProducts(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = getProducts(ownerId);
      stream.listen((products) {
        _products = products;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load products: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await addProduct(product);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (id) {
        // Product added successfully, stream will update
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editProduct(Product product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateProduct(product);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Product updated successfully
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteProduct(id);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Product deleted successfully
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<Product?> fetchProductById(String id) async {
    final result = await getProductById(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return null;
      },
      (product) => product,
    );
  }
}