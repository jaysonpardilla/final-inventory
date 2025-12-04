import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart' as auth_provider;

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final GlobalKey _filterKey = GlobalKey(); // For popup dropdown placement

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<auth_provider.AuthProvider>();
      final user = authProvider.user;
      if (user != null) {
        context.read<TransactionProvider>().loadTransactions(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.getFilteredTransactions();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        titleSpacing: -2,
        title: const Text(
          "Transactions",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // ────────────────────────────────────────────────
          // SEARCH + FILTER ROW (full width)
          // ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                // SEARCH (75% of width)
                SizedBox(
                  width: width * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // FILTER BUTTON (20–25% width)
                SizedBox(
                  key: _filterKey,
                  width: width * 0.20,
                  child: ElevatedButton(
                    onPressed: () => _openFilterDropdown(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 203, 231, 255),   // 🔵 CHANGE BACKGROUND HERE
                      foregroundColor: Colors.white,  // 🎨 icon color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.filter_alt), // you can change this too
                  ),

                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : transactions.isEmpty
                        ? const Center(child: Text("No transactions found"))
                        : _buildTransactionTable(provider, transactions),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // POPUP FILTER DROPDOWN (under button)
  // ────────────────────────────────────────────────
  void _openFilterDropdown(BuildContext context, TransactionProvider provider) {
    final RenderBox box =
        _filterKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + box.size.height,
        position.dx + box.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        PopupMenuItem(
          height: 30,
          child: const Text("Date ↑", style: TextStyle(fontSize: 12)),
          onTap: () => provider.setFilter("dateAsc"),
        ),
        PopupMenuItem(
          height: 30,
          child: const Text("Date ↓", style: TextStyle(fontSize: 12)),
          onTap: () => provider.setFilter("dateDesc"),
        ),
        PopupMenuItem(
          height: 30,
          child: const Text("Amount ↑", style: TextStyle(fontSize: 12)),
          onTap: () => provider.setFilter("amountAsc"),
        ),
        PopupMenuItem(
          height: 30,
          child: const Text("Amount ↓", style: TextStyle(fontSize: 12)),
          onTap: () => provider.setFilter("amountDesc"),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────
  // TABLE (full width + ellipsis + small font)
  // ────────────────────────────────────────────────
  Widget _buildTransactionTable(
      TransactionProvider provider, List transactions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width, // FULL WIDTH
        child: DataTable(
          columnSpacing: 25,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.grey.shade200,
          ),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 50,

          columns: const [
            DataColumn(label: Text("Product", style: TextStyle(fontSize: 12))),
            DataColumn(label: Text("Date", style: TextStyle(fontSize: 12))),
            DataColumn(label: Text("Qty", style: TextStyle(fontSize: 12))),
            DataColumn(label: Text("Amount", style: TextStyle(fontSize: 12))),
          ],

          rows: transactions.map((t) {
            final product = provider.productsMap[t.productId];

            final date = t.transactionDate;
            final formattedDate =
                "${date.month.toString().padLeft(2, '0')}-"
                "${date.day.toString().padLeft(2, '0')}-"
                "${date.year.toString().substring(2)}";

            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 90,
                    child: Text(
                      product?.name ?? "Loading...",
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Text(formattedDate, style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text("${t.quantity}", style: const TextStyle(fontSize: 12)),
                ),
                DataCell(
                  Text(
                    "₱${t.amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
