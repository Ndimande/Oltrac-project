import 'package:flutter/material.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';

class _FishingMethodDropdown extends StatelessWidget {
  final Function _onChanged;
  final FishingMethod _selected;

  _FishingMethodDropdown(this._selected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Fishing method:',
            style: TextStyle(fontSize: 24),
          ),
          DropdownButton<FishingMethod>(
            style: TextStyle(fontSize: 22, color: Colors.black),
            value: _selected,
            onChanged: _onChanged,
            items:
                fishingMethods.map<DropdownMenuItem<FishingMethod>>((method) {
              return DropdownMenuItem<FishingMethod>(
                value: method,
                child: Text(method.name),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class HaulView extends StatefulWidget {
  final AppStore _appStore;

// todo change to stateful widget so it can hold the selection
  HaulView(this._appStore);

  HaulViewState createState() => HaulViewState();
}

class HaulViewState extends State<HaulView> {
  FishingMethod _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text('No active haul', style: TextStyle(fontSize: 35))
              ],
            ),
          ),
          _FishingMethodDropdown(
              _selectedMethod,
              (_fishingMethod) =>
                  setState(() => _selectedMethod = _fishingMethod)),
          Container(
            child: Column(
              children: <Widget>[
                BigButton(child: Text('Start Haul'), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }
}
