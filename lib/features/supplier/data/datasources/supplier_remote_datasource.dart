import '../models/supplier_model.dart';

abstract class SupplierRemoteDatasource {
  Stream<List<SupplierModel>> streamSuppliers(String ownerId);
  Future<String> addSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
  Future<SupplierModel?> getSupplierById(String id);
}