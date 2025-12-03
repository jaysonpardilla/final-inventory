import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.quantityInStock,
    required super.supplierId,
    required super.categoryId,
    super.imageUrl,
    super.quantityBuyPerItem,
    required super.ownerId,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantityInStock: (map['quantityInStock'] ?? 0).toInt(),
      supplierId: map['supplierId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantityBuyPerItem: (map['quantityBuyPerItem'] ?? 0).toInt(),
      ownerId: map['ownerId'] ?? '',
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      quantityInStock: product.quantityInStock,
      supplierId: product.supplierId,
      categoryId: product.categoryId,
      imageUrl: product.imageUrl,
      quantityBuyPerItem: product.quantityBuyPerItem,
      ownerId: product.ownerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantityInStock': quantityInStock,
      'supplierId': supplierId,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'quantityBuyPerItem': quantityBuyPerItem,
      'ownerId': ownerId,
    };
  }
}