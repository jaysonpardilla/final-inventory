import 'package:dartz/dartz.dart';

import '../../domain/entities/purchase_item.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/purchase_remote_datasource.dart';
import '../models/purchase_item_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDatasource datasource;

  PurchaseRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, void>> processPurchase(String ownerId, List<PurchaseItem> items) async {
    try {
      final models = items.map((item) => PurchaseItemModel.fromEntity(item)).toList();
      await datasource.processPurchase(ownerId, models);
      return const Right(null);
    } catch (e) {
      return Left(PurchaseFailure('Failed to process purchase: $e'));
    }
  }
}