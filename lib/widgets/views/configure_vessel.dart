import 'package:flutter/material.dart';
import 'package:oltrace/data/countries.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/data/fisheries.dart';
import 'package:oltrace/widgets/big_button.dart';

class _FisheryDropdown extends StatelessWidget {
  final Fishery _selected;
  final Function _onChanged;

  _FisheryDropdown(this._selected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          DropdownButton<Fishery>(
            hint: Text('Fishery'),
            isExpanded: true,
            style: TextStyle(fontSize: 16, color: Colors.black),
            value: _selected,
            onChanged: _onChanged,
            items: fisheries.map<DropdownMenuItem<Fishery>>((Fishery fishery) {
              return DropdownMenuItem<Fishery>(
                value: fishery,
                child: Text(fishery.name),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class _CountryDropdown extends StatelessWidget {
  final Country _selected;
  final Function _onChanged;

  _CountryDropdown(this._selected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          DropdownButton<Country>(
            hint: Text('Country'),
            isExpanded: true,
            style: TextStyle(fontSize: 16, color: Colors.black),
            value: _selected,
            onChanged: _onChanged,
            items: countries.map<DropdownMenuItem<Country>>((Country country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Text(country.name),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class ConfigureVesselView extends StatefulWidget {
  final AppStore _appStore;

  ConfigureVesselView(this._appStore);

  ConfigureVesselViewState createState() => ConfigureVesselViewState();
}

class ConfigureVesselViewState extends State<ConfigureVesselView> {
  Vessel _oldVessel;
  Fishery _selectedFishery;
  Country _selectedCountry;
  String _vesselName;
  String _skipperName;
  final TextEditingController _vesselNameController = TextEditingController();
  final TextEditingController _skipperNameController = TextEditingController();

  void initState() {
    _oldVessel = widget._appStore.vessel;

    if (_oldVessel != null) {
      _selectedFishery = _oldVessel.fishery;
      _selectedCountry = _oldVessel.country;
      _vesselNameController.text = _oldVessel.name;
      _skipperNameController.text = _oldVessel.skipper?.name;
    }
    _vesselNameController.addListener(() {
      _vesselName = _vesselNameController.text;
    });

    _skipperNameController.addListener(() {
      _skipperName = _skipperNameController.text;
    });
    super.initState();
  }

  void dispose() {
    _vesselNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /// Vessel name
          TextField(
            decoration: InputDecoration(labelText: 'Vessel name'),
            controller: _vesselNameController,
          ),

          /// Skipper name
          TextField(
            decoration: InputDecoration(labelText: 'Skipper name'),
            controller: _skipperNameController,
          ),

          /// Fishery
          _FisheryDropdown(_selectedFishery,
              (_fishery) => setState(() => _selectedFishery = _fishery)),
          _CountryDropdown(_selectedCountry,
              (_country) => setState(() => _selectedCountry = _country)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_selectedCountry == null ||
                        _selectedFishery == null ||
                        _vesselName == null ||
                        _skipperName == null) {
                      // Find the Scaffold in the widget tree and use it to show a SnackBar.
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Please complete the form before saving.')));

                      return;
                    }
                    final _vessel = Vessel(
                        name: _vesselName,
                        skipper: Skipper(name: _skipperName),
                        fishery: _selectedFishery,
                        country: _selectedCountry);
                    widget._appStore.setVessel(_vessel);
                    widget._appStore.changeMainView(NavIndex.home);
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Vessel configuration saved.')));
                  })
            ],
          )
        ],
      )),
    );
  }
}
