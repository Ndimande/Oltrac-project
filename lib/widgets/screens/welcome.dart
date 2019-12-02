import 'package:flutter/material.dart';
import 'package:oltrace/data/countries.dart';
import 'package:oltrace/data/fisheries.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/stores/app_store.dart';

class WelcomeScreen extends StatefulWidget {
  final AppStore _appStore;

  WelcomeScreen(this._appStore);

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final _jsonRepo = JsonRepository();
  final _formKey = GlobalKey<FormState>();
  FisheryType _selectedFisheryType;
  Country _selectedCountry;
  String _vesselName;
  String _skipperName;

  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Welcome to OlTrace',
          style: TextStyle(fontSize: 32, color: Colors.black),
          textAlign: TextAlign.start,
        ),
        Text('Please enter your vessel information.',
            style: TextStyle(fontSize: 22, color: Colors.grey),
            textAlign: TextAlign.start),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: <Widget>[
        _CountryDropdown(_selectedCountry,
            (_country) => setState(() => _selectedCountry = _country)),
        _FisheryDropdown(_selectedFisheryType,
            (_fishery) => setState(() => _selectedFisheryType = _fishery)),
        _buildVesselNameTextFormField(),
        _buildSkipperNameTextFormField(),
      ],
    );
  }

  Widget _buildVesselNameTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Vessel Name', labelStyle: TextStyle(fontSize: 14)),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a vessel name.';
        }
        _vesselName = value;
        return null;
      },
    );
  }

  Widget _buildSkipperNameTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Skipper Name', labelStyle: TextStyle(fontSize: 14)),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a skipper name.';
        }
        _skipperName = value;
        return null;
      },
    );
  }

  Future<void> _onPressSave(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (_selectedFisheryType == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Please select a fishery type')),
      );
      return;
    }
    if (_selectedCountry == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Please select a country')),
      );
      return;
    }
    final _profile = Profile(
      name: _vesselName,
      skipper: Skipper(name: _skipperName),
      fisheryType: _selectedFisheryType,
      country: _selectedCountry,
    );
    await widget._appStore.saveProfile(_profile);

    await Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(
      builder: (context) => SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildWelcomeMessage(),
                  _buildInputFields(),
                  Container(
                    child: RaisedButton(
                        child: Text('Save'),
                        onPressed: () async => await _onPressSave(context)),
                    alignment: Alignment.bottomRight,
                  )
                ],
              ),
            )),
      ),
    ));
  }
}

class _FisheryDropdown extends StatelessWidget {
  final FisheryType _selected;
  final Function _onChanged;

  _FisheryDropdown(this._selected, this._onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          DropdownButton<FisheryType>(
            hint: Text('Fishery Type'),
            isExpanded: true,
            style: TextStyle(fontSize: 16, color: Colors.black),
            value: _selected,
            onChanged: _onChanged,
            items: fisheries
                .map<DropdownMenuItem<FisheryType>>((FisheryType fishery) {
              return DropdownMenuItem<FisheryType>(
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
