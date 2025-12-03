import 'package:dartz/dartz.dart';

import '../../../product/domain/entities/product.dart';
import '../../core/failures/failure.dart';

abstract class StockAlertRepository {
  Stream<Either<Failure, List<Product>>> getLowStockProducts(String ownerId);
}