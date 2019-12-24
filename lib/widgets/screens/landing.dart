import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/product_list_item.dart';

final _rowFontStyle = TextStyle(fontSize: 18);

class LandingScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Landing _landingArg;

  LandingScreen(this._landingArg);

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

  String _lengthLabel(landing) => landing.individuals > 1 ? 'Length (Avg)' : 'Length';

  String _weightLabel(landing) => landing.individuals > 1 ? 'Weight (Total)' : 'Weight';

  // (Catch section)
  Widget _landingSection(landing) {
    return Column(
      children: [
        _buildRow('ID', landing.id.toString()),
        _buildRow(_weightLabel(landing), (landing.weight / 1000).toString() + ' kg'),
        _buildRow(_lengthLabel(landing), landing.length.toString() + ' cm'),
        _buildRow('Timestamp', friendlyDateTimestamp(landing.createdAt)),
        _buildRow('Location', landing.location.toMultilineString()),
        _buildRow('Individuals', landing.individuals.toString()),
      ],
    );
  }

  Widget _speciesSection(landing) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(
            'Species',
            style: TextStyle(fontSize: 30),
          ),
        ),
        _buildRow('Australian name', landing.species.australianName),
        _buildRow('Scientific name', landing.species.scientificName),
      ],
    );
  }

  Widget _products(landing) {
    final List<Widget> items = landing.products
        .map<Widget>((Product p) => ProductListItem(p, () {
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

    return Observer(builder: (_) {
      // We need to be sure not to use the stale data from
      // the item pushed as an argument
      // It would be wise to push an int instead and always retrieve
      // the item from global state.
    Haul haul = _appStore.activeTrip.hauls
        .singleWhere((h) => h.id == _landingArg.haulId, orElse: () => null);

    final Landing landing = haul.landings.singleWhere((Landing l) => l.id == _landingArg.id);

      return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: haul != null
            ? _floatingActionButton(() async => _onPressFloatingActionButton(landing))
            : null,
        appBar: AppBar(
          title: Text('Shark - ${landing.id}'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  child: _landingSection(landing),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: _speciesSection(landing),
                ),
                Container(
                  child: _products(landing),
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
