import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';

class InfoTable extends StatelessWidget {
  final String title;
  final List<List<String>> data;

  InfoTable({
    @required this.title,
    this.data = const [],
  });

  Widget _heading(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          color: OlracColours.olspsBlue,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  TableRow _row(String left, String right) {
    return TableRow(children: [
      TableCell(
        child: Text(left),
      ),
      TableCell(
        child: Text(right),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _heading(title),
          Table(children: data.map<TableRow>((List<String> row) => _row(row[0], row[1])).toList())
        ],
      ),
    );
  }
}
