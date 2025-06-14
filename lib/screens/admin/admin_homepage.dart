// screens/admin/admin_home_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // [PENYESUAIAN] Import untuk format tanggal & mata uang
import 'package:tokoku/screens/pembeli/order_detail_page.dart'; // [PENYESUAIAN] Import halaman detail
import 'package:tokoku/services/auth_service.dart';
import 'package:tokoku/services/pesanan_admin.dart'; // Sesuaikan dengan nama file service Anda

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final PesananAdmin _pesananService = PesananAdmin();
  late Future<List<Map<String, dynamic>>> _futurePesanan;

  Future<void> _navigateToDetail(Map<String, dynamic> pesanan) async {
    // `push` sekarang akan 'menunggu' halaman detail ditutup
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderDetailPage(pesanan: pesanan, userRole: 'admin'),
      ),
    );

    // Jika hasil yang dikirim kembali adalah 'true', muat ulang data pesanan
    if (result == true) {
      _loadPesanan();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  // [PENYESUAIAN] Buat fungsi terpisah untuk memuat data agar bisa dipanggil ulang
  void _loadPesanan() {
    setState(() {
      _futurePesanan = _pesananService.getSemuaPesanan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Daftar Pesanan'),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      // [PENYESUAIAN] Tambahkan RefreshIndicator untuk fitur pull-to-refresh
      body: RefreshIndicator(
        onRefresh: () async => _loadPesanan(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futurePesanan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return LayoutBuilder(
                builder:
                    (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: const Center(
                          child: Text('Belum ada pesanan masuk.'),
                        ),
                      ),
                    ),
              );
            }

            final pesananList = snapshot.data!;
            // [PENYESUAIAN] Siapkan formatter di sini
            final formatCurrency = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );
            final formatDate = DateFormat('d MMM yyyy, HH:mm');

            return ListView.builder(
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final pesanan = pesananList[index];
                final userEmail =
                    pesanan['users']?['email'] ?? 'Email tidak ditemukan';
                final tglPesanan = DateTime.parse(pesanan['created_at']);

                // [PENYESUAIAN] Bungkus Card dengan InkWell agar bisa di-klik
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // [PENYESUAIAN] Navigasi ke halaman detail saat di-klik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => OrderDetailPage(
                                pesanan: pesanan,
                                userRole: 'admin',
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // [PENYESUAIAN] Tampilan email pembeli dibuat lebih menonjol
                              Expanded(
                                child: Text(
                                  userEmail,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // [PENYESUAIAN] Status pesanan dibuat menjadi Chip berwarna
                              _buildStatusChip(pesanan['status']),
                            ],
                          ),
                          const Divider(height: 20, thickness: 1),
                          // [PENYESUAIAN] Format harga dan tanggal
                          Text(
                            'Total Pesanan: ${formatCurrency.format(pesanan['total_harga'])}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal: ${formatDate.format(tglPesanan)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // [PENYESUAIAN] Widget helper untuk membuat Chip status
  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (status) {
      case 'diproses':
        chipColor = Colors.blue.shade700;
        icon = Icons.hourglass_top;
        break;
      case 'dikirim':
        chipColor = Colors.orange.shade700;
        icon = Icons.local_shipping;
        break;
      case 'selesai':
        chipColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'dibatalkan':
        chipColor = Colors.red.shade700;
        icon = Icons.cancel;
        break;
      default: // menunggu_pembayaran
        chipColor = Colors.grey.shade600;
        icon = Icons.payment;
    }

    return Chip(
      avatar: Icon(icon, color: textColor, size: 16),
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    );
  }
}
