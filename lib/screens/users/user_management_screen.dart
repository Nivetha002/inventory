import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      context.read<UserProvider>().loadUsers();
    });

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // FILTER USERS
  // --------------------------------------------------

  List<UserModel> _filteredUsers(
    List<UserModel> users,
  ) {
    if (_searchText.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.fullName.toLowerCase().contains(_searchText) ||
          user.username.toLowerCase().contains(_searchText) ||
          user.email.toLowerCase().contains(_searchText) ||
          user.role.toLowerCase().contains(_searchText);
    }).toList();
  }

  // --------------------------------------------------
  // ADD USER
  // --------------------------------------------------

  void _showAddUserDialog() {
    final fullNameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    String selectedRole = 'CASHIER';

    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Add User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon:
                            Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon:
                            Icon(Icons.account_circle_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon:
                            Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon:
                            Icon(Icons.badge_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text('Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'MANAGER',
                          child: Text('Manager'),
                        ),
                        DropdownMenuItem(
                          value: 'CASHIER',
                          child: Text('Cashier'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final fullName =
                        fullNameController.text.trim();

                    final username =
                        usernameController.text.trim();

                    final email =
                        emailController.text.trim();

                    final password =
                        passwordController.text;

                    // Validation
                    if (fullName.isEmpty ||
                        username.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (password.length < 6) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Password must contain at least 6 characters.',
                          ),
                        ),
                      );

                      return;
                    }

                    final provider =
                        context.read<UserProvider>();

                    final success =
                        await provider.createUser(
                      fullName: fullName,
                      username: username,
                      email: email,
                      password: password,
                      role: selectedRole,
                    );

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    if (success) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User created successfully.',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ??
                                'Unable to create user.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Create User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------
  // EDIT USER
  // --------------------------------------------------

  void _showEditUserDialog(
    UserModel user,
  ) {
    final fullNameController =
        TextEditingController(text: user.fullName);

    final usernameController =
        TextEditingController(text: user.username);

    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Edit User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon:
                            Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon:
                            Icon(Icons.account_circle_outlined),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon:
                            Icon(Icons.badge_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text('Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'MANAGER',
                          child: Text('Manager'),
                        ),
                        DropdownMenuItem(
                          value: 'CASHIER',
                          child: Text('Cashier'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final fullName =
                        fullNameController.text.trim();

                    final username =
                        usernameController.text.trim();

                    if (fullName.isEmpty ||
                        username.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields.',
                          ),
                        ),
                      );

                      return;
                    }

                    final provider =
                        context.read<UserProvider>();

                    final success =
                        await provider.updateUser(
                      userId: user.id,
                      fullName: fullName,
                      username: username,
                      role: selectedRole,
                    );

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    if (success) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User updated successfully.',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ??
                                'Unable to update user.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------
  // ACTIVATE / DEACTIVATE
  // --------------------------------------------------

  void _confirmStatusChange(
    UserModel user,
  ) {
    final action =
        user.isActive ? 'Deactivate' : 'Activate';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$action User?'),
          content: Text(
            'Are you sure you want to ${action.toLowerCase()} ${user.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final provider =
                    context.read<UserProvider>();

                final success =
                    await provider.toggleUserStatus(user);

                if (!mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User ${action.toLowerCase()}d successfully.'
                          : provider.errorMessage ??
                              'Unable to update user.',
                    ),
                  ),
                );
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // USER CARD
  // --------------------------------------------------

  Widget _buildUserCard(
    UserModel user,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Text(
            user.fullName.isNotEmpty
                ? user.fullName[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '@${user.username} • ${user.role}',
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditUserDialog(user);
            }

            if (value == 'status') {
              _confirmStatusChange(user);
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(
                    user.isActive
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                  ),
                  title: Text(
                    user.isActive
                        ? 'Deactivate'
                        : 'Activate',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add User'),
      ),

      body: Consumer<UserProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final users =
              _filteredUsers(provider.users);

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: provider.loadUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadUsers,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search users...',
                    prefixIcon:
                        const Icon(Icons.search),
                    suffixIcon:
                        _searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  _searchController
                                      .clear();
                                },
                              )
                            : null,
                  ),
                ),

                const SizedBox(height: 20),

                if (users.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 80),
                    child: Column(
                      children: const [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...users.map(
                    _buildUserCard,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}