import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tokoku/models/cart_item_model.dart';
import 'package:tokoku/providers/cart_provider.dart';
import 'package:tokoku/screens/pembeli/struk.dart';
import 'package:tokoku/services/auth_service.dart';
import 'package:tokoku/services/pesanan_pembeli.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> itemsToCheckout;
  const CheckoutPage({Key? key, required this.itemsToCheckout})
    : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late double _subtotal;
  late double _tax;
  late double _total;
  late int _totalItems;

  final AuthService _authService = AuthService();
  // [PERBAIKAN] Buat instance dari PesananService
  final PesananPembeli _PesananPembeli = PesananPembeli();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateSummary();
    _initializeAnimations();
  }

  void _calculateSummary() {
    _subtotal = widget.itemsToCheckout.fold(
      0,
      (sum, item) => sum + (item.product.harga * item.quantity),
    );
    _tax = _subtotal * 0.11;
    _total = _subtotal + _tax;
    _totalItems = widget.itemsToCheckout.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  // --- [PERBAIKAN] FUNGSI PROSES PESANAN DENGAN ALUR YANG BENAR ---
  Future<void> _processOrder() async {
    setState(() => _isLoading = true);

    try {
      // 1. Dapatkan data yang diperlukan dari profil
      final userProfile = await _authService.getUserProfile();
      final address = userProfile?['alamat'];

      if (address == null || (address as String).isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Alamat belum diatur. Silakan atur di halaman profil.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. Siapkan detail pesanan dalam format JSON
      // Pastikan model Anda punya method toJson() seperti yang disarankan sebelumnya
      final detailPesananJson =
          widget.itemsToCheckout.map((item) => item.toJson()).toList();

      // 3. SIMPAN KE DATABASE terlebih dahulu
      await _PesananPembeli.buatPesananBaru(
        totalHarga: _total,
        subtotal: _subtotal,
        pajak: _tax,
        alamatPengiriman: address,
        detailPesananJson: detailPesananJson,
      );

      // --- Jika berhasil, baru lanjutkan ke langkah berikutnya ---

      // 4. BERSIHKAN KERANJANG LOKAL
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.removeCheckedOutItems(widget.itemsToCheckout);

      if (!mounted) return;

      // 5. PINDAH KE HALAMAN STRUK
      final userEmail = _authService.currentUser?.email ?? 'user';
      final userName = userEmail.split('@')[0];
      final String trxId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => StrukPage(
                orderItems: widget.itemsToCheckout,
                subtotal: _subtotal,
                tax: _tax,
                total: _total,
                transactionId: trxId,
                customerName: userName,
                customerAddress: address,
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses pesanan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ... (SliverAppBar Anda tidak berubah, sudah bagus)
        SliverAppBar(
          // ...
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildOrderItemsCard(),
                const SizedBox(height: 20),
                _buildPaymentSummaryCard(),
                const SizedBox(height: 24),
                _buildCreateOrderButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Bagian Card Header tidak berubah)
          Container(
            //...
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              // Gunakan .map untuk membuat daftar item secara dinamis
              children:
                  widget.itemsToCheckout.map((cartItem) {
                    // Beri jarak antar item kecuali item terakhir
                    return Padding(
                      padding:
                          widget.itemsToCheckout.last == cartItem
                              ? EdgeInsets.zero
                              : const EdgeInsets.only(bottom: 16.0),
                      child: _buildOrderItem(cartItem),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem cartItem) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A574).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // --- PERUBAHAN GAMBAR & HERO TAG ---
          Hero(
            // Gunakan ID produk untuk tag yang unik
            tag: cartItem.product.id.toString(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Gunakan Image.network
              child: Image.network(
                cartItem.product.linkFoto,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.bakery_dining,
                      size: 32,
                      color: Color(0xFF8B4513),
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PERUBAHAN NAMA & DESKRIPSI PRODUK ---
                Text(
                  cartItem.product.namaProduk, // Gunakan 'namaProduk'
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cartItem.product.deskripsi, // Gunakan 'deskripsi'
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  cartItem.product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'x${cartItem.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ... (style decoration tidak berubah)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Header Ringkasan tidak berubah)
          const SizedBox(height: 20),
          _buildSummaryRow(
            'Total $_totalItems Produk',
            formatCurrency.format(_subtotal),
            false,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Pajak (11%)', formatCurrency.format(_tax), false),
          const SizedBox(height: 16),
          // ... (Garis pemisah tidak berubah)
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Total Pembayaran',
            formatCurrency.format(_total),
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? const Color(0xFF8B4513) : const Color(0xFF2C1810),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? const Color(0xFF8B4513) : const Color(0xFF2C1810),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateOrderButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFD4A574)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_checkout,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context) {
    // Panggil provider untuk aksi bersih-bersih
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // ... (style dialog tidak berubah)
          content: Column(
            // ...
            children: [
              // ...
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // AKSI UTAMA DI SINI
                    // 1. Bersihkan item yang sudah di-checkout dari keranjang
                    cartProvider.removeCheckedOutItems(widget.itemsToCheckout);

                    // 2. Tutup dialog dan kembali ke halaman utama
                    // Pop 2x: 1x untuk menutup dialog, 1x untuk menutup CheckoutPage
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  // ... (style tombol tidak berubah)
                  child: const Text('Konfirmasi Pesanan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
