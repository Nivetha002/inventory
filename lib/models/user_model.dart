class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'CASHIER',
      isActive: map['is_active'] == true,
    );
  }
}