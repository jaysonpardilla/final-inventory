import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config.dart';
import 'product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final FirebaseFirestore _db;

  ProductRemoteDatasourceImpl(this._db);

  @override
  Stream<List<ProductModel>> streamProducts(String ownerId) {
    return _db
        .collection(Config.productsCollection)
        .where("ownerId", isEqualTo: ownerId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<String> addProduct(ProductModel product) async {
    final doc = _db.collection(Config.productsCollection).doc();
    await doc.set(product.toMap());
    return doc.id;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _db.collection(Config.productsCollection).doc(product.id).update(product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.collection(Config.productsCollection).doc(id).delete();
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final doc = await _db.collection(Config.productsCollection).doc(id).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}