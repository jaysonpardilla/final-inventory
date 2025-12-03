import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    required super.country,
    super.profileUrl,
    super.backgroundUrl,
    required super.ownerId,
  });

  factory SupplierModel.fromMap(String id, Map<String, dynamic> map) {
    return SupplierModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      country: map['country'] ?? '',
      profileUrl: map['profileUrl'] ?? '',
      backgroundUrl: map['backgroundUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
    );
  }

  factory SupplierModel.fromEntity(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      email: supplier.email,
      phone: supplier.phone,
      address: supplier.address,
      country: supplier.country,
      profileUrl: supplier.profileUrl,
      backgroundUrl: supplier.backgroundUrl,
      ownerId: supplier.ownerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'country': country,
      'profileUrl': profileUrl,
      'backgroundUrl': backgroundUrl,
      'ownerId': ownerId,
    };
  }
}