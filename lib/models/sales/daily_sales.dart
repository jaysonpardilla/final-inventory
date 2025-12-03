import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DailySales extends Equatable {
  final String id;
  final DateTime date;
  final double salesAmount;
  final String ownerId;

  const DailySales({
    required this.id,
    required this.date,
    required this.salesAmount,
    required this.ownerId,
  });

  factory DailySales.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedDate;

    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return DailySales(
      id: id,
      date: parsedDate,
      salesAmount: (map['salesAmount'] ?? 0).toDouble(),
      ownerId: map['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'salesAmount': salesAmount,
      'ownerId': ownerId,
    };
  }

  @override
  List<Object> get props => [id, date, salesAmount, ownerId];
}