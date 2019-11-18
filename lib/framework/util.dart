import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:oltrace/framework/model.dart';

String friendlyTimestamp(DateTime dateTime) {
  return DateFormat('d MMM y HH:mm').format(dateTime);
}

void printDebug(value) {
  try {
    if (value is String) {
      print(value);
    } else {
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      if (value is Model) {
        print(encoder.convert(value.toMap()));
      } else if (value is Map || value is List) {
        print(encoder.convert(value));
      }
    }
  } catch (e) {
    print('Failed to print debug' + e.toString());
  }
}
