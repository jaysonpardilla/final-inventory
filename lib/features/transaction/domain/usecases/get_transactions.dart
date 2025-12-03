import 'package:dartz/dartz.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../core/failures/failure.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Stream<Either<Failure, List<Transaction>>> call(String ownerId, {int limit = 50}) {
    return repository.getTransactions(ownerId, limit: limit);
  }
}