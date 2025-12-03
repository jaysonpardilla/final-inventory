import 'package:dartz/dartz.dart';

import '../entities/weekly_sales.dart';
import '../repositories/sales_repository.dart';
import '../../core/failures/failure.dart';

class GetWeeklySales {
  final SalesRepository repository;

  GetWeeklySales(this.repository);

  Stream<Either<Failure, List<WeeklySales>>> call(String ownerId) {
    return repository.streamWeeklySales(ownerId);
  }
}