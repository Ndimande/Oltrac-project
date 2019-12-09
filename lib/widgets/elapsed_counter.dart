import 'package:flutter/material.dart';
import 'dart:async';

/// How frequently the text is updated
final _updateInterval = Duration(milliseconds: 1000);

class ElapsedCounter extends StatefulWidget {
  final DateTime startedDateTime;
  final TextStyle textStyle;

  ElapsedCounter(this.startedDateTime, {this.textStyle});

  @override
  State<StatefulWidget> createState() => ElapsedCounterState();
}

class ElapsedCounterState extends State<ElapsedCounter> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_updateInterval, (Timer t) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final Duration difference =
        DateTime.now().difference(widget.startedDateTime);

    final minutes = _getMinutes(difference);

    final seconds = _getSeconds(difference);

    final text = "$minutes:$seconds";

    return Text(
      text,
      style: widget.textStyle,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

String _getMinutes(Duration difference) =>
    (difference.inMinutes).round().toString();

String _getSeconds(Duration difference) =>
    (difference.inSeconds % 60).round().toString().padLeft(2, '0');