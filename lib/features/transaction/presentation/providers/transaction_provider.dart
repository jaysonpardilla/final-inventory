import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/get_products.dart';


class TransactionProvider extends ChangeNotifier {
  final GetTransactions getTransactions;
  final GetProducts getProducts;

  TransactionProvider({
    required this.getTransactions,
    required this.getProducts,
  });

  List<Transaction> _transactions = [];
  Map<String, Product> _productsMap = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = "";
  String _filter = "none";

  List<Transaction> get transactions => _transactions;
  Map<String, Product> get productsMap => _productsMap;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadTransactions(String ownerId, {int limit = 50}) {
    _isLoading = true;
    notifyListeners();

    // Load products first
    getProducts(ownerId).listen(
      (products) {
        _productsMap = {for (var p in products) p.id: p};

        // Then load transactions
        getTransactions(ownerId, limit: limit).listen(
          (result) {
            result.fold(
              (failure) {
                _error = failure.message;
                _transactions = [];
              },
              (transactions) {
                _transactions = transactions;
                _error = null;
              },
            );
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Failed to load: $error';
            _transactions = [];
            _isLoading = false;
            notifyListeners();
          },
        );
      },
      onError: (error) {
        _error = 'Failed to load products: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  List<Transaction> getFilteredTransactions() {
    List<Transaction> filtered = List.from(_transactions);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final productName =
            _productsMap[t.productId]?.name.toLowerCase() ?? "";
        return productName.contains(_searchQuery);
      }).toList();
    }

    switch (_filter) {
      case "dateAsc":
        filtered.sort((a, b) => a.transactionDate.compareTo(b.transactionDate));
        break;
      case "dateDesc":
        filtered.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
        break;
      case "amountAsc":
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case "amountDesc":
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }

    return filtered;
  }
}

