import 'package:flutter/material.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/product_list_item.dart';

class ProductsScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  Widget _productList(List<Product> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final Product product = items[index];

        return ProductListItem(product, () async {
          await Navigator.pushNamed(
            context,
            '/product',
            arguments: product,
          );
        });
      },
    );
  }

  Widget _empty() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No product tags yet',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _appStore.products.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Tags'),
      ),
      body: items.length > 0 ? _productList(items) : _empty(),
    );
  }
}
