import 'dart:ui';

import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class DashboardController extends GetxController {
  // Ambil data user yang sudah login dari GetX
  // Get.find<UserModel>() = ambil UserModel yang disimpan
  // di LoginController saat login berhasil
  final UserModel currentUser = Get.find<UserModel>();

  // Index halaman aktif di navbar
  // 0 = Kasir, 1 = Produk, 2 = Transaksi, 3 = Laporan
  var selectedIndex = 0.obs;

  final _authRepo = AuthRepository();

  // Ganti halaman saat klik menu navbar
  void changePage(int index) {
    selectedIndex.value = index;
  }

  // Navigasi ke halaman berdasarkan index
  void navigateTo(int index) {
    changePage(index);
    switch (index) {
      case 0:
        Get.toNamed(Routes.KASIR);
        break;
      case 1:
        Get.toNamed(Routes.PRODUK);
        break;
      case 2:
        Get.toNamed(Routes.TRANSAKSI);
        break;
      case 3:
        Get.toNamed(Routes.LAPORAN);
        break;
    }
  }

  // Fungsi logout
  Future<void> logout() async {
    // Tampilkan dialog konfirmasi dulu
    Get.defaultDialog(
      title: 'Keluar',
      middleText: 'Yakin mau keluar dari sistem?',
      textConfirm: 'Ya, Keluar',
      textCancel: 'Batal',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () async {
        await _authRepo.logout();
        // Kembali ke login dan hapus semua history
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}
