import 'package:dartz/dartz.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../core/failures/failure.dart';

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<Either<Failure, void>> call(Product product) {
    return repository.updateProduct(product);
  }
}