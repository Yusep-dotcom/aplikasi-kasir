import 'package:aplikasi_kasir/app/core/widgets/costum_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/laporan_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_navbar.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Stack(
        children: [
          // Konten utama
          Row(
            children: [
              AppNavbar(activePage: NavPage.laporan),
              Expanded(child: _buildBody()),
            ],
          ),
          // Dialog export — tampil di atas konten
          Obx(
            () => controller.showExportDialog.value
                ? _buildExportDialog()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        CustomHeader(title: 'Laporan Penjualan'),
        _buildTopbar(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildGrafikHarian()),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildProdukTerlaris()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMetodePembayaran()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildRingkasanTransaksi()),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ═══════════════════════════════════
  // TOPBAR
  // ═══════════════════════════════════
  Widget _buildTopbar() {
    return Container(
      color: AppTheme.bgMain,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          // Dropdown periode
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                value: controller.selectedPeriode.value,

                underline: const SizedBox(),
                isDense: true,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                items: controller.periodeOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    if (val == 'Custom') {
                      _showDateRangePicker();
                    } else {
                      controller.changePeriode(val);
                    }
                  }
                },
              ),
            ),
          ),
          const Spacer(),
          // Tombol Export PDF
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isExporting.value
                  ? null
                  : controller.bukaExportDialog,
              icon: controller.isExporting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(
                controller.isExporting.value ? 'Mengexport...' : 'Export PDF',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Date range picker untuk periode Custom
  Future<void> _showDateRangePicker() async {
    controller.selectedPeriode.value = 'Custom';

    final now = DateTime.now();

    DateTime start = controller.selectedStartDate.value;
    DateTime end = controller.selectedEndDate.value;

    // ✅ FIX 1: kalau end > sekarang → paksa ke sekarang
    if (end.isAfter(now)) {
      end = now;
    }

    // ✅ FIX 2: kalau start > end → reset
    if (start.isAfter(end)) {
      start = end.subtract(const Duration(days: 7));
    }

    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: DateTimeRange(start: start, end: end),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      controller.setCustomDate(picked.start, picked.end);
    }
  }

  // ═══════════════════════════════════
  // STAT CARDS
  // ═══════════════════════════════════

  // ═══════════════════════════════════
  // GRAFIK PENDAPATAN HARIAN
  // ═══════════════════════════════════
  Widget _buildGrafikHarian() {
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
            'Pendapatan Harian',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final data = controller.pendapatanHarian;
            if (data.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Tidak ada data',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              );
            }

            // Cari nilai maksimum untuk skala grafik
            final maxVal = data.values.isEmpty
                ? 1
                : data.values.reduce((a, b) => a > b ? a : b);

            return SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.entries.map((e) {
                  // Hitung tinggi bar relatif terhadap nilai max
                  final height = maxVal > 0
                      ? (e.value / maxVal * 140).clamp(4.0, 140.0)
                      : 4.0;
                  // Highlight hari dengan nilai tertinggi
                  final isMax = e.value == maxVal;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Nilai di atas bar
                          if (isMax)
                            Text(
                              _shortNumber(e.value),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          const SizedBox(height: 2),
                          // Bar
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: height,
                            decoration: BoxDecoration(
                              color: isMax
                                  ? AppTheme.primary
                                  : AppTheme.primary.withOpacity(0.45),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Label tanggal
                          Text(
                            e.key,
                            style: TextStyle(
                              fontSize: 9,
                              color: isMax
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                              fontWeight: isMax
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Singkat angka: 1400000 → 1,4jt
  String _shortNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}rb';
    return n.toString();
  }

  // ═══════════════════════════════════
  // PRODUK TERLARIS
  // ═══════════════════════════════════
  Widget _buildProdukTerlaris() {
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
          Row(
            children: [
              const Text(
                'Produk Terlaris',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Obx(
                () => Text(
                  'Top ${controller.produkTerlaris.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (controller.produkTerlaris.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada data',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              );
            }

            final maxQty = controller.produkTerlaris.isNotEmpty
                ? controller.produkTerlaris.first['qty'] as int
                : 1;

            return Column(
              children: controller.produkTerlaris.asMap().entries.map((e) {
                final i = e.key;
                final p = e.value;
                final qty = p['qty'] as int;
                final pct = maxQty > 0 ? qty / maxQty : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Nomor ranking
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? AppTheme.primary
                              : i == 1
                              ? const Color(0xFFB5651D)
                              : AppTheme.bgSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: i < 2
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Nama + bar progress
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppTheme.bgSecondary,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppTheme.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Qty terjual
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$qty',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'terjual',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // METODE PEMBAYARAN
  // ═══════════════════════════════════
  Widget _buildMetodePembayaran() {
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
            'Metode Pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final metode = controller.metodePembayaran;
            if (metode.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada data',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }

            final total = metode.values.fold(0, (s, v) => s + v);
            final colors = [
              AppTheme.primary,
              const Color(0xFF2563EB),
              AppTheme.success,
              AppTheme.warning,
            ];

            return Column(
              children: metode.entries.toList().asMap().entries.map((e) {
                final i = e.key;
                final met = e.value;
                final pct = total > 0 ? met.value / total : 0.0;
                final pctText = '${(pct * 100).toStringAsFixed(1)}%';
                final color = colors[i % colors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              met.key,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${met.value} transaksi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 36,
                            child: Text(
                              pctText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: AppTheme.bgSecondary,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // RINGKASAN TRANSAKSI TERBARU
  // ═══════════════════════════════════
  Widget _buildRingkasanTransaksi() {
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
            'Transaksi Terbaru',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final list = controller.transaksiList.take(5).toList();
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada transaksi',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }
            return Column(
              children: list.map((trx) {
                final idShort =
                    '#${trx['id'].toString().substring(0, 6).toUpperCase()}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      // ID
                      SizedBox(
                        width: 70,
                        child: Text(
                          idShort,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      // Tanggal
                      Expanded(
                        child: Text(
                          controller.formatTanggal(trx['createdAt']),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Total
                      Text(
                        CurrencyFormatter.format(trx['totalAmount'] ?? 0),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // DIALOG EXPORT PDF
  // ═══════════════════════════════════
  Widget _buildExportDialog() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dialog
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Laporan PDF',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Pilih periode dan isi laporan yang ingin diekspor',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: controller.tutupExportDialog,
                    ),
                  ],
                ),
              ),

              // Body dialog
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Periode
                    const Text(
                      'PILIH PERIODE LAPORAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          _periodeChip('Hari Ini'),
                          const SizedBox(width: 8),
                          _periodeChip('Minggu Ini'),
                          const SizedBox(width: 8),
                          _periodeChip('Bulan Ini'),
                          const SizedBox(width: 8),
                          _periodeChip('Custom'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Isi laporan
                    const Text(
                      'PILIH ISI LAPORAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _isiCheckbox(
                            '💰 Ringkasan Pendapatan',
                            controller.exportRingkasanPendapatan.value,
                            controller.toggleExportRingkasan,
                          ),
                          _isiCheckbox(
                            '📋 Daftar Transaksi',
                            controller.exportDaftarTransaksi.value,
                            controller.toggleExportTransaksi,
                          ),
                          _isiCheckbox(
                            '🏆 Produk Terlaris',
                            controller.exportProdukTerlaris.value,
                            controller.toggleExportProduk,
                          ),
                          _isiCheckbox(
                            '💳 Metode Pembayaran',
                            controller.exportMetodePembayaran.value,
                            controller.toggleExportMetode,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Format file
                    const Text(
                      'FORMAT FILE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          _formatCard('PDF', '📕', 'Siap cetak & bagikan'),
                          const SizedBox(width: 8),
                          _formatCard('Excel', '📗', 'Untuk analisis data'),
                          const SizedBox(width: 8),
                          _formatCard('CSV', '📄', 'Format universal'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Preview nama file
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                controller.namaFile,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer dialog
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: controller.tutupExportDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: controller.exportPDF,
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('Export PDF Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Chip pilihan periode di dialog
  Widget _periodeChip(String label) {
    final isActive = controller.selectedPeriode.value == label;
    return GestureDetector(
      onTap: () {
        if (label == 'Custom') {
          controller.selectedPeriode.value = 'Custom';
        } else {
          controller.changePeriode(label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // Checkbox isi laporan di dialog
  Widget _isiCheckbox(String label, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? AppTheme.primaryLight : AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value ? AppTheme.primary : AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: value ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card pilihan format export
  Widget _formatCard(String format, String icon, String desc) {
    final isActive = controller.exportFormat.value == format;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setExportFormat(format),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryLight : AppTheme.bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppTheme.primary : AppTheme.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                format,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppTheme.primary : AppTheme.textPrimary,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
