import 'package:dartz/dartz.dart';

import '../entities/category.dart';
import '../../core/failures/failure.dart';

abstract class CategoryRepository {
  Stream<List<Category>> getCategories(String ownerId);
  Future<Either<Failure, String>> addCategory(Category category);
  Future<Either<Failure, void>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, Category?>> getCategoryById(String id);
}