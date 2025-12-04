import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_category_by_id.dart';

class CategoryProvider extends ChangeNotifier {
  final GetCategories getCategories;
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final GetCategoryById getCategoryById;

  CategoryProvider({
    required this.getCategories,
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.getCategoryById,
  }) {
    _init();
  }

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Category>> get categoriesStream => getCategories('');

  void _init() {
    // Initialize if needed
  }

  Future<void> loadCategories(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = getCategories(ownerId);
      stream.listen((categories) {
        _categories = categories;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to load categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await addCategory(category);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (id) {
        // Category added successfully, stream will update
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> editCategory(Category category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await updateCategory(category);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Category updated successfully
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeCategory(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await deleteCategory(id);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        // Category deleted successfully
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<Category?> fetchCategoryById(String id) async {
    final result = await getCategoryById(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return null;
      },
      (category) => category,
    );
  }
}