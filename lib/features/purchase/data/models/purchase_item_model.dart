import '../../domain/entities/purchase_item.dart';

class PurchaseItemModel extends PurchaseItem {
  const PurchaseItemModel({
    required super.productId,
    required super.quantity,
  });

  factory PurchaseItemModel.fromEntity(PurchaseItem item) {
    return PurchaseItemModel(
      productId: item.productId,
      quantity: item.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}