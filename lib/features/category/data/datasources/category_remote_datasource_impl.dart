import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config.dart';
import 'category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final FirebaseFirestore _db;

  CategoryRemoteDatasourceImpl(this._db);

  @override
  Stream<List<CategoryModel>> streamCategories(String ownerId) {
    return _db
        .collection(Config.categoriesCollection)
        .where("ownerId", isEqualTo: ownerId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CategoryModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<String> addCategory(CategoryModel category) async {
    final doc = _db.collection(Config.categoriesCollection).doc();
    await doc.set(category.toMap());
    return doc.id;
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _db.collection(Config.categoriesCollection).doc(category.id).update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _db.collection(Config.categoriesCollection).doc(id).delete();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await _db.collection(Config.categoriesCollection).doc(id).get();
    if (doc.exists) {
      return CategoryModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}