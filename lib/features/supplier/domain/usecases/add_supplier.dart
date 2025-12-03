import 'package:dartz/dartz.dart';

import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../../core/failures/failure.dart';

class AddSupplier {
  final SupplierRepository repository;

  AddSupplier(this.repository);

  Future<Either<Failure, String>> call(Supplier supplier) {
    return repository.addSupplier(supplier);
  }
}