import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:sqflite/sqflite.dart';

final _productRepo = ProductRepository();

Future<Product> getProduct(int id) async {
  final Database db = DatabaseProvider().database;
  final List<Map<String, dynamic>> results = await db.query('products', where: 'id= $id');

  if (results.length == 0) {
    return null;
  }
  print(results);
  assert(results.length == 1);
  return _productRepo.fromDatabaseMap(results.first);
}

class ProductScreen extends StatelessWidget {
  final int _productId;

  ProductScreen(this._productId);

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

  Widget buildHasData(AsyncSnapshot snapshot) {
    final Product product = snapshot.data;
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              _detailRow('Timestamp', product.tagCode),
              _detailRow('ID', product.id.toString()),
              _detailRow('Product Type', product.productType.name),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  LocationButton(location: product.location),
                ],
              ),
              _detailRow('Timestamp', friendlyDateTime(product.createdAt)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProduct(_productId),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        final Product product = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text('Product'),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  _detailRow('Tag Code', product.tagCode),
                  _detailRow('ID', product.id.toString()),
                  _detailRow('Product Type', product.productType.name),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Location',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      LocationButton(location: product.location),
                    ],
                  ),
                  _detailRow('Timestamp', friendlyDateTime(product.createdAt)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
