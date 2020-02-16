import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';

final _updateInterval = Duration(milliseconds: 1000);

class HaulSubtitle extends StatefulWidget {
  final Haul haul;

  HaulSubtitle({this.haul});

  @override
  State<StatefulWidget> createState() => HaulSubtitleState();
}

class HaulSubtitleState extends State<HaulSubtitle> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_updateInterval, (Timer t) => setState(() {}));
  }

  int get totalWeightGrams => widget.haul.landings.fold(0, (total, Landing l) => total + l.weight);

  double get totalWeightKilograms => (totalWeightGrams / 1000);

  Duration get elapsed {
    final DateTime endedAt = widget.haul.endedAt;
    final DateTime startedAt = widget.haul.startedAt;

    DateTime until = endedAt != null ? endedAt : DateTime.now();
    return until.difference(startedAt);
  }

  int get elapsedSeconds => elapsed.inSeconds;

  double get kilogramsPerSecond => elapsed.inSeconds == 0 ? 0 : (totalWeightGrams / 1000) / elapsedSeconds;

  double get kilogramsPerMinute => kilogramsPerSecond * 60;

  TextSpan get elapsedTextSpan => TextSpan(
        text: '${_getHours(elapsed)}:${_getMinutes(elapsed)}:${_getSeconds(elapsed)}',
        style: TextStyle(color: Colors.black),
      );

  TextSpan get kilogramsTotalTextSpan => TextSpan(
        text: ' ${totalWeightKilograms.toStringAsFixed(2)}kg ',
        style: TextStyle(color: Colors.black),
      );

  TextSpan get kilogramsPerMinuteTextSpan => TextSpan(
        text: '(${kilogramsPerMinute.toStringAsFixed(2)}kg/min)',
        style: TextStyle(color: Colors.black),
      );

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: <TextSpan>[
        elapsedTextSpan,
        kilogramsTotalTextSpan,
        kilogramsPerMinuteTextSpan,
      ]),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}


String _getHours(Duration difference) => difference.inHours.toString();

String _getMinutes(Duration difference) =>
  (difference.inMinutes % 60).round().toString().padLeft(2, '0');

String _getSeconds(Duration difference) =>
  (difference.inSeconds % 60).round().toString().padLeft(2, '0');
