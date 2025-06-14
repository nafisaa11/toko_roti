// services/product_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokoku/models/product_model.dart'; // Pastikan path model ini benar

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fungsi untuk mengambil semua produk dari tabel 'produk'.
  /// Ini sudah benar dan tidak perlu diubah.
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('produk')
          .select()
          .order('created_at', ascending: false);

      final List<Product> products =
          response.map((json) => Product.fromJson(json)).toList();

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Gagal mengambil data produk dari server.');
    }
  }

  // --- [PENYESUAIAN] IMPLEMENTASI FUNGSI CRUD UNTUK ADMIN ---

  /// Menambahkan produk baru ke database.
  Future<void> addProduct(Product product) async {
    try {
      // Menggunakan method toInsert() dari model Product Anda,
      // yang secara otomatis hanya menyertakan field yang diperlukan untuk insert.
      await _client.from('produk').insert(product.toInsert());
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Gagal menambahkan produk baru.');
    }
  }

  /// Mengupdate produk yang sudah ada di database.
  Future<void> updateProduct(Product product) async {
    try {
      // Menggunakan method toUpdate() dari model Product Anda,
      // yang menyertakan 'updated_at' dan field lain yang bisa diubah.
      await _client
          .from('produk')
          .update(product.toUpdate())
          .eq(
            'id',
            product.id!,
          ); // Klausa WHERE untuk menargetkan produk yang benar
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Gagal memperbarui produk.');
    }
  }

  /// Menghapus produk dari database berdasarkan ID-nya.
  Future<void> deleteProduct(int productId) async {
    try {
      await _client
          .from('produk')
          .delete()
          .eq(
            'id',
            productId,
          ); // Klausa WHERE untuk menghapus produk yang benar
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Gagal menghapus produk.');
    }
  }
}
