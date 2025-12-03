import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Stream<List<Product>> call(String ownerId) {
    return repository.getProducts(ownerId);
  }
}