import 'cart_item.model.dart';

class TransactionModel {
  final String id;
  final String kasirId;
  final List<CartItemModel> items;
  final int totalAmount;
  final String paymentMethod;
  final String status;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.kasirId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Map<String, dynamic> toMap() {
    return {
      'kasirId': kasirId,
      // .map().toList() = ubah tiap CartItemModel jadi Map
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
