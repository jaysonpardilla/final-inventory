import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../providers/supplier_provider.dart';
import '../../domain/entities/supplier.dart';
import '../../../product/domain/entities/product.dart';
import 'supplier_form_screen.dart';

class SupplierDetailScreen extends StatelessWidget {
  final Supplier supplier;
  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final user = authProvider.user!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: supplier.backgroundUrl.isNotEmpty
                      ? Image.network(
                          supplier.backgroundUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image, size: 100, color: Colors.grey),
                ),

                // Back button
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Menu
                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    radius: 20,
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplierFormScreen(supplier: supplier),
                            ),
                          );
                        } else if (value == 'delete') {
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
                            await supplierProvider.removeSupplier(supplier.id);
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Supplier deleted successfully"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text("Edit Supplier")),
                        const PopupMenuItem(value: 'delete', child: Text("Delete Supplier")),
                      ],
                    ),
                  ),
                ),

                // Profile + Name
                Positioned(
                  bottom: -60,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 114, 161, 255),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color.fromARGB(255, 212, 248, 255),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundImage: supplier.profileUrl.isNotEmpty
                                ? NetworkImage(supplier.profileUrl)
                                : null,
                            child: supplier.profileUrl.isEmpty
                                ? const Icon(Icons.person, size: 36, color: Colors.grey)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        supplier.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          shadows: [
                            Shadow(blurRadius: 1, color: Colors.black54),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Supplier Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (supplier.email.isNotEmpty)
                    Text("Email: ${supplier.email}", style: const TextStyle(fontSize: 15)),
                  if (supplier.phone.isNotEmpty)
                    Text("Phone: ${supplier.phone}", style: const TextStyle(fontSize: 15)),
                  if (supplier.address.isNotEmpty)
                    Text("Address: ${supplier.address}", style: const TextStyle(fontSize: 15)),
                  if (supplier.country.isNotEmpty)
                    Text("Country: ${supplier.country}", style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),

            const Divider(),
            const SizedBox(height: 8),

            // Products Grid
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Products Supplied",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<Product>>(
              stream: productProvider.getProducts(user.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data!
                    .where((p) => p.supplierId == supplier.id)
                    .toList();

                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("⚠️ No products supplied."),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      elevation: 3,
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Positioned.fill(
                            child: p.imageUrl.isNotEmpty
                                ? Image.network(p.imageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                          ),
                          Container(
                            height: 40,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}