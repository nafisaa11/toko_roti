// screens/pembeli/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokoku/services/pesanan_pembeli.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> pesanan;
  final String userRole; // Tambahkan parameter untuk mengetahui role pengguna

  const OrderDetailPage({
    Key? key,
    required this.pesanan,
    required this.userRole, // Jadikan wajib diisi
  }) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final PesananPembeli _PesananPembeli = PesananPembeli();

  // [PERBAIKAN] State untuk mengelola status
  late String _currentStatus;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi status awal dari data yang diterima
    _currentStatus = widget.pesanan['status'];
  }

  /// Fungsi untuk menangani perubahan status oleh admin
  Future<void> _updateStatus(String? newStatus) async {
    if (newStatus == null || newStatus == _currentStatus) return;

    setState(() => _isUpdatingStatus = true);

    try {
      await _PesananPembeli.updateOrderStatus(widget.pesanan['id'], newStatus);
      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status pesanan berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

   @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formatDate = DateFormat('d MMMM yyyy, HH:mm');
    final List<dynamic> detailItems = widget.pesanan['detail_pesanan'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${widget.pesanan['id']}'),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informasi Pesanan'),

            // [PERBAIKAN] Tampilkan dropdown untuk admin, atau teks biasa untuk pembeli
            _buildStatusSection(),

            _buildInfoCard(
              'Tanggal Pesanan',
              formatDate.format(DateTime.parse(widget.pesanan['created_at'])),
              Icons.calendar_today,
            ),
            _buildInfoCard(
              'Alamat Pengiriman',
              widget.pesanan['alamat_pengiriman'] ?? 'Tidak ada alamat',
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Item yang Dipesan'),
            for (var item in detailItems)
              _buildOrderItemTile(item, formatCurrency),
            const SizedBox(height: 24),
            _buildSectionTitle('Ringkasan Pembayaran'),
            _buildSummaryCard(widget.pesanan, formatCurrency),
          ],
        ),
      ),
    );
  }

  // [PERBAIKAN] Widget baru untuk menampilkan status secara kondisional
  Widget _buildStatusSection() {
    // Tampilkan dropdown HANYA jika pengguna adalah admin
    if (widget.userRole == 'admin') {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF8B4513)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentStatus,
                    isExpanded: true,
                    items:
                        <String>[
                          'diproses',
                          'dikirim',
                          'selesai',
                          'dibatalkan',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.toUpperCase()),
                          );
                        }).toList(),
                    onChanged:
                        _isUpdatingStatus
                            ? null
                            : (newValue) {
                              _updateStatus(newValue);
                            },
                  ),
                ),
              ),
              if (_isUpdatingStatus)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      );
    } else {
      // Jika bukan admin, tampilkan seperti biasa
      return _buildInfoCard(
        'Status',
        _currentStatus.replaceAll('_', ' ').toUpperCase(),
        Icons.info_outline,
      );
    }
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
