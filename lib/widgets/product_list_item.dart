import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/time_ago.dart';

class ProductListItem extends StatelessWidget {
  final Product _product;
  final Function _onPressed;

  ProductListItem(this._product, this._onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]),top: BorderSide(color: Colors.grey[300]))
      ),
      padding: EdgeInsets.all(0),
      child: ListTile(
        onTap: _onPressed,
        isThreeLine: true,
        leading: Icon(Icons.local_offer, size: 48, color: olracBlue),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _product.tagCode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _product.productType.name,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        subtitle: Text(friendlyDateTime(_product.createdAt)),
        trailing: ForwardArrow(),
      ),
    );
  }
}
