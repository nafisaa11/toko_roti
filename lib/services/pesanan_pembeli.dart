// services/pesanan_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

// SARAN: Gunakan nama 'PesananService' agar lebih umum dan standar.
class PesananPembeli {
  final _client = Supabase.instance.client;

  /// Menyimpan pesanan baru ke tabel 'pesanan' di Supabase.
  Future<void> buatPesananBaru({
    required double totalHarga,
    required double subtotal,
    required double pajak,
    required String
    alamatPengiriman, // <-- PERBAIKAN 1: Tambahkan parameter ini
    required List<Map<String, dynamic>> detailPesananJson,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Pengguna tidak login!');
    }

    // Persiapkan data untuk dimasukkan ke database
    final pesananData = {
      'user_id': userId,
      'total_harga': totalHarga,
      'subtotal': subtotal,
      'pajak': pajak,
      'alamat_pengiriman':
          alamatPengiriman, // <-- PERBAIKAN 2: Sertakan alamat di data
      'detail_pesanan': detailPesananJson,
      'status': 'diproses',
    };

    // Lakukan insert ke tabel 'pesanan'
    // Jika ada error di sini (misal: karena RLS), ia akan ditangkap oleh blok 'catch' di UI.
    await _client.from('pesanan').insert(pesananData);
  }

  /// Fungsi untuk pembeli melihat riwayat pesanannya sendiri
  Future<List<Map<String, dynamic>>> getPesananKu() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('pesanan')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response as List<Map<String, dynamic>>;
  }

  /// Fungsi untuk admin mengambil semua pesanan
  Future<List<Map<String, dynamic>>> getSemuaPesanan() async {
    final response = await _client
        .from('pesanan')
        .select('*, users(email)')
        .order('created_at', ascending: false);

    return response as List<Map<String, dynamic>>;
  }
}
