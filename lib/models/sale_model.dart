class SaleModel {
  final String id;
  final String invoiceNumber;
  final String? customerId;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;
  final double paidAmount;
  final double dueAmount;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.paidAmount,
    required this.dueAmount,
    required this.createdAt,
  });

  factory SaleModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return SaleModel(
      id: map['id']?.toString() ?? '',
      invoiceNumber:
          map['invoice_number']?.toString() ?? '',
      customerId:
          map['customer_id']?.toString(),
      subtotal:
          double.tryParse(
                map['subtotal']?.toString() ?? '0',
              ) ??
              0,
      discount:
          double.tryParse(
                map['discount']?.toString() ?? '0',
              ) ??
              0,
      tax:
          double.tryParse(
                map['tax']?.toString() ?? '0',
              ) ??
              0,
      total:
          double.tryParse(
                map['total']?.toString() ?? '0',
              ) ??
              0,
      paymentMethod:
          map['payment_method']?.toString() ?? 'CASH',
      paidAmount:
          double.tryParse(
                map['paid_amount']?.toString() ?? '0',
              ) ??
              0,
      dueAmount:
          double.tryParse(
                map['due_amount']?.toString() ?? '0',
              ) ??
              0,
      createdAt:
          DateTime.tryParse(
            map['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}