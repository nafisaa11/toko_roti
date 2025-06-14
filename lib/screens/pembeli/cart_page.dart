import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tokoku/models/cart_item_model.dart';
import 'package:tokoku/providers/cart_provider.dart';
import 'package:tokoku/screens/pembeli/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text(
          'Keranjang Tokoku',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyCartView(context);
          }
          return Column(
            children: [
              _buildInfoBanner(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];
                    return _buildCartItemCard(context, cartItem, cart);
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildSummarySection(),
    );
  }

  Widget _buildEmptyCartView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Keranjang Anda kosong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mulai berbelanja sekarang!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            label: const Text(
              'Mulai Belanja',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    // Di sini Anda bisa mengganti teksnya jika perlu, misal menghapus 'sesuai ukuran'
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      // ... (style decoration tidak berubah)
      child: const Row(
        children: [
          // ...
          Expanded(
            child: Text(
              'Periksa kembali pesanan Anda sebelum checkout',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildCartItemCard(
    BuildContext context,
    CartItem cartItem,
    CartProvider cart,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: cartItem.isSelected,
              onChanged: (value) {
                cart.toggleSelection(cartItem);
              },
              activeColor: const Color(0xFF8B4513),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Image
         ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // Gunakan Image.network dengan linkFoto dari model Supabase
            child: Image.network(
              cartItem.product.linkFoto,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              // Tambahkan error handling untuk gambar
              errorBuilder:
                  (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PERUBAHAN NAMA PRODUK ---
                Text(
                  cartItem.product.namaProduk, // Gunakan 'namaProduk'
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cartItem.product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Right side controls
          Column(
            children: [
              // Delete button
              GestureDetector(
                onTap: () => cart.removeFromCart(cartItem),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => cart.decrementQuantity(cartItem),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    cartItem.quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => cart.incrementQuantity(cartItem),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B4513),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) return const SizedBox.shrink();

        final formatCurrency = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BAGIAN KIRI: Pilih Semua
              Row(
                children: [
                  Checkbox(
                    value: cart.isAllSelected,
                    onChanged: (value) {
                      cart.selectAllItems(value!);
                    },
                    activeColor: const Color(0xFF8B4513),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pilih Semua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '(${cart.selectedItemsCount}/${cart.items.length})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),

              // BAGIAN KANAN: Total & Tombol
              // Gunakan Expanded untuk mengisi sisa ruang dan mencegah overflow
              Expanded(
                child: Row(
                  // Buat konten rapat ke kanan
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Total Pembayaran
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency.format(cart.selectedItemsTotalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Tombol Pesan Sekarang
                    ElevatedButton(
                     onPressed:
                          cart.selectedItemsCount > 0
                              ? () {
                                // 1. Ambil daftar item yang sedang dipilih
                                final itemsToCheckout =
                                    cart.items
                                        .where((item) => item.isSelected)
                                        .toList();

                                // 2. Navigasi ke CheckoutPage sambil mengirim data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CheckoutPage(
                                          itemsToCheckout: itemsToCheckout,
                                        ),
                                  ),
                                );
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Pesan', // Dibuat lebih pendek agar muat
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
