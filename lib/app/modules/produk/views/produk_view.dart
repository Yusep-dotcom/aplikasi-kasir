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
          // Navbar kiri — aktif di menu Produk
          AppNavbar(activePage: NavPage.produk),
          // Konten utama
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Topbar
        CustomHeader(title: 'Manajemen Produk'),
        // Konten scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat cards — ringkasan angka produk
                _buildStatCards(),
                const SizedBox(height: 24),
                // Tabel/grid produk
                _buildProdukSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════
  // TOPBAR
  // ═══════════════════════════════════

  // ═══════════════════════════════════
  // STAT CARDS
  // ═══════════════════════════════════
  Widget _buildStatCards() {
    return Obx(() {
      // Obx di sini karena stat cards bergantung pada data products
      // yang bisa berubah kapan saja dari Firestore
      return Row(
        children: [
          _statCard(
            label: 'Total Produk',
            // toString() = ubah angka jadi teks
            value: controller.totalProduk.toString(),
            sub: 'Produk aktif',
            icon: '📦',
            // Tidak ada warna khusus = pakai warna default
          ),
          const SizedBox(width: 16),
          _statCard(
            label: 'Total Stok',
            value: controller.totalStok.toString(),
            sub: 'Unit tersedia',
            icon: '🏷️',
          ),
          const SizedBox(width: 16),
          _statCard(
            label: 'Stok Menipis',
            value: controller.produkMenipis.toString(),
            sub: 'Stok ≤ 5 unit',
            icon: '⚠️',
            // Kalau ada produk yang stoknya menipis,
            // tampilkan warna peringatan
            valueColor: controller.produkMenipis > 0
                ? AppTheme.error
                : AppTheme.textPrimary,
          ),
          const SizedBox(width: 16),
          _statCard(
            label: 'Stok Habis',
            value: controller.produkHabis.toString(),
            sub: 'Perlu restock',
            icon: '🚫',
            valueColor: controller.produkHabis > 0
                ? AppTheme.error
                : AppTheme.textPrimary,
          ),
        ],
      );
    });
  }

  // Widget satu stat card
  Widget _statCard({
    required String label,
    required String value,
    required String sub,
    required String icon,
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),

          // Border kiri merah = penanda visual
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
                      // valueColor = warna angka, default textPrimary
                      color: valueColor ?? AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Icon besar di kanan, transparan
            Text(icon, style: const TextStyle(fontSize: 28)),
          ],
        ),
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
      child: Column(
        children: [
          // Header section: filter + search
          // Grid produk
          _buildSectionHeader(),
          _buildProdukGrid(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Filter kategori — tombol pill
          // Search bar
          SizedBox(
            width: 220,
            child: TextField(
              onChanged: controller.onSearch,
              // onChanged = dipanggil setiap user ketik huruf baru
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

          SizedBox(width: 20),

          // Filter kategori — tombol pilih kategori
          Obx(
            () => SizedBox(
              width: 200,
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

          Spacer(),

          ElevatedButton.icon(
            onPressed: controller.goToTambahProduk,
            label: Text('Tambah Produk'),
            icon: Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.primaryLight,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      // Tampilkan loading spinner saat data masih dimuat
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

      // Tampilkan pesan kalau tidak ada produk
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.goToTambahProduk,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Produk Pertama'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Tampilkan grid produk
      return Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          // shrinkWrap = GridView hanya setinggi kontennya
          // tidak mengisi seluruh layar
          // Diperlukan karena GridView ada di dalam Column
          shrinkWrap: true,
          // NeverScrollableScrollPhysics = nonaktifkan scroll GridView
          // biarkan parent (SingleChildScrollView) yang scroll
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            // crossAxisCount = jumlah kolom
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
            // childAspectRatio = rasio lebar:tinggi tiap kartu
            // 0.78 = sedikit lebih tinggi dari lebarnya
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
  // KARTU PRODUK
  // ═══════════════════════════════════
  Widget _buildProductCard(ProductModel product) {
    // Tentukan status stok untuk tampilan badge
    final isHabis = product.stock <= 0;
    final isMenipis = product.stock > 0 && product.stock <= 5;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Border merah kalau stok habis,
          // border normal kalau stok aman
          color: isHabis ? AppTheme.error.withOpacity(0.3) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          Expanded(
            child: Stack(
              children: [
                // Gambar
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // errorBuilder = tampilkan ini kalau gambar gagal load
                          errorBuilder: (_, __, ___) => _placeholderImg(),
                        )
                      : _placeholderImg(),
                ),

                // Badge status stok di pojok kanan atas
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

          // Info produk
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama produk
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // overflow: ellipsis = kalau teks terlalu panjang
                  // tampilkan "..." di akhir
                ),
                const SizedBox(height: 2),
                // Kategori
                Text(
                  product.category,
                  style: const TextStyle(fontSize: 14, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                // Harga
                Text(
                  CurrencyFormatter.format(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Tombol aksi: Edit dan Hapus
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                // Tombol Edit
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
                // Tombol Hapus
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

  // Placeholder gambar kalau tidak ada / gagal load
  Widget _placeholderImg() {
    return Container(
      width: double.infinity,
      color: AppTheme.bgSecondary,
      child: const Center(child: Text('🏷️', style: TextStyle(fontSize: 32))),
    );
  }
}
