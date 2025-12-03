import 'package:dartz/dartz.dart';

import '../repositories/category_repository.dart';
import '../../core/failures/failure.dart';

class DeleteCategory {
  final CategoryRepository repository;

  DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCategory(id);
  }
}