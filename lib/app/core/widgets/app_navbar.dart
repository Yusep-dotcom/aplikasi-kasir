import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

enum NavPage { kasir, produk, transaksi, laporan }

class AppNavbar extends StatelessWidget {
  final NavPage activePage;

  const AppNavbar({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    final role = GetStorage().read('userRole') ?? 'kasir';
    final isAdmin = role == 'admin';

    return Container(
      width: 80,
      color: AppTheme.primary,
      child: Column(
        children: [
          SizedBox(height: 20),

          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: ClipOval(
              child: Center(child: Image.asset('assets/logo.png')),
            ),
          ),
          const SizedBox(height: 16),

          // Kasir — semua role bisa akses
          _NavItem(
            icon: '🛒',
            label: 'Kasir',
            isActive: activePage == NavPage.kasir,
            onTap: () => _navigate(Routes.KASIR, NavPage.kasir),
          ),

          // Produk — admin only
          if (isAdmin)
            _NavItem(
              icon: '📦',
              label: 'Produk',
              isActive: activePage == NavPage.produk,
              onTap: () => _navigate(Routes.PRODUK, NavPage.produk),
            ),

          // Transaksi — admin only
          _NavItem(
            icon: '📋',
            label: 'Transaksi',
            isActive: activePage == NavPage.transaksi,
            onTap: () => _navigate(Routes.TRANSAKSI, NavPage.transaksi),
          ),

          // Laporan — admin only
          if (isAdmin)
            _NavItem(
              icon: '📊',
              label: 'Laporan',
              isActive: activePage == NavPage.laporan,
              onTap: () => _navigate(Routes.LAPORAN, NavPage.laporan),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Divider(color: Colors.white24, height: 1),
          ),

          // Logout
          _NavItem(
            icon: '🚪',
            label: 'Keluar',
            isActive: false,
            activeColor: const Color(0xFFFFAAAA),
            onTap: () => Get.defaultDialog(
              title: 'Keluar',
              middleText: 'Yakin mau keluar dari sistem?',
              textConfirm: 'Ya, Keluar',
              textCancel: 'Batal',
              confirmTextColor: Colors.white,
              buttonColor: AppTheme.primary,
              onConfirm: () => Get.offAllNamed(Routes.LOGIN),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  

  void _navigate(String route, NavPage page) {
    // Kalau sudah di halaman yang sama, tidak perlu navigasi
    if (activePage == page) return;

    // offAllNamed = hapus semua history lalu pergi ke halaman baru
    // Ini yang membuat navbar selalu bisa pindah ke mana saja
    // tanpa terjebak di history halaman sebelumnya
    Get.offAllNamed(route);
  }
}

// ═══════════════════════════════════
// Widget item navbar
// ═══════════════════════════════════
class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // AnimatedContainer = Container yang animasi saat
        // propertinya berubah — warna aktif jadi smooth
        duration: const Duration(milliseconds: 200),
        width: 64,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),

          // Border kiri putih tebal = penanda aktif
          // seperti di desain aplikasi kasir modern
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 20,
                // Opacity icon dikurangi kalau tidak aktif
                color: isActive ? Colors.white : Colors.white.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? activeColor : Colors.white.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
