import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../product/domain/entities/product.dart';
import 'stock_alert_remote_datasource.dart';

class StockAlertRemoteDatasourceImpl implements StockAlertRemoteDatasource {
  final FirebaseFirestore _db;

  StockAlertRemoteDatasourceImpl(this._db);

  @override
  Stream<List<Product>> streamLowStockProducts(String ownerId) {
    // Assuming low stock is when quantityInStock <= 5, for example
    return _db
        .collection('products')
        .where('ownerId', isEqualTo: ownerId)
        .where('quantityInStock', isLessThanOrEqualTo: 5)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              // Convert Firestore data to Product entity
              final data = doc.data();
              return Product(
                id: doc.id,
                name: data['name'] ?? '',
                price: (data['price'] ?? 0).toDouble(),
                quantityInStock: (data['quantityInStock'] ?? 0).toInt(),
                supplierId: data['supplierId'] ?? '',
                categoryId: data['categoryId'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                quantityBuyPerItem: (data['quantityBuyPerItem'] ?? 0).toInt(),
                ownerId: data['ownerId'] ?? '',
              );
            }).toList());
  }
}