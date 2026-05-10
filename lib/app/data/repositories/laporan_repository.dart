import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanRepository {
  final _db = FirebaseFirestore.instance;

  // Ambil semua transaksi selesai dalam rentang tanggal tertentu
  // startDate = awal periode, endDate = akhir periode
  Future<List<Map<String, dynamic>>> getTransaksiByPeriode({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Tambah 1 hari ke endDate supaya transaksi di hari terakhir
    // ikut masuk — karena Firestore pakai waktu 00:00:00
    final endOfDay = endDate.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('transactions')
        .where('status', isEqualTo: 'selesai')
        // where = filter dokumen berdasarkan kondisi
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThan: endOfDay)
        .orderBy('createdAt', descending: false)
        .get();

    // .get() = ambil sekali (bukan stream)
    // Untuk laporan lebih cocok get() daripada stream
    // karena kita butuh snapshot data pada periode tertentu
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }
}