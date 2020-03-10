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

  int get _totalWeightGrams => widget.haul.landings.fold(0, (total, Landing l) => total + l.weight);

  double get _totalWeightKilograms => (_totalWeightGrams / 1000);

  Duration get _elapsed {
    final DateTime endedAt = widget.haul.endedAt;
    final DateTime startedAt = widget.haul.startedAt;

    DateTime until = endedAt != null ? endedAt : DateTime.now();
    return until.difference(startedAt);
  }

  TextSpan get elapsedTextSpan => TextSpan(
        text: '${_getHours(_elapsed)}:${_getMinutes(_elapsed)}:${_getSeconds(_elapsed)}, ',
        style: TextStyle(color: Colors.black),
      );

  TextSpan get _kilogramsTotal => TextSpan(
        text: ' ${_totalWeightKilograms.toStringAsFixed(2)}kg, ',
        style: TextStyle(color: Colors.black),
      );


  TextSpan get _totalProducts {
    int totalProducts = 0;
    for (Landing landing in widget.haul.landings) {
      totalProducts += landing.products.length;
    }

    return TextSpan(
      text: '$totalProducts tags',
      style: TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: <TextSpan>[
        elapsedTextSpan,
        _kilogramsTotal,
        _totalProducts,
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
