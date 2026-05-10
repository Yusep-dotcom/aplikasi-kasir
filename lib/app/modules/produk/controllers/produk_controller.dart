import 'package:aplikasi_kasir/app/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class ProdukController extends GetxController {
  // Repository = perantara antara controller dan Firebase
  // Controller tidak boleh langsung bicara ke Firebase
  // Harus lewat Repository dulu — ini prinsip Clean Architecture
  final _repo = ProductRepository();

  // selek kategori

  // products = list semua produk, reaktif dengan .obs
  // Setiap kali isinya berubah, widget Obx() otomatis rebuild
  var products = <ProductModel>[].obs;

  // isLoading = penanda apakah data sedang dimuat
  // true = masih loading (tampilkan spinner)
  // false = data sudah siap (tampilkan list)
  var isLoading = true.obs;

  // searchQuery = teks yang diketik di search bar
  var searchQuery = ''.obs;

  // selectedCategory = filter kategori yang aktif
  // 'Semua' = tidak ada filter, tampilkan semua produk
  var selectedCategory = 'Semua'.obs;

  // Daftar pilihan kategori untuk tombol filter
  final List<String> categories = [
    'Semua',
    'Gantungan Kunci',
    'Hiasan Rajut',
    'Aksesoris Tas',
  ];

  @override
  void onInit() {
    super.onInit();
    // onInit = dipanggil otomatis saat controller pertama dibuat
    // Langsung load produk begitu controller siap
    loadProducts();
  }

  // Fungsi load produk dari Firestore via Repository
  void loadProducts() {
    isLoading.value = true;

    // listen() = "pasang pendengar" pada stream
    // Setiap kali ada perubahan data di Firestore,
    // blok kode di dalam listen() akan dijalankan otomatis
    _repo.getProducts().listen(
      (list) {
        // list = data produk terbaru dari Firestore
        // assignAll = isi ulang list products dengan data baru
        products.assignAll(list);
        isLoading.value = false;
      },
      onError: (error) {
        // onError = dipanggil kalau ada error saat ambil data
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat produk: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Getter filteredProducts = produk setelah difilter
  // Getter = properti yang dihitung otomatis setiap dipanggil
  // Tidak perlu simpan di variabel terpisah
  List<ProductModel> get filteredProducts {
    var result = products.toList();
    // Langkah 1: filter berdasarkan kategori
    if (selectedCategory.value != 'Semua') {
      result = result
          .where((p) => p.category == selectedCategory.value)
          .toList();
    }
    // Langkah 2: filter berdasarkan kata kunci search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      // toLowerCase() = ubah ke huruf kecil semua
      // supaya pencarian tidak case-sensitive
      // contoh: "GANCI" dan "ganci" dianggap sama
      result = result
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  // Getter statistik — untuk stat cards di atas halaman
  // Total semua produk
  int get totalProduk => products.length;

  // Total semua stok dari semua produk
  int get totalStok => products.fold(0, (sum, p) => sum + p.stock);

  // Jumlah produk dengan stok menipis (stok <= 5)
  int get produkMenipis =>
      products.where((p) => p.stock <= 5 && p.stock > 0).length;

  // Jumlah produk dengan stok habis
  int get produkHabis => products.where((p) => p.stock <= 0).length;

  // Fungsi ganti filter kategori
  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  // Fungsi update search query saat user ketik
  void onSearch(String query) {
    searchQuery.value = query;
  }

  // Navigasi ke halaman tambah produk baru
  // arguments: null = mode tambah (bukan edit)
  void goToTambahProduk() {
    Get.toNamed(Routes.FORM_PRODUK, arguments: null);
  }

  // Navigasi ke halaman edit produk
  // arguments: product = data produk yang mau diedit
  void goToEditProduk(ProductModel product) {
    Get.toNamed(
      Routes.FORM_PRODUK,
      arguments: product,
      // Kita kirim object ProductModel ke halaman form
      // Di FormProdukController, diterima via Get.arguments
    );
  }

  // Navigasi ke halaman konfirmasi hapus produk
  void goToHapusProduk(ProductModel product) {
    Get.toNamed(Routes.HAPUS_PRODUK, arguments: product);
  }
}
