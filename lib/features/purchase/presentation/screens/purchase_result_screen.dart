import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PurchaseResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> purchasedItems;

  const PurchaseResultScreen({super.key, required this.purchasedItems});

  Future<void> _downloadReceipt(BuildContext context) async {
    final pdf = pw.Document();

    final totalAmount = purchasedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['total'] as double),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "STORE RECEIPT",
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                pw.SizedBox(height: 4),
                pw.Text("------------------------------------------------",
                    style: pw.TextStyle(fontSize: 7)),

                pw.Text("Item                  Qty   Total",
                    style: pw.TextStyle(fontSize: 7)),

                pw.SizedBox(height: 10),

                ...purchasedItems.map((item) {
                  final name = item['productName'];
                  final qty = item['quantity'];
                  final total = (item['total'] as double).toStringAsFixed(2);

                  String fixedName = name.padRight(18).substring(0, 18);
                  String fixedQty = qty.toString().padLeft(3);
                  String fixedTotal = total.padLeft(7);

                  return pw.Text(
                    "$fixedName $fixedQty $fixedTotal",
                    style: pw.TextStyle(fontSize: 7),
                  );
                }),

                pw.SizedBox(height: 10),
                pw.Text(
                  "TOTAL: ${totalAmount.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 4),

                pw.Center(
                  child: pw.Text(
                    "Thank you for your purchase!",
                    style: pw.TextStyle(fontSize: 6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final file = File("${directory.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Receipt saved to ${file.path}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = purchasedItems.fold<double>(
      0.0,
      (sum, item) => sum + (item['total'] as double),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 🔹 Top Back Arrow
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F5F5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),

            // Success Header
            Column(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                SizedBox(height: 10),
                Text(
                  "Purchase Successful!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Here are your transaction details",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Receipt Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: purchasedItems.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final item = purchasedItems[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                      title: Text(
                        item['productName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${item['quantity']} × ₱${item['price']}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Text(
                        "₱${(item['total'] as double).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Total Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    "Total Amount:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "₱${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 DOWNLOAD RECEIPT BUTTON ONLY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadReceipt(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.download),
                  label: const Text(
                    "Download Receipt",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
