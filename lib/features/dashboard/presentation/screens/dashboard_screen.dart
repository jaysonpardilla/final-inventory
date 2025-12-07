import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../product/domain/usecases/get_products.dart';
import '../../../supplier/domain/usecases/get_suppliers.dart';
import '../../../transaction/domain/usecases/get_transactions.dart';
import '../../../sales/domain/usecases/get_daily_sales.dart';
import '../../../sales/domain/usecases/get_weekly_sales.dart';
import '../../../sales/domain/usecases/get_monthly_sales.dart';
import '../../../sales/domain/usecases/get_total_sales.dart';
import '../../../stock_alert/domain/usecases/get_low_stock_alerts.dart';
import '../../../stock_alert/presentation/screens/stock_alert_screen.dart';
import '../../../product/domain/entities/product.dart';
// import '../../../transaction/domain/entities/transaction.dart';
// import '../../../sales/domain/entities/daily_sales.dart';
// import '../../../sales/domain/entities/weekly_sales.dart';
// import '../../../sales/domain/entities/monthly_sales.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 120,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 6, 34, 49),
                    Color.fromARGB(255, 8, 44, 116),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(width: 16),
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage("lib/assets/logo.png"),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "ApexStock",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 8,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Products'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/products'),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Suppliers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/suppliers'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Transactions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/transactions'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/categories'),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Point of Sale (POS)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/purchase'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await authProvider.logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 242, 242),
        titleSpacing: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 38, 38, 38),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          StreamBuilder(
            stream: context.read<GetLowStockAlerts>()(user.id),
            builder: (context, snapshot) {
              final lowStockCount = snapshot.data?.fold(
                (failure) => 0,
                (products) => products.length,
              ) ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StockAlertScreen(userId: user.id),
                        ),
                      );
                    },
                  ),
                  if (lowStockCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$lowStockCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _SummaryRow(userId: user.id),
                const SizedBox(height: 12),
                // Daily Sales (wider) + Best Seller (narrower)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Daily Sales (last 5 days)',
                                    style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(height: 6),
                            SizedBox(height: 220, child: _DailySalesPie(userId: user.id)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Best Seller',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _BestSellersThisMonth(userId: user.id),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Monthly sales (left) + Weekly donut (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Monthly Sales', style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(height: 8),
                            SizedBox(height: 220, child: _MonthlyLineChart(userId: user.id)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Weekly Sales', style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(height: 8),
                            SizedBox(height: 220, child: _WeeklyLineChart(userId: user.id)),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
             ],
            ),
          ),

        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 3.0, right: 5.0),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/purchase'),
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text(
            "Purchase",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255)),
          ),
          backgroundColor: const Color.fromARGB(230, 7, 175, 133),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String userId;
  const _SummaryRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    final getProducts = context.read<GetProducts>();
    final getSuppliers = context.read<GetSuppliers>();
    // ignore: unused_local_variable
    final getTotalSales = context.read<GetTotalSales>();

    return Row(
      children: [
        Expanded(
          child: _SummaryCard<int>(
            title: 'Products',
            stream: getProducts(userId).map((l) => l.length),
            color: const Color(0xFF48B7F4),
            onTap: () => Navigator.pushNamed(context, '/products'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard<int>(
            title: 'Suppliers',
            stream: getSuppliers(userId).map((l) => l.length),
            color: const Color(0xFF4983F3),
            onTap: () => Navigator.pushNamed(context, '/suppliers'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard<String>(
            title: 'Total Sales',
            stream: context.read<GetTransactions>()(userId, limit: 1000).map((result) {
              return result.fold(
                (failure) => "0.00",
                (transactions) {
                  final sum = transactions.fold<double>(0.0, (p, e) => p + e.amount);
                  return sum.toStringAsFixed(2);
                },
              );
            }),
            color: const Color.fromARGB(255, 74, 220, 196),
            onTap: () => Navigator.pushNamed(context, '/transactions'),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard<T> extends StatelessWidget {
  final String title;
  final Stream<T> stream;
  final VoidCallback? onTap;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.stream,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
          child: StreamBuilder<T>(
            stream: stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return const Center(
                    child: Text('Error', style: TextStyle(color: Colors.red)));
              }
              if (!snap.hasData) {
                return const Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final value = snap.data;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

//DAILY SALES
class _DailySalesPie extends StatelessWidget {
  final String userId;
  const _DailySalesPie({required this.userId});

  @override
  Widget build(BuildContext context) {
    final getDailySales = context.read<GetDailySales>();
    return StreamBuilder(
      stream: getDailySales(userId),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final result = snap.data;
        return result!.fold(
          (failure) => Center(child: Text('Error: ${failure.message}')),
          (all) {
            if (all.isEmpty) return const Center(child: Text('No daily sales'));

            final sorted = [...all]..sort((a, b) => b.date.compareTo(a.date));
            final last5 = sorted.take(5).toList();

            return LayoutBuilder(builder: (context, constraints) {
              final double radius = (constraints.maxHeight * 0.45).clamp(20.0, 80.0);

              final sections = <PieChartSectionData>[];
              for (var i = 0; i < last5.length; i++) {
                final item = last5[i];
                final label = "${item.date.day}/${item.date.month}\n${item.salesAmount.toStringAsFixed(0)}";
                sections.add(PieChartSectionData(
                  value: item.salesAmount,
                  title: label,
                  radius: radius,
                  titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  titlePositionPercentageOffset: 0.6,
                ));
              }

              return Center(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: radius * 0.10,
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }
}

//BEST SELLER
class _BestSellersThisMonth extends StatelessWidget {
  final String userId;
  const _BestSellersThisMonth({required this.userId});

  static const _colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];

  @override
  Widget build(BuildContext context) {
    final getProducts = context.read<GetProducts>();
    final getTransactions = context.read<GetTransactions>();

    return StreamBuilder(
      stream: getProducts(userId),
      builder: (context, pSnap) {
        if (pSnap.hasError) return Center(child: Text('Error: ${pSnap.error}'));
        if (!pSnap.hasData) return const Center(child: CircularProgressIndicator());
        final products = pSnap.data!;

        return StreamBuilder(
          stream: getTransactions(userId, limit: 500),
          builder: (context, txSnap) {
            if (txSnap.hasError) return Center(child: Text('Error: ${txSnap.error}'));
            if (!txSnap.hasData) return const Center(child: CircularProgressIndicator());
            final result = txSnap.data;
            return result!.fold(
              (failure) => Center(child: Text('Error: ${failure.message}')),
              (tx) {
                final now = DateTime.now();
                final monthTx = tx.where((t) => t.transactionDate.year == now.year && t.transactionDate.month == now.month);

                final Map<String, int> agg = {};
                for (var t in monthTx) {
                  agg[t.productId] = (agg[t.productId] ?? 0) + t.quantity;
                }

                final entries = agg.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                final top5 = entries.take(5).toList();
                if (top5.isEmpty) return const Text("No sales this month");

                // find maximum total quantity (for scaling background bars)
                final maxTotal = top5
                    .map((e) => products.firstWhere((p) => p.id == e.key,
                        orElse: () => Product(
                            id: e.key,
                            name: "?",
                            price: 0,
                            quantityInStock: 0,
                            supplierId: "",
                            categoryId: "",
                            imageUrl: "",
                            quantityBuyPerItem: 0,
                            ownerId: userId)))
                    .map((p) => p.quantityInStock.toDouble())
                    .fold<double>(0.0, (prev, curr) => curr > prev ? curr : prev);

                // legend (2 columns)
                final legend = GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 5,
                  children: top5.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    final product = products.firstWhere((p) => p.id == e.key,
                        orElse: () => Product(
                            id: e.key,
                            name: "Unknown",
                            price: 0,
                            quantityInStock: 0,
                            supplierId: "",
                            categoryId: "",
                            imageUrl: "",
                            quantityBuyPerItem: 0,
                            ownerId: userId));
                    return Row(children: [
                      Container(width: 9, height: 9, color: _colors[idx % _colors.length]),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(product.name,
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis)),
                    ]);
                  }).toList(),
                );

                // Bars (overlay)
                final bars = Column(
                  children: top5.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    final sold = e.value.toDouble();
                    final product = products.firstWhere((p) => p.id == e.key,
                        orElse: () => Product(
                            id: e.key,
                            name: "Unknown",
                            price: 0,
                            quantityInStock: 0,
                            supplierId: "",
                            categoryId: "",
                            imageUrl: "",
                            quantityBuyPerItem: 0,
                            ownerId: userId));
                    final total = product.quantityInStock.toDouble();
                    final base = maxTotal > 0 ? (total / maxTotal).clamp(0.0, 1.0) : 0.0;
                    final pct = total > 0 ? (sold / total).clamp(0.0, 1.0) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Sold this month: ${sold.toInt()}'),
                                Text('Total stock: ${total.toInt()}'),
                                const SizedBox(height: 8),
                                Text('Price: \$${product.price.toStringAsFixed(2)}'),
                                const SizedBox(height: 12),
                                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
                              ]),
                            ),
                          );
                        },
                        child: Stack(children: [
                          Container(height: 22, width: double.infinity, decoration: BoxDecoration(color: const Color.fromARGB(255, 211, 239, 241), borderRadius: BorderRadius.circular(4))),
                          FractionallySizedBox(
                            widthFactor: base.toDouble(),
                            child: Container(height: 22, decoration: BoxDecoration(color: _colors[idx % _colors.length].withOpacity(0.70), borderRadius: BorderRadius.circular(4))),
                          ),
                          FractionallySizedBox(
                            widthFactor: (base * pct).toDouble(),
                            child: Container(height: 22, decoration: BoxDecoration(color: _colors[idx % _colors.length], borderRadius: BorderRadius.circular(4))),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: Text('${sold.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 15, 15, 15))),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                );

                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [legend, const SizedBox(height: 8), bars]);
              },
            );
          },
        );
      },
    );
  }
}


//MONTHLY SALES BAR CHART
class _MonthlyLineChart extends StatelessWidget {
  final String userId;
  const _MonthlyLineChart({required this.userId});

  @override
  Widget build(BuildContext context) {
    final getMonthlySales = context.read<GetMonthlySales>();
    return StreamBuilder(
      stream: getMonthlySales(userId),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final result = snap.data;
        return result!.fold(
          (failure) => Center(child: Text('Error: ${failure.message}')),
          (dataAll) {
            if (dataAll.isEmpty) return const Center(child: Text('No monthly sales'));

            final sorted = [...dataAll]..sort((a, b) {
              final yr = a.year.compareTo(b.year);
              if (yr != 0) return yr;
              return a.month.compareTo(b.month);
            });
            final last12 = sorted.length > 12 ? sorted.sublist(sorted.length - 12) : sorted;

            // Prepare bar groups
            final barGroups = last12.asMap().entries.map((entry) {
              final idx = entry.key;
              final m = entry.value;
              return BarChartGroupData(
                x: idx,
                barRods: [
                  BarChartRodData(
                    toY: m.salesAmount,
                    color: Colors.green,
                    width: 16,
                  ),
                ],
              );
            }).toList();

            final maxY = barGroups.isNotEmpty
                ? barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b)
                : 0;

            return BarChart(
              BarChartData(
                barGroups: barGroups,
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)),
                      reservedSize: 30,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < last12.length) {
                          final m = last12[idx];
                          return Text("${m.month}/${m.year}", style: const TextStyle(fontSize: 8));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                maxY: maxY > 0 ? maxY * 1.1 : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final m = last12[groupIndex];
                      return BarTooltipItem(
                        "${m.month}/${m.year}\nSales: ${m.salesAmount.toStringAsFixed(0)}",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


//WEEKLY SALES DONUT CHART
class _WeeklyLineChart extends StatelessWidget {
  final String userId;
  const _WeeklyLineChart({required this.userId});

  DateTime _representativeDateFromYearWeek(int year, int weekNumber) {
    final dt = DateTime(year, 1, 1).add(Duration(days: (weekNumber - 1) * 7));
    return dt;
  }

  @override
  Widget build(BuildContext context) {
    final getWeeklySales = context.read<GetWeeklySales>();
    final now = DateTime.now();

    return StreamBuilder(
      stream: getWeeklySales(userId),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final result = snap.data;
        return result!.fold(
          (failure) => Center(child: Text('Error: ${failure.message}')),
          (allData) {
            if (allData.isEmpty) return const Center(child: Text('No weekly sales'));

            // Filter for current month
            final currentMonthData = allData.where((w) {
              final repDate = _representativeDateFromYearWeek(w.year, w.weekNumber);
              return repDate.year == now.year && repDate.month == now.month;
            }).toList();

            if (currentMonthData.isEmpty) return const Center(child: Text('No weekly sales this month'));

            // Sort by week number
            currentMonthData.sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

            return LayoutBuilder(builder: (context, constraints) {
              final double radius = (constraints.maxHeight * 0.25).clamp(30.0, 70.0);
              final double centerSpace = radius * 0.4;

              // Prepare sections for donut chart
              final sections = currentMonthData.asMap().entries.map((entry) {
                // ignore: unused_local_variable
                final idx = entry.key;
                final w = entry.value;
                final repDate = _representativeDateFromYearWeek(w.year, w.weekNumber);
                final weekOfMonth = ((repDate.day + DateTime(repDate.year, repDate.month, 1).weekday - 1) / 7).floor() + 1;
                return PieChartSectionData(
                  value: w.salesAmount,
                  title: 'W$weekOfMonth\n${w.salesAmount.toStringAsFixed(0)}',
                  radius: radius,
                  titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  titlePositionPercentageOffset: 0.6,
                );
              }).toList();

              return Center(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: centerSpace, // This makes it a donut chart
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }
}