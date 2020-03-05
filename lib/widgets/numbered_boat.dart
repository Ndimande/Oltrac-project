import 'package:flutter/material.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/widgets/olrac_icon.dart';

class NumberedBoat extends StatelessWidget {
  final int number;
  final double size;

  NumberedBoat({this.number, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          child: OlracIcon(
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
