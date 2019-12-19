import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';

final _rowFontStyle = TextStyle(fontSize: 18);

class LandingScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Landing _landing;

  LandingScreen(this._landing);

  _buildRow(String key, String val) => Container(
        margin: EdgeInsets.symmetric(vertical: 5),
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
    await Navigator.pushNamed(_scaffoldKey.currentContext, '/create_product',
        arguments: landing);


  }

  _floatingActionButton(onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 220,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Tag Product',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.add_circle_outline),
        onPressed: onPressed,
      ),
    );
  }

  String _lengthLabel() => _landing.individuals > 1 ? 'Length (Average)' : 'Length';

  String _weightLabel() => _landing.individuals > 1 ? 'Weight (Total)' : 'Weight';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton:
          _floatingActionButton(() async => _onPressFloatingActionButton(_landing)),
      appBar: AppBar(
        title: Text('Catch - ${_landing.id}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _buildRow('ID', _landing.id.toString()),
              _buildRow(_weightLabel(), (_landing.weight / 1000).toString() + ' kg'),
              _buildRow(_lengthLabel(), _landing.length.toString() + ' cm'),
              _buildRow('Timestamp', friendlyDateTimestamp(_landing.createdAt)),
              _buildRow('Location', _landing.location.toString()),
              _buildRow('Individuals', _landing.individuals.toString()),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Species',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              _buildRow('English name', _landing.species.englishName),
              _buildRow('Australian name', _landing.species.australianName),
              _buildRow('Scientific name', _landing.species.scientificName),
              _buildRow('Alpha3 Code', _landing.species.alpha3Code),
              _buildRow('Family', _landing.species.family),
              _buildRow('CPC class', _landing.species.cpcClass),
              _buildRow('CPC Group', _landing.species.cpcGroup),
              _buildRow('Major group', _landing.species.majorGroup),
              _buildRow('ISSCAAP group', _landing.species.isscaapGroup),
              _buildRow('Yearbook group', _landing.species.yearbookGroup),
              _buildRow('Caab Code', _landing.species.caabCode),
            ],
          ),
        ),
      ),
    );
  }
}
