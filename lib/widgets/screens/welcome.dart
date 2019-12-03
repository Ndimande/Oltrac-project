import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/countries.dart';
import 'package:oltrace/data/fisheries.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/stores/app_store.dart';

final double _labelSize = 22;

class WelcomeScreen extends StatefulWidget {
  final AppStore _appStore;

  WelcomeScreen(this._appStore);

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
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
          style: TextStyle(fontSize: 34),
          textAlign: TextAlign.start,
        ),
        Container(
          height: 10,
        ),
        Text(
          'Please enter your vessel information:',
          style: TextStyle(fontSize: 22, color: AppConfig.textColor2),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: <Widget>[
        _CountryDropdown(
          _selectedCountry,
          (_country) => setState(() => _selectedCountry = _country),
        ),
        // State / Province
        // Fisheries (list/dropdown)
        _FisheryDropdown(
          _selectedFisheryType,
          (_fishery) => setState(() => _selectedFisheryType = _fishery),
        ),
        _buildVesselNameTextFormField(),
        _buildSkipperNameTextFormField(),
      ],
    );
  }

  Widget _buildVesselNameTextFormField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: TextStyle(fontSize: _labelSize),
        decoration: InputDecoration(
          labelText: 'Vessel name',
          helperText: 'The name of the vessel.',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a vessel name.';
          }
          _vesselName = value;
          return null;
        },
      ),
    );
  }

  Widget _buildSkipperNameTextFormField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: TextStyle(fontSize: _labelSize),
        decoration: InputDecoration(
          labelText: 'Skipper name',
          helperText: 'The name of the skipper. ',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter a skipper name.';
          }
          _skipperName = value;
          return null;
        },
      ),
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
        backgroundColor: AppConfig.backgroundColor,
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
                        onPressed: () async => await _onPressSave(context),
                      ),
                      alignment: Alignment.bottomRight,
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
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
            hint: Text(
              'Country',
              style: TextStyle(fontSize: _labelSize, color: Colors.white),
            ),
            isExpanded: true,
            style: TextStyle(fontSize: _labelSize, color: Colors.white),
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
            hint: Text(
              'Fishery Type',
              style: TextStyle(fontSize: _labelSize, color: Colors.white),
            ),
            isExpanded: true,
            style: TextStyle(fontSize: _labelSize, color: Colors.white),
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
