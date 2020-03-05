import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/forward_arrow.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final Function onPressed;

  ProductListItem({this.product, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey[300]),
              top: BorderSide(color: Colors.grey[300]))),
      padding: EdgeInsets.all(0),
      child: ListTile(
        onTap: onPressed,
        isThreeLine: true,
        leading: Icon(Icons.local_offer, size: 48, color: olracBlue),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              product.tagCode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              product.productType.name,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        subtitle: Text(friendlyDateTime(product.createdAt)),
        trailing: ForwardArrow(),
      ),
    );
  }
}
