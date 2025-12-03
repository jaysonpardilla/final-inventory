import 'package:dartz/dartz.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../../core/failures/failure.dart';

class GetCategoryById {
  final CategoryRepository repository;

  GetCategoryById(this.repository);

  Future<Either<Failure, Category?>> call(String id) {
    return repository.getCategoryById(id);
  }
}