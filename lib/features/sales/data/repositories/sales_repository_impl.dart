import 'package:dartz/dartz.dart';

import '../../domain/entities/daily_sales.dart';
import '../../domain/entities/weekly_sales.dart';
import '../../domain/entities/monthly_sales.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/sales_remote_datasource.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDatasource datasource;

  SalesRepositoryImpl(this.datasource);

  @override
  Stream<Either<Failure, List<DailySales>>> streamDailySales(String ownerId) {
    try {
      return datasource.streamDailySales(ownerId).map(
            (models) => Right(models),
          );
    } catch (e) {
      return Stream.value(Left(SalesFailure('Failed to load daily sales: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<WeeklySales>>> streamWeeklySales(String ownerId) {
    try {
      return datasource.streamWeeklySales(ownerId).map(
            (models) => Right(models),
          );
    } catch (e) {
      return Stream.value(Left(SalesFailure('Failed to load weekly sales: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<MonthlySales>>> streamMonthlySales(String ownerId) {
    try {
      return datasource.streamMonthlySales(ownerId).map(
            (models) => Right(models),
          );
    } catch (e) {
      return Stream.value(Left(SalesFailure('Failed to load monthly sales: $e')));
    }
  }

  @override
  Stream<Either<Failure, List<MonthlySales>>> streamTotalSales(String ownerId) {
    try {
      return datasource.streamTotalSales(ownerId).map(
            (models) => Right(models),
          );
    } catch (e) {
      return Stream.value(Left(SalesFailure('Failed to load total sales: $e')));
    }
  }
}