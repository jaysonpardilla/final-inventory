import '../models/product_model.dart';

abstract class ProductRemoteDatasource {
  Stream<List<ProductModel>> streamProducts(String ownerId);
  Future<String> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<ProductModel?> getProductById(String id);
}