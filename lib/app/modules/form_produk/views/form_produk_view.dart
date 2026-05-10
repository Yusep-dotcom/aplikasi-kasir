import 'package:aplikasi_kasir/app/core/widgets/app_navbar.dart';
import 'package:aplikasi_kasir/app/core/widgets/costum_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_produk_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

class FormProdukView extends GetView<FormProdukController> {
  const FormProdukView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          AppNavbar(activePage: NavPage.produk),
          Expanded(
            child: Column(
              children: [
                CustomHeader(title: 'Manajemen Produk'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kolom kiri — form input (lebih lebar)
                        Expanded(flex: 3, child: _buildForm()),
                        const SizedBox(width: 20),
                        // Kolom kanan — preview + tips (lebih sempit)
                        Expanded(flex: 2, child: _buildSidebar()),
                      ],
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

  // ═══════════════════════════════════
  // TOPBAR
  // ═══════════════════════════════════
 

  // ═══════════════════════════════════
  // FORM UTAMA
  // ═══════════════════════════════════
  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul form
          Obx(
            () => Row(
              children: [
                Text(
                  controller.isEditMode.value
                      ? '✏️ Edit Produk'
                      : '➕ Tambah Produk Baru',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.isEditMode.value) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      border: Border.all(color: const Color(0xFFFFE082)),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Mode Edit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF57F17),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── NAMA PRODUK ──
          _label('Nama Produk', required: true),
          _inputField(
            controller: controller.nameController,
            hint: 'contoh: Ganci Bunga Rajut Warna Merah',
            hint2: 'Gunakan nama yang jelas dan spesifik',
          ),
          const SizedBox(height: 16),

          // ── KATEGORI + HARGA (2 kolom) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Kategori', required: true),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value.isEmpty
                            ? null
                            : controller.selectedCategory.value,
                        hint: const Text(
                          'Pilih kategori...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        decoration: _inputDecoration(),
                        items: controller.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedCategory.value = val;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Harga
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Harga Jual', required: true),
                    _inputField(
                      controller: controller.priceController,
                      hint: 'contoh: 10000',
                      hint2: 'Masukkan harga dalam Rupiah (tanpa titik/koma)',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── STOK + HARGA MODAL (2 kolom) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stok dengan tombol +/-
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Stok Awal', required: true),
                    Row(
                      children: [
                        // Tombol kurangi
                        _stockBtn(
                          icon: Icons.remove,
                          onTap: controller.decreaseStock,
                        ),
                        // Input stok
                        Expanded(
                          child: TextField(
                            controller: controller.stockController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.border),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.primary,
                                  width: 1.5,
                                ),
                              ),
                              hintText: '0',
                              hintStyle: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        // Tombol tambah
                        _stockBtn(
                          icon: Icons.add,
                          onTap: controller.increaseStock,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isEditMode.value
                          ? 'Stok saat produk dibuat: ${controller.editProduct?.stock ?? 0} unit'
                          : 'Jumlah stok yang tersedia saat ini',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Placeholder kolom kanan (kosong atau bisa diisi field lain)
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),

          // ── URL FOTO PRODUK ──
          _label('URL Foto Produk'),
          TextField(
            controller: controller.imageUrlController,
            style: const TextStyle(fontSize: 13),
            // onSubmitted = dipanggil saat user tekan Enter
            onSubmitted: controller.onImageUrlSubmitted,
            // onChanged = dipanggil setiap ketik 1 huruf
            // kita pakai onChanged supaya preview update realtime
            onChanged: controller.onImageUrlSubmitted,
            decoration:
                _inputDecoration(
                  hint: 'https://contoh.com/foto-produk.jpg',
                ).copyWith(
                  // copyWith = salin decoration lama + ubah properti tertentu
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.link,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Paste URL gambar dari internet. Kosongkan jika tidak ada foto.',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          // ── DESKRIPSI ──
          _label('Deskripsi Produk'),
          TextField(
            controller: controller.descriptionController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(
              hint:
                  'contoh: Gantungan kunci rajut berbentuk bunga '
                  'dengan warna cerah. Cocok untuk hadiah dan souvenir...',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Opsional — akan ditampilkan di detail produk',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // ── TOMBOL AKSI ──
          Row(
            children: [
              // Tombol Batal
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  side: const BorderSide(color: AppTheme.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 12),
              // Tombol Reset (mode tambah saja)
              Obx(
                () => controller.isEditMode.value
                    ? const SizedBox()
                    : OutlinedButton(
                        onPressed: controller.resetForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reset Form'),
                      ),
              ),
              const Spacer(),
              // Tombol Simpan
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.simpan,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    controller.isLoading.value
                        ? 'Menyimpan...'
                        : controller.isEditMode.value
                        ? 'Simpan Perubahan'
                        : 'Tambah Produk',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
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

  // ═══════════════════════════════════
  // SIDEBAR KANAN
  // ═══════════════════════════════════
  Widget _buildSidebar() {
    return Column(
      children: [
        // Preview kartu produk
        _buildPreviewCard(),
        const SizedBox(height: 16),
        // Tips pengisian
        _buildTipsCard(),
      ],
    );
  }

  Widget _buildPreviewCard() {
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
            '👁️ Preview Kartu Produk',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),

          // Preview gambar — update realtime saat URL berubah
          Obx(() {
            final url = controller.previewImageUrl.value;
            return Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: url.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        // loadingBuilder = tampilkan loading
                        // saat gambar masih diunduh
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 32,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'URL tidak valid',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 32,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Foto belum dipilih',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          }),

          const SizedBox(height: 14),

          // Preview nama produk
          Obx(
            () => Text(
              controller.previewNama.value.isEmpty
                  ? 'Nama Produk'
                  : controller.previewNama.value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: controller.previewNama.value.isEmpty
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Preview kategori
          Obx(
            () => Text(
              controller.selectedCategory.value.isEmpty
                  ? 'Kategori'
                  : controller.selectedCategory.value,
              style: TextStyle(
                fontSize: 12,
                color: controller.selectedCategory.value.isEmpty
                    ? AppTheme.textSecondary.withOpacity(0.5)
                    : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Preview harga
          Obx(
            () => Text(
              CurrencyFormatter.format(controller.previewHarga.value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: controller.previewHarga.value == 0
                    ? AppTheme.textSecondary
                    : AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Preview stok
          Obx(
            () => Text(
              'Stok: ${controller.previewStok.value} unit',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '💡 Tips Pengisian',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _TipItem(
            icon: '📝',
            text:
                'Nama produk sebaiknya spesifik\ncontoh: "Ganci Bunga Merah" bukan cuma "Ganci"',
          ),
          SizedBox(height: 10),
          _TipItem(
            icon: '💰',
            text:
                'Isi harga dalam Rupiah tanpa titik\ncontoh: 10000 bukan 10.000',
          ),
          SizedBox(height: 10),
          _TipItem(
            icon: '🔗',
            text:
                'URL foto bisa dari Google Images\nKlik kanan gambar → Copy image address',
          ),
          SizedBox(height: 10),
          _TipItem(
            icon: '📦',
            text:
                'Stok akan otomatis berkurang setiap kali produk terjual di kasir',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════

  // Label field dengan tanda * untuk yang wajib
  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFC0392B),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  // Input field standar yang reusable
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? hint2,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(hint: hint),
        ),
        if (hint2 != null) ...[
          const SizedBox(height: 4),
          Text(
            hint2,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ],
    );
  }

  // Decoration standar untuk semua input
  InputDecoration _inputDecoration({String hint = ''}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFFAF8F6),
    );
  }

  // Tombol +/- untuk stok
  Widget _stockBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 18, color: AppTheme.primary),
      ),
    );
  }
}

// Widget item tips — dipisah jadi class sendiri
// karena dipakai berulang
class _TipItem extends StatelessWidget {
  final String icon;
  final String text;
  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
