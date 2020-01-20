import 'dart:math';

import 'package:intl/intl.dart';

String friendlyDateTimestamp(DateTime dateTime) {
  return dateTime == null ? null : DateFormat('d MMM y HH:mm').format(dateTime);
}

enum WeightUnit { GRAMS, OUNCES }

enum LengthUnit { CENTIMETERS, INCHES }

String randomTagCode() => '0x' + new Random().nextInt(1000000000).toRadixString(16).padLeft(8, '0');
