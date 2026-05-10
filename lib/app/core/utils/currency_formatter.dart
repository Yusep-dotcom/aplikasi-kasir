class CurrencyFormatter {

  // Format angka jadi Rupiah
  // contoh: 10000 → "Rp 10.000"
  static String format(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  // Parse string Rupiah kembali ke int
  // contoh: "Rp 10.000" → 10000
  static int parse(String formatted) {
    return int.tryParse(
      formatted.replaceAll('Rp ', '').replaceAll('.', ''),
    ) ?? 0;
  }
}