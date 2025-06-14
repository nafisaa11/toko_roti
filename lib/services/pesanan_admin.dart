// services/pesanan_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananAdmin {
  final _client = Supabase.instance.client;

  // Fungsi untuk admin mengambil semua pesanan
  // Kita juga mengambil email pembeli menggunakan join!
  Future<List<Map<String, dynamic>>> getSemuaPesanan() async {
    final response = await _client
        .from('pesanan')
        .select(
          '*, users(email)',
        ) // Ambil semua kolom dari pesanan DAN email dari tabel users
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getStatistikPesanan() async {
    // Ambil hanya kolom yang kita butuhkan untuk statistik agar lebih efisien
    final response = await _client
        .from('pesanan')
        .select('total_harga, status');

    // Inisialisasi variabel
    double totalPendapatan = 0;
    int jumlahPesanan = response.length;

    // Hitung total pendapatan
    if (response.isNotEmpty) {
      totalPendapatan = response.fold(0.0, (sum, order) {
        final harga = order['total_harga'] ?? 0;
        return sum + (harga is int ? harga.toDouble() : harga);
      });
    }

    // Mengembalikan hasil dalam bentuk Map
    return {'jumlahPesanan': jumlahPesanan, 'totalPendapatan': totalPendapatan};
  }

  // Nanti kita akan tambahkan fungsi untuk pembeli di sini
}
