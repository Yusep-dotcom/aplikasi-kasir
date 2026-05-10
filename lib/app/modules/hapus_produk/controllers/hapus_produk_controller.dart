import 'dart:ui';

import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class HapusProdukController extends GetxController {
  final _repo = ProductRepository();

  late ProductModel product;
  var isLoading = false.obs;
  var konfirmasiText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Terima data produk yang dikirim dari ProdukView
    product = Get.arguments as ProductModel;
  }

  // Cek apakah teks konfirmasi sudah sesuai
  // Tombol hapus hanya aktif kalau nama produk diketik dengan benar
  bool get isKonfirmasiValid =>
      konfirmasiText.value.toLowerCase() == product.name.toLowerCase();

  void updateKonfirmasi(String val) {
    konfirmasiText.value = val;
  }

  Future<void> hapusProduk() async {
    if (!isKonfirmasiValid) return;

    isLoading.value = true;
    try {
      await _repo.deleteProduct(product.id);
      // Kembali ke halaman produk setelah hapus berhasil
      Get.snackbar(
        '✅ Berhasil',
        '${product.name} berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE1F5EE),
        colorText: const Color(0xFF085041),
      );
      Get.toNamed(Routes.PRODUK);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDECEA),
        colorText: const Color(0xFFC0392B),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
