import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

   // Ambil semua produk dari Firestore
   // Stream = data yang terus diperbarui secara realtime
   // Kalau ada perubahan di Firestore → UI otomatis update
   Stream<List<ProductModel>> getProducts() {
     return _db
         .collection('products')
         .orderBy('createdAt', descending: true)
         .snapshots()
         .map((snapshot) {
           return snapshot.docs
               .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
               .toList();
         })
         .handleError((error) {
           print('Error getting products: $error');
           return <ProductModel>[];
         });
   }

   // Tambah produk baru ke Firestore
   Future<void> addProduct(ProductModel product) async {
     try {
       await _db.collection('products').add({
         ...product.toMap(),
         'createdAt': FieldValue.serverTimestamp(),
       });
     } catch (e) {
       print('Error adding product: $e');
       rethrow;
     }
   }

   // Update produk yang sudah ada
   Future<void> updateProduct(ProductModel product) async {
     try {
       await _db
           .collection('products')
           .doc(product.id)
           .update(product.toMap());
     } catch (e) {
       print('Error updating product: $e');
       rethrow;
     }
   }

   // Hapus produk
   Future<void> deleteProduct(String productId) async {
     try {
       await _db.collection('products').doc(productId).delete();
     } catch (e) {
       print('Error deleting product: $e');
       rethrow;
     }
   }

   // Update stok produk setelah transaksi
   // decrement = kurangi stok
   Future<void> decrementStock(String productId, int quantity) async {
     try {
       // Cek stok cukup sebelum decrement
       final doc = await _db.collection('products').doc(productId).get();
       if (doc.exists) {
         final currentStock = doc.data()?['stock'] ?? 0;
         if (currentStock < quantity) {
           throw Exception('Stok tidak mencukupi');
         }
       }
       await _db.collection('products').doc(productId).update({
         'stock': FieldValue.increment(-quantity),
       });
     } catch (e) {
       print('Error decrementing stock: $e');
       rethrow;
     }
   }

   // Method cek stok sebelum decrement (opsional, untuk validasi di UI)
   Future<bool> canDecrementStock(String productId, int quantity) async {
     try {
       final doc = await _db.collection('products').doc(productId).get();
       if (doc.exists) {
         final stock = doc.data()?['stock'] ?? 0;
         return (stock as int) >= quantity;
       }
       return false;
     } catch (e) {
       print('Error checking stock: $e');
       return false;
     }
   }
}