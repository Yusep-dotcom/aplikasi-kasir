import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthMiddleware extends GetMiddleware {
  // priority = urutan middleware dijalankan
  // makin kecil angkanya, makin duluan dijalankan
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final role = storage.read('userRole') ?? '';

    // Kalau belum login → redirect ke login
    if (role.isEmpty) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Kalau role kasir tapi coba akses halaman admin
    // redirect paksa ke halaman kasir
    final halamanAdminOnly = [
      Routes.PRODUK,
      Routes.FORM_PRODUK,
      Routes.HAPUS_PRODUK,
      Routes.LAPORAN,
    ];

    if (role == 'kasir' && halamanAdminOnly.contains(route)) {
      // Kasir tidak boleh akses halaman ini
      // langsung redirect ke halaman kasir
      return const RouteSettings(name: Routes.KASIR);
    }

    // Akses diizinkan — return null = lanjut ke halaman tujuan
    return null;
  }
}
