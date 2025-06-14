// screens/pembeli/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatelessWidget {
  final Map<String, dynamic> pesanan;

  const OrderDetailPage({Key? key, required this.pesanan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper untuk format mata uang
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // Helper untuk format tanggal
    final formatDate = DateFormat('d MMMM yyyy, HH:mm');

    // Mengambil daftar item dari kolom JSONB
    final List<dynamic> detailItems = pesanan['detail_pesanan'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${pesanan['id']}'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informasi Pesanan'),
            _buildInfoCard(
              'Status',
              pesanan['status'].toString().replaceAll('_', ' ').toUpperCase(),
              Icons.info_outline,
            ),
            _buildInfoCard(
              'Tanggal Pesanan',
              formatDate.format(DateTime.parse(pesanan['created_at'])),
              Icons.calendar_today,
            ),
            _buildInfoCard(
              'Alamat Pengiriman',
              pesanan['alamat_pengiriman'] ?? 'Tidak ada alamat',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Item yang Dipesan'),
            // Menampilkan daftar produk yang dipesan
            for (var item in detailItems)
              _buildOrderItemTile(item, formatCurrency),

            const SizedBox(height: 24),
            _buildSectionTitle('Ringkasan Pembayaran'),
            _buildSummaryCard(pesanan, formatCurrency),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C1810),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8B4513)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildOrderItemTile(
    Map<String, dynamic> item,
    NumberFormat formatCurrency,
  ) {
    final product = item['product'];
    final quantity = item['quantity'];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product['link_foto'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(product['nama_produk'] ?? 'Nama Produk Tidak Ada'),
        subtitle: Text(
          '${quantity}x ${formatCurrency.format(product['harga'])}',
        ),
        trailing: Text(
          formatCurrency.format(quantity * product['harga']),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> data,
    NumberFormat formatCurrency,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow(
              'Subtotal',
              formatCurrency.format(data['subtotal'] ?? 0),
            ),
            _buildSummaryRow(
              'Pajak',
              formatCurrency.format(data['pajak'] ?? 0),
            ),
            const Divider(height: 20, thickness: 1),
            _buildSummaryRow(
              'Total',
              formatCurrency.format(data['total_harga'] ?? 0),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
