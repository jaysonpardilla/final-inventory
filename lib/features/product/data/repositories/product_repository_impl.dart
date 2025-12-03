import 'package:dartz/dartz.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Stream<List<Product>> getProducts(String ownerId) {
    return datasource.streamProducts(ownerId).map(
          (models) => models.map((model) => model as Product).toList(),
        );
  }

  @override
  Future<Either<Failure, String>> addProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final id = await datasource.addProduct(model);
      return Right(id);
    } catch (e) {
      return Left(ProductFailure('Failed to add product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      final model = ProductModel.fromEntity(product);
      await datasource.updateProduct(model);
      return const Right(null);
    } catch (e) {
      return Left(ProductFailure('Failed to update product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await datasource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(ProductFailure('Failed to delete product: $e'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(String id) async {
    try {
      final model = await datasource.getProductById(id);
      return Right(model);
    } catch (e) {
      return Left(ProductFailure('Failed to get product: $e'));
    }
  }
}