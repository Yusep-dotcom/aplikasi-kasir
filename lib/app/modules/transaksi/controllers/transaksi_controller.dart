import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/currency_formatter.dart';

class TransaksiController extends GetxController {
  final _db = FirebaseFirestore.instance;

  var transactions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  // Filter
  var filterMetode = 'Semua'.obs;
  var filterStatus = 'Semua'.obs;

  final List<String> metodeOptions = ['Semua', 'Cash', 'Transfer', 'Qris'];
  final List<String> statusOptions = ['Semua', 'selesai', 'batal'];

  final periodeOptions = [
    'Hari ini',
    'Kemarin',
    '7 Hari Terakhir',
    'Bulan ini',
    'Custom',
  ].obs;

  final selectedPeriode = 'Hari ini'.obs;

  final selectedStartDate = DateTime.now().obs;
  final selectedEndDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    changePeriode('Hari ini'); // 🔥 langsung load awal
  }

  // 🔥 SATU-SATUNYA FUNCTION LOAD DATA
  void loadTransactions() {
    isLoading.value = true;

    final start = selectedStartDate.value;
    final end = selectedEndDate.value;

    Query query = _db.collection('transactions');

    // 🔥 FILTER TANGGAL (WAJIB pakai Timestamp)
    query = query
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));

    // 🔥 FILTER METODE
    if (filterMetode.value != 'Semua') {
      query = query.where('paymentMethod',
          isEqualTo: filterMetode.value);
    }

    // 🔥 FILTER STATUS
    if (filterStatus.value != 'Semua') {
      query = query.where('status',
          isEqualTo: filterStatus.value);
    }

    query = query.orderBy('createdAt', descending: true);

    query.snapshots().listen((snapshot) {
      transactions.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'items': data['items'] ?? [],
            'kasirId': data['kasirId'] ?? '',
            'kasirName': data['kasirName'] ?? 'Admin',
            'totalAmount': data['totalAmount'] ?? 0,
            'paymentMethod': data['paymentMethod'] ?? '-',
            'status': data['status'] ?? 'selesai',
            'createdAt': data['createdAt'],
          };
        }).toList(),
      );
      isLoading.value = false;
    });
  }

  // 🔥 PERIODE
  void changePeriode(String value) {
    selectedPeriode.value = value;

    final now = DateTime.now();

    switch (value) {
      case 'Hari ini':
        selectedStartDate.value =
            DateTime(now.year, now.month, now.day);
        selectedEndDate.value = now;
        break;

      case 'Kemarin':
        final yesterday = now.subtract(const Duration(days: 1));
        selectedStartDate.value = DateTime(
            yesterday.year, yesterday.month, yesterday.day);
        selectedEndDate.value = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
        break;

      case '7 Hari Terakhir':
        selectedStartDate.value =
            now.subtract(const Duration(days: 6));
        selectedEndDate.value = now;
        break;

      case 'Bulan ini':
        selectedStartDate.value =
            DateTime(now.year, now.month, 1);
        selectedEndDate.value = now;
        break;

      case 'Custom':
        break;
    }

    loadTransactions(); // 🔥 reload
  }

  void setCustomDate(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    selectedPeriode.value = 'Custom';

    loadTransactions(); // 🔥 reload
  }

  // 🔥 FILTER METODE
  void changeFilterMetode(String val) {
    filterMetode.value = val;
    loadTransactions();
  }

  // 🔥 FILTER STATUS
  void changeFilterStatus(String val) {
    filterStatus.value = val;
    loadTransactions();
  }

  // Format tanggal
  String formatTanggal(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    final hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final bln = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${hari[dt.weekday - 1]}, ${dt.day} ${bln[dt.month - 1]} ${dt.year} — '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  int totalItemCount(List items) {
    return items.fold<int>(0, (sum, item) {
      if (item is Map) {
        final quantity = item['quantity'];
        if (quantity is int) return sum + quantity;
        if (quantity is num) return sum + quantity.toInt();
      }
      return sum;
    });
  }

  String formatHarga(int amount) => CurrencyFormatter.format(amount);
}