// screens/admin/admin_kelola_produk_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokoku/models/product_model.dart';
import 'package:tokoku/screens/admin/admin_produk_form_page.dart';
import 'package:tokoku/services/product_service.dart';

class AdminKelolaProdukPage extends StatefulWidget {
  const AdminKelolaProdukPage({Key? key}) : super(key: key);

  @override
  State<AdminKelolaProdukPage> createState() => _AdminKelolaProdukPageState();
}

class _AdminKelolaProdukPageState extends State<AdminKelolaProdukPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _futureProducts = _productService.getProducts();
    });
  }

  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Jika halaman form mengirim 'true', berarti ada perubahan, muat ulang daftar produk
    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(int productId) async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _productService.deleteProduct(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts(); // Muat ulang daftar produk
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Produk'),
        backgroundColor: Colors.brown[700],
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('Belum ada produk. Tekan + untuk menambah.'),
              );
            }

            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.linkFoto,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stack) =>
                                Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(
                      product.namaProduk,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Harga: ${product.formattedPrice} - Stok: ${product.stok}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue.shade700),
                          onPressed:
                              () => _navigateAndRefresh(
                                AdminProdukFormPage(product: product),
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade700),
                          onPressed: () => _deleteProduct(product.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(AdminProdukFormPage()),
        child: Icon(Icons.add),
        backgroundColor: Colors.brown,
      ),
    );
  }
}
