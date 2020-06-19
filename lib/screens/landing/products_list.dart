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

  Widget _noProductTags() {
    return Builder(builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            'No product tags',
            style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(color: Colors.black),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = products.isNotEmpty ? _productListItems(context) : [_noProductTags()];
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Product Tags',
        style: Theme.of(context).accentTextTheme.headline5,
      ),
      children: items,
    );
  }
}
