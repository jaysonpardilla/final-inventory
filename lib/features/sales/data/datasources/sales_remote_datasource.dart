import '../../domain/entities/daily_sales.dart';
import '../../domain/entities/weekly_sales.dart';
import '../../domain/entities/monthly_sales.dart';

abstract class SalesRemoteDatasource {
  Stream<List<DailySales>> streamDailySales(String ownerId);
  Stream<List<WeeklySales>> streamWeeklySales(String ownerId);
  Stream<List<MonthlySales>> streamMonthlySales(String ownerId);
  Stream<List<MonthlySales>> streamTotalSales(String ownerId);
}