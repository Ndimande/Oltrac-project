import 'package:flutter/material.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

Widget _haulDropdown(List<Haul> _items, Haul _selected, Function _onChanged) {
  return DropdownButton<Haul>(
      hint: Text('Select haul'),
      value: _selected,
      onChanged: _onChanged,
      items: _items.map<DropdownMenuItem<Haul>>((Haul haul) {
        return DropdownMenuItem<Haul>(
          value: haul,
          child: Text('Haul of ' + haul.startedAt.toString()),
        );
      }).toList());
}

Widget _speciesDropdown(Species _selected, Function _onChanged) {
  return DropdownButton<Species>(
      hint: Text('Select species'),
      value: _selected,
      onChanged: _onChanged,
      items: species.map<DropdownMenuItem<Species>>((Species species) {
        return DropdownMenuItem<Species>(
          value: species,
          child: Text(species.englishName),
        );
      }).toList());
}

class TagPrimaryView extends StatefulWidget {
  final AppStore _appStore;

  TagPrimaryView(this._appStore);

  @override
  _TagPrimaryViewState createState() => _TagPrimaryViewState();
}

class _TagPrimaryViewState extends State<TagPrimaryView> {
  String _tagCode;
  Haul _selectedHaul;
  Species _selectedSpecies;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();

  Widget buildRfid() {
    final String tagCodeText = _tagCode ?? 'No tag scanned';

    return Container(
      child: Column(
        children: <Widget>[
          Text('Tag code:'),
          Text(
            tagCodeText,
            style: TextStyle(fontSize: 28),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    FlutterNfcReader.onTagDiscovered().listen((NfcData onData) {
      setState(() {
        _tagCode = onData.id;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          buildRfid(),
          _haulDropdown(_getAvailableHauls(), _selectedHaul, (Haul haul) {
            setState(() {
              _selectedHaul = haul;
            });
          }),
          _speciesDropdown(_selectedSpecies, (Species species) {
            setState(() {
              _selectedSpecies = species;
            });
          }),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Weight (g)'),
            controller: _weightController,
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Length (cm)'),
            controller: _lengthController,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: BigButton(
                label: 'Save',
                onPressed: _tagCode == null
                    ? null
                    : () {
                        widget._appStore.changeMainView(NavIndex.tag);
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(_tagCode + ' saved'),
                        ));
                      }),
          ),
          RaisedButton(
            child: Text('Fake RFID scan'),
            onPressed: () => setState(() {
              _tagCode = '0xFA7E5C46';
            }),
          )
        ],
      ),
    );
  }

  List<Haul> _getAvailableHauls() {
    List<Haul> availableHauls = widget._appStore.activeTrip.hauls;
    return widget._appStore.activeHaul == null
        ? availableHauls
        : [...availableHauls, widget._appStore.activeHaul];
  }
}
