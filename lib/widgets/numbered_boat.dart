import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class NumberedBoat extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  NumberedBoat({this.number, this.size = 64, this.color = OlracColours.olspsBlue});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          child: SvgIcon(
            color: color,
            assetPath: SvgIcons.path('Boat'),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            number.toString(),
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
