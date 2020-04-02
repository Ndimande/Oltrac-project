import 'dart:async';

import 'package:flutter/material.dart';

final _updateInterval = Duration(milliseconds: 1000);

class HaulSubtitle extends StatefulWidget {
  final DateTime startedAt;
  final DateTime endedAt;

  final int totalProducts;
  final int totalWeight;

  HaulSubtitle({
    @required this.totalProducts,
    @required this.totalWeight,
    @required this.startedAt,
    this.endedAt,
  })  : assert(totalProducts != null),
        assert(totalWeight != null);

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

  double get _totalWeightKilograms => (widget.totalWeight / 1000);

  Duration get _elapsed {
    final DateTime endedAt = widget.endedAt;
    final DateTime startedAt = widget.startedAt;

    DateTime until = endedAt != null ? endedAt : DateTime.now();
    return until.difference(startedAt);
  }

  TextSpan get elapsedTextSpan => TextSpan(
        text: '${_getHours(_elapsed)}h ${_getMinutes(_elapsed)}m ${_getSeconds(_elapsed)}s, ',
        style: TextStyle(color: Colors.black),
      );

  TextSpan get _kilogramsTotal => TextSpan(
        text: ' ${_totalWeightKilograms.toStringAsFixed(2)}kg, ',
        style: TextStyle(color: Colors.black),
      );

  TextSpan get _totalProducts {
    final int totalTags = widget.totalProducts;

    return TextSpan(
      text: '$totalTags tags',
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

String _getMinutes(Duration difference) => (difference.inMinutes % 60).round().toString().padLeft(2, '0');

String _getSeconds(Duration difference) => (difference.inSeconds % 60).round().toString().padLeft(2, '0');
