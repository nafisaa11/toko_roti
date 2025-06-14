import 'package:flutter/material.dart';
import 'package:tokoku/services/auth_service.dart';
import 'package:tokoku/services/location_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  // State untuk menyimpan alamat dalam bentuk String, bukan lagi Position
  String? _currentAddress;
  bool _isLoadingLocation = false;

  // Fungsi ini sekarang melakukan 2 langkah: get coordinate -> get address
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _currentAddress = 'Mendapatkan lokasi...'; // Beri feedback ke user
    });

    try {
      // 1. Dapatkan posisi (Lat/Lon) dari geolocator
      final position = await _locationService.getCurrentLocation();

      // 2. Ubah posisi tersebut menjadi alamat menggunakan geocoding
      final address = await _locationService.getAddressFromCoordinates(
        position,
      );
      await _authService.updateUserAddress(address);

      // 3. Perbarui state dengan alamat yang sudah jadi
      setState(() {
        _currentAddress = address;
      });
    } catch (e) {
      // Tangani error dari kedua proses di atas
      setState(() {
        _currentAddress = 'Gagal mendapatkan lokasi.';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      // Selalu hentikan loading indicator
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.brown[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _authService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat data profil.'));
          }

          final userProfile = snapshot.data!;
          final userEmail = userProfile['email'] ?? 'Tidak ada email';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.brown,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 24),

                _buildProfileInfoCard(
                  icon: Icons.email,
                  title: 'Email Pengguna',
                  subtitle: userEmail,
                ),
                const SizedBox(height: 16),

                // --- KARTU LOKASI YANG SUDAH DIPERBARUI ---
                _buildProfileInfoCard(
                  icon: Icons.location_on,
                  title: 'Alamat Saya',
                  // Tampilkan alamat jika sudah ada, jika tidak, tampilkan pesan default
                  subtitle:
                      _currentAddress ??
                      'Tekan tombol untuk mendapatkan lokasi',
                  trailing:
                      _isLoadingLocation
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.brown,
                            ),
                          )
                          : IconButton(
                            icon: const Icon(
                              Icons.my_location,
                              color: Colors.brown,
                            ),
                            onPressed: _getCurrentLocation,
                          ),
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () async {
                      await _authService.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
