import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String country;
  final String profileUrl;
  final String backgroundUrl;
  final String ownerId;

  const Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.country,
    this.profileUrl = '',
    this.backgroundUrl = '',
    required this.ownerId,
  });

  @override
  List<Object> get props => [
        id,
        name,
        email,
        phone,
        address,
        country,
        profileUrl,
        backgroundUrl,
        ownerId,
      ];
}