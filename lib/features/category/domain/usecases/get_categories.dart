import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  Stream<List<Category>> call(String ownerId) {
    return repository.getCategories(ownerId);
  }
}