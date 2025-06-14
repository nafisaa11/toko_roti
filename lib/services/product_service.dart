import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokoku/models/product_model.dart'; // Sesuaikan path jika berbeda

class ProductService {
  // Membuat instance dari Supabase client untuk berinteraksi dengan database
  final SupabaseClient _client = Supabase.instance.client;

  /// Fungsi untuk mengambil semua produk dari tabel 'produk' di Supabase.
  /// Mengembalikan sebuah Future yang berisi List<Product>.
  Future<List<Product>> fetchProducts() async {
    try {
      // Melakukan query ke Supabase:
      // 1. .from('produk') -> Memilih tabel bernama 'produk'. PASTIKAN NAMA INI SAMA.
      // 2. .select() -> Mengambil semua kolom (*).
      // 3. .order() -> Mengurutkan hasilnya berdasarkan kolom 'created_at'.
      final response = await _client
          .from('produk')
          .select()
          .order('created_at', ascending: false);

      // Supabase mengembalikan data dalam format List<dynamic>, di mana setiap elemen
      // adalah sebuah Map<String, dynamic>.
      // Kita gunakan .map() untuk mengubah setiap Map menjadi objek Product
      // dengan bantuan factory `Product.fromJson` yang sudah Anda buat.
      final List<Product> products =
          response.map((json) => Product.fromJson(json)).toList();

      return products;
    } catch (e) {
      // Jika terjadi error (misal: tidak ada koneksi, salah nama tabel),
      // kita cetak errornya di console untuk debugging dan lemparkan Exception.
      // Exception ini akan ditangkap oleh FutureBuilder di HomePage.
      print('Error fetching products: $e');
      throw Exception('Gagal mengambil data produk dari server.');
    }
  }

  // NANTINYA FUNGSI-FUNGSI UNTUK ADMIN BISA DITAMBAHKAN DI SINI

  /*
  Future<void> addProduct(Product product) async {
    // Logika untuk menambah produk baru
  }

  Future<void> updateProduct(Product product) async {
    // Logika untuk memperbarui produk
  }

  Future<void> deleteProduct(int productId) async {
    // Logika untuk menghapus produk
  }
  */
}
