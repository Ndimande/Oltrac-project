//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_picker/flutter_picker.dart';
//import 'package:oltrace/models/location.dart';
//
//enum LocationPickerType { Latitude, Longitude }
//
//List<String> _degreesRange(LocationPickerType type) {
//  final int limit = type == LocationPickerType.Latitude ? 90 : 180;
//  final List<String> degrees = [];
//  for (int i = 0; i <= limit; i++) {
//    degrees.add('$i °');
//  }
//  return degrees;
//}
//
//List<String> get _minutesRange {
//  final List<String> minutes = [];
//  for (int i = 0; i <= 59; i++) {
//    minutes.add("$i '");
//  }
//  return minutes;
//}
//
//List<String> get _secondsRange {
//  final List<String> seconds = [];
//  for (int i = 0; i <= 599; i++) {
//    seconds.add("${(i / 10).toStringAsFixed(1)} ''");
//  }
//  return seconds;
//}
//
//List<List<String>> _pickerData(LocationPickerType type) => [
//      _degreesRange(type),
//      _minutesRange,
//      _secondsRange,
//      type == LocationPickerType.Longitude ? ['N', 'S'] : ['E', 'W']
//    ];
//
//
//class LocationPicker extends StatelessWidget {
//  final LocationPickerType type;
//
//  LocationPicker({@required this.type})
//      : assert(type != null);
//
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      height: 170,
//      child: Picker(
//          adapter: PickerDataAdapter<String>(pickerdata: _pickerData(type), isArray: true),
//          hideHeader: true,
//          title: new Text("Please Select"),
//          onSelect: (Picker picker, int i, List<int> list) {
//            print([i, list]);
//          },
//          onConfirm: (Picker picker, List value) {
//            print(value.toString());
//            print(picker.getSelectedValues());
//          }).makePicker(),
//    );
//  }
//}
