import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/location_button.dart';

class ProductScreen extends StatelessWidget {
  final Product _product;

  ProductScreen(this._product);

  Widget _detailRow(String lhs, String rhs) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
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
        title: Text('Product Tag ${_product.tagCode}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              _detailRow('ID', _product.id.toString()),
              _detailRow('Product Type', _product.productType.name),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  LocationButton(location: _product.location),
                ],
              ),
              _detailRow('Timestamp', friendlyDateTime(_product.createdAt)),
            ],
          ),
        ),
      ),
    );
  }
}
