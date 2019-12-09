import 'package:flutter/material.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/widgets/screens/create_product.dart';

final _rowFontStyle = TextStyle(fontSize: 18);

class TagScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    await Navigator.push(
      _scaffoldKey.currentContext,
      MaterialPageRoute(
        builder: (context) => CreateProductScreen(),
        settings: RouteSettings(
          arguments: tag,
        ),
      ),
    );
  }

  _floatingActionButton(onPressed) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 220,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Create Product',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.add_circle_outline),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Tag tagArg = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      key: _scaffoldKey,
//      floatingActionButton: _floatingActionButton(() async => _onPressFloatingActionButton(tagArg)),
      appBar: AppBar(
        title: Text('Tag - ${tagArg.tagCode}'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Tag code', tagArg.tagCode),
              _buildRow('Weight', (tagArg.weight / 1000).toString() + ' kg'),
              _buildRow('Length', tagArg.length.toString() + ' cm'),
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
              _buildRow('English name', tagArg.species.englishName),
              _buildRow('Australian name', tagArg.species.australianName),
              _buildRow('Scientific name', tagArg.species.scientificName),
              _buildRow('Alpha3 Code', tagArg.species.alpha3Code),
              _buildRow('Family', tagArg.species.family),
              _buildRow('CPC class', tagArg.species.cpcClass),
              _buildRow('CPC Group', tagArg.species.cpcGroup),
              _buildRow('Major group', tagArg.species.majorGroup),
              _buildRow('ISSCAAP group', tagArg.species.isscaapGroup),
              _buildRow('Yearbook group', tagArg.species.yearbookGroup),
              _buildRow('Caab Code', tagArg.species.caabCode),
            ],
          ),
        ),
      ),
    );
  }
}
