import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String ownerId;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.ownerId,
  });

  @override
  List<Object> get props => [id, name, imageUrl, ownerId];
}