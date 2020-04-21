import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/app_config.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final bool darker;

  SvgIcon({
    @required this.assetPath,
    this.width = 64,
    this.height = 64,
    this.darker = false,
  });

  Widget _notFound() {
    if(!AppConfig.debugMode) {
      return Container();
    }
    return Stack(
      children: <Widget>[
        Container(
          width: width - 10,
          height: height - 10,
          color: Colors.red,
        ),
        Text(
          'SVG missing\n(path $assetPath)',
          style: TextStyle(fontSize: 8, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return _notFound();
    }
    final Color color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : darker ? OlracColours.olspsDarkBlue : OlracColours.olspsBlue;

    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: color,
    );
  }
}
