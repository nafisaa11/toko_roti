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

  // [PERBAIKAN] State untuk mengelola data dan status loading halaman
  bool _isPageLoading = true; // Untuk loading awal seluruh halaman
  Map<String, dynamic>? _userProfile;
  String? _displayedAddress; // Untuk menampilkan alamat di UI
  bool _isLocationLoading =
      false; // Khusus untuk loading saat menekan tombol lokasi

  @override
  void initState() {
    super.initState();
    // [PERBAIKAN] Panggil fungsi untuk memuat data profil saat halaman pertama kali dibuka
    _loadUserProfile();
  }

  /// Memuat data profil dari database dan menginisialisasi state.
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          // [PERBAIKAN] Tampilkan alamat dari database sebagai alamat awal
          _displayedAddress = profile?['alamat'];
          _isPageLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPageLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      }
    }
  }

  /// Mendapatkan lokasi saat ini, menyimpannya, dan memperbarui UI.
  Future<void> _getCurrentLocationAndUpdate() async {
    setState(() {
      _isLocationLoading = true;
      _displayedAddress = 'Mendapatkan lokasi...';
    });

    try {
      // 1. Dapatkan posisi (Lat/Lon)
      final position = await _locationService.getCurrentLocation();
      // 2. Ubah posisi menjadi alamat string
      final address = await _locationService.getAddressFromCoordinates(
        position,
      );
      // 3. Simpan alamat baru ke database
      await _authService.updateUserAddress(address);

      // 4. Perbarui state untuk ditampilkan di UI
      if (mounted) {
        setState(() {
          _displayedAddress = address;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Jika gagal, kembalikan ke alamat sebelumnya dari profil
          _displayedAddress =
              _userProfile?['alamat'] ?? 'Gagal mendapatkan lokasi.';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error Lokasi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
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
        // Tombol logout sekarang hanya ada di profil pembeli
        // Jika profil ini juga untuk admin, Anda bisa tambahkan kondisi
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
       body:
          _isPageLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadUserProfile, // Tambahkan fitur pull-to-refresh
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.brown,
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildProfileInfoCard(
                        icon: Icons.email,
                        title: 'Email Pengguna',
                        subtitle: _userProfile?['email'] ?? 'Memuat...',
                      ),
                      const SizedBox(height: 16),

                      // --- KARTU LOKASI YANG SUDAH DIPERBAIKI ---
                      _buildProfileInfoCard(
                        icon: Icons.location_on,
                        title: 'Alamat Saya',
                        // [PERBAIKAN] Tampilkan alamat dari state, atau pesan default jika null
                        subtitle: _displayedAddress ?? 'Alamat belum diatur',
                        trailing:
                            _isLocationLoading
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
                                  onPressed: _getCurrentLocationAndUpdate,
                                ),
                      ),
                      const SizedBox(
                        height: 48,
                      ), // Memberi jarak dari konten di atas

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: () async {
                            // Panggil fungsi signOut dari AuthService
                            await _authService.signOut();
                            // AuthGate akan otomatis menangani navigasi ke halaman login
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
