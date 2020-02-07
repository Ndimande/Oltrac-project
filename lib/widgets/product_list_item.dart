import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/time_ago.dart';

class ProductListItem extends StatelessWidget {
  final Product _product;
  final Function _onPressed;

  ProductListItem(this._product, this._onPressed);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: _onPressed,
      child: ListTile(
        isThreeLine: true,
        leading: Icon(Icons.local_offer,size: 48,color: olracBlue,),
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
        subtitle: TimeAgo(
          prefix: 'Added ',
          dateTime: _product.createdAt,
        ),
        trailing: ForwardArrow(),
      ),
    );
  }
}
