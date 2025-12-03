import 'package:equatable/equatable.dart';

class TotalSales extends Equatable {
  final String id;
  final String? productId;
  final double salesPerItem;
  final double totalSales;
  final String ownerId;

  const TotalSales({
    required this.id,
    this.productId,
    this.salesPerItem = 0,
    this.totalSales = 0,
    required this.ownerId,
  });

  factory TotalSales.fromMap(String id, Map<String, dynamic> map) {
    return TotalSales(
      id: id,
      productId: map['productId'],
      salesPerItem: (map['salesPerItem'] ?? 0).toDouble(),
      totalSales: (map['totalSales'] ?? 0).toDouble(),
      ownerId: map['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'salesPerItem': salesPerItem,
      'totalSales': totalSales,
      'ownerId': ownerId,
    };
  }

  @override
  List<Object> get props => [id, productId ?? '', salesPerItem, totalSales, ownerId];
}