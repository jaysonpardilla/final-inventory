import 'package:dartz/dartz.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Stream<Either<Failure, List<Transaction>>> getTransactions(String ownerId, {int limit = 50}) {
    try {
      return datasource.streamTransactions(ownerId, limit: limit).map(
            (models) => Right(models.map((model) => model).toList()),
          );
    } catch (e) {
      return Stream.value(Left(TransactionFailure('Failed to load transactions: $e')));
    }
  }
}