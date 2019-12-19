import 'package:flutter/material.dart';

const double _defaultWidth = 180;
const double _defaultHeight = 65;

class AppFAB extends StatelessWidget {
  final Function onPressed;
  final Widget label;
  final Icon icon;
  final double width;
  final double height;
  final Color backgroundColor;

  AppFAB({
    this.onPressed,
    this.label,
    this.icon,
    this.backgroundColor,
    width,
    height,
  })  : this.width = width ?? _defaultWidth,
        this.height = height ?? _defaultHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: FloatingActionButton.extended(
        icon: icon,
        label: label,
        backgroundColor: backgroundColor,
        onPressed: onPressed,
      ),
    );
  }
}
