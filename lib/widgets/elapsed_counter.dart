import 'package:flutter/material.dart';
import 'dart:async';

class ElapsedCounter extends StatefulWidget {
  final DateTime startedDateTime;

  ElapsedCounter(this.startedDateTime);

  @override
  State<StatefulWidget> createState() => ElapsedCounterState();
}

class ElapsedCounterState extends State<ElapsedCounter> {
  Timer _timer;
  String _text;

  String _getMinutes(Duration difference) =>
      (difference.inMinutes).round().toString();

  String _getSeconds(Duration difference) =>
      (difference.inSeconds % 60).round().toString().padLeft(2, '0');

  String _getMilliseconds(Duration difference) =>
      (difference.inMilliseconds % 1000).toString().padLeft(3, '0');

  String _formatCounter() {
    final Duration difference =
        DateTime.now().difference(widget.startedDateTime);
    final minutes = (difference.inMinutes).round().toString();
    final seconds =
        (difference.inSeconds % 60).round().toString().padLeft(2, '0');
    final milliseconds =
        (difference.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$milliseconds';
  }

  @override
  void initState() {
    super.initState();
    _text = _formatCounter();
    final updateInterval = Duration(milliseconds: 123);
    _timer = Timer.periodic(
        updateInterval,
        (Timer t) => setState(() {
              _text = _formatCounter();
            }));
  }

  @override
  Widget build(BuildContext context) {
    final Duration difference =
        DateTime.now().difference(widget.startedDateTime);

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            _getMinutes(difference),
            style: TextStyle(fontSize: 15),
          ),
          Text(':' + _getSeconds(difference), style: TextStyle(fontSize: 15)),
          Text(
            '.' + _getMilliseconds(difference),
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
