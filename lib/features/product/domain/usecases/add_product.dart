import 'package:dartz/dartz.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../../core/failures/failure.dart';

class AddProduct {
  final ProductRepository repository;

  AddProduct(this.repository);

  Future<Either<Failure, String>> call(Product product) {
    return repository.addProduct(product);
  }
}