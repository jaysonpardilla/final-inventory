import 'package:dartz/dartz.dart';

import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../../core/failures/failure.dart';

class UpdateSupplier {
  final SupplierRepository repository;

  UpdateSupplier(this.repository);

  Future<Either<Failure, void>> call(Supplier supplier) {
    return repository.updateSupplier(supplier);
  }
}