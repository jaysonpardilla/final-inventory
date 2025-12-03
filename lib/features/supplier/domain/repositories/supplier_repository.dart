import 'package:dartz/dartz.dart';

import '../entities/supplier.dart';
import '../../core/failures/failure.dart';

abstract class SupplierRepository {
  Stream<List<Supplier>> getSuppliers(String ownerId);
  Future<Either<Failure, String>> addSupplier(Supplier supplier);
  Future<Either<Failure, void>> updateSupplier(Supplier supplier);
  Future<Either<Failure, void>> deleteSupplier(String id);
  Future<Either<Failure, Supplier?>> getSupplierById(String id);
}