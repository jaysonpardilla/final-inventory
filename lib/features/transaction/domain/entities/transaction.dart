import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String productId;
  final String transactionType;
  final DateTime transactionDate;
  final double amount;
  final int quantity;
  final String ownerId;

  const Transaction({
    required this.id,
    required this.productId,
    required this.transactionType,
    required this.transactionDate,
    required this.amount,
    required this.quantity,
    required this.ownerId,
  });

  @override
  List<Object> get props => [
        id,
        productId,
        transactionType,
        transactionDate,
        amount,
        quantity,
        ownerId,
      ];
}