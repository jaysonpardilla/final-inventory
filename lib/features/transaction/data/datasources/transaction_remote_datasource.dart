import '../models/transaction_model.dart';

abstract class TransactionRemoteDatasource {
  Stream<List<TransactionModel>> streamTransactions(String ownerId, {int limit = 50});
}