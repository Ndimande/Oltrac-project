import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:oltrace/app_themes.dart';

class ForwardArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 90 * math.pi / 180,
      child: Icon(
        Icons.navigation,
        color: olracBlue,
        size: 30,
      ),
    );
  }
}