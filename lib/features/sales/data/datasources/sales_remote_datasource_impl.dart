import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config.dart';
import 'sales_remote_datasource.dart';
import '../../domain/entities/daily_sales.dart';
import '../../domain/entities/weekly_sales.dart';
import '../../domain/entities/monthly_sales.dart';

class SalesRemoteDatasourceImpl implements SalesRemoteDatasource {
  final FirebaseFirestore _db;

  SalesRemoteDatasourceImpl(this._db);

  @override
  Stream<List<DailySales>> streamDailySales(String ownerId) {
    return _db
        .collection(Config.dailySalesCollection)
        .where("ownerId", isEqualTo: ownerId)
        .orderBy("date", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => DailySales.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<WeeklySales>> streamWeeklySales(String ownerId) {
    return _db
        .collection(Config.weeklySalesCollection)
        .where("ownerId", isEqualTo: ownerId)
        .orderBy("year", descending: true)
        .orderBy("weekNumber", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => WeeklySales.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<MonthlySales>> streamMonthlySales(String ownerId) {
    return _db
        .collection(Config.monthlySalesCollection)
        .where("ownerId", isEqualTo: ownerId)
        .orderBy("year", descending: true)
        .orderBy("month", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => MonthlySales.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<MonthlySales>> streamTotalSales(String ownerId) {
    return _db
        .collection(Config.totalSalesCollection)
        .where("ownerId", isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => MonthlySales.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}