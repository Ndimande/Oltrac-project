import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/product_list_item.dart';

class ProductsList extends StatelessWidget {
  final List<Product> products;

  const ProductsList({this.products});

  Future<void> _onPressed(BuildContext context, Product product) async {
    await Navigator.pushNamed(context, '/product', arguments: {'productId': product.id});
  }

  List<Widget> _productListItems(BuildContext context) => products
      .map<Widget>((Product p) => ProductListItem(product: p, onPressed: () async => await _onPressed(context, p)))
      .toList();

  @override
  Widget build(BuildContext context) {
    final List<Widget> items =
        products.isNotEmpty ? _productListItems(context) : [const ListTile(title: Text('No Product Tags'))];
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Product Tags',
        style: TextStyle(fontSize: 22, color: OlracColours.olspsBlue),
      ),
      children: items,
    );
  }
}
