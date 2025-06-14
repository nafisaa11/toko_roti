// screens/admin/admin_home_page.dart
import 'package:flutter/material.dart';
import 'package:tokoku/services/auth_service.dart';
import 'package:tokoku/services/pesanan_admin.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final PesananAdmin _pesananService = PesananAdmin();
  late Future<List<Map<String, dynamic>>> _futurePesanan;

  @override
  void initState() {
    super.initState();
    _futurePesanan = _pesananService.getSemuaPesanan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Daftar Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              // AuthGate akan otomatis menangani navigasi ke halaman login
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futurePesanan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada pesanan masuk.'));
          }

          final pesananList = snapshot.data!;

          return ListView.builder(
            itemCount: pesananList.length,
            itemBuilder: (context, index) {
              final pesanan = pesananList[index];
              // Karena kita join dengan users, datanya ada di dalam map
              final userEmail =
                  pesanan['users']?['email'] ?? 'Email tidak ditemukan';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Pesanan dari: $userEmail'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: Rp ${pesanan['total_harga']}'),
                      Text('Status: ${pesanan['status']}'),
                      Text('Tanggal: ${pesanan['created_at']}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
