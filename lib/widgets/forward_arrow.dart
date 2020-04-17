import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';

class ForwardArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 90 * math.pi / 180,
      child: Icon(
        Icons.navigation,
        color: OlracColours.olspsBlue,
        size: 30,
      ),
    );
  }
}
