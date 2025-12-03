import 'package:dartz/dartz.dart';

import '../entities/purchase_item.dart';
import '../../core/failures/failure.dart';

abstract class PurchaseRepository {
  Future<Either<Failure, void>> processPurchase(String ownerId, List<PurchaseItem> items);
}