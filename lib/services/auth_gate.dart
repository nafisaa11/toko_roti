// auth_gate.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokoku/screens/auth/login.dart';

// --- UBAH IMPORT UNTUK HANYA MENGGUNAKAN MAINLAYOUTPAGE ---
import 'package:tokoku/screens/main_layout_page.dart'; // Halaman layout utama kita
import 'package:tokoku/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          return FutureBuilder<String?>(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                return const LoginPage();
              }

              final role = roleSnapshot.data;

              // --- PERUBAHAN UTAMA: ARAHKAN KE MAINLAYOUTPAGE DENGAN ROLE ---
              if (role == 'admin' || role == 'pembeli') {
                return MainLayoutPage(role: role!);
              } else {
                // Fallback jika role tidak dikenali
                return const LoginPage();
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
