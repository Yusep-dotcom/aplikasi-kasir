import 'package:aplikasi_kasir/app/core/widgets/app_navbar.dart';
import 'package:aplikasi_kasir/app/core/widgets/costum_header.dart';
import 'package:aplikasi_kasir/app/data/models/cart_item.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kasir_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/product_model.dart';
// import '../../../data/models/cart_item.model.dart';

class KasirView extends GetView<KasirController> {
  const KasirView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          // NAVBAR KIRI
          AppNavbar(activePage: NavPage.kasir),
          // KONTEN UTAMA (split screen)
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // NAVBAR KIRI
  // ═══════════════════════════════════

  // ═══════════════════════════════════
  // BODY UTAMA (split screen)
  // ═══════════════════════════════════
  Widget _buildBody() {
    return Column(
      children: [
        // TOPBAR
        CustomHeader(title: 'Kasir'),
        // SPLIT SCREEN
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KIRI: Katalog Produk (60%)
              Expanded(flex: 6, child: _buildKatalog()),
              // KANAN: Keranjang (40%)
              Container(
                width: 340,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: AppTheme.border)),
                ),
                child: _buildKeranjang(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════
  // TOPBAR
  // ═══════════════════════════════════
  // FUNGSI BARU — ganti seluruh _buildTopbar() dengan ini:

  // ═══════════════════════════════════
  // PANEL KIRI: KATALOG PRODUK
  // ═══════════════════════════════════
  Widget _buildKatalog() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, size: 20),
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

        // Filter kategori
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              return Obx(() {
                final isActive = controller.selectedCategory.value == cat;
                return GestureDetector(
                  onTap: () => controller.changeCategory(cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),

        const SizedBox(height: 12),

        // Grid produk
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            final list = controller.filteredProducts;

            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada produk',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 kolom
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85, // tinggi kartu
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return _buildProductCard(list[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  // Widget kartu produk
  Widget _buildProductCard(ProductModel product) {
    final isHabis = product.stock <= 0;

    return GestureDetector(
      onTap: isHabis ? null : () => controller.addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: isHabis ? AppTheme.bgSecondary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHabis ? AppTheme.border : AppTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
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
                  // Badge stok
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
                            : product.stock <= 5
                            ? AppTheme.error
                            : AppTheme.success,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        isHabis ? 'Habis' : 'Stok: ${product.stock}',
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // KODE BARU — tampilkan harga produk, bukan total keranjang:
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder saat gambar tidak ada / gagal load
  Widget _placeholderImg() {
    return Container(
      width: double.infinity,
      color: AppTheme.bgSecondary,
      child: const Center(child: Text('🏷️', style: TextStyle(fontSize: 32))),
    );
  }

  // ═══════════════════════════════════
  // PANEL KANAN: KERANJANG
  // ═══════════════════════════════════
  Widget _buildKeranjang() {
    return Column(
      children: [
        // Header keranjang
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: [
              const Text(
                'Keranjang Belanja',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              // KODE BARU:
              Obx(
                () => Text(
                  '${controller.totalItems} item',
                  // .value karena totalItems sekarang .obs
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // List item keranjang
        Expanded(
          child: Obx(() {
            if (controller.cartItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🛒',
                      style: TextStyle(fontSize: 40, color: Colors.black12),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Keranjang kosong',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(controller.cartItems[index]);
              },
            );
          }),
        ),

        // Footer: total + metode bayar + tombol
        _buildKeranjangFooter(),
      ],
    );
  }

  // Widget tiap item di keranjang
  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Info produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${CurrencyFormatter.format(item.priceAtSale)} × ${item.quantity} = '
                  '${CurrencyFormatter.format(item.totalPrice)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Kontrol quantity
          Row(
            children: [
              _qtyButton(
                icon: Icons.remove,
                onTap: () => controller.decreaseQty(item),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _qtyButton(
                icon: Icons.add,
                onTap: () => controller.increaseQty(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tombol + dan - quantity
  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 14, color: AppTheme.textPrimary),
      ),
    );
  }

  // Footer keranjang: total + metode bayar + tombol aksi
  Widget _buildKeranjangFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          // Total harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Obx(
                () => Text(
                  CurrencyFormatter.format(controller.totalHarga),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown metode pembayaran
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedPayment.value.isEmpty
                  ? null
                  : controller.selectedPayment.value,
              hint: const Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: 13),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: controller.paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.selectPayment(val);
              },
            ),
          ),

          const SizedBox(height: 10),

          // Tombol Bayar Sekarang
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : controller.bayar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isProcessing.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Bayar Sekarang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Tombol Reset Cart
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: controller.resetCart,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reset Cart', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
