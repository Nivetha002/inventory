import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              profile?['full_name'] ?? 'User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              profile?['role'] ?? 'Unknown',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            _ProfileItem(
              icon: Icons.person_outline,
              title: 'Full Name',
              value: profile?['full_name'] ?? '-',
            ),

            _ProfileItem(
              icon: Icons.badge_outlined,
              title: 'Username',
              value: profile?['username'] ?? '-',
            ),

            _ProfileItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: profile?['email'] ?? '-',
            ),

            _ProfileItem(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Role',
              value: profile?['role'] ?? '-',
            ),

            _ProfileItem(
              icon: Icons.check_circle_outline,
              title: 'Status',
              value: profile?['is_active'] == true
                  ? 'Active'
                  : 'Inactive',
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/change-password',
                  );
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}