import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/theme/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          // NAVBAR KIRI
          _buildNavbar(),
          // KONTEN UTAMA
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // Widget navbar kiri
  Widget _buildNavbar() {
    return Container(
      width: 90,
      color: AppTheme.primary,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Logo toko
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🧶', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 16),

          // Menu navigasi
          _buildNavItem(
            icon: '🛒',
            label: 'Kasir',
            index: 0,
            route: Routes.KASIR,
          ),
          _buildNavItem(
            icon: '📦',
            label: 'Produk',
            index: 1,
            route: Routes.PRODUK,
          ),
          _buildNavItem(
            icon: '📋',
            label: 'Transaksi',
            index: 2,
            route: Routes.TRANSAKSI,
          ),
          _buildNavItem(
            icon: '📊',
            label: 'Laporan',
            index: 3,
            route: Routes.LAPORAN,
          ),

          const Divider(color: Colors.white24, indent: 16, endIndent: 16),

          _buildNavItem(icon: '⚙️', label: 'Setting', index: 4, route: null),

          const Spacer(),

          // Tombol logout
          GestureDetector(
            onTap: controller.logout,
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: const [
                  Text('🚪', style: TextStyle(fontSize: 22)),
                  SizedBox(height: 4),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFFFAAAA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget tiap item menu di navbar
  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
    required String? route,
  }) {
    return Obx(() {
      final isActive = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () {
          controller.changePage(index);
          if (route != null) Get.toNamed(route);
        },
        child: Container(
          width: 70,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Konten utama — dashboard ringkasan
  Widget _buildContent() {
    return Column(
      children: [
        // Topbar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${controller.currentUser.name}! 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Role: ${controller.currentUser.role.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                DateTime.now().toString().substring(0, 10),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Konten dashboard
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu Utama',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Grid menu cepat
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      '🛒',
                      'Kasir',
                      'Proses transaksi penjualan',
                      Routes.KASIR,
                      0,
                    ),
                    _buildMenuCard(
                      '📦',
                      'Produk',
                      'Kelola data produk aksesoris',
                      Routes.PRODUK,
                      1,
                    ),
                    _buildMenuCard(
                      '📋',
                      'Transaksi',
                      'Riwayat semua transaksi',
                      Routes.TRANSAKSI,
                      2,
                    ),
                    _buildMenuCard(
                      '📊',
                      'Laporan',
                      'Statistik & export laporan',
                      Routes.LAPORAN,
                      3,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget kartu menu di dashboard
  Widget _buildMenuCard(
    String icon,
    String title,
    String desc,
    String route,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        controller.changePage(index);
        Get.toNamed(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
