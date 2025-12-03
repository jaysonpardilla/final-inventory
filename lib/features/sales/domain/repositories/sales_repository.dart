import 'package:dartz/dartz.dart';

import '../entities/daily_sales.dart';
import '../entities/weekly_sales.dart';
import '../entities/monthly_sales.dart';
import '../../core/failures/failure.dart';

abstract class SalesRepository {
  Stream<Either<Failure, List<DailySales>>> streamDailySales(String ownerId);
  Stream<Either<Failure, List<WeeklySales>>> streamWeeklySales(String ownerId);
  Stream<Either<Failure, List<MonthlySales>>> streamMonthlySales(String ownerId);
  Stream<Either<Failure, List<MonthlySales>>> streamTotalSales(String ownerId);
}