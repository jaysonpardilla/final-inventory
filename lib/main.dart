import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth imports
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/register_with_email.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

// Category imports
import 'features/category/data/datasources/category_remote_datasource_impl.dart';
import 'features/category/data/repositories/category_repository_impl.dart';
import 'features/category/domain/usecases/get_categories.dart';
import 'features/category/domain/usecases/add_category.dart';
import 'features/category/domain/usecases/update_category.dart';
import 'features/category/domain/usecases/delete_category.dart';
import 'features/category/domain/usecases/get_category_by_id.dart';
import 'features/category/presentation/providers/category_provider.dart';

// Dashboard
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

// Category screens
import 'features/category/presentation/screens/categories_list_screen.dart';
import 'features/category/presentation/screens/category_form_screen.dart';

// Product imports
import 'features/product/data/datasources/product_remote_datasource_impl.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/get_products.dart';
import 'features/product/domain/usecases/add_product.dart';
import 'features/product/domain/usecases/update_product.dart';
import 'features/product/domain/usecases/delete_product.dart';
import 'features/product/domain/usecases/get_product_by_id.dart';
import 'features/product/presentation/providers/product_provider.dart';

// Product screens
import 'features/product/presentation/screens/products_list_screen.dart';

// Supplier imports
import 'features/supplier/data/datasources/supplier_remote_datasource_impl.dart';
import 'features/supplier/data/repositories/supplier_repository_impl.dart';
import 'features/supplier/domain/usecases/get_suppliers.dart';
import 'features/supplier/domain/usecases/add_supplier.dart';
import 'features/supplier/domain/usecases/update_supplier.dart';
import 'features/supplier/domain/usecases/delete_supplier.dart';
import 'features/supplier/domain/usecases/get_supplier_by_id.dart';
import 'features/supplier/presentation/providers/supplier_provider.dart';

// Supplier screens
import 'features/supplier/presentation/screens/suppliers_list_screen.dart';

// Transaction screens
import 'features/transaction/presentation/screens/transactions_screen.dart';

// Purchase imports
import 'features/purchase/data/datasources/purchase_remote_datasource_impl.dart';
import 'features/purchase/data/repositories/purchase_repository_impl.dart';
import 'features/purchase/domain/usecases/process_purchase.dart';
import 'features/purchase/presentation/providers/purchase_provider.dart';

// Purchase screens
import 'features/purchase/presentation/screens/purchase_screen.dart';

//transaction
import 'features/transaction/data/datasources/transaction_remote_datasource_impl.dart';
import 'features/transaction/data/repositories/transaction_repository_impl.dart';
import 'features/transaction/domain/usecases/get_transactions.dart';
import 'features/transaction/presentation/providers/transaction_provider.dart';

//sales
import 'features/sales/data/datasources/sales_remote_datasource_impl.dart';
import 'features/sales/data/repositories/sales_repository_impl.dart';
import 'features/sales/domain/usecases/get_daily_sales.dart';
import 'features/sales/domain/usecases/get_weekly_sales.dart';
import 'features/sales/domain/usecases/get_monthly_sales.dart';
import 'features/sales/domain/usecases/get_total_sales.dart';

