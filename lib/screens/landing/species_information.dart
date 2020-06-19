import 'package:flutter/material.dart';
import 'package:oltrace/models/landing.dart';

class SpeciesInformation extends StatelessWidget {
  final Landing landing;

  const SpeciesInformation({this.landing});

  Widget _buildRow(String key, String val, {bool italic = false}) {
    return Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        child: Column(
          children: [
            // LHS
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
            // RHS
            Row(
              children: [
                Text(
                  val,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontStyle: italic ? FontStyle.italic : FontStyle.normal),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(
        'Species Information',
        style: Theme.of(context).accentTextTheme.headline5,
      ),
      children: <Widget>[
        _buildRow('Australian name', landing.species.australianName),
        _buildRow('Scientific name', landing.species.scientificName, italic: true),
        _buildRow('Family', landing.species.family),
        _buildRow('Major Group', landing.species.majorGroup),
        _buildRow('3 Alpha Code', landing.species.alpha3Code),
        _buildRow('Caab Code', landing.species.caabCode),
        _buildRow('CPC Class', landing.species.cpcClass),
        const SizedBox(height: 15),
      ],
    );
  }
}
