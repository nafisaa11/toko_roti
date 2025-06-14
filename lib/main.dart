import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokoku/providers/cart_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tokoku/screens/pembeli/homepage.dart';
import 'package:tokoku/screens/pembeli/main_page.dart';
import 'package:tokoku/services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // --- TAMBAHKAN BLOK KODE INI ---
  await Supabase.initialize(
    url: 'https://namsmqlsgletflprfurx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hbXNtcWxzZ2xldGZscHJmdXJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1OTY0OTgsImV4cCI6MjA2MjE3MjQ5OH0.2HUS3jzQgs8T5IuOEpzHqSfS4_2nnYyTxrAGpE86nBI', // Ganti dengan anon key Anda yang sebenarnya
  );
  // --------------------------------

  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokoku',
      theme: ThemeData(primarySwatch: Colors.brown),
      // --- PERUBAHAN DI SINI ---
      // Jadikan AuthGate sebagai halaman pertama yang dibuka
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
