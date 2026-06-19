import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_item.model.dart';
// import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../core/utils/currency_formatter.dart';

class KasirController extends GetxController {
  final _productRepo = ProductRepository();
  final _db = FirebaseFirestore.instance;
  final _storage = GetStorage();

  // GANTI dengan getter biasa:
  int get totalHarga => cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Daftar produk dari Firestore — reaktif
  var products = <ProductModel>[].obs;

  // Kategori yang sedang dipilih untuk filter
  // 'Semua' = tampilkan semua produk
  var selectedCategory = 'Semua'.obs;

  // Metode pembayaran yang dipilih
  var selectedPayment = ''.obs;

  // List item di keranjang — reaktif
  var cartItems = <CartItemModel>[].obs;

  // Status loading
  var isLoading = true.obs;

  // pilih menu
  final selectedIndex = 0.obs;

  // Status sedang proses bayar
  var isProcessing = false.obs;

  // Daftar kategori untuk tombol filter
  final List<String> categories = [
    'Semua',
    'Gantungan Kunci',
    'Hiasan Rajut',
    'Aksesoris Tas',
  ];

  // Daftar metode pembayaran
  final List<String> paymentMethods = ['Cash', 'Qris'];

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Load produk dari Firestore secara realtime
  void loadProducts() {
    isLoading.value = true;

    // listen() = dengarkan perubahan data secara realtime
    // Setiap ada produk ditambah/diubah/dihapus di Firestore
    // list produk di sini otomatis terupdate
    _productRepo.getProducts().listen((list) {
      products.assignAll(list);
      isLoading.value = false;
    });
  }

  // Getter: produk yang sudah difilter berdasarkan kategori
  List<ProductModel> get filteredProducts {
    if (selectedCategory.value == 'Semua') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  // Ganti filter kategori
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // Pilih metode pembayaran
  void selectPayment(String method) {
    selectedPayment.value = method;
  }

  // Tambah produk ke keranjang
  void addToCart(ProductModel product) {
    // Cek stok dulu sebelum tambah
    if (product.stock <= 0) {
      Get.snackbar(
        'Stok Habis',
        '${product.name} sudah tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDECEA),
        colorText: const Color(0xFFC0392B),
      );
      return;
    }

    // Cek apakah produk sudah ada di keranjang
    final existing = cartItems.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );

    if (existing != null) {
      // Cek apakah quantity di keranjang sudah melebihi stok
      if (existing.quantity >= product.stock) {
        Get.snackbar(
          'Stok Tidak Cukup',
          'Stok ${product.name} hanya ${product.stock} unit',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      existing.quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(
        CartItemModel(
          product: product,
          quantity: 1,
          priceAtSale: product.price,
        ),
      );
    }
  }

  // Tambah quantity item di keranjang
  void increaseQty(CartItemModel item) {
    if (item.quantity >= item.product.stock) {
      Get.snackbar(
        'Stok Tidak Cukup',
        'Stok ${item.product.name} hanya ${item.product.stock} unit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    item.quantity++;
    cartItems.refresh();
  }

  // Kurangi quantity — kalau jadi 0, hapus dari keranjang
  void decreaseQty(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      cartItems.remove(item);
    }
  }

  // Reset semua keranjang
  void resetCart() {
    cartItems.clear();
    selectedPayment.value = '';
  }

  // TAMBAHKAN fungsi ini setelah resetCart():

  // Proses pembayaran
  Future<void> bayar() async {
    // Validasi keranjang tidak kosong
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Keranjang Kosong',
        'Tambahkan produk ke keranjang dulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validasi metode pembayaran sudah dipilih
    if (selectedPayment.value.isEmpty) {
      Get.snackbar(
        'Pilih Metode Bayar',
        'Pilih metode pembayaran terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF3E0),
        colorText: const Color(0xFFE65100),
      );
      return;
    }

    isProcessing.value = true;

    try {
      final batch = _db.batch();
      final transRef = _db.collection('transactions').doc();
      final kasirId = _storage.read('userId') ?? '';
      final kasirName = _storage.read('userName') ?? 'Admin';

      batch.set(transRef, {
        'kasirId': kasirId,
        'kasirName': kasirName,
        'items': cartItems.map((item) => item.toMap()).toList(),
        'totalAmount': totalHarga,
        'paymentMethod': selectedPayment.value,
        'status': 'selesai',
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final item in cartItems) {
        final prodRef = _db.collection('products').doc(item.product.id);
        batch.update(prodRef, {'stock': FieldValue.increment(-item.quantity)});
      }

      await batch.commit();

      // Simpan nilai SEBELUM resetCart()
      // karena resetCart() akan mengosongkan cartItems
      // sehingga totalHarga dan selectedPayment jadi 0 / kosong
      final totalFinal = totalHarga;
      final metodeFinal = selectedPayment.value;

      // Reset keranjang SETELAH disimpan ke variabel lokal
      resetCart();

      // Tampilkan dialog dengan nilai yang sudah disimpan
      Get.defaultDialog(
        title: 'Transaksi Berhasil! 🎉',
        middleText:
            'Total: ${CurrencyFormatter.format(totalFinal)}\n'
            'Metode: $metodeFinal\n\n'
            'Stok produk sudah diperbarui.',
        textConfirm: 'Transaksi Baru',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF7D2A2A),
        onConfirm: () => Get.back(),
      );
    } catch (e) {
      Get.snackbar(
        'Transaksi Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDECEA),
        colorText: const Color(0xFFC0392B),
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
