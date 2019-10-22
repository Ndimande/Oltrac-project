import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/views/haul.dart';

class TripView extends StatelessWidget {
  final AppStore _appStore;

  TripView(this._appStore);

  @override
  Widget build(BuildContext context) {
    return Text('Trip Screen');
  }
}
