import '../../../product/domain/entities/product.dart';

abstract class StockAlertRemoteDatasource {
  Stream<List<Product>> streamLowStockProducts(String ownerId);
}