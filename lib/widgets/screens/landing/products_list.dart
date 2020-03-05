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

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = products
        .map<Widget>((Product p) =>
            ProductListItem(product: p, onPressed: () async => await _onPressed(context, p)))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(
            'Product Tags',
            style: TextStyle(fontSize: 28, color: olracBlue),
          ),
        ),
        Column(children: items),
      ],
    );
  }
}
