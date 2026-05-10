import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final int priceAtSale;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    required this.priceAtSale,
  });

  int get totalPrice => priceAtSale * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'quantity': quantity,
      'priceAtSale': priceAtSale,
      'totalPrice': totalPrice,
    };
  }
}
