import 'package:dartz/dartz.dart';

import '../entities/purchase_item.dart';
import '../repositories/purchase_repository.dart';
import '../../core/failures/failure.dart';

class ProcessPurchase {
  final PurchaseRepository repository;

  ProcessPurchase(this.repository);

  Future<Either<Failure, void>> call(String ownerId, List<PurchaseItem> items) {
    return repository.processPurchase(ownerId, items);
  }
}