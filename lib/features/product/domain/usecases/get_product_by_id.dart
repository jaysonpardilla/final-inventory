import 'package:dartz/dartz.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../core/failures/failure.dart';

class GetProductById {
  final ProductRepository repository;

  GetProductById(this.repository);

  Future<Either<Failure, Product?>> call(String id) {
    return repository.getProductById(id);
  }
}