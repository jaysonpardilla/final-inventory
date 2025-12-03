import 'package:dartz/dartz.dart';

import '../../../product/domain/entities/product.dart';
import '../../domain/repositories/stock_alert_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/stock_alert_remote_datasource.dart';

class StockAlertRepositoryImpl implements StockAlertRepository {
  final StockAlertRemoteDatasource datasource;

  StockAlertRepositoryImpl(this.datasource);

  @override
  Stream<Either<Failure, List<Product>>> getLowStockProducts(String ownerId) {
    try {
      return datasource.streamLowStockProducts(ownerId).map(
            (models) => Right(models.map((model) => model).toList()),
          );
    } catch (e) {
      return Stream.value(Left(StockAlertFailure('Failed to load low stock products: $e')));
    }
  }
}