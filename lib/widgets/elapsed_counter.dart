import 'dart:async';

import 'package:flutter/material.dart';

/// How frequently the text is updated
const _updateInterval = Duration(milliseconds: 1000);

class ElapsedCounter extends StatefulWidget {
  final DateTime startedDateTime;
  final TextStyle style;
  final String prefix;
  final String suffix;

  const ElapsedCounter({
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

  String get _text {
    final Duration difference = DateTime.now().difference(widget.startedDateTime);
    final hours = _getHours(difference);

    final minutes = _getMinutes(difference);

    final seconds = _getSeconds(difference);

    return '${widget.prefix}${hours}h ${minutes}m ${seconds}s ${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
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

String _getMinutes(Duration difference) => (difference.inMinutes % 60).round().toString();

String _getSeconds(Duration difference) => (difference.inSeconds % 60).round().toString();
