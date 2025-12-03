import 'package:dartz/dartz.dart';

import '../repositories/product_repository.dart';
import '../../core/failures/failure.dart';

class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteProduct(id);
  }
}