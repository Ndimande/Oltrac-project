import 'package:intl/intl.dart';

String friendlyDateTimestamp(DateTime dateTime) {
  return dateTime == null ? null : DateFormat('d MMM y HH:mm').format(dateTime);
}

enum WeightUnit { GRAMS, OUNCES }

enum LengthUnit { CENTIMETERS, INCHES }
