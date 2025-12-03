import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config.dart';
import 'transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDatasourceImpl implements TransactionRemoteDatasource {
  final FirebaseFirestore _db;

  TransactionRemoteDatasourceImpl(this._db);

  @override
  Stream<List<TransactionModel>> streamTransactions(String ownerId,
      {int limit = 50}) {
    return _db
        .collection(Config.transactionsCollection)
        .where("ownerId", isEqualTo: ownerId)
        .orderBy("transactionDate", descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
