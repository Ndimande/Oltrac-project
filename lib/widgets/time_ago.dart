import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class TimeAgo extends StatefulWidget {
  @override
  TimeAgoState createState() => TimeAgoState();

  final DateTime startedAt;
  final String prefix;
  final String suffix;
  TimeAgo({this.startedAt, this.prefix = '', this.suffix = ''});
}

class TimeAgoState extends State<TimeAgo> {
  Timer updateTimer;

  @override
  void initState() {
    super.initState();
    updateTimer =
        Timer.periodic(Duration(seconds: 5), (Timer timer) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startedAt == null) {
      return Text('');
    }

    final Duration difference = DateTime.now().difference(widget.startedAt);
    final humanDiff = DateTime.now().subtract(difference);
    return Text(widget.prefix + timeAgo.format(humanDiff));
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }
}
