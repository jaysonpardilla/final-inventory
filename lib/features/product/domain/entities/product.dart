import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantityInStock;
  final String supplierId;
  final String categoryId;
  final String imageUrl;
  final int quantityBuyPerItem;
  final String ownerId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantityInStock,
    required this.supplierId,
    required this.categoryId,
    this.imageUrl = '',
    this.quantityBuyPerItem = 0,
    required this.ownerId,
  });

  @override
  List<Object> get props => [
        id,
        name,
        price,
        quantityInStock,
        supplierId,
        categoryId,
        imageUrl,
        quantityBuyPerItem,
        ownerId,
      ];
}