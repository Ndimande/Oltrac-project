import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/tag.dart';

final _rowFontStyle = TextStyle(fontSize: 18);

class TagScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Tag _tag;

  TagScreen(this._tag);

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

  _onPressFloatingActionButton(Tag tag) async {
    var created =
        await Navigator.pushNamed(_scaffoldKey.currentContext, '/create_product', arguments: tag);
    if (created == true) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Product Tag saved.'),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _floatingActionButton(() async => _onPressFloatingActionButton(_tag)),
      appBar: AppBar(
        title: Text('Tag - ${_tag.tagCode}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _buildRow('Tag code', _tag.tagCode),
              _buildRow('Weight', (_tag.weight / 1000).toString() + ' kg'),
              _buildRow('Length', _tag.length.toString() + ' cm'),
              _buildRow('Timestamp', friendlyDateTimestamp(_tag.createdAt)),
              _buildRow('Location', _tag.location.toString()),
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
              _buildRow('English name', _tag.species.englishName),
              _buildRow('Australian name', _tag.species.australianName),
              _buildRow('Scientific name', _tag.species.scientificName),
              _buildRow('Alpha3 Code', _tag.species.alpha3Code),
              _buildRow('Family', _tag.species.family),
              _buildRow('CPC class', _tag.species.cpcClass),
              _buildRow('CPC Group', _tag.species.cpcGroup),
              _buildRow('Major group', _tag.species.majorGroup),
              _buildRow('ISSCAAP group', _tag.species.isscaapGroup),
              _buildRow('Yearbook group', _tag.species.yearbookGroup),
              _buildRow('Caab Code', _tag.species.caabCode),
            ],
          ),
        ),
      ),
    );
  }
}
