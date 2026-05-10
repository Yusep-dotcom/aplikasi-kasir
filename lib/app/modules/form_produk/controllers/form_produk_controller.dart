import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class FormProdukController extends GetxController {
  final _repo = ProductRepository();

  // ── Input Controllers ──
  // TextEditingController = objek yang "menempel" di TextField
  // Dia yang menyimpan teks yang diketik user
  // Analoginya: clipboard yang nempel di tiap kotak input
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final imageUrlController = TextEditingController();
  final descriptionController = TextEditingController();

  // ── State ──
  var selectedCategory = ''.obs;
  var isLoading = false.obs;
  var isEditMode = false.obs;
  // previewImageUrl = URL yang ditampilkan di preview
  // berubah setiap kali user selesai ketik di input URL
  var previewImageUrl = ''.obs;
  var previewNama = ''.obs;
  var previewHarga = 0.obs;
  var previewStok = 0.obs;

  // Produk yang sedang diedit (null kalau mode tambah)
  ProductModel? editProduct;

  // Daftar pilihan kategori
  final List<String> categories = [
    'Gantungan Kunci',
    'Hiasan Rajut',
    'Aksesoris Tas',
  ];

  @override
  void onInit() {
    super.onInit();

    nameController.addListener(() {
      previewNama.value = nameController.text;
    });

    priceController.addListener(() {
      previewHarga.value = int.tryParse(priceController.text) ?? 0;
    });

    stockController.addListener(() {
      previewStok.value = int.tryParse(stockController.text) ?? 0;
    });

    // Cek apakah ada arguments yang dikirim
    // null   = mode TAMBAH → form kosong
    // object = mode EDIT   → form terisi data lama
    if (Get.arguments != null) {
      isEditMode.value = true;
      editProduct = Get.arguments as ProductModel;
      _isiFormUntukEdit(editProduct!);
    }
  }

  // Isi semua field form dengan data produk (mode edit)
  void _isiFormUntukEdit(ProductModel product) {
    nameController.text = product.name;
    priceController.text = product.price.toString();
    stockController.text = product.stock.toString();
    imageUrlController.text = product.imageUrl;
    descriptionController.text = product.description;
    selectedCategory.value = product.category;
    previewImageUrl.value = product.imageUrl;
    // Langsung tampilkan preview foto kalau ada
  }

  // Dipanggil saat user selesai ketik URL gambar
  // dan menekan Enter atau pindah ke field lain
  void onImageUrlSubmitted(String url) {
    previewImageUrl.value = url.trim();
    // .trim() = hapus spasi di awal dan akhir
  }

  // Tombol + stok
  void increaseStock() {
    final current = int.tryParse(stockController.text) ?? 0;
    // int.tryParse = coba ubah String ke int
    // Kalau gagal (bukan angka), kembalikan null
    // ?? 0 = kalau null, pakai 0 sebagai default
    stockController.text = (current + 1).toString();
  }

  // Tombol - stok (minimal 0)
  void decreaseStock() {
    final current = int.tryParse(stockController.text) ?? 0;
    if (current > 0) {
      stockController.text = (current - 1).toString();
    }
  }

  // Validasi semua field sebelum simpan
  // Mengembalikan true kalau semua valid
  // Mengembalikan false + tampilkan snackbar kalau ada yang salah
  bool _isFormValid() {
    // Cek nama tidak kosong
    if (nameController.text.trim().isEmpty) {
      _showError('Nama produk tidak boleh kosong');
      return false;
    }

    // Cek kategori sudah dipilih
    if (selectedCategory.value.isEmpty) {
      _showError('Pilih kategori produk terlebih dahulu');
      return false;
    }

    // Cek harga tidak kosong
    if (priceController.text.trim().isEmpty) {
      _showError('Harga tidak boleh kosong');
      return false;
    }

    // Cek harga adalah angka yang valid
    final harga = int.tryParse(priceController.text.trim());
    if (harga == null) {
      _showError('Harga harus berupa angka\ncontoh: 10000');
      return false;
    }

    // Cek harga tidak negatif
    if (harga < 0) {
      _showError('Harga tidak boleh negatif');
      return false;
    }

    return true; // semua valid!
  }

  // Helper tampilkan snackbar error
  void _showError(String message) {
    Get.snackbar(
      'Periksa Form',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFDECEA),
      colorText: const Color(0xFFC0392B),
      duration: const Duration(seconds: 3),
    );
  }

  // Fungsi simpan — dipanggil saat tombol Simpan diklik
  Future<void> simpan() async {
    // Validasi dulu — kalau tidak valid, berhenti di sini
    if (!_isFormValid()) return;

    isLoading.value = true;

    try {
      // Buat object ProductModel dari isi form
      final product = ProductModel(
        // Mode tambah: id dikosongkan
        // Firestore akan generate id otomatis
        // Mode edit: pakai id produk yang lama
        id: isEditMode.value ? editProduct!.id : '',
        name: nameController.text.trim(),
        category: selectedCategory.value,
        price: int.parse(priceController.text.trim()),
        // int.parse berbeda dari int.tryParse:
        // tryParse = tidak throw error kalau gagal (kembalikan null)
        // parse = throw error kalau gagal
        // Aman dipakai di sini karena sudah divalidasi di _isFormValid()
        stock: int.tryParse(stockController.text.trim()) ?? 0,
        imageUrl: imageUrlController.text.trim(),
        description: descriptionController.text.trim(),
        createdAt: isEditMode.value ? editProduct!.createdAt : DateTime.now(),
        // Mode tambah: createdAt = sekarang
        // Mode edit: createdAt = tetap pakai tanggal asli
      );

      if (isEditMode.value) {
        // Mode edit → update dokumen yang sudah ada
        await _repo.updateProduct(product);
      } else {
        // Mode tambah → buat dokumen baru
        await _repo.addProduct(product);
      }

      // Tampilkan notifikasi sukses
      Get.snackbar(
        'Berhasil! ✅',
        isEditMode.value
            ? '${product.name} berhasil diperbarui'
            : '${product.name} berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE1F5EE),
        colorText: const Color(0xFF085041),
        duration: const Duration(seconds: 2),
      );

      // Kembali ke halaman produk
      // Get.back() = sama seperti tekan tombol back
      Get.toNamed(Routes.PRODUK);
    } catch (e) {
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      // finally = selalu dijalankan meski ada error
      // Pastikan loading dimatikan
      isLoading.value = false;
    }
  }

  // Reset semua field ke kondisi kosong
  void resetForm() {
    nameController.clear();
    priceController.clear();
    stockController.text = '0';
    imageUrlController.clear();
    descriptionController.clear();
    selectedCategory.value = '';
    previewImageUrl.value = '';
  }

  @override
  void onClose() {
    // WAJIB dispose semua TextEditingController
    // saat halaman ditutup supaya tidak ada memory leak
    // Analoginya: matikan keran air setelah selesai pakai
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
