import 'package:flutter/material.dart';
import 'package:tokoku/screens/pembeli/Homepage.dart';
import 'package:tokoku/screens/pembeli/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // State untuk melacak tab/halaman mana yang sedang aktif
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  static const List<Widget> _pages = <Widget>[
    HomePage(), // Index 0
    ProfilePage(), // Index 1
  ];

  // Fungsi yang akan dipanggil saat salah satu tab ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman sesuai dengan _selectedIndex
      body: Center(child: _pages.elementAt(_selectedIndex)),

      // Definisikan BottomNavigationBar di sini
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex, // Tab yang sedang aktif
        selectedItemColor: Colors.brown[800], // Warna ikon tab aktif
        unselectedItemColor: Colors.grey, // Warna ikon tab tidak aktif
        onTap: _onItemTapped, // Panggil fungsi saat tab ditekan
        type: BottomNavigationBarType.fixed, // Agar label selalu terlihat
      ),
    );
  }
}
