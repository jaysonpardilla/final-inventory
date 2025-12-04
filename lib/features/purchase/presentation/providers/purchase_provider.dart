import 'package:flutter/material.dart';
import '../../domain/entities/purchase_item.dart';
import '../../domain/usecases/process_purchase.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/get_products.dart';

class PurchaseProvider extends ChangeNotifier {
  final ProcessPurchase processPurchase;
  final GetProducts getProducts;

  PurchaseProvider({
    required this.processPurchase,
    required this.getProducts,
  });

  List<Product> _products = [];
  final List<PurchaseItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<PurchaseItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalAmount {
    double total = 0;
    for (final item in _cartItems) {
      final product = _products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: item.productId,
          name: 'Unknown',
          price: 0,
          quantityInStock: 0,
          supplierId: '',
          categoryId: '',
          imageUrl: '',
          quantityBuyPerItem: 0,
          ownerId: '',
        ),
      );
      total += product.price * item.quantity;
    }
    return total;
  }

  // Note: Using loadProducts() method instead of stream for better control

  void loadProducts(String ownerId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    getProducts(ownerId).listen(
      (products) {
        _products = products;
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load products: $error';
        _products = [];
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void addToCart(String productId, int quantity) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = PurchaseItem(
        productId: productId,
        quantity: existingItem.quantity + quantity,
      );
    } else {
      _cartItems.add(PurchaseItem(
        productId: productId,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = PurchaseItem(
          productId: productId,
          quantity: quantity,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<bool> checkout(String ownerId) async {
    if (_cartItems.isEmpty) {
      _error = 'Cart is empty';
      notifyListeners();
      return false;
    }

    // Validate stock availability
    for (final item in _cartItems) {
      final product = _products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: item.productId,
          name: 'Unknown',
          price: 0,
          quantityInStock: 0,
          supplierId: '',
          categoryId: '',
          imageUrl: '',
          quantityBuyPerItem: 0,
          ownerId: '',
        ),
      );

      if (product.quantityInStock < item.quantity) {
        _error = 'Insufficient stock for ${product.name}';
        notifyListeners();
        return false;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await processPurchase(ownerId, _cartItems);
    final success = result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (_) {
        clearCart();
        return true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  List<Map<String, dynamic>> getReceiptItems() {
    return _cartItems.map((item) {
      final product = _products.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(
          id: item.productId,
          name: 'Unknown',
          price: 0,
          quantityInStock: 0,
          supplierId: '',
          categoryId: '',
          imageUrl: '',
          quantityBuyPerItem: 0,
          ownerId: '',
        ),
      );

      return {
        'productName': product.name,
        'quantity': item.quantity,
        'price': product.price,
        'total': product.price * item.quantity,
      };
    }).toList();
  }
}