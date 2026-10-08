import 'package:flutter/material.dart';
import 'package:inventory_pos/providers/billing_provider.dart';
import 'package:inventory_pos/providers/customer_provider.dart';
import 'package:inventory_pos/repositories/customer_repository.dart';
import 'package:inventory_pos/repositories/sales_repository.dart';
import 'package:inventory_pos/screens/users/user_management_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/forgot_password/forgot_password_screen.dart';
import 'screens/auth/reset_password/reset_password_screen.dart';
import 'package:inventory_pos/screens/auth/change_password/change_password_screen.dart';
import 'screens/profile/my_profile/my_profile_screen.dart';
import 'providers/user_provider.dart';
import 'repositories/user_repository.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'screens/categories/category_management_screen.dart';
import 'screens/products/product_management_screen.dart';
import 'repositories/category_repository.dart';
import 'repositories/product_repository.dart';
import 'screens/customers/customer_management_screen.dart';
import 'screens/billing/billing_screen.dart';
import 'screens/sales/sales_history_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vcjcugytqevzawpcavpo.supabase.co',
    publishableKey: 'sb_publishable_tMHtTSnXQ5ETPrJu5jorMw_ac487s2H',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            AuthRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            UserRepository(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            CategoryRepository(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            ProductRepository(),
          ),
        ),

        ChangeNotifierProvider(
            create: (_) => CustomerProvider(CustomerRepository()),
          ),

          ChangeNotifierProvider(
            create: (_) => BillingProvider(SalesRepository()),
          ),

      ],
      child: const InventoryPosApp(),
    ),
  );
}

class InventoryPosApp extends StatelessWidget {
  const InventoryPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        // '/splash': (_) => const SplashScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/change-password': (_) => const ChangePasswordScreen(),
        '/profile': (_) => const MyProfileScreen(),
        '/users': (_) => const UserManagementScreen(),
        '/categories': (_) =>
            const CategoryManagementScreen(),

        '/products': (_) =>
            const ProductManagementScreen(),
        '/customers': (_) =>
            const CustomerManagementScreen(),

        '/billing': (_) =>
            const BillingScreen(),

        '/sales': (_) =>
            const SalesHistoryScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Inventory POS',
     home: const LoginScreen(),
    );
  }
}