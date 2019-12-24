import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/product_list_item.dart';

final _rowFontStyle = TextStyle(fontSize: 18);

class LandingScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Landing _landing;

  LandingScreen(this._landing);

  _buildRow(String key, String val) => Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                key,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                val,
                style: _rowFontStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

  _onPressFloatingActionButton(Landing landing) async {
    // We will pop true if a product was created
    await Navigator.pushNamed(_scaffoldKey.currentContext, '/create_product', arguments: landing);
  }

  _floatingActionButton(onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 165,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Tag',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.add_circle_outline),
        onPressed: onPressed,
      ),
    );
  }

  String _lengthLabel() => _landing.individuals > 1 ? 'Length (Avg)' : 'Length';

  String _weightLabel() => _landing.individuals > 1 ? 'Weight (Total)' : 'Weight';

  // (Catch section)
  Widget _landingSection() {
    return Column(
      children: [
        _buildRow('ID', _landing.id.toString()),
        _buildRow(_weightLabel(), (_landing.weight / 1000).toString() + ' kg'),
        _buildRow(_lengthLabel(), _landing.length.toString() + ' cm'),
        _buildRow('Timestamp', friendlyDateTimestamp(_landing.createdAt)),
        _buildRow('Location', _landing.location.toMultilineString()),
        _buildRow('Individuals', _landing.individuals.toString()),
      ],
    );
  }

  Widget _speciesSection() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(
            'Species',
            style: TextStyle(fontSize: 30),
          ),
        ),
        _buildRow('Australian name', _landing.species.australianName),
        _buildRow('Scientific name', _landing.species.scientificName),
      ],
    );
  }

  Widget _products() {
    final List<Widget> items = _landing.products
        .map((Product p) => ProductListItem(p, () {
              Navigator.pushNamed(_scaffoldKey.currentContext, '/product', arguments: p);
            }))
        .toList();
    return Column(
      children: <Widget>[
        Text(
          'Product Tags',
          style: TextStyle(fontSize: 30),
        ),
        Column(children: items),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool inActiveTrip = _appStore.activeTrip.hauls
            .singleWhere((h) => h.id == _landing.haulId, orElse: () => null) !=
        null;

    return Observer(builder: (_) {
      return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: inActiveTrip
            ? _floatingActionButton(() async => _onPressFloatingActionButton(_landing))
            : null,
        appBar: AppBar(
          title: Text('Shark - ${_landing.id}'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  child: _landingSection(),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: _speciesSection(),
                ),
                Container(
                  child: _products(),
                ),
                Container(height: 100) // So you can scroll past FAB
              ],
            ),
          ),
        ),
      );
    });
  }
}
