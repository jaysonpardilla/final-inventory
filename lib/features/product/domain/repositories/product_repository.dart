import 'package:dartz/dartz.dart';

import '../entities/product.dart';
import '../../core/failures/failure.dart';

abstract class ProductRepository {
  Stream<List<Product>> getProducts(String ownerId);
  Future<Either<Failure, String>> addProduct(Product product);
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, Product?>> getProductById(String id);
}