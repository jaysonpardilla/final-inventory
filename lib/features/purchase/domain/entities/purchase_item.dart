import 'package:equatable/equatable.dart';

class PurchaseItem extends Equatable {
  final String productId;
  final int quantity;

  const PurchaseItem({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}