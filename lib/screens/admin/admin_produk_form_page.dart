// screens/admin/admin_produk_form_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tokoku/models/product_model.dart';
import 'package:tokoku/services/product_service.dart';

class AdminProdukFormPage extends StatefulWidget {
  final Product? product;
  const AdminProdukFormPage({Key? key, this.product}) : super(key: key);

  @override
  State<AdminProdukFormPage> createState() => _AdminProdukFormPageState();
}

class _AdminProdukFormPageState extends State<AdminProdukFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  bool _isLoading = false;

  late final TextEditingController _namaController;
  late final TextEditingController _hargaController;
  late final TextEditingController _stokController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _komposisiController;

  File? _imageFile;
  String? _imageUrl;

  bool get _isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.product?.namaProduk);
    _hargaController = TextEditingController(
      text: widget.product?.harga.toStringAsFixed(0),
    );
    _stokController = TextEditingController(
      text: widget.product?.stok.toString(),
    );
    _deskripsiController = TextEditingController(
      text: widget.product?.deskripsi,
    );
    _komposisiController = TextEditingController(
      text: widget.product?.komposisi,
    );
    _imageUrl = widget.product?.linkFoto;
  } // <-- [PERBAIKAN] Kurung kurawal penutup untuk initState ada di sini

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    _komposisiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrl ?? '';

      if (_imageFile != null) {
        finalImageUrl = await _productService.uploadProductImage(_imageFile!);
      }

      if (finalImageUrl.isEmpty) {
        throw Exception('Mohon pilih gambar produk.');
      }

      final productData = Product(
        id: widget.product?.id,
        namaProduk: _namaController.text,
        harga: double.tryParse(_hargaController.text) ?? 0.0,
        stok: int.tryParse(_stokController.text) ?? 0,
        deskripsi: _deskripsiController.text,
        komposisi: _komposisiController.text,
        linkFoto: finalImageUrl,
        terjual: widget.product?.terjual ?? 0,
      );

      if (_isEditMode) {
        await _productService.updateProduct(productData);
      } else {
        await _productService.addProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: Colors.brown[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _namaController,
                label: 'Nama Produk',
              ),
              _buildTextFormField(
                controller: _hargaController,
                label: 'Harga',
                keyboardType: TextInputType.number,
              ),
              _buildTextFormField(
                controller: _stokController,
                label: 'Stok',
                keyboardType: TextInputType.number,
              ),
              _buildTextFormField(
                controller: _deskripsiController,
                label: 'Deskripsi',
                maxLines: 3,
              ),
              _buildTextFormField(
                controller: _komposisiController,
                label: 'Komposisi',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                icon:
                    _isLoading
                        ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gambar Produk',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _pickImage,
            child:
                _imageFile != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Text('Gagal memuat gambar'),
                            ),
                      ),
                    )
                    : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Ketuk untuk memilih gambar'),
                        ],
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          if (keyboardType == TextInputType.number &&
              double.tryParse(value) == null) {
            return 'Mohon masukkan angka yang valid';
          }
          return null;
        },
      ),
    );
  }
}
