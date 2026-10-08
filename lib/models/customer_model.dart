class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double totalPurchases;
  final double outstandingBalance;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.totalPurchases,
    required this.outstandingBalance,
    required this.isActive,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      totalPurchases:
          double.tryParse(
            map['total_purchases']?.toString() ?? '0',
          ) ??
          0,
      outstandingBalance:
          double.tryParse(
            map['outstanding_balance']?.toString() ?? '0',
          ) ??
          0,
      isActive: map['is_active'] == true,
    );
  }
}