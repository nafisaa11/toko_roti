import 'package:flutter/material.dart';
import 'package:tokoku/models/cart_item_model.dart';
import 'package:tokoku/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // --- GETTER (TIDAK ADA PERUBAHAN, SUDAH BENAR) ---
  int get selectedItemsCount => _items.where((item) => item.isSelected).length;
  double get selectedItemsTotalPrice {
    return _items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + (item.product.harga * item.quantity));
  }

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  // --- FUNGSI MANAJEMEN KERANJANG ---

  void addToCart(Product product) {
    // --- PERUBAHAN DI SINI ---
    // Cek apakah produk sudah ada di keranjang berdasarkan ID unik
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex >= 0) {
      // Jika sudah ada, tambah kuantitasnya
      _items[existingItemIndex].quantity++;
    } else {
      // Jika belum ada, tambahkan sebagai item baru
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem cartItem) {
    _items.remove(cartItem);
    notifyListeners();
  }

  void incrementQuantity(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  void decrementQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      removeFromCart(cartItem);
    }
    notifyListeners();
  }

  void toggleSelection(CartItem cartItem) {
    cartItem.isSelected = !cartItem.isSelected;
    notifyListeners();
  }

  void selectAllItems(bool isSelected) {
    for (var item in _items) {
      item.isSelected = isSelected;
    }
    notifyListeners();
  }

  void removeCheckedOutItems(List<CartItem> checkedOutItems) {
    // --- PERUBAHAN DI SINI ---
    // Hapus semua item yang ada di daftar checkedOutItems dari keranjang utama
    for (var checkedOutItem in checkedOutItems) {
      _items.removeWhere(
        // Bandingkan berdasarkan ID unik untuk kepastian
        (item) => item.product.id == checkedOutItem.product.id,
      );
    }
    notifyListeners();
  }
}
