import 'package:aplikasi_kasir/app/core/widgets/app_navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaksi_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/costum_header.dart';

class TransaksiView extends GetView<TransaksiController> {
  const TransaksiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          AppNavbar(activePage: NavPage.transaksi),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Topbar
        CustomHeader(title: 'Riwayat Transaksi'),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat cards
                _buildStatCards(),
                const SizedBox(height: 24),
                // Filter + Tabel
                _buildTableSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Obx(() {
      final all = controller.transactions;
      final totalTrx = all.length;
      final totalPendapatan = all.fold<int>(
        0,
        (sum, t) => sum + ((t['totalAmount'] ?? 0) as int),
      );
      final totalItem = all.fold<int>(
        0,
        (sum, t) => sum + controller.totalItemCount(t['items'] ?? []),
      );

      return Row(
        children: [
          _statCard('Transaksi', '$totalTrx', '+3 dari kemarin', '📋'),
          const SizedBox(width: 16),
          _statCard(
            'Pendapatan',
            controller.formatHarga(totalPendapatan),
            'Total keseluruhan',
            '💰',
          ),
          const SizedBox(width: 16),
          _statCard('Item Terjual', '$totalItem', 'Unit terjual', '🛍️'),
        ],
      );
    });
  }

  Widget _statCard(String label, String value, String sub, String icon) {
    return Expanded(
      child: Container(
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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
            Text(icon, style: const TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header tabel + filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Daftar Transaksi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // Filter Metode
                Obx(
                  () => _filterDropdown(
                    value: controller.filterMetode.value,
                    items: controller.metodeOptions,
                    onChanged: controller.changeFilterMetode,
                  ),
                ),
                const SizedBox(width: 8),
                // Filter Status
                Obx(
                  () => _filterDropdown(
                    value: controller.filterStatus.value,
                    items: controller.statusOptions,
                    onChanged: controller.changeFilterStatus,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => _filterDropdown(
                    value: controller.selectedPeriode.value,
                    items: controller.periodeOptions,
                    onChanged: (val) {
                      if (val == 'Custom') {
                        _showDateRangePicker();
                      } else {
                        controller.changePeriode(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Tabel header
          Container(
            color: AppTheme.bgSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                _THeader('ID TRANSAKSI', flex: 2),
                _THeader('TANGGAL & WAKTU', flex: 3),
                _THeader('ITEM', flex: 1),
                _THeader('TOTAL BAYAR', flex: 2),
                _THeader('METODE', flex: 2),
                _THeader('STATUS', flex: 2),
                _THeader('KASIR', flex: 1),
                _THeader('AKSI', flex: 2),
              ],
            ),
          ),

          // Baris data
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }

            final list = controller.transactions;

            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'Belum ada transaksi',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              );
            }

            return Column(
              children: list.asMap().entries.map((entry) {
                final i = entry.key;
                final t = entry.value;
                final items = t['items'] ?? [];
                final isSelesai = t['status'] == 'selesai';
                final idShort =
                    '#${t['id'].toString().substring(0, 8).toUpperCase()}';

                return Container(
                  decoration: BoxDecoration(
                    color: i.isOdd ? AppTheme.bgSecondary : Colors.white,
                    border: const Border(
                      bottom: BorderSide(color: AppTheme.border),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // ID
                      Expanded(
                        flex: 2,
                        child: Text(
                          idShort,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // Tanggal
                      Expanded(
                        flex: 3,
                        child: Text(
                          controller.formatTanggal(t['createdAt']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // Item
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${controller.totalItemCount(items)} item',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // Total
                      Expanded(
                        flex: 2,
                        child: Text(
                          controller.formatHarga(t['totalAmount'] ?? 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // Metode
                      Expanded(
                        flex: 2,
                        child: _metodeBadge(t['paymentMethod'] ?? ''),
                      ),
                      // Status
                      Expanded(flex: 2, child: _statusBadge(isSelesai)),
                      // Kasir
                      Expanded(
                        flex: 1,
                        child: Text(
                          t['kasirName'] ?? 'Admin',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // Aksi
                      Expanded(
                        flex: 2,
                        child: _actionBtn(
                          'Lihat Detail',
                          onTap: () => _showDetailDialog(t),
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

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary, // warna header & tombol OK
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      controller.setCustomDate(picked.start, picked.end);
    }
  }

  // TAMBAHKAN dua fungsi ini sebelum _filterDropdown():

  void _showDetailDialog(Map<String, dynamic> t) {
    final items = t['items'] as List? ?? [];
    final idShort = '#${t['id'].toString().substring(0, 8).toUpperCase()}';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        idShort,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Info grid: tanggal, kasir, metode
              Row(
                children: [
                  _infoBox('Tanggal', controller.formatTanggal(t['createdAt'])),
                  const SizedBox(width: 10),
                  _infoBox('Kasir', t['kasirName'] ?? 'Admin'),
                  const SizedBox(width: 10),
                  _infoBox('Metode', t['paymentMethod'] ?? '-'),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Item Dibeli',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              // Tabel item
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Header tabel
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: const BoxDecoration(
                        color: AppTheme.bgSecondary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Nama Produk',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Harga Satuan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Qty',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Baris tiap item
                    ...items.asMap().entries.map((e) {
                      final i = e.key;
                      final item = e.value as Map;
                      final harga = (item['priceAtSale'] ?? 0) as int;
                      final qty = (item['quantity'] ?? 0) as int;
                      final subtotal = (item['totalPrice'] ?? 0) as int;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: i.isOdd ? AppTheme.bgSecondary : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: i < items.length - 1
                                  ? AppTheme.border
                                  : Colors.transparent,
                            ),
                          ),
                          // Bulatkan pojok bawah untuk item terakhir
                          borderRadius: i == items.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(8),
                                )
                              : BorderRadius.zero,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                item['productName'] ?? '-',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                controller.formatHarga(harga),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                controller.formatHarga(subtotal),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total bayar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    controller.formatHarga(t['totalAmount'] ?? 0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tombol tutup
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _metodeBadge(String metode) {
    Color bg;
    Color text;
    switch (metode.toLowerCase()) {
      case 'cash':
        bg = const Color(0xFFE1F5EE);
        text = const Color(0xFF085041);
        break;
      case 'transfer':
        bg = const Color(0xFFE6F1FB);
        text = const Color(0xFF0C447C);
        break;
      case 'qris':
        bg = const Color(0xFFEEEDFE);
        text = const Color(0xFF3C3489);
        break;
      default:
        bg = AppTheme.bgSecondary;
        text = AppTheme.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        metode,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _statusBadge(bool selesai) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: selesai ? const Color(0xFFE1F5EE) : const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        selesai ? '✓ Selesai' : '✕ Batal',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selesai ? const Color(0xFF085041) : const Color(0xFFC0392B),
        ),
      ),
    );
  }

  Widget _actionBtn(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Widget header kolom tabel
class _THeader extends StatelessWidget {
  final String text;
  final int flex;
  const _THeader(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.04,
        ),
      ),
    );
  }
}
