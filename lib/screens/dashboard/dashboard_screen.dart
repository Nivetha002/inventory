import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;

    final isAdmin = authProvider.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // My Profile
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
              );
            },
          ),

          // Change Password
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Change Password',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/change-password',
              );
            },
          ),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(
                context,
                '/login',
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${profile?['full_name'] ?? 'User'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Role: ${authProvider.role ?? 'Unknown'}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Inventory POS Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // Admin only
            if (isAdmin)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.people_outline),
                  ),
                  title: const Text(
                    'User Management',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Manage users and roles',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/users',
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.category_outlined,
                    ),
                  ),
                  title: const Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Manage product categories',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/categories',
                    );
                  },
                ),
              ),


              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.inventory_2_outlined,
                    ),
                  ),
                  title: const Text(
                    'Products',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Manage products and stock',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/products',
                    );
                  },
                ),
              ),
              Card(
  child: ListTile(
    leading: const Icon(Icons.point_of_sale),
    title: const Text('Billing'),
    subtitle: const Text(
      'Create new sales',
    ),
    onTap: () {
      Navigator.pushNamed(
        context,
        '/billing',
      );
    },
  ),
),
Card(
  child: ListTile(
    leading: const Icon(Icons.people),
    title: const Text('Customers'),
    subtitle: const Text(
      'Manage customers',
    ),
    onTap: () {
      Navigator.pushNamed(
        context,
        '/customers',
      );
    },
  ),
),
Card(
  child: ListTile(
    leading: const Icon(Icons.receipt_long),
    title: const Text('Sales History'),
    subtitle: const Text(
      'View previous sales',
    ),
    onTap: () {
      Navigator.pushNamed(
        context,
        '/sales',
      );
    },
  ),
),
          ],
        ),
      ),
    );
  }
}