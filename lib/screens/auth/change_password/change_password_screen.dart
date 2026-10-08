import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword =
        _currentPasswordController.text;
    final newPassword =
        _newPasswordController.text;
    final confirmPassword =
        _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage(
        'New password must be at least 6 characters',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    if (currentPassword == newPassword) {
      _showMessage(
        'New password must be different from current password',
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;

      if (user?.email == null) {
        _showMessage('User session not found');
        return;
      }

      // Verify current password
      await Supabase.instance.client.auth
          .signInWithPassword(
        email: user!.email!,
        password: currentPassword,
      );

      // Update password
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      if (!mounted) return;

      _showMessage('Password changed successfully');

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on AuthException catch (e) {
      if (!mounted) return;

      _showMessage(e.message);
    } catch (e) {
      if (!mounted) return;

      _showMessage('Something went wrong');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onVisibilityPressed,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: onVisibilityPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 70,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Change your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Enter your current password and create a new one.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller:
                        _currentPasswordController,
                    obscureText: _obscureCurrent,
                    decoration: _decoration(
                      label: 'Current Password',
                      icon: Icons.lock_outline,
                      obscure: _obscureCurrent,
                      onVisibilityPressed: () {
                        setState(() {
                          _obscureCurrent =
                              !_obscureCurrent;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: _decoration(
                      label: 'New Password',
                      icon: Icons.lock_reset,
                      obscure: _obscureNew,
                      onVisibilityPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller:
                        _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: _decoration(
                      label: 'Confirm New Password',
                      icon: Icons.lock_reset,
                      obscure: _obscureConfirm,
                      onVisibilityPressed: () {
                        setState(() {
                          _obscureConfirm =
                              !_obscureConfirm;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _changePassword,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Change Password',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}