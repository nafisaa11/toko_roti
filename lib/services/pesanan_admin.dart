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

    return response as List<Map<String, dynamic>>;
  }

  // Nanti kita akan tambahkan fungsi untuk pembeli di sini
}
