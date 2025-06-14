// models/cart_item_model.dart

import 'package:tokoku/models/product_model.dart'; // Pastikan path import ini benar

class CartItem {
  final Product product;
  int quantity;
  bool isSelected; // Di kode Anda sebelumnya, ini bernama 'isSelected'

  CartItem({required this.product, this.quantity = 1, this.isSelected = true});

  // --- TAMBAHKAN METHOD INI ---
  /// Mengubah objek CartItem menjadi format Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      // Penting: Panggil juga .toJson() dari objek product
      // untuk membuat data JSON yang bersarang (nested).
      'product': product.toJson(),
    };
  }
}
