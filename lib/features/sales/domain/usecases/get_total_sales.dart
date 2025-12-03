import 'package:dartz/dartz.dart';

import '../entities/monthly_sales.dart';
import '../repositories/sales_repository.dart';
import '../../core/failures/failure.dart';

class GetTotalSales {
  final SalesRepository repository;

  GetTotalSales(this.repository);

  Stream<Either<Failure, List<MonthlySales>>> call(String ownerId) {
    return repository.streamTotalSales(ownerId);
  }
}