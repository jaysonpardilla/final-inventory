import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category.dart';
import 'category_form_screen.dart';

class CategoriesListScreen extends StatefulWidget {
  @override
  _CategoriesListScreenState createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  String searchQuery = "";
  String filter = "none";
  int itemsToShow = 10; // pagination count

  String _filterLabel(String filter) {
    switch (filter) {
      case "asc":
        return "Sorted by: Ascending (A–Z)";
      case "desc":
        return "Sorted by: Descending (Z–A)";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final user = authProvider.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == "add") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CategoryFormScreen()),
                );
              } else {
                setState(() {
                  filter = value;
                  itemsToShow = 10;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "add", child: Text("Add Category")),
              const PopupMenuDivider(),
              const PopupMenuItem(value: "asc", child: Text("Sort: Ascending")),
              const PopupMenuItem(value: "desc", child: Text("Sort: Descending")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search categories...",
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
              ],
            ),
          ),

          if (filter != "none")
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.grey[200],
              child: Text(
                _filterLabel(filter),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),

          // 🔹 Category List
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: categoryProvider.getCategories(user.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var categories = snapshot.data!;

                // 🔹 Apply search
                if (searchQuery.isNotEmpty) {
                  categories = categories
                      .where((c) => c.name.toLowerCase().contains(searchQuery))
                      .toList();
                }

                // 🔹 Apply sorting
                if (filter == "asc") {
                  categories.sort((a, b) => a.name.compareTo(b.name));
                } else if (filter == "desc") {
                  categories.sort((a, b) => b.name.compareTo(a.name));
                }

                if (categories.isEmpty) {
                  return const Center(child: Text("No categories found"));
                }

                final paginatedCategories = categories.take(itemsToShow).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedCategories.length,
                        itemBuilder: (context, idx) {
                          final cat = paginatedCategories[idx];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 241, 240, 240),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: cat.imageUrl.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(cat.imageUrl))
                                  : const CircleAvatar(child: Icon(Icons.image)),
                              title: Text(
                                cat.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoryFormScreen(category: cat),
                                  ),
                                );
                              },
                              onLongPress: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Category"),
                                    content: Text("Are you sure you want to delete '${cat.name}'?"),
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
                                  await categoryProvider.removeCategory(cat.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Category deleted successfully")),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (itemsToShow < categories.length)
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