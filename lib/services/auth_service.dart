import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // AuthService.dart - KONSEP, JANGAN LANGSUNG DIGUNAKAN DI CLIENT
  Future<void> signUp({required String email, required String password}) async {
    // Langkah 1: Buat user di sistem Auth
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
    );

    // Pastikan pengguna berhasil dibuat di Auth sebelum lanjut
    if (res.user != null) {
      // Langkah 2: Coba masukkan profil ke tabel 'users'
      try {
        final String role = email.endsWith('@admin.com') ? 'admin' : 'pembeli';
        await _client.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'role': role,
        });
      } catch (error) {
        // Jika GAGAL memasukkan profil, idealnya kita hapus user auth yang baru dibuat
        // Namun, ini operasi admin yang berisiko di client-side.
        // Jadi, kita cukup lempar error agar UI tahu ada masalah.
        print('Error saat insert profil: $error');
        throw Exception('Gagal membuat profil pengguna setelah sign up.');
      }
    } else {
      throw Exception('Gagal mendaftarkan pengguna di sistem autentikasi.');
    }
  }
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<String?> getUserRole() async {
    if (currentUser == null) return null;
    try {
      final response =
          await _client
              // --- PERUBAHAN DI SINI: Mengambil data dari tabel 'users' ---
              .from('users')
              .select('role')
              .eq('id', currentUser!.id)
              .single();

      return response['role'];
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    try {
      final response =
          await _client
              .from('users')
              .select() // Ambil semua kolom
              .eq('id', currentUser!.id)
              .single();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserAddress(String address) async {
    if (currentUser == null) return;

    await _client
        .from('users') // atau 'profiles'
        .update({'alamat': address})
        .eq('id', currentUser!.id);
  }
}
