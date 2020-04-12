import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/product_list_item.dart';

class ProductsList extends StatelessWidget {
  final List<Product> products;

  ProductsList({this.products});

  Future<void> _onPressed(BuildContext context, Product product) async {
    await Navigator.pushNamed(context, '/product', arguments: {'productId': product.id});
  }

  List<Widget> _productListItems(BuildContext context) => products
    .map<Widget>((Product p) => ProductListItem(product: p, onPressed: () async => await _onPressed(context, p)))
    .toList();

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = products.length > 0 ? _productListItems(context) : [ListTile(title: Text('No Product Tags'),)];
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Product Tags',
        style: TextStyle(fontSize: 22, color: olracBlue),
      ),
      children: items,
    );
  }
}
