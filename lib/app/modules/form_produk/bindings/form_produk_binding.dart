import 'package:get/get.dart';
import '../controllers/form_produk_controller.dart';

class FormProdukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormProdukController>(
      () => FormProdukController(),
      // fenix: true = kalau controller sudah di-dispose
      // tapi dibutuhkan lagi, buat ulang otomatis
      // Berguna karena FormProduk bisa dibuka berkali-kali
      // (tambah produk A, kembali, tambah produk B)
      fenix: true,
    );
  }
}