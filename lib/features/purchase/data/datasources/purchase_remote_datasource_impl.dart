import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory/config.dart';

import 'purchase_remote_datasource.dart';
import '../models/purchase_item_model.dart';

class PurchaseRemoteDatasourceImpl implements PurchaseRemoteDatasource {
  final FirebaseFirestore _db;

  PurchaseRemoteDatasourceImpl(this._db);

  @override
  Future<void> processPurchase(String ownerId, List<PurchaseItemModel> items) async {
    await _db.runTransaction((tx) async {
      double totalPurchaseAmount = 0;
      final productSnaps = <String, Map<String, dynamic>>{};

      // 🔹 Step 1: READ all products first
      for (final item in items) {
        final productId = item.productId;
        final productRef = _db.collection(Config.productsCollection).doc(productId);
        final prodSnap = await tx.get(productRef);

        if (!prodSnap.exists) throw Exception('Product $productId does not exist');
        productSnaps[productId] = prodSnap.data()!;
      }

      // 🔹 Step 2: PROCESS products & WRITE updates
      for (final item in items) {
        final productId = item.productId;
        final quantity = item.quantity;

        final product = productSnaps[productId]!;
        final price = (product['price'] as num).toDouble();
        final quantityInStock = (product['quantityInStock'] as num).toInt();
        final quantityBuyPerItem = (product['quantityBuyPerItem'] as num?)?.toInt() ?? 0;

        if (quantityInStock < quantity) {
          throw Exception('Insufficient stock for product $productId');
        }

        final double purchaseAmount = quantity * price;
        totalPurchaseAmount += purchaseAmount;

        final newQty = quantityInStock - quantity;
        final newQuantityBuyPerItem = quantityBuyPerItem + quantity;

        // 🔹 Update product stock
        final productRef = _db.collection(Config.productsCollection).doc(productId);
        tx.update(productRef, {
          'quantityInStock': newQty,
          'quantityBuyPerItem': newQuantityBuyPerItem,
        });

        // 🔹 Add transaction record
        final transRef = _db.collection(Config.transactionsCollection).doc();
        tx.set(transRef, {
          'productId': productId,
          'transactionType': 'Decrease stock',
          'transactionDate': Timestamp.now(),
          'amount': purchaseAmount,
          'quantity': quantity,
          'ownerId': ownerId,
        });

        // 🔹 Update per-product Total Sales
        final productTotalQuery = await _db
            .collection(Config.totalSalesCollection)
            .where('productId', isEqualTo: productId)
            .where('ownerId', isEqualTo: ownerId)
            .limit(1)
            .get();

        if (productTotalQuery.docs.isEmpty) {
          final doc = _db.collection(Config.totalSalesCollection).doc();
          tx.set(doc, {
            'productId': productId,
            'salesPerItem': purchaseAmount,
            'totalSales': purchaseAmount,
            'ownerId': ownerId,
          });
        } else {
          final docRef = productTotalQuery.docs.first.reference;
          final current = productTotalQuery.docs.first.data();
          final updatedSales =
              (current['salesPerItem'] as num? ?? 0).toDouble() + purchaseAmount;
          final updatedTotal =
              (current['totalSales'] as num? ?? 0).toDouble() + purchaseAmount;
          tx.update(docRef, {
            'salesPerItem': updatedSales,
            'totalSales': updatedTotal,
          });
        }
      }

      // 🔹 Step 3: Update Aggregated Sales (Daily, Weekly, Monthly, Overall)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // --- DAILY ---
      final dailyQuery = await _db
          .collection(Config.dailySalesCollection)
          .where('ownerId', isEqualTo: ownerId)
          .where('date', isEqualTo: Timestamp.fromDate(todayDate))
          .limit(1)
          .get();

      if (dailyQuery.docs.isEmpty) {
        final doc = _db.collection(Config.dailySalesCollection).doc();
        tx.set(doc, {
          'date': Timestamp.fromDate(todayDate),
          'salesAmount': totalPurchaseAmount,
          'ownerId': ownerId,
        });
      } else {
        final docRef = dailyQuery.docs.first.reference;
        final current = dailyQuery.docs.first.data();
        final updated =
            (current['salesAmount'] as num? ?? 0).toDouble() + totalPurchaseAmount;
        tx.update(docRef, {'salesAmount': updated});
      }

      // --- WEEKLY ---
      final year = today.year;
      int weekNumber(DateTime date) {
        final firstDayOfYear = DateTime(date.year, 1, 1);
        final daysOffset = firstDayOfYear.weekday - 1;
        final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
        return ((date.difference(firstMonday).inDays) / 7).floor() + 1;
      }

      final week = weekNumber(today);
      final weeklyQuery = await _db
          .collection(Config.weeklySalesCollection)
          .where('ownerId', isEqualTo: ownerId)
          .where('year', isEqualTo: year)
          .where('weekNumber', isEqualTo: week)
          .limit(1)
          .get();

      if (weeklyQuery.docs.isEmpty) {
        final doc = _db.collection(Config.weeklySalesCollection).doc();
        tx.set(doc, {
          'year': year,
          'weekNumber': week,
          'salesAmount': totalPurchaseAmount,
          'ownerId': ownerId,
        });
      } else {
        final docRef = weeklyQuery.docs.first.reference;
        final current = weeklyQuery.docs.first.data();
        final updated =
            (current['salesAmount'] as num? ?? 0).toDouble() + totalPurchaseAmount;
        tx.update(docRef, {'salesAmount': updated});
      }

      // --- MONTHLY ---
      final month = today.month;
      final monthlyQuery = await _db
          .collection(Config.monthlySalesCollection)
          .where('ownerId', isEqualTo: ownerId)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .limit(1)
          .get();

      if (monthlyQuery.docs.isEmpty) {
        final doc = _db.collection(Config.monthlySalesCollection).doc();
        tx.set(doc, {
          'year': year,
          'month': month,
          'salesAmount': totalPurchaseAmount,
          'ownerId': ownerId,
        });
      } else {
        final docRef = monthlyQuery.docs.first.reference;
        final current = monthlyQuery.docs.first.data();
        final updated =
            (current['salesAmount'] as num? ?? 0).toDouble() + totalPurchaseAmount;
        tx.update(docRef, {'salesAmount': updated});
      }

      // --- OVERALL TOTAL ---
      final overallQuery = await _db
          .collection(Config.totalSalesCollection)
          .where('productId', isNull: true)
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (overallQuery.docs.isEmpty) {
        final doc = _db.collection(Config.totalSalesCollection).doc();
        tx.set(doc, {
          'productId': null,
          'salesPerItem': 0,
          'totalSales': totalPurchaseAmount,
          'ownerId': ownerId,
        });
      } else {
        final docRef = overallQuery.docs.first.reference;
        final current = overallQuery.docs.first.data();
        final updated =
            (current['totalSales'] as num? ?? 0).toDouble() + totalPurchaseAmount;
        tx.update(docRef, {'totalSales': updated});
      }
    });
  }
}