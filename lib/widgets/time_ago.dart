import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as time_ago;

/// How frequently the text is updated
const _updateInterval = Duration(seconds: 5);

class TimeAgo extends StatefulWidget {
  @override
  TimeAgoState createState() => TimeAgoState();

  final DateTime dateTime;
  final String prefix;
  final String suffix;
  final TextStyle textStyle;

  const TimeAgo({
    @required this.dateTime,
    this.prefix = '',
    this.suffix = '',
    this.textStyle,
  });
}

class TimeAgoState extends State<TimeAgo> {
  Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(_updateInterval, (Timer timer) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dateTime == null) {
      return const Text('-');
    }

    final Duration difference = DateTime.now().difference(widget.dateTime);
    final humanDiff = DateTime.now().subtract(difference);

    return Text(
      widget.prefix + time_ago.format(humanDiff) + widget.suffix,
      style: widget.textStyle,
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }
}
