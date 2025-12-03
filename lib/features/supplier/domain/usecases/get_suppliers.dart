import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';

class GetSuppliers {
  final SupplierRepository repository;

  GetSuppliers(this.repository);

  Stream<List<Supplier>> call(String ownerId) {
    return repository.getSuppliers(ownerId);
  }
}