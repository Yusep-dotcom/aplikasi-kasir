import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/repositories/laporan_repository.dart';
import '../../../core/utils/currency_formatter.dart';

class LaporanController extends GetxController {
  final _repo = LaporanRepository();

  // ── State ──
  var isLoading     = false.obs;
  var isExporting   = false.obs;
  var showExportDialog = false.obs;

  // Periode yang dipilih — default bulan ini
  var selectedPeriode = 'Bulan Ini'.obs;
  var selectedStartDate = DateTime.now().obs;
  var selectedEndDate   = DateTime.now().obs;

  final List<String> periodeOptions = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Custom',
  ];

  // ── Data hasil kalkulasi ──
  var transaksiList    = <Map<String, dynamic>>[].obs;
  var totalPendapatan  = 0.obs;
  var totalTransaksi   = 0.obs;
  var totalItemTerjual = 0.obs;

  // Data untuk grafik — pendapatan per hari
  // key = tanggal (String), value = total pendapatan
  var pendapatanHarian = <String, int>{}.obs;

  // Data produk terlaris
  // List of Map: {name, qty, revenue}
  var produkTerlaris = <Map<String, dynamic>>[].obs;

  // Data metode pembayaran
  var metodePembayaran = <String, int>{}.obs;

  // Untuk export PDF — isi laporan yang dipilih
  var exportRingkasanPendapatan = true.obs;
  var exportDaftarTransaksi     = true.obs;
  var exportProdukTerlaris      = true.obs;
  var exportMetodePembayaran    = true.obs;

  // Format export yang dipilih
  var exportFormat = 'PDF'.obs;

  @override
  void onInit() {
    super.onInit();
    // Set periode default = bulan ini
    _setPeriodeBulanIni();
    loadLaporan();
  }

  // Set tanggal awal & akhir untuk "Bulan Ini"
  void _setPeriodeBulanIni() {
    final now = DateTime.now();
    selectedStartDate.value = DateTime(now.year, now.month, 1);
    // DateTime(year, month, 1) = tanggal 1 bulan ini
    selectedEndDate.value   = DateTime(now.year, now.month + 1, 0);
    // DateTime(year, month+1, 0) = hari terakhir bulan ini
    // month+1, day=0 = hari sebelum tanggal 1 bulan depan
  }

  // Ganti periode yang dipilih
  Future<void> changePeriode(String periode) async {
    selectedPeriode.value = periode;
    final now = DateTime.now();

    switch (periode) {
      case 'Hari Ini':
        selectedStartDate.value = DateTime(now.year, now.month, now.day);
        selectedEndDate.value   = DateTime(now.year, now.month, now.day);
        break;
      case 'Minggu Ini':
        // weekday: 1=Senin, 7=Minggu
        // Hitung mundur ke hari Senin minggu ini
        final senin = now.subtract(Duration(days: now.weekday - 1));
        selectedStartDate.value = DateTime(senin.year, senin.month, senin.day);
        selectedEndDate.value   = now;
        break;
      case 'Bulan Ini':
        _setPeriodeBulanIni();
        break;
    }

    if (periode != 'Custom') {
      await loadLaporan();
    }
  }

  // Set tanggal custom dari date picker
  Future<void> setCustomDate(DateTime start, DateTime end) async {
    selectedStartDate.value = start;
    selectedEndDate.value   = end;
    await loadLaporan();
  }

  // Load dan kalkulasi data laporan dari Firestore
  Future<void> loadLaporan() async {
    isLoading.value = true;

    try {
      // Ambil semua transaksi dalam periode
      final data = await _repo.getTransaksiByPeriode(
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
      );

      transaksiList.assignAll(data);

      // ── Kalkulasi statistik utama ──
      int pendapatan = 0;
      int itemTerjual = 0;
      final Map<String, int> harian     = {};
      final Map<String, int> produkQty  = {};
      final Map<String, int> produkRev  = {};
      final Map<String, int> metode     = {};

      for (final trx in data) {
        // Total pendapatan
        pendapatan += (trx['totalAmount'] ?? 0) as int;

        // Total item terjual
        final items = trx['items'] as List? ?? [];
        for (final item in items) {
          itemTerjual += (item['quantity'] ?? 0) as int;

          // Rekap produk terlaris
          final nama = item['productName'] ?? 'Unknown';
          final qty  = (item['quantity'] ?? 0) as int;
          final rev  = (item['totalPrice'] ?? 0) as int;
          produkQty[nama] = (produkQty[nama] ?? 0) + qty;
          produkRev[nama] = (produkRev[nama] ?? 0) + rev;
        }

        // Rekap pendapatan harian
        // createdAt dari Firestore bertipe Timestamp
        if (trx['createdAt'] != null) {
          final tgl = (trx['createdAt'] as Timestamp).toDate();
          // Format tanggal jadi key: "01", "02", dst
          final key = DateFormat('dd').format(tgl);
          harian[key] = (harian[key] ?? 0) +
              (trx['totalAmount'] ?? 0) as int;
        }

        // Rekap metode pembayaran
        final met = trx['paymentMethod'] ?? 'Lainnya';
        metode[met] = (metode[met] ?? 0) + 1;
      }

      // Update semua state sekaligus
      totalPendapatan.value  = pendapatan;
      totalTransaksi.value   = data.length;
      totalItemTerjual.value = itemTerjual;
      pendapatanHarian.assignAll(harian);
      metodePembayaran.assignAll(metode);

      // Susun produk terlaris — urutkan berdasarkan qty terbanyak
      final produkList = produkQty.entries.map((e) => {
        'name'   : e.key,
        'qty'    : e.value,
        'revenue': produkRev[e.key] ?? 0,
      }).toList();
      // sort = urutkan list berdasarkan kriteria tertentu
      // descending = terbesar di atas
      produkList.sort((a, b) =>
          (b['qty'] as int).compareTo(a['qty'] as int));
      // Ambil top 5 saja
      produkTerlaris.assignAll(produkList.take(5).toList());

    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat laporan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── EXPORT PDF ──

  // Buka dialog export
  void bukaExportDialog() {
    showExportDialog.value = true;
  }

  // Tutup dialog export
  void tutupExportDialog() {
    showExportDialog.value = false;
  }

  // Toggle isi export
  void toggleExportRingkasan(bool val) =>
      exportRingkasanPendapatan.value = val;
  void toggleExportTransaksi(bool val) =>
      exportDaftarTransaksi.value = val;
  void toggleExportProduk(bool val) =>
      exportProdukTerlaris.value = val;
  void toggleExportMetode(bool val) =>
      exportMetodePembayaran.value = val;
  void setExportFormat(String format) =>
      exportFormat.value = format;

  // Nama file yang akan digenerate
  String get namaFile {
    final start = DateFormat('dd-MMM-yyyy').format(selectedStartDate.value);
    final end   = DateFormat('dd-MMM-yyyy').format(selectedEndDate.value);
    final ext   = exportFormat.value == 'PDF' ? 'pdf' : 'xlsx';
    return 'Laporan_${start}_sd_${end}.$ext';
  }

  // Generate dan preview PDF
  Future<void> exportPDF() async {
    if (exportFormat.value != 'PDF') {
      Get.snackbar(
        'Info',
        'Export Excel dan CSV akan segera hadir',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isExporting.value = true;
    tutupExportDialog();

    try {
      final pdf = pw.Document();
      // Format periode untuk judul
      final periodeText =
          '${DateFormat('dd MMM yyyy').format(selectedStartDate.value)} '
          '— ${DateFormat('dd MMM yyyy').format(selectedEndDate.value)}';

      pdf.addPage(
        pw.MultiPage(
          // MultiPage = PDF bisa lebih dari 1 halaman otomatis
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // ── HEADER ──
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('7D2A2A'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN PENJUALAN',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Crochet House Collection',
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Periode: $periodeText',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ── RINGKASAN PENDAPATAN ──
              if (exportRingkasanPendapatan.value) ...[
                _pdfSectionTitle('Ringkasan Pendapatan'),
                pw.Row(children: [
                  _pdfStatBox(
                    'Total Pendapatan',
                    CurrencyFormatter.format(totalPendapatan.value),
                  ),
                  pw.SizedBox(width: 8),
                  _pdfStatBox(
                    'Total Transaksi',
                    '${totalTransaksi.value} transaksi',
                  ),
                  pw.SizedBox(width: 8),
                  _pdfStatBox(
                    'Item Terjual',
                    '${totalItemTerjual.value} unit',
                  ),
                ]),
                pw.SizedBox(height: 16),
              ],

              // ── PRODUK TERLARIS ──
              if (exportProdukTerlaris.value &&
                  produkTerlaris.isNotEmpty) ...[
                _pdfSectionTitle('Produk Terlaris'),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('E8E4DF'),
                    width: 0.5,
                  ),
                  children: [
                    // Header tabel
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F5F2EE')),
                      children: [
                        _pdfTableCell('No', isHeader: true),
                        _pdfTableCell('Nama Produk', isHeader: true),
                        _pdfTableCell('Qty Terjual', isHeader: true),
                        _pdfTableCell('Total Pendapatan', isHeader: true),
                      ],
                    ),
                    // Baris data
                    ...produkTerlaris.asMap().entries.map((e) {
                      final i = e.key;
                      final p = e.value;
                      return pw.TableRow(
                        children: [
                          _pdfTableCell('${i + 1}'),
                          _pdfTableCell(p['name'] ?? ''),
                          _pdfTableCell('${p['qty']} unit'),
                          _pdfTableCell(
                            CurrencyFormatter.format(p['revenue'] as int)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],

              // ── METODE PEMBAYARAN ──
              if (exportMetodePembayaran.value &&
                  metodePembayaran.isNotEmpty) ...[
                _pdfSectionTitle('Metode Pembayaran'),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('E8E4DF'),
                    width: 0.5,
                  ),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F5F2EE')),
                      children: [
                        _pdfTableCell('Metode', isHeader: true),
                        _pdfTableCell('Jumlah Transaksi', isHeader: true),
                        _pdfTableCell('Persentase', isHeader: true),
                      ],
                    ),
                    ...metodePembayaran.entries.map((e) {
                      final pct = totalTransaksi.value > 0
                          ? (e.value / totalTransaksi.value * 100)
                              .toStringAsFixed(1)
                          : '0';
                      return pw.TableRow(children: [
                        _pdfTableCell(e.key),
                        _pdfTableCell('${e.value} transaksi'),
                        _pdfTableCell('$pct%'),
                      ]);
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],

              // ── DAFTAR TRANSAKSI ──
              if (exportDaftarTransaksi.value &&
                  transaksiList.isNotEmpty) ...[
                _pdfSectionTitle('Daftar Transaksi'),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('E8E4DF'),
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F5F2EE')),
                      children: [
                        _pdfTableCell('ID', isHeader: true),
                        _pdfTableCell('Tanggal', isHeader: true),
                        _pdfTableCell('Item', isHeader: true),
                        _pdfTableCell('Total', isHeader: true),
                        _pdfTableCell('Metode', isHeader: true),
                      ],
                    ),
                    ...transaksiList.map((trx) {
                      // Format tanggal
                      String tgl = '-';
                      if (trx['createdAt'] != null) {
                        final dt = (trx['createdAt'] as Timestamp).toDate();
                        tgl = DateFormat('dd/MM/yyyy HH:mm').format(dt);
                      }
                      final idShort =
                          trx['id'].toString().substring(0, 8).toUpperCase();
                      final items = trx['items'] as List? ?? [];
                      final totalItem = items.fold<int>(
                        0, (s, i) => s + ((i['quantity'] ?? 0) as int));

                      return pw.TableRow(children: [
                        _pdfTableCell('#$idShort'),
                        _pdfTableCell(tgl),
                        _pdfTableCell('$totalItem item'),
                        _pdfTableCell(
                          CurrencyFormatter.format(
                            trx['totalAmount'] ?? 0)),
                        _pdfTableCell(trx['paymentMethod'] ?? '-'),
                      ]);
                    }),
                  ],
                ),
              ],

              pw.SizedBox(height: 24),

              // ── FOOTER ──
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Digenerate oleh Sistem Kasir CHIC',
                    style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey),
                  ),
                  pw.Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      // Preview dan share PDF menggunakan package printing
      // Ini akan buka dialog native HP untuk save/print/share
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: namaFile,
      );

    } catch (e) {
      Get.snackbar(
        'Export Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFDECEA),
        colorText: const Color(0xFFC0392B),
      );
    } finally {
      isExporting.value = false;
    }
  }

  // ── Helper widget untuk PDF ──

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('7D2A2A'),
          ),
        ),
        pw.SizedBox(height: 6),
      ],
    );
  }

  pw.Widget _pdfStatBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColor.fromHex('E8E4DF'), width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
              style: const pw.TextStyle(
                fontSize: 9, color: PdfColors.grey)),
            pw.SizedBox(height: 4),
            pw.Text(value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              )),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  // Format tanggal untuk tampilan
  String formatTanggal(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    final hari  = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    final bulan = ['Jan','Feb','Mar','Apr','Mei','Jun',
                   'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${hari[dt.weekday-1]}, ${dt.day} ${bulan[dt.month-1]} ${dt.year} '
           '— ${dt.hour.toString().padLeft(2,'0')}:'
           '${dt.minute.toString().padLeft(2,'0')}';
  }
}