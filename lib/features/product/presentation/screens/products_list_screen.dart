// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../supplier/presentation/providers/supplier_provider.dart';
import '../../domain/entities/product.dart';
import '../../../../services/cloudinary_service.dart';

/// ===========================================================
///                    PRODUCTS LIST SCREEN
/// ===========================================================
class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  String searchQuery = "";
  String filter = "none";
  int itemsToShow = 10;

  String _filterLabel(String filter) {
    switch (filter) {
      case "asc":
        return "Sorted by: Ascending (A–Z)";
      case "desc":
        return "Sorted by: Descending (Z–A)";
      case "low":
        return "Filtered by: Low Stock";
      case "high":
        return "Filtered by: High Stock";
      case "category":
        return "Grouped by: Category";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final user = authProvider.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == "add") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditProductScreen()),
                );
              } else {
                setState(() {
                  filter = value;
                  itemsToShow = 10;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "add", child: Text("Add Product")),
              const PopupMenuDivider(),
              const PopupMenuItem(value: "asc", child: Text("Sort: Ascending")),
              const PopupMenuItem(value: "desc", child: Text("Sort: Descending")),
              const PopupMenuItem(value: "low", child: Text("Low Stock")),
              const PopupMenuItem(value: "high", child: Text("High Stock")),
              const PopupMenuItem(value: "category", child: Text("By Category")),
            ],
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
                hintText: "Search products...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query.toLowerCase();
                  itemsToShow = 10;
                });
              },
            ),
          ),

          if (filter != "none")
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.grey[200],
              child: Text(
                _filterLabel(filter),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),

          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productProvider.getProducts(user.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var products = snapshot.data!;

                // Searching
                if (searchQuery.isNotEmpty) {
                  products = products.where((p) =>
                      p.name.toLowerCase().contains(searchQuery) ||
                      p.categoryId.toLowerCase().contains(searchQuery)).toList();
                }

                // Sorting/filtering
                if (filter == "asc") {
                  products.sort((a, b) => a.name.compareTo(b.name));
                } else if (filter == "desc") {
                  products.sort((a, b) => b.name.compareTo(a.name));
                }

                if (products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                final paginatedProducts = products.take(itemsToShow).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedProducts.length,
                        itemBuilder: (context, index) {
                          final p = paginatedProducts[index];
                          return Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: p.imageUrl.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(p.imageUrl))
                                  : const CircleAvatar(child: Icon(Icons.inventory)),

                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text("Stock: ${p.quantityInStock} | ₱${p.price.toStringAsFixed(2)}"),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditProductScreen(product: p),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Delete Product"),
                                          content: const Text("Are you sure?"),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text("Delete"),
                                            )
                                          ],
                                        ),
                                      );

                                      if (confirm == true) await productProvider.removeProduct(p.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (itemsToShow < products.length)
                      ElevatedButton(
                        onPressed: () => setState(() => itemsToShow += 10),
                        child: const Text("Load More"),
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

/// ===========================================================
///              CLEAN — ADD / EDIT PRODUCT SCREEN
/// ===========================================================

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedSupplierId;

  File? _imageFile;
  bool _isSaving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.quantityInStock.toString();
      _selectedCategoryId = widget.product!.categoryId;
      _selectedSupplierId = widget.product!.supplierId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    await Future.wait([
      categoryProvider.loadCategories(user.id),
      supplierProvider.loadSuppliers(user.id),
    ]);

    // Fix invalid dropdown values
    if (!categoryProvider.categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = null;
    }
    if (!supplierProvider.suppliers.any((s) => s.id == _selectedSupplierId)) {
      _selectedSupplierId = null;
    }

    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final cloudinary = CloudinaryService();

    String imageUrl = widget.product?.imageUrl ?? "";
    if (_imageFile != null) {
      final uploaded = await cloudinary.uploadFile(_imageFile!);
      if (uploaded != null) imageUrl = uploaded;
    }

    final product = Product(
      id: widget.product?.id ?? "",
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      quantityInStock: int.tryParse(_stockController.text) ?? 0,
      categoryId: _selectedCategoryId!,
      supplierId: _selectedSupplierId!,
      imageUrl: imageUrl,
      ownerId: auth.user!.id,
    );

    if (widget.product == null) {
      await productProvider.createProduct(product);
    } else {
      await productProvider.editProduct(product);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: -2,
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // PRICE
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // STOCK
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // CATEGORY
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: categoryProvider.categories.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? "Select a category" : null,
              ),
                        const SizedBox(height: 16),

              // SUPPLIER
              DropdownButtonFormField<String>(
                value: _selectedSupplierId,
                decoration: const InputDecoration(labelText: 'Supplier', border: OutlineInputBorder()),
                items: supplierProvider.suppliers.map((s) {
                  return DropdownMenuItem(value: s.id, child: Text(s.name));
                }).toList(),
                onChanged: (v) => setState(() => _selectedSupplierId = v),
                validator: (v) => v == null ? "Select a supplier" : null,
              ),
                        const SizedBox(height: 20),

              // IMAGE PICKER
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!, height: 150, fit: BoxFit.cover)
                    : (widget.product?.imageUrl.isNotEmpty ?? false)
                      ? Image.network(widget.product!.imageUrl, height: 150, fit: BoxFit.cover)
                      : Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.add_a_photo, size: 40),
                        ),
              ),
              const SizedBox(height: 20),

              // SAVE BUTTON
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(widget.product == null ? "Create Product" : "Save Changes"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
