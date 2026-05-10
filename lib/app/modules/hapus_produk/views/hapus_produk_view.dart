import 'package:aplikasi_kasir/app/core/widgets/costum_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hapus_produk_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_navbar.dart';

class HapusProdukView extends GetView<HapusProdukController> {
  const HapusProdukView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          AppNavbar(activePage: NavPage.produk),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Topbar dengan breadcrumb
        CustomHeader(title: 'Hapus Produk'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kiri — info + peringatan + konfirmasi
                Expanded(child: _buildKiri()),
                const SizedBox(width: 20),
                // Kanan — alternatif sebelum hapus
                SizedBox(width: 300, child: _buildKanan()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  

  Widget _buildKiri() {
    return Column(
      children: [
        // Info produk yang akan dihapus
        _buildInfoProduk(),
        const SizedBox(height: 16),
        // Peringatan
        _buildPeringatan(),
        const SizedBox(height: 16),
        // Form konfirmasi
        _buildKonfirmasi(),
      ],
    );
  }

  Widget _buildInfoProduk() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📦 Produk yang Akan Dihapus',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Foto produk
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: controller.product.imageUrl.isNotEmpty
                      ? Image.network(
                          controller.product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text('🏷️', style: TextStyle(fontSize: 36)),
                          ),
                        )
                      : const Center(
                          child: Text('🏷️', style: TextStyle(fontSize: 36)),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              // Detail produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        controller.product.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _detailRow(
                      'Harga Jual',
                      CurrencyFormatter.format(controller.product.price),
                    ),
                    _detailRow(
                      'Stok Tersisa',
                      '${controller.product.stock} unit',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            ':  $value',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPeringatan() {
    final peringatan = [
      _peringatanItem(
        '🗑️',
        'Data produk ini akan dihapus permanen dan tidak bisa dikembalikan.',
      ),
      _peringatanItem(
        '📋',
        'Riwayat transaksi yang mengandung produk ini tetap tersimpan.',
      ),
      _peringatanItem(
        '📦',
        'Stok ${controller.product.stock} unit yang tersisa akan hilang dan tidak tersedia untuk penjualan berikutnya.',
      ),
      _peringatanItem(
        '🛒',
        'Produk tidak akan muncul lagi di halaman kasir setelah dihapus.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ Perhatikan Sebelum Menghapus',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 12),

          ...peringatan,
        ],
      ),
    );
  }

  Widget _peringatanItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKonfirmasi() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔐 Konfirmasi Penghapusan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Untuk memastikan tidak terjadi penghapusan tidak sengaja, '
            'ketik nama produk secara lengkap di bawah ini.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Label instruksi
          Text(
            'Ketik nama produk: "${controller.product.name}"',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 8),

          // Input konfirmasi
          Obx(
            () => TextField(
              onChanged: controller.updateKonfirmasi,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ketik: ${controller.product.name}',
                hintStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                // Border hijau kalau teks sudah cocok
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: controller.isKonfirmasiValid
                        ? AppTheme.success
                        : AppTheme.error.withOpacity(0.4),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: controller.isKonfirmasiValid
                        ? AppTheme.success
                        : AppTheme.error.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: controller.isKonfirmasiValid
                        ? AppTheme.success
                        : AppTheme.error,
                    width: 1.5,
                  ),
                ),
                // Suffix icon centang kalau sudah cocok
                suffixIcon: controller.isKonfirmasiValid
                    ? const Icon(Icons.check_circle, color: AppTheme.success)
                    : null,
                filled: true,
                fillColor: controller.isKonfirmasiValid
                    ? const Color(0xFFF0FFF8)
                    : const Color(0xFFFFF8F8),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Status teks konfirmasi
          Obx(
            () => Text(
              controller.konfirmasiText.value.isEmpty
                  ? 'Ketik nama produk untuk mengaktifkan tombol hapus'
                  : controller.isKonfirmasiValid
                  ? '✓ Nama produk cocok — tombol hapus aktif'
                  : '✕ Nama belum cocok',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: controller.konfirmasiText.value.isEmpty
                    ? AppTheme.textSecondary
                    : controller.isKonfirmasiValid
                    ? AppTheme.success
                    : AppTheme.error,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tombol aksi
          Row(
            children: [
              // Batal
              OutlinedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Batal, Kembali'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Hapus — hanya aktif kalau nama sudah cocok
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isKonfirmasiValid &&
                          !controller.isLoading.value
                      ? controller.hapusProduk
                      : null,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Hapus Produk Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.error.withOpacity(0.3),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanan() {
    return Column(
      children: [
        // Pertimbangkan alternatif
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡 Pertimbangkan Alternatif Ini',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              _altItem(
                icon: '📦',
                title: 'Kosongkan Stok Saja',
                desc:
                    'Set stok menjadi 0. Produk tidak muncul '
                    'di kasir tapi data tetap tersimpan.',
                onTap: () => Get.back(),
              ),
              const Divider(height: 16),
              _altItem(
                icon: '🏷️',
                title: 'Tandai sebagai Nonaktif',
                desc:
                    'Tambahkan "[NONAKTIF]" di nama produk. '
                    'Data tetap ada tapi tidak aktif.',
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _altItem({
    required String icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 16,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
