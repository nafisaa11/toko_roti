// screens/admin/admin_profile_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokoku/services/auth_service.dart';
import 'package:tokoku/services/pesanan_admin.dart'; // Sesuaikan dengan nama file service Anda

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AuthService _authService = AuthService();
  final PesananAdmin _PesananAdmin = PesananAdmin();
  late Future<List<dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Memuat data profil dan statistik secara bersamaan
  Future<void> _loadData() async {
    setState(() {
      _futureData = Future.wait([
        _authService.getUserProfile(),
        _PesananAdmin.getStatistikPesanan(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Dashboard Admin'),
        backgroundColor: Colors.brown[700],
        automaticallyImplyLeading: false, // Menghilangkan tombol back
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: FutureBuilder<List<dynamic>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error memuat data: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('Tidak ada data.'));
            }

            // Unpack data dari Future.wait
            final profileData = snapshot.data![0] as Map<String, dynamic>?;
            final statistikData = snapshot.data![1] as Map<String, dynamic>;

            final formatCurrency = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KARTU INFORMASI ADMIN ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.shield,
                        color: Colors.brown,
                        size: 40,
                      ),
                      title: Text(
                        profileData?['email'] ?? 'Email Admin',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                     
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BAGIAN STATISTIK ---
                  const Text(
                    'Statistik Toko',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Jumlah Pesanan',
                          statistikData['jumlahPesanan'].toString(),
                          Icons.shopping_cart_checkout,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Pendapatan',
                          formatCurrency.format(
                            statistikData['totalPendapatan'],
                          ),
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- TOMBOL LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _authService.signOut();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget helper untuk membuat kartu statistik
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
