import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/usecases/get_low_stock_alerts.dart';
import '../../core/failures/failure.dart';

class StockAlertProvider extends ChangeNotifier {
  final GetLowStockAlerts getLowStockAlerts;

  StockAlertProvider({
    required this.getLowStockAlerts,
  }) {
    _init();
  }

  List<Product> _lowStockProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get lowStockProducts => _lowStockProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<Either<Failure, List<Product>>> get lowStockAlertsStream => getLowStockAlerts('');

  void _init() {
    // Initialize if needed
  }

  void loadLowStockAlerts(String ownerId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    getLowStockAlerts(ownerId).listen(
      (result) {
        result.fold(
          (failure) {
            _error = failure.message;
            _lowStockProducts = [];
          },
          (products) {
            _lowStockProducts = products;
            _error = null;
          },
        );
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load stock alerts: $error';
        _lowStockProducts = [];
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}