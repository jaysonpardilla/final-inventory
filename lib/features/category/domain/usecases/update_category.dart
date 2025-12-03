import 'package:dartz/dartz.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../../core/failures/failure.dart';

class UpdateCategory {
  final CategoryRepository repository;

  UpdateCategory(this.repository);

  Future<Either<Failure, void>> call(Category category) {
    return repository.updateCategory(category);
  }
}