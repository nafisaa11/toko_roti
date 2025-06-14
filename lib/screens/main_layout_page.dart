// screens/main_layout_page.dart

import 'package:flutter/material.dart';
import 'package:tokoku/screens/admin/admin_homepage.dart';
import 'package:tokoku/screens/pembeli/homepage.dart';
import 'package:tokoku/screens/pembeli/profile_page.dart';
import 'package:tokoku/screens/pembeli/riwayat_pesanan_page.dart';
// Tambahkan import untuk halaman lain yang Anda buat
// import 'package:tokoku/screens/pembeli/riwayat_pesanan_page.dart';
// import 'package:tokoku/screens/shared/profile_page.dart';

class MainLayoutPage extends StatefulWidget {
  final String role;
  const MainLayoutPage({Key? key, required this.role}) : super(key: key);

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _selectedIndex = 0;

  // Daftar halaman untuk setiap role
  late final List<Widget> _pages;
  // Daftar item navbar untuk setiap role
  late final List<BottomNavigationBarItem> _navBarItems;

  @override
  void initState() {
    super.initState();
    _setupNavigationForRole(widget.role);
  }

  void _setupNavigationForRole(String role) {
    if (role == 'admin') {
      _pages = [
        const AdminHomePage(), // Halaman daftar pesanan
        const Center(child: Text('Kelola Produk (Admin)')), // Placeholder
        const Center(child: Text('Profil Admin')), // Placeholder
      ];
      _navBarItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      // 'pembeli'
      _pages = [
        const HomePage(), // Halaman utama pembeli
        const RiwayatPesananPage(), // Placeholder
        const ProfilePage(), // Placeholder
      ];
      _navBarItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Pesanan Saya',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman yang sesuai dari daftar _pages
      body: _pages[_selectedIndex],

      // BottomNavigationBar akan dibangun dari daftar _navBarItems
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Anda bisa menambahkan style lain di sini
        // type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
