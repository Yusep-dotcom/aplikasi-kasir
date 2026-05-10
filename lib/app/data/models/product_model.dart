import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String imageUrl;
  final String description;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle price - bisa integer atau string
    int getPrice() {
      if (map['price'] is int) return map['price'];
      if (map['price'] is String) return int.tryParse(map['price']) ?? 0;
      if (map['price'] != null) return int.tryParse(map['price'].toString()) ?? 0;
      return 0;
    }

    // Handle stock - bisa integer atau string
    int getStock() {
      if (map['stock'] is int) return map['stock'];
      if (map['stock'] is String) return int.tryParse(map['stock']) ?? 0;
      if (map['stock'] != null) return int.tryParse(map['stock'].toString()) ?? 0;
      return 0;
    }

    // Handle createdAt - bisa Timestamp atau String atau DateTime
    DateTime getCreatedAt() {
      if (map['createdAt'] is Timestamp) {
        return (map['createdAt'] as Timestamp).toDate();
      }
      if (map['createdAt'] is String) {
        return DateTime.parse(map['createdAt']);
      }
      if (map['createdAt'] is DateTime) {
        return map['createdAt'];
      }
      return DateTime.now();
    }

    return ProductModel(
      id: id,
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      price: getPrice(),
      stock: getStock(),
      imageUrl: map['imageUrl']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      createdAt: getCreatedAt(),
    );
  }

  // Convert object ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
