import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';

class ProductScreen extends StatelessWidget {
  final Product _product;

  ProductScreen(this._product);

  Widget _detailRow(String lhs, String rhs) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            lhs,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            rhs,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product - ${_product.tagCode}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              _detailRow('ID', _product.id.toString()),
              _detailRow('Product Type', _product.productType.name),
              _detailRow('Location', _product.location.toString()),
              _detailRow('Weight', _product.weight.toString()),
              _detailRow('Timestamp', friendlyDateTimestamp(_product.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
