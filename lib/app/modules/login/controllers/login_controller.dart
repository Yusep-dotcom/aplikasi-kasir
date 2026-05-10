import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  // TextEditingController = pengontrol input teks
  // Dia yang simpan dan baca teks yang diketik user
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // isLoading = tampilkan spinner saat proses login
  var isLoading = false.obs;

  // isPasswordVisible = toggle tampilkan/sembunyikan password
  var isPasswordVisible = false.obs;

  // Repository = yang bertugas bicara dengan Firebase
  final _authRepo = AuthRepository();

  final _storage = GetStorage();

  // Toggle tampilkan/sembunyikan password
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Fungsi login utama
  Future<void> login() async {
    // Validasi dulu sebelum kirim ke Firebase
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Oops!',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Oops!',
        'Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true; // tampilkan loading

    try {
      final UserModel user = await _authRepo.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // Login berhasil → simpan data user ke GetX
      // supaya bisa diakses dari halaman manapun
      Get.put(user); // simpan UserModel secara global

      // Simpan data user ke storage lokal
      _storage.write('userId', user.id);
      _storage.write('userName', user.name);
      _storage.write('userRole', user.role);
      // write() = simpan data dengan key tertentu
      // bisa dibaca nanti dengan read('key')

      // Arahkan ke halaman berdasarkan role

      Get.offAllNamed(Routes.KASIR);

      // Simpan data user ke storage lokal
      _storage.write('userId', user.id);
      _storage.write('userName', user.name);
      _storage.write('userRole', user.role);
      // write() = simpan data dengan key tertentu
      // bisa dibaca nanti dengan read('key')
    } catch (e) {
      // Tampilkan pesan error dari repository
      Get.snackbar(
        'Login Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDECEA),
        colorText: const Color(0xFFC0392B),
      );
    } finally {
      // finally = selalu dijalankan, baik berhasil maupun gagal
      isLoading.value = false; // sembunyikan loading
    }
  }

  @override
  void onClose() {
    // Wajib dispose TextEditingController
    // supaya tidak ada memory leak
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
