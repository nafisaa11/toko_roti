import 'package:flutter/material.dart';
import 'package:tokoku/models/product_model.dart';
import 'package:tokoku/services/product_service.dart'; // Import service
import 'package:tokoku/widgets/home/category_tabs.dart';
import 'package:tokoku/widgets/home/home_header.dart';
import 'package:tokoku/widgets/home/product_grid.dart';
import 'package:tokoku/widgets/home/promo_banner.dart';
import 'package:tokoku/widgets/home/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Semua';

  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
            const SearchBarWidget(),
            const PromoBanner(),
            CategoryTabs(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada produk.'));
                  }
                  final products = snapshot.data!;
                  return ProductGrid(products: products);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
