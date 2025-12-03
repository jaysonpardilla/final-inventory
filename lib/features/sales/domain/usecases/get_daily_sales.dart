import 'package:dartz/dartz.dart';

import '../entities/daily_sales.dart';
import '../repositories/sales_repository.dart';
import '../../core/failures/failure.dart';

class GetDailySales {
  final SalesRepository repository;

  GetDailySales(this.repository);

  Stream<Either<Failure, List<DailySales>>> call(String ownerId) {
    return repository.streamDailySales(ownerId);
  }
}