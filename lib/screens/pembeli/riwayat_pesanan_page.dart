// screens/pembeli/riwayat_pesanan_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokoku/screens/pembeli/order_detail_page.dart';
import 'package:tokoku/services/pesanan_pembeli.dart';

class RiwayatPesananPage extends StatefulWidget {
  const RiwayatPesananPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPesananPage> createState() => _RiwayatPesananPageState();
}

class _RiwayatPesananPageState extends State<RiwayatPesananPage> {
  final PesananPembeli _PesananPembeli = PesananPembeli();
  late Future<List<Map<String, dynamic>>> _futurePesanan;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  void _loadPesanan() {
    _futurePesanan = _PesananPembeli.getPesananKu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan Saya'),
        backgroundColor: const Color(0xFF8B4513),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadPesanan();
          });
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futurePesanan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Terjadi error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Anda belum memiliki riwayat pesanan.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final pesananList = snapshot.data!;
            final formatCurrency = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );

            return ListView.builder(
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final pesanan = pesananList[index];
                final status = pesanan['status'].toString().replaceAll(
                  '_',
                  ' ',
                );
                final tglPesanan = DateTime.parse(pesanan['created_at']);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => OrderDetailPage(pesanan: pesanan),
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
                              Text(
                                'Pesanan #${pesanan['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(DateFormat('d MMM yyyy').format(tglPesanan)),
                            ],
                          ),
                          const Divider(height: 20),
                          Text(
                            'Total: ${formatCurrency.format(pesanan['total_harga'])}',
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
}
