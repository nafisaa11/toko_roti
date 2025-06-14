// services/pesanan_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

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

  Future<String> uploadProductImage(File imageFile) async {
    try {
      // Membuat nama file yang unik berdasarkan waktu saat ini
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      final String filePath =
          'public/$fileName'; // Simpan di dalam folder 'public' di bucket

      // Mengunggah file
      await _client.storage.from('product').upload(filePath, imageFile);

      // Mengambil URL publik dari file yang baru diunggah
      final String publicUrl = _client.storage
          .from('product')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal mengunggah gambar produk.');
    }
  }

  // Nanti kita akan tambahkan fungsi untuk pembeli di sini
}
