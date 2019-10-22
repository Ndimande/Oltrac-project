import 'package:flutter/material.dart';
import 'package:oltrace/models/vessel.dart';

class VesselInfo extends StatelessWidget {
  final Vessel _vessel;

  VesselInfo(this._vessel);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(_vessel.name, style: TextStyle(fontSize: 29)),
          Text(_vessel.fishery.name),
          Text(_vessel.fishery.country.name)
        ],
      ),
    );
  }
}