//stock alert
import 'features/stock_alert/data/datasources/stock_alert_remote_datasource_impl.dart';
import 'features/stock_alert/data/repositories/stock_alert_repository_impl.dart';
import 'features/stock_alert/domain/usecases/get_low_stock_alerts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase instances
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),

        // Auth providers
        Provider<AuthRemoteDatasourceImpl>(
          create: (context) => AuthRemoteDatasourceImpl(
            context.read<FirebaseAuth>(),
            context.read<FirebaseFirestore>(),
          ),
        ),
        Provider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthRemoteDatasourceImpl>(),
            context.read<FirebaseFirestore>(),
          ),
        ),
        Provider<SignInWithEmail>(
          create: (context) => SignInWithEmail(context.read<AuthRepositoryImpl>()),
        ),
        Provider<RegisterWithEmail>(
          create: (context) => RegisterWithEmail(context.read<AuthRepositoryImpl>()),
        ),
        Provider<SignOut>(
          create: (context) => SignOut(context.read<AuthRepositoryImpl>()),
        ),
        Provider<GetCurrentUser>(
          create: (context) => GetCurrentUser(context.read<AuthRepositoryImpl>()),
        ),
        ChangeNotifierProvider<auth_provider.AuthProvider>(
          create: (context) => auth_provider.AuthProvider(
            signInWithEmail: context.read<SignInWithEmail>(),
            registerWithEmail: context.read<RegisterWithEmail>(),
            signOut: context.read<SignOut>(),
            getCurrentUser: context.read<GetCurrentUser>(),
          ),
        ),

        // Category providers
        Provider<CategoryRemoteDatasourceImpl>(
          create: (context) => CategoryRemoteDatasourceImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<CategoryRepositoryImpl>(
          create: (context) => CategoryRepositoryImpl(context.read<CategoryRemoteDatasourceImpl>()),
        ),
        Provider<GetCategories>(
          create: (context) => GetCategories(context.read<CategoryRepositoryImpl>()),
        ),
        Provider<AddCategory>(
          create: (context) => AddCategory(context.read<CategoryRepositoryImpl>()),
        ),
        Provider<UpdateCategory>(
          create: (context) => UpdateCategory(context.read<CategoryRepositoryImpl>()),
        ),
        Provider<DeleteCategory>(
          create: (context) => DeleteCategory(context.read<CategoryRepositoryImpl>()),
        ),
        Provider<GetCategoryById>(
          create: (context) => GetCategoryById(context.read<CategoryRepositoryImpl>()),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(
            getCategories: context.read<GetCategories>(),
            addCategory: context.read<AddCategory>(),
            updateCategory: context.read<UpdateCategory>(),
            deleteCategory: context.read<DeleteCategory>(),
            getCategoryById: context.read<GetCategoryById>(),
          ),
        ),

        // Product providers
        Provider<ProductRemoteDatasourceImpl>(
          create: (context) => ProductRemoteDatasourceImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<ProductRepositoryImpl>(
          create: (context) => ProductRepositoryImpl(context.read<ProductRemoteDatasourceImpl>()),
        ),
        Provider<GetProducts>(
          create: (context) => GetProducts(context.read<ProductRepositoryImpl>()),
        ),
        Provider<AddProduct>(
          create: (context) => AddProduct(context.read<ProductRepositoryImpl>()),
        ),
        Provider<UpdateProduct>(
          create: (context) => UpdateProduct(context.read<ProductRepositoryImpl>()),
        ),
        Provider<DeleteProduct>(
          create: (context) => DeleteProduct(context.read<ProductRepositoryImpl>()),
        ),
        Provider<GetProductById>(
          create: (context) => GetProductById(context.read<ProductRepositoryImpl>()),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(
            getProducts: context.read<GetProducts>(),
            addProduct: context.read<AddProduct>(),
            updateProduct: context.read<UpdateProduct>(),
            deleteProduct: context.read<DeleteProduct>(),
            getProductById: context.read<GetProductById>(),
          ),
        ),

        // Supplier providers
        Provider<SupplierRemoteDatasourceImpl>(
          create: (context) => SupplierRemoteDatasourceImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<SupplierRepositoryImpl>(
          create: (context) => SupplierRepositoryImpl(context.read<SupplierRemoteDatasourceImpl>()),
        ),
        Provider<GetSuppliers>(
          create: (context) => GetSuppliers(context.read<SupplierRepositoryImpl>()),
        ),
        Provider<AddSupplier>(
          create: (context) => AddSupplier(context.read<SupplierRepositoryImpl>()),
        ),
        Provider<UpdateSupplier>(
          create: (context) => UpdateSupplier(context.read<SupplierRepositoryImpl>()),
        ),
        Provider<DeleteSupplier>(
          create: (context) => DeleteSupplier(context.read<SupplierRepositoryImpl>()),
        ),
        Provider<GetSupplierById>(
          create: (context) => GetSupplierById(context.read<SupplierRepositoryImpl>()),
        ),
        ChangeNotifierProvider<SupplierProvider>(
          create: (context) => SupplierProvider(
            getSuppliers: context.read<GetSuppliers>(),
            addSupplier: context.read<AddSupplier>(),
            updateSupplier: context.read<UpdateSupplier>(),
            deleteSupplier: context.read<DeleteSupplier>(),
            getSupplierById: context.read<GetSupplierById>(),
          ),
        ),

        // Purchase providers
        Provider<PurchaseRemoteDatasourceImpl>(
          create: (context) => PurchaseRemoteDatasourceImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<PurchaseRepositoryImpl>(
          create: (context) => PurchaseRepositoryImpl(context.read<PurchaseRemoteDatasourceImpl>()),
        ),
        Provider<ProcessPurchase>(
          create: (context) => ProcessPurchase(context.read<PurchaseRepositoryImpl>()),
        ),
        ChangeNotifierProvider<PurchaseProvider>(
          create: (context) => PurchaseProvider(
            processPurchase: context.read<ProcessPurchase>(),
            getProducts: context.read<GetProducts>(),
          ),
        ),

        // Transaction providers
Provider<TransactionRemoteDatasourceImpl>(
  create: (context) => TransactionRemoteDatasourceImpl(
    context.read<FirebaseFirestore>(),
  ),
),

Provider<TransactionRepositoryImpl>(
  create: (context) => TransactionRepositoryImpl(
    context.read<TransactionRemoteDatasourceImpl>(),
  ),
),

Provider<GetTransactions>(
  create: (context) => GetTransactions(
    context.read<TransactionRepositoryImpl>(),
  ),
),

ChangeNotifierProvider<TransactionProvider>(
  create: (context) => TransactionProvider(
    getTransactions: context.read<GetTransactions>(),
    getProducts: context.read<GetProducts>(), // already registered above
  ),
),

// Sales providers
Provider<SalesRemoteDatasourceImpl>(
  create: (context) => SalesRemoteDatasourceImpl(
    context.read<FirebaseFirestore>(),
  ),
),

Provider<SalesRepositoryImpl>(
  create: (context) => SalesRepositoryImpl(
    context.read<SalesRemoteDatasourceImpl>(),
  ),
),

Provider<GetDailySales>(
  create: (context) => GetDailySales(
    context.read<SalesRepositoryImpl>(),
  ),
),

Provider<GetWeeklySales>(
  create: (context) => GetWeeklySales(
    context.read<SalesRepositoryImpl>(),
  ),
),

Provider<GetMonthlySales>(
  create: (context) => GetMonthlySales(
    context.read<SalesRepositoryImpl>(),
  ),
),

Provider<GetTotalSales>(
  create: (context) => GetTotalSales(
    context.read<SalesRepositoryImpl>(),
  ),
),

// Stock Alert providers
Provider<StockAlertRemoteDatasourceImpl>(
  create: (context) => StockAlertRemoteDatasourceImpl(
    context.read<FirebaseFirestore>(),
  ),
),

Provider<StockAlertRepositoryImpl>(
  create: (context) => StockAlertRepositoryImpl(
    context.read<StockAlertRemoteDatasourceImpl>(),
  ),
),

Provider<GetLowStockAlerts>(
  create: (context) => GetLowStockAlerts(
    context.read<StockAlertRepositoryImpl>(),
  ),
),

      ],
      child: MaterialApp(
        title: 'ApexStock - Inventory Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/categories': (context) => CategoriesListScreen(),
          '/category-form': (context) => const CategoryFormScreen(),
          '/products': (context) => ProductsListScreen(),
          '/suppliers': (context) => SuppliersListScreen(),
          '/transactions': (context) => TransactionsScreen(),
          '/purchase': (context) => const PurchaseScreen(),
          '/pos': (context) => const PlaceholderPOSScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context);

    return StreamBuilder(
      stream: authProvider.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class PlaceholderPOSScreen extends StatelessWidget {
  const PlaceholderPOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.point_of_sale,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Point of Sale',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Coming Soon...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
