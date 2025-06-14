// services/product_service.dart

import 'dart:io'; // Import dart:io untuk menggunakan tipe data File
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokoku/models/product_model.dart'; // Pastikan path model ini benar

class ProductService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Mengambil semua produk dari database.
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .from('produk')
          .select()
          .order('created_at', ascending: false);
      return response.map((map) => Product.fromJson(map)).toList();
    } catch (e) {
      print('Error getProducts: $e');
      throw Exception('Gagal mengambil data produk.');
    }
  }

  /// Menambahkan produk baru ke database.
  Future<void> addProduct(Product product) async {
    try {
      await _client.from('produk').insert(product.toInsert());
    } catch (e) {
      print('Error addProduct: $e');
      throw Exception('Gagal menambahkan produk baru.');
    }
  }

  /// Mengupdate produk yang sudah ada di database.
  Future<void> updateProduct(Product product) async {
    try {
      await _client
          .from('produk')
          .update(product.toUpdate())
          .eq('id', product.id!);
    } catch (e) {
      print('Error updateProduct: $e');
      throw Exception('Gagal memperbarui produk.');
    }
  }

  /// Menghapus produk dari database berdasarkan ID-nya.
  Future<void> deleteProduct(int productId) async {
    try {
      await _client.from('produk').delete().eq('id', productId);
    } catch (e) {
      print('Error deleteProduct: $e');
      throw Exception('Gagal menghapus produk.');
    }
  }

  // --- INI FUNGSI YANG HILANG YANG MENYEBABKAN ERROR ---
  /// Mengunggah gambar produk ke Supabase Storage dan mengembalikan URL publiknya.
  Future<String> uploadProductImage(File imageFile) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';

      // [PERBAIKAN] Ubah 'public' menjadi 'cookies' sesuai nama folder Anda
      final String filePath = '$fileName';

      // Mengunggah file ke bucket 'product' di dalam folder 'cookies'
      await _client.storage.from('products').upload(filePath, imageFile);

      // Mengambil URL publik dari file yang baru diunggah
      final String publicUrl = _client.storage
          .from('products')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal mengunggah gambar produk.');
    }
  }
}
