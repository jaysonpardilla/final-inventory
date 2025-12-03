import 'package:equatable/equatable.dart';

class MonthlySales extends Equatable {
  final String id;
  final int year;
  final int month;
  final double salesAmount;
  final String ownerId;

  const MonthlySales({
    required this.id,
    required this.year,
    required this.month,
    required this.salesAmount,
    required this.ownerId,
  });

  factory MonthlySales.fromMap(String id, Map<String, dynamic> map) {
    return MonthlySales(
      id: id,
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      salesAmount: (map['salesAmount'] ?? 0).toDouble(),
      ownerId: map['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'salesAmount': salesAmount,
      'ownerId': ownerId,
    };
  }

  @override
  List<Object> get props => [id, year, month, salesAmount, ownerId];
}