import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokoku/models/product_model.dart';
import 'package:tokoku/providers/cart_provider.dart';
import 'package:tokoku/screens/pembeli/cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  bool _isAddedToCart = false;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    // Panggil provider di dalam build method agar bisa diakses
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // Menggunakan field 'namaProduk' dari model baru
        title: Text(product.namaProduk),
        backgroundColor: Colors.brown[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menggunakan Image.network untuk memuat gambar dari URL
            Image.network(
              product.linkFoto, // Menggunakan field 'linkFoto' dari Supabase
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              // Menampilkan indikator loading saat gambar sedang diunduh
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              // Menampilkan ikon error jika gambar gagal dimuat
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 80,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menggunakan field 'namaProduk'
                  Text(
                    product.namaProduk,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Menggunakan getter 'formattedPrice'
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.brown[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Menggunakan field 'deskripsi'
                  Text(
                    product.deskripsi,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Komposisi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Menggunakan field 'komposisi'
                  Text(
                    product.komposisi,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(cartProvider),
    );
  }

  Widget _buildBottomActionBar(CartProvider cartProvider) {
    if (_isAddedToCart) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.shopping_cart_checkout),
          label: const Text('Lihat Keranjang'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            foregroundColor: Colors.brown[800],
            side: BorderSide(color: Colors.brown[800]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.brown[700],
                  size: 30,
                ),
                onPressed: _decrementQuantity,
              ),
              Text(
                '$_quantity',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.brown[700],
                  size: 30,
                ),
                onPressed: _incrementQuantity,
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Panggil `addToCart` sebanyak `_quantity`
              for (int i = 0; i < _quantity; i++) {
                cartProvider.addToCart(widget.product);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_quantity}x ${widget.product.namaProduk} ditambahkan!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              // Ubah state untuk mengganti tombol
              setState(() {
                _isAddedToCart = true;
              });
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Tambah ke Keranjang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[800],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
