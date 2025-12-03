import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config.dart';
import 'supplier_remote_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRemoteDatasourceImpl implements SupplierRemoteDatasource {
  final FirebaseFirestore _db;

  SupplierRemoteDatasourceImpl(this._db);

  @override
  Stream<List<SupplierModel>> streamSuppliers(String ownerId) {
    return _db
        .collection(Config.suppliersCollection)
        .where("ownerId", isEqualTo: ownerId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SupplierModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<String> addSupplier(SupplierModel supplier) async {
    final doc = _db.collection(Config.suppliersCollection).doc();
    await doc.set(supplier.toMap());
    return doc.id;
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) async {
    await _db.collection(Config.suppliersCollection).doc(supplier.id).update(supplier.toMap());
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _db.collection(Config.suppliersCollection).doc(id).delete();
  }

  @override
  Future<SupplierModel?> getSupplierById(String id) async {
    final doc = await _db.collection(Config.suppliersCollection).doc(id).get();
    if (doc.exists) {
      return SupplierModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}