import 'package:dartz/dartz.dart';

import '../repositories/supplier_repository.dart';
import '../../core/failures/failure.dart';

class DeleteSupplier {
  final SupplierRepository repository;

  DeleteSupplier(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteSupplier(id);
  }
}