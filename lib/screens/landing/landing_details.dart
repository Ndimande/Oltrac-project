import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/location_button.dart';

const double rowFontSize = 16;
const TextStyle _rowFontStyle = const TextStyle(fontSize: rowFontSize);

class LandingDetails extends StatelessWidget {
  final Landing landing;

  LandingDetails({this.landing});

  _buildRow(String key, String val, {bool italic = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              key,
              style: _rowFontStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              val,
              style: _rowFontStyle.copyWith(fontStyle: italic ? FontStyle.italic : FontStyle.normal),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Species Information',
        style: TextStyle(fontSize: 22, color: olracBlue),
      ),
      children: <Widget>[
        _buildRow('Australian name', landing.species.australianName),
        _buildRow('Scientific name', landing.species.scientificName, italic: true),
        _buildRow('Family', landing.species.family),
        _buildRow('Major Group', landing.species.majorGroup),
        _buildRow('3 Alpha Code', landing.species.alpha3Code),
        _buildRow('Caab Code', landing.species.caabCode),
        _buildRow('CPC Class', landing.species.cpcClass),
      ],
    );
  }
}
