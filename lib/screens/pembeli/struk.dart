import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokoku/models/cart_item_model.dart';

class StrukPage extends StatelessWidget {
  // Terima semua data yang relevan dari halaman checkout
  final List<CartItem> orderItems;
  final double subtotal;
  final double tax;
  final double total;
  final String transactionId;
  final String customerName;
  final String customerAddress;

  const StrukPage({
    Key? key,
    required this.orderItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.transactionId,
    required this.customerName,
    required this.customerAddress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formattedDate = DateFormat(
      'd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(DateTime.now());
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFD2691E), // Warna coklat
      appBar: AppBar(
        backgroundColor: const Color(0xFFD2691E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          // Menggunakan popUntil agar kembali ke halaman paling awal (HomePage)
          onPressed:
              () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text(
          'Struk Pembayaran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              // Menggunakan Expanded agar SingleChildScrollView mengisi ruang yang tersedia
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReceiptHeader(), // Header dipisah agar lebih rapi
                        const SizedBox(height: 30),
                        _buildInfoRow('Nama Pembeli', customerName),
                        _buildInfoRow(
                          'Alamat Pengiriman',
                          customerAddress,
                          isAddress: true,
                        ),
                        _buildInfoRow('No. Struk', transactionId),
                        _buildInfoRow('Tanggal', formattedDate),
                        const SizedBox(height: 20),
                        _buildProductTableHeader(),
                        // Daftar produk dinamis
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderItems.length,
                          itemBuilder: (context, index) {
                            final item = orderItems[index];
                            return _buildProductRow(item);
                          },
                          separatorBuilder:
                              (context, index) => const Divider(
                                height: 24,
                                color: Colors.black12,
                              ),
                        ),
                        const SizedBox(height: 20),
                        _buildSummarySection(formatCurrency),
                        const SizedBox(height: 30),
                        _buildThankYouMessage(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tombol Selesai
              _buildFinishButton(context),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget-widget privat untuk kerapian kode ---

  Widget _buildReceiptHeader() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4513),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.coffee, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tokoku', // Ganti nama toko jika perlu
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Jl. Kertajaya Indah No.4, Surabaya',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Text(
            'Telp: 0877-7777-7777',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'PRODUK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'JML',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'HARGA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'TOTAL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(CartItem item) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final itemTotal = item.product.harga * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            // --- PERUBAHAN DI SINI ---
            child: Text(
              item
                  .product
                  .namaProduk, // Menggunakan 'namaProduk' dari model baru
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'x${item.quantity}',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatCurrency.format(item.product.harga), // Menggunakan 'harga'
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatCurrency.format(itemTotal),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(NumberFormat formatCurrency) {
    int totalItems = orderItems.fold(0, (sum, item) => sum + item.quantity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($totalItems Produk)',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                formatCurrency.format(subtotal),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pajak (11%)', style: TextStyle(fontSize: 14)),
              Text(
                formatCurrency.format(tax),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL PEMBAYARAN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                formatCurrency.format(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB6C1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.favorite, color: Color(0xFF8B4513), size: 32),
          SizedBox(height: 12),
          Text(
            'Terima Kasih!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Pesanan Anda telah berhasil.\nSilakan lakukan pembayaran di kasir!',
            style: TextStyle(fontSize: 14, color: Color(0xFF8B4513)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2F4F2F), // Dark green color
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Selesai & Kembali ke Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
