import 'package:flutter/material.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';

class _FishingMethodDropdown extends StatelessWidget {
  final Function _onChanged;
  final FishingMethod _selected;

  _FishingMethodDropdown(this._selected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<FishingMethod>(
      hint: Text('Fishing Method'),
      style: TextStyle(fontSize: 26, color: Colors.black),
      value: _selected,
      onChanged: _onChanged,
      items: fishingMethods.map<DropdownMenuItem<FishingMethod>>((method) {
        return DropdownMenuItem<FishingMethod>(
          value: method,
          child: Text(method.name),
        );
      }).toList(),
    );
  }
}

class HaulView extends StatefulWidget {
  final AppStore _appStore;

  HaulView(this._appStore);

  HaulViewState createState() => HaulViewState();
}

class HaulViewState extends State<HaulView> {
  FishingMethod _selectedMethod;

  Widget buildCurrentHaul() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text('Haul started at ' +
            widget._appStore.activeHaul.startedAt.toIso8601String()),
        BigButton(
            label: 'End Haul',
            onPressed: () {
              setState(() {
                widget._appStore.endHaul();
              });
            })
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget._appStore.activeHaul != null) {
      return buildCurrentHaul();
    }
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
          Container(
            child: _FishingMethodDropdown(
                _selectedMethod,
                (_fishingMethod) =>
                    setState(() => _selectedMethod = _fishingMethod)),
          ),
          Container(
            child: BigButton(
                label: 'Start Haul',
                onPressed: _selectedMethod == null
                    ? null
                    : () {
                        if (_selectedMethod == null) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Please select a fishing method'),
                          ));
                        } else {
                          setState(() {
                            widget._appStore.startHaul(Haul(
                                startedAt: DateTime.now(),
                                fishingMethod: _selectedMethod));
                          });

//                    widget._appStore.changeMainView(MainViewIndex.tag);
                        }
                      }),
          )
        ],
      ),
    );
  }
}
