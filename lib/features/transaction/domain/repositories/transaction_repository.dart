import 'package:dartz/dartz.dart';

import '../entities/transaction.dart';
import '../../core/failures/failure.dart';

abstract class TransactionRepository {
  Stream<Either<Failure, List<Transaction>>> getTransactions(String ownerId, {int limit = 50});
}