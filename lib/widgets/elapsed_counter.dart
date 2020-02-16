import 'package:flutter/material.dart';
import 'dart:async';

/// How frequently the text is updated
final _updateInterval = Duration(milliseconds: 1000);

class ElapsedCounter extends StatefulWidget {
  final DateTime startedDateTime;
  final TextStyle style;
  final String prefix;
  final String suffix;

  ElapsedCounter({
    this.startedDateTime,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

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
    final Duration difference = DateTime.now().difference(widget.startedDateTime);
    final hours = _getHours(difference);

    final minutes = _getMinutes(difference);

    final seconds = _getSeconds(difference);

    final text = "${widget.prefix}$hours:$minutes:$seconds${widget.suffix}";

    return Text(
      text,
      style: widget.style,
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
