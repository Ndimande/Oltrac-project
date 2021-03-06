import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

String friendlyDateTime(DateTime dateTime) {
  return dateTime == null ? null : DateFormat('d MMM y, HH:mm').format(dateTime);
}

String friendlyDate(DateTime dateTime) {
  return dateTime == null ? null : DateFormat('d MMM y').format(dateTime);
}

enum WeightUnit { GRAMS, OUNCES }

enum LengthUnit { MICROMETERS, INCHES }

String randomTagCode() => '0x' + new Random().nextInt(1000000000).toRadixString(16).padLeft(8, '0');

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showTextSnackBar(
  GlobalKey<ScaffoldState> scaffoldKey,
  String text, {
  duration = const Duration(seconds: 2),
}) =>
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text), duration: duration));



/// Rounds [value] to given number of [decimals]
double roundDouble(final double value, {final int decimals: 6}) =>
  (value * math.pow(10, decimals)).round() / math.pow(10, decimals);
