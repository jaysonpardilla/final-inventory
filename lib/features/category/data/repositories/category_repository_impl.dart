import 'package:dartz/dartz.dart';

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Stream<List<Category>> getCategories(String ownerId) {
    return datasource.streamCategories(ownerId).map(
          (models) => models.map((model) => model).toList(),
        );
  }

  @override
  Future<Either<Failure, String>> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final id = await datasource.addCategory(model);
      return Right(id);
    } catch (e) {
      return Left(CategoryFailure('Failed to add category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await datasource.updateCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(CategoryFailure('Failed to update category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await datasource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(CategoryFailure('Failed to delete category: $e'));
    }
  }

  @override
  Future<Either<Failure, Category?>> getCategoryById(String id) async {
    try {
      final model = await datasource.getCategoryById(id);
      return Right(model);
    } catch (e) {
      return Left(CategoryFailure('Failed to get category: $e'));
    }
  }
}