import 'package:dartz/dartz.dart';

import '../../../product/domain/entities/product.dart';
import '../repositories/stock_alert_repository.dart';
import '../../core/failures/failure.dart';

class GetLowStockAlerts {
  final StockAlertRepository repository;

  GetLowStockAlerts(this.repository);

  Stream<Either<Failure, List<Product>>> call(String ownerId) {
    return repository.getLowStockProducts(ownerId);
  }
}