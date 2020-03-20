import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oltrace/app_themes.dart';

// Todo rename to SvgIcon
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
  }) : assert(assetPath != null);

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : darker ? olracDarkBlue : olracBlue;
    if (assetPath == null) {
      return Container(
        color: Colors.red,
      );
    }
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: color,
    );
  }
}
