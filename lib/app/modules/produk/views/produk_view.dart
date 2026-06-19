import 'package:aplikasi_kasir/app/core/widgets/costum_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_navbar.dart';
import '../../../data/models/product_model.dart';

class ProdukView extends GetView<ProdukController> {
  const ProdukView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          // Navbar kiri — tetap aktif di menu Produk
          AppNavbar(activePage: NavPage.produk),

          // Konten utama (Topbar + area bawahnya)
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Topbar tetap memanjang di atas
        CustomHeader(title: 'Manajemen Produk'),

        // Membagi konten bawah menjadi Grid (Kiri) dan Info Ringkasan (Kanan)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // SISI KIRI: Filter dan Grid Utama Produk
                // ==========================================
                Expanded(
                  flex: 7, // Mengambil porsi 70% lebar layar
                  child: SingleChildScrollView(child: _buildProdukSection()),
                ),

                const SizedBox(width: 24),

                // ==========================================
                // SISI KANAN: Panel Informasi Ringkasan (Stat Cards)
                // ==========================================
                Expanded(
                  flex: 3, // Mengambil porsi 30% lebar layar
                  child: SingleChildScrollView(child: _buildRightInfoPanel()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════
  // PANEL INFORMASI KANAN (Ubah Row jadi Column)
  // ═══════════════════════════════════
  // ═══════════════════════════════════
  // PANEL INFORMASI KANAN (Hanya 1 Card Besar Utuh)
  // ═══════════════════════════════════
  Widget _buildRightInfoPanel() {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Utama di dalam Card
            Text(
              'Ringkasan Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Baris 1: Total Produk
            _rowInfoItem(
              label: 'Total Produk',
              value: controller.totalProduk.toString(),
            ),
            const Divider(height: 32, color: AppTheme.border),

            // Baris 2: Total Stok
            _rowInfoItem(
              label: 'Total Stok',
              value: controller.totalStok.toString(),
            ),
            const Divider(height: 32, color: AppTheme.border),

            // Baris 3: Stok Menipis
            _rowInfoItem(
              label: 'Stok Menipis',
              value: controller.produkMenipis.toString(),

              valueColor: controller.produkMenipis > 0
                  ? AppTheme.error
                  : AppTheme.textPrimary,
            ),
            const Divider(height: 32, color: AppTheme.border),

            // Baris 4: Stok Habis
            _rowInfoItem(
              label: 'Stok Habis',
              value: controller.produkHabis.toString(),

              valueColor: controller.produkHabis > 0
                  ? AppTheme.error
                  : AppTheme.textPrimary,
            ),
          ],
        ),
      );
    });
  }

  // Widget baris informasi di dalam card utama
  Widget _rowInfoItem({
    required String label,
    required String value,

    Color? valueColor,
  }) {
    return Row(
      children: [
        // Icon di kiri baris

        // Label Nama Statistik
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
        ),
        const Spacer(),

        // Angka Nilai di Kanan
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // Widget satu stat card (Hapus Expanded internal agar tidak error di dalam Column)
  Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required String icon,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity, // Memaksa kartu memenuhi lebar panel kanan
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                ),
              ],
            ),
          ),
          Text(icon, style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // SECTION PRODUK (filter + grid)
  // ═══════════════════════════════════
  Widget _buildProdukSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [_buildSectionHeader(), _buildProdukGrid()]),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              onChanged: controller.onSearch,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.bgSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppTheme.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.border),
                  ),
                ),
                items: controller.categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.changeCategory(value);
                  }
                },
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: controller.goToTambahProduk,
            label: const Text('Tambah Produk'),
            icon: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdukGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(60),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 16),
                Text(
                  'Memuat produk...',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        );
      }

      final list = controller.filteredProducts;

      if (list.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(60),
          child: Center(
            child: Column(
              children: [
                const Text('📦', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  controller.searchQuery.value.isNotEmpty
                      ? 'Tidak ada produk yang cocok\ndengan kata kunci "${controller.searchQuery.value}"'
                      : 'Belum ada produk\ndi kategori ini',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                4, // Diubah ke 3 atau 4 kolom karena lebar area kiri berkurang
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildProductCard(list[index]);
          },
        ),
      );
    });
  }

  // ═══════════════════════════════════
  // KARTU PRODUK (Metode ini tetap utuh seperti kode lamamu)
  // ═══════════════════════════════════
  Widget _buildProductCard(ProductModel product) {
    final isHabis = product.stock <= 0;
    final isMenipis = product.stock > 0 && product.stock <= 5;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHabis ? AppTheme.error.withOpacity(0.3) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImg(),
                        )
                      : _placeholderImg(),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isHabis
                          ? Colors.grey
                          : isMenipis
                          ? AppTheme.error
                          : AppTheme.success,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      isHabis
                          ? 'Habis'
                          : isMenipis
                          ? '⚠️ ${product.stock}'
                          : 'Stok: ${product.stock}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: const TextStyle(fontSize: 13, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(product.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.goToEditProduk(product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primary),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => controller.goToHapusProduk(product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.error.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 14,
                      color: AppTheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(
      width: double.infinity,
      color: AppTheme.bgSecondary,
      child: const Center(child: Text('🏷️', style: TextStyle(fontSize: 32))),
    );
  }
}
