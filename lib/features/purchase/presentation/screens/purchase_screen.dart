import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/purchase_provider.dart';
import '../../../product/domain/entities/product.dart';
import 'purchase_result_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final List<Map<String, dynamic>> _cartItems = [];
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    final user = authProvider.user!;
    purchaseProvider.loadProducts(user.id);
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = purchaseProvider.products
          .where((product) => product.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addProductToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item['product'].id == product.id);
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['quantity'] = (_cartItems[existingIndex]['quantity'] as int) + 1;
      } else {
        _cartItems.add({
          'product': product,
          'quantity': 1,
        });
      }
    });
    _searchController.clear();
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      setState(() {
        _cartItems.removeAt(index);
      });
    } else {
      setState(() {
        _cartItems[index]['quantity'] = quantity;
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  double get _totalAmount {
    return _cartItems.fold(0.0, (total, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      return total + (product.price * quantity);
    });
  }

  Future<void> _purchase() async {
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Cart is empty")),
      );
      return;
    }

    final List<Map<String, dynamic>> purchasedItems = [];

    try {
      // Validate stock availability
      for (final cartItem in _cartItems) {
        final product = cartItem['product'] as Product;
        final quantity = cartItem['quantity'] as int;

        if (quantity > product.quantityInStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "❌ Not enough stock for '${product.name}'. Available: ${product.quantityInStock}",
              ),
            ),
          );
          return;
        }

        purchasedItems.add({
          'productName': product.name,
          'quantity': quantity,
          'price': product.price,
          'total': quantity * product.price,
        });
      }

      // Add items to purchase provider cart
      for (final cartItem in _cartItems) {
        final product = cartItem['product'] as Product;
        final quantity = cartItem['quantity'] as int;
        purchaseProvider.addToCart(product.id, quantity);
      }

      final success = await purchaseProvider.checkout(user.id);
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseResultScreen(purchasedItems: purchasedItems),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }
bool _isSearchOpen = false;
  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<PurchaseProvider>(context);

    return Scaffold(
    appBar: AppBar(
      titleSpacing: 0,
      title: _isSearchOpen
          ? Padding(
              padding: const EdgeInsets.only(right: 12), // <-- right margin added
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 4000),
                curve: Curves.easeOut,
                height: 50,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _isSearchOpen = false;
                          _searchController.clear();
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            )
          : const Text(
              "Point Of Sale",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

      actions: [
        if (!_isSearchOpen)
          Padding(
            padding: const EdgeInsets.only(right: 12), // <-- right margin added
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchOpen = true;
                });
              },
            ),
          ),
      ],
    ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Products Available Box
            SizedBox(
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text(
                      "Products Available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: purchaseProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : (_searchController.text.isEmpty ? purchaseProvider.products : _filteredProducts).isEmpty
                              ? const Center(child: Text("⚠️ No products available"))
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3.2,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 1,
                                  ),
                                  itemCount: (_searchController.text.isEmpty ? purchaseProvider.products : _filteredProducts).length,
                                  itemBuilder: (context, index) {
                                    final products = _searchController.text.isEmpty ? purchaseProvider.products : _filteredProducts;
                                    final p = products[index];
                                    return InkWell(
                                      onTap: () => _addProductToCart(p),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: FittedBox(
                                          alignment: Alignment.topLeft,
                                          fit: BoxFit.scaleDown,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                p.name,
                                                style: const TextStyle(
                                                  fontSize: 70,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "₱${p.price.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(255, 124, 28, 28),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                              Text(
                                                "Stock: ${p.quantityInStock}",
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  color: Color.fromARGB(255, 98, 76, 76),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Cart Items",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),


            // Cart Items
            Expanded(
              flex: 3,
              child: _cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        "Cart is empty\nTap products above to add items",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        final product = item['product'] as Product;
                        final quantity = item['quantity'] as int;
                        final total = product.price * quantity;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          title: Row(
                            children: [
                              // ────────────────────────────────
                              // 1️⃣ PRODUCT DETAILS COLUMN
                              // ────────────────────────────────
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "₱${product.price.toStringAsFixed(2)} each",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ────────────────────────────────
                              // 2️⃣ QUANTITY COLUMN
                              // ────────────────────────────────
                              SizedBox(
                                width: 40,
                                child: Text(
                                  quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // ────────────────────────────────
                              // 3️⃣ BUTTONS COLUMN (− + delete)
                              // Buttons auto-fit without overflow
                              // ────────────────────────────────
                              SizedBox(
                                width: 110,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        onPressed: () => _updateQuantity(index, quantity - 1),
                                        icon: const Icon(Icons.remove),
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        onPressed: () => _updateQuantity(index, quantity + 1),
                                        icon: const Icon(Icons.add),
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 20,
                                        onPressed: () => _removeFromCart(index),
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ────────────────────────────────
                              // 4️⃣ PRICE COLUMN
                              // ────────────────────────────────
                              SizedBox(
                                width: 70,
                                child: Text(
                                  "₱${total.toStringAsFixed(2)}",
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),

      // Bottom Bar for Total + Charge Button
      bottomNavigationBar: Container(
        color: Colors.blue.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Total: ₱${_totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            purchaseProvider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _cartItems.isEmpty ? null : _purchase,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Charge"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cartItems.isEmpty ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}