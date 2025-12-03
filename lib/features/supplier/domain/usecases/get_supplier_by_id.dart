import 'package:dartz/dartz.dart';

import '../entities/supplier.dart';
import '../repositories/supplier_repository.dart';
import '../../core/failures/failure.dart';

class GetSupplierById {
  final SupplierRepository repository;

  GetSupplierById(this.repository);

  Future<Either<Failure, Supplier?>> call(String id) {
    return repository.getSupplierById(id);
  }
}