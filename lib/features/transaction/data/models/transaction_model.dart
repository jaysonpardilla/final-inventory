import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/transaction.dart' as domain;

class TransactionModel extends domain.Transaction {
  const TransactionModel({
    required super.id,
    required super.productId,
    required super.transactionType,
    required super.transactionDate,
    required super.amount,
    required super.quantity,
    required super.ownerId,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedDate;

    if (map['transactionDate'] is Timestamp) {
      parsedDate = (map['transactionDate'] as Timestamp).toDate();
    } else if (map['transactionDate'] is String) {
      parsedDate = DateTime.tryParse(map['transactionDate']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: id,
      productId: map['productId'] ?? '',
      transactionType: map['transactionType'] ?? '',
      transactionDate: parsedDate,
      amount: (map['amount'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      ownerId: map['ownerId'] ?? '',
    );
  }

  factory TransactionModel.fromEntity(domain.Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      productId: transaction.productId,
      transactionType: transaction.transactionType,
      transactionDate: transaction.transactionDate,
      amount: transaction.amount,
      quantity: transaction.quantity,
      ownerId: transaction.ownerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'transactionType': transactionType,
      'transactionDate': Timestamp.fromDate(transactionDate),
      'amount': amount,
      'quantity': quantity,
      'ownerId': ownerId,
    };
  }
}