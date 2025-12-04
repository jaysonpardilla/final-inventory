import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/usecases/get_low_stock_alerts.dart';

class StockAlertScreen extends StatelessWidget {
  final String userId;

  const StockAlertScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final getLowStockAlerts = context.read<GetLowStockAlerts>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: -2,
        title: const Text('Low Stock Alerts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder(
        stream: getLowStockAlerts(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshot.data!.fold(
            (failure) => Center(
              child: Text(
                'Error: ${failure.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'No low stock products',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange, size: 30),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: ${product.quantityInStock}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
