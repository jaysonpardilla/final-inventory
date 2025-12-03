import 'package:dartz/dartz.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';
import '../../core/failures/failure.dart';

class AddCategory {
  final CategoryRepository repository;

  AddCategory(this.repository);

  Future<Either<Failure, String>> call(Category category) {
    return repository.addCategory(category);
  }
}