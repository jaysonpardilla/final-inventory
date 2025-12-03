import 'package:equatable/equatable.dart';

class WeeklySales extends Equatable {
  final String id;
  final int year;
  final int weekNumber;
  final double salesAmount;
  final String ownerId;

  const WeeklySales({
    required this.id,
    required this.year,
    required this.weekNumber,
    required this.salesAmount,
    required this.ownerId,
  });

  factory WeeklySales.fromMap(String id, Map<String, dynamic> map) {
    return WeeklySales(
      id: id,
      year: map['year'] ?? 0,
      weekNumber: map['weekNumber'] ?? 0,
      salesAmount: (map['salesAmount'] ?? 0).toDouble(),
      ownerId: map['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'weekNumber': weekNumber,
      'salesAmount': salesAmount,
      'ownerId': ownerId,
    };
  }

  @override
  List<Object> get props => [id, year, weekNumber, salesAmount, ownerId];
}