import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../../domain/entities/category.dart';
import '../../../../services/cloudinary_service.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  File? _imageFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _name = widget.category!.name;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _saving = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final cloudinary = CloudinaryService();
    final user = authProvider.user!;

    String imageUrl = widget.category?.imageUrl ?? "";
    if (_imageFile != null) {
      final uploaded = await cloudinary.uploadFile(_imageFile!);
      if (uploaded != null) {
        imageUrl = uploaded;
      }
    }

    final category = Category(
      id: widget.category?.id ?? "",
      name: _name,
      imageUrl: imageUrl,
      ownerId: user.id,
    );

    if (widget.category == null) {
      await categoryProvider.createCategory(category);
    } else {
      await categoryProvider.editCategory(category);
    }

    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -2,
        title: Text(widget.category == null ? "Add Category" : "Edit Category", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1565C0).withOpacity(0.1), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.white.withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                       initialValue: _name,
                       decoration: const InputDecoration(
                         labelText: "Category Name",
                         border: OutlineInputBorder(),
                       ),
                       validator: (val) =>
                           val == null || val.isEmpty ? "Enter a name" : null,
                       onSaved: (val) => _name = val!,
                     ),
                     const SizedBox(height: 20),
                     GestureDetector(
                       onTap: _pickImage,
                       child: _imageFile != null
                           ? ClipRRect(
                               borderRadius: BorderRadius.circular(12),
                               child: Image.file(
                                 _imageFile!,
                                 height: 120,
                                 fit: BoxFit.cover,
                               ),
                             )
                           : (widget.category?.imageUrl.isNotEmpty ?? false)
                               ? ClipRRect(
                                   borderRadius: BorderRadius.circular(12),
                                   child: Image.network(
                                     widget.category!.imageUrl,
                                     height: 120,
                                     fit: BoxFit.cover,
                                   ),
                                 )
                               : Container(
                                   height: 120,
                                   width: double.infinity,
                                   decoration: BoxDecoration(
                                     color: Colors.grey[300],
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   child:
                                       const Icon(Icons.add_a_photo, size: 40),
                                 ),
                     ),
                     const SizedBox(height: 20),
                     SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveCategory,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text("Saving..."),
                                  ],
                                )
                              : const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}