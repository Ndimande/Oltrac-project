import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class TripStartedAgo extends StatefulWidget {
  @override
  TripStartedAgoState createState() => TripStartedAgoState();

  final DateTime startedAt;
  final Trip trip;

  TripStartedAgo({this.trip})
      : startedAt = trip != null ? trip.startedAt : null;
}

class TripStartedAgoState extends State<TripStartedAgo> {
  Timer updateTimer;

  @override
  void initState() {
    super.initState();
    updateTimer =
        Timer.periodic(Duration(seconds: 10), (Timer timer) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startedAt == null) {
      return Text('No active trip');
    }

    final Duration difference = DateTime.now().difference(widget.startedAt);
    final humanDiff = DateTime.now().subtract(difference);
    return Text('Trip started ' + timeAgo.format(humanDiff));
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }
}
