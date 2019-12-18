import 'package:flutter/material.dart';
import 'package:oltrace/models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product _product;
final Function _onPressed;

  ProductListItem(this._product, this._onPressed);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: FlatButton(
        onPressed: _onPressed,
        child: ListTile(
          leading: Icon(Icons.local_offer),
          title: Text(
            _product.tagCode,
            style: TextStyle(fontSize: 18),
          ),
          subtitle: Text(
            _product.productType.name,
            style: TextStyle(fontSize: 16),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
      ),
    );
  }
}