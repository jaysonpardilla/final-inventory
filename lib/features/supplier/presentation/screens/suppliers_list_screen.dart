import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/supplier_provider.dart';
import '../../domain/entities/supplier.dart';
import 'supplier_detail_screen.dart';
import 'supplier_form_screen.dart';

class SuppliersListScreen extends StatefulWidget {
  const SuppliersListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SuppliersListScreenState createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  String searchQuery = "";
  int itemsToShow = 10;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final user = authProvider.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suppliers",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SupplierFormScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              label: const Text(
                "new",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                side: const BorderSide(color: Colors.white, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search suppliers...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                  itemsToShow = 10;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Supplier>>(
              stream: supplierProvider.getSuppliersStream(user.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var suppliers = snapshot.data!;

                // Search filter
                if (searchQuery.isNotEmpty) {
                  suppliers = suppliers
                      .where((s) =>
                          s.name.toLowerCase().contains(searchQuery) ||
                          s.email.toLowerCase().contains(searchQuery))
                      .toList();
                }

                if (suppliers.isEmpty) {
                  return const Center(child: Text("No suppliers found"));
                }

                final paginatedSuppliers = suppliers.take(itemsToShow).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedSuppliers.length,
                        itemBuilder: (context, i) {
                          final s = paginatedSuppliers[i];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: s.profileUrl.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(s.profileUrl))
                                  : const CircleAvatar(child: Icon(Icons.business)),
                              title: Text(
                                s.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                s.email.isNotEmpty ? s.email : "No email",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SupplierFormScreen(supplier: s),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Delete Supplier", style: TextStyle(color: Colors.red, fontSize: 19,fontWeight: FontWeight.bold)),
                                          content: const Text("Are you sure you want to delete this supplier?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await supplierProvider.removeSupplier(s.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Supplier deleted successfully")),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SupplierDetailScreen(supplier: s),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (itemsToShow < suppliers.length)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              itemsToShow += 10;
                            });
                          },
                          child: const Text("Load More"),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}









