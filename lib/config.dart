class Config {
  static const String categoriesCollection = 'categories';
  static const String productsCollection = 'products';
  static const String suppliersCollection = 'suppliers';
  static const String transactionsCollection = 'transactions';
  static const String dailySalesCollection = 'daily_sales';
  static const String weeklySalesCollection = 'weekly_sales';
  static const String monthlySalesCollection = 'monthly_sales';
  static const String totalSalesCollection = 'total_sales';

  // Cloudinary Configuration
  static const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/dc8r27msb/image/upload';
  static const String cloudinaryUploadPreset = 'inventory-unsigned';
}