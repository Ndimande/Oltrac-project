import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/product_list_item.dart';

class ProductsList extends StatelessWidget {
  final Landing landing;

  ProductsList({this.landing});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = landing.products
      .map<Widget>((Product p) => ProductListItem(p, () {
      Navigator.pushNamed(context, '/product', arguments: p.id);
    }))
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