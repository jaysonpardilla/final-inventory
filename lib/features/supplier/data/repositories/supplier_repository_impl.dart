import 'package:dartz/dartz.dart';

import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/supplier_remote_datasource.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDatasource datasource;

  SupplierRepositoryImpl(this.datasource);

  @override
  Stream<List<Supplier>> getSuppliers(String ownerId) {
    return datasource.streamSuppliers(ownerId).map(
          (models) => models.map((model) => model).toList(),
        );
  }

  @override
  Future<Either<Failure, String>> addSupplier(Supplier supplier) async {
    try {
      final model = SupplierModel.fromEntity(supplier);
      final id = await datasource.addSupplier(model);
      return Right(id);
    } catch (e) {
      return Left(SupplierFailure('Failed to add supplier: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSupplier(Supplier supplier) async {
    try {
      final model = SupplierModel.fromEntity(supplier);
      await datasource.updateSupplier(model);
      return const Right(null);
    } catch (e) {
      return Left(SupplierFailure('Failed to update supplier: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(String id) async {
    try {
      await datasource.deleteSupplier(id);
      return const Right(null);
    } catch (e) {
      return Left(SupplierFailure('Failed to delete supplier: $e'));
    }
  }

  @override
  Future<Either<Failure, Supplier?>> getSupplierById(String id) async {
    try {
      final model = await datasource.getSupplierById(id);
      return Right(model);
    } catch (e) {
      return Left(SupplierFailure('Failed to get supplier: $e'));
    }
  }
}