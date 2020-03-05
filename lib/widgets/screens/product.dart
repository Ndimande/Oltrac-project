import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:sqflite/sqflite.dart';

final _productRepo = ProductRepository();
final _landingRepo = LandingRepository();

final Database db = DatabaseProvider().database;

Future<Product> getProduct(int id) async {
  final List<Map<String, dynamic>> results = await db.query('products', where: 'id= $id');

  if (results.length == 0) {
    return null;
  }
  assert(results.length == 1);
  final Product product = _productRepo.fromDatabaseMap(results.first);
  final List<Landing> landings = await _getLandings(id);
  return product.copyWith(landings: landings);
}

Future<List<Landing>> _getLandings(int productId) async {
  final List<Map> results =
      await db.query('product_has_landings', where: 'product_id = $productId');

  List landings = <Landing>[];
  for (Map<String, dynamic> result in results) {
    final int landingId = result['landing_id'];
    final List<Map> landingResults = await db.query('landings', where: 'id = $landingId');
    if (landingResults.length != 0) {
      final Landing landing = _landingRepo.fromDatabaseMap(landingResults.first);
      landings.add(landing);
    }
  }

  return landings;
}

class ProductScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final int productId;

  ProductScreen({this.productId});

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

  Widget sourceLandings(List<Landing> landings) => ListView.builder(
      itemCount: landings.length,
      itemBuilder: (BuildContext context, int index) {
        return LandingListItem(
          landing: landings[index],
          listIndex: index,
          onPressed: null,
        );
      });

  Future<void> _onPressLanding(Landing landing, int landingIndex) async {

    assert(landing.id != null);
    assert(landingIndex != null);

    await Navigator.pushNamed(_scaffoldKey.currentContext, '/landing', arguments: {
      'landingId': landing.id,
      'listIndex': landingIndex,
    });
  }

  Widget scrollViewChild(Product product) {
    int listIndex = 1;
    final List<Widget> items = product.landings
        .map<Widget>((Landing l) => LandingListItem(
            landing: l,
            listIndex: listIndex++,
            onPressed: (int index) async => await _onPressLanding(l, listIndex)))
        .toList();

    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          _detailRow('Tag Code', product.tagCode),
          _detailRow('ID', product.id.toString()),
          _detailRow('Product Type', product.productType.name),
          _detailRow('Packaging Type', product.packagingType.name),
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
          Column(children: items),
//          Container(child: sourceLandings(product.landings),),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProduct(productId),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }

        final Product product = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text('Product'),
            key: _scaffoldKey,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                  child: SingleChildScrollView(
                child: scrollViewChild(product),
              ))
            ],
          ),
        );
      },
    );
  }
}
