import '../models/purchase_item_model.dart';

abstract class PurchaseRemoteDatasource {
  Future<void> processPurchase(String ownerId, List<PurchaseItemModel> items);
}