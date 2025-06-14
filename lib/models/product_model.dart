import 'package:intl/intl.dart';

class Product {
  final int? id;
  final String namaProduk;
  final double harga;
  final int stok;
  final int terjual;
  final String komposisi;
  final String deskripsi;
  final String linkFoto;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isNew;

  Product({
    this.id,
    required this.namaProduk,
    required this.harga,
    required this.stok,
    required this.komposisi,
    required this.deskripsi,
    required this.linkFoto,
    required this.terjual,
    this.createdAt,
    this.updatedAt,
    this.isNew = false, // default false
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      namaProduk: json['nama_produk'] ?? '',
      harga: _parseDouble(json['harga']),
      stok: json['stok'] ?? 0,
      komposisi: json['komposisi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      linkFoto: json['link_foto'] ?? '',
      terjual: json['terjual'] ?? 0,
      isNew: json['is_new'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Helper method untuk parsing harga yang bisa berupa int atau double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Method untuk menentukan apakah produk baru berdasarkan tanggal
  bool get isNewProduct {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inDays <= 7; // Produk dianggap baru jika kurang dari 7 hari
  }

  // Copy with method untuk membuat instance baru dengan beberapa field yang diubah
  Product copyWith({
    int? id,
    String? namaProduk,
    double? harga,
    int? stok,
    int? terjual,
    String? komposisi,
    String? deskripsi,
    String? linkFoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isNew,
  }) {
    return Product(
      id: id ?? this.id,
      namaProduk: namaProduk ?? this.namaProduk,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      terjual: terjual ?? this.terjual,
      komposisi: komposisi ?? this.komposisi,
      deskripsi: deskripsi ?? this.deskripsi,
      linkFoto: linkFoto ?? this.linkFoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'terjual': terjual,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'link_foto': linkFoto,
      'is_new': isNew,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Method untuk insert ke Supabase
  Map<String, dynamic> toInsert() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'terjual': terjual,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'link_foto': linkFoto,
      'is_new': isNew,
    };
  }

  // Method untuk update ke Supabase
  Map<String, dynamic> toUpdate() {
    return {
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
      'terjual': terjual,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'link_foto': linkFoto,
      'is_new': isNew,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String get formattedPrice {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(harga); // 'harga' adalah field double Anda
  }
}