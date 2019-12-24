import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/stores/app_store.dart';

class CreateLandingScreen extends StatefulWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final Haul _haulArg;

  CreateLandingScreen(this._haulArg);

  @override
  State<StatefulWidget> createState() => CreateLandingScreenState(_haulArg);
}

class CreateLandingScreenState extends State<CreateLandingScreen> {
  /// Animal species to be associated with the tag.
  Species _selectedSpecies;
  static final sharedPrefs = SharedPreferencesProvider().sharedPreferences;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final geolocator = Geolocator();

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _individualsController = TextEditingController();

  final Haul _haul;

  // Local state
  bool _bulkMode = sharedPrefs.getBool('bulkMode') ?? false;

  CreateLandingScreenState(this._haul);

  _onPressSaveButton(haul, context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (_selectedSpecies == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Please select a species'),
        ),
      );
      return;
    }

    var position = await geolocator.getLastKnownPosition();
    if (position == null) {
      position = await geolocator.getCurrentPosition();
    }

    final landing = await widget._appStore.saveLanding(
      Landing(
        species: _selectedSpecies,
        createdAt: DateTime.now(),
        location: Location.fromPosition(position),
        // kg -> g
        weight: (double.parse(_weightController.value.text) * 1000).round(),
        length: int.parse(_lengthController.value.text),
        haulId: haul.id,
        individuals: _bulkMode ? int.parse(_individualsController.value.text) : 1,
      ),
    );

    bool createAnotherDialogResponse = await _showLandingSavedDialog(landing);

    setState(() {
      _weightController.clear();
      _lengthController.clear();
    });

    if (createAnotherDialogResponse == false) {
       Navigator.pop(context);
    }
  }

  Future<bool> _showLandingSavedDialog(Landing landing) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(15),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 60),
            child: FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 26),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          Container(
            child: FlatButton(
              child: Text(
                'No',
                style: TextStyle(fontSize: 26),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
        content: Container(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                size: 50,
              ),
              Text(
                'Shark ${landing.species.englishName} (ID ${landing.id.toString()}) saved!',
                style: TextStyle(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              Text(
                'Do you want to add another?',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _floatingActionButton(Haul haul, context) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 180,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Save',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.save),
        onPressed: () async => await _onPressSaveButton(haul, context),
      ),
    );
  }

  Widget _individualsTextInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Text(
              'Number of Individuals',
              style: TextStyle(fontSize: 20),
            ),
          ),
          TextFormField(
            style: TextStyle(fontSize: 30),
            keyboardType: TextInputType.number,
            controller: _individualsController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter number of individuals';
              }

              // check if valid float
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number of individuals';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  _changeBulkMode() {
    setState(() {
      _bulkMode = !_bulkMode;
    });
    sharedPrefs.setBool('bulkMode', _bulkMode);
    _individualsController.clear();
  }

  Widget _bulkModeButtonSwitch() {
    return FlatButton(
      onPressed: () {
        _changeBulkMode();
      },
      child: Row(
        children: <Widget>[
          Text(
            'Bulk Mode',
            style: TextStyle(color: Colors.white),
          ),
          Switch(
            activeColor: Colors.white,
            onChanged: (bool value) {
              _changeBulkMode();
            },
            value: _bulkMode,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedSpecies = species;
    sortedSpecies.sort((Species a, Species b) => a.englishName.compareTo(b.englishName));

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _floatingActionButton(_haul, context),
      appBar: AppBar(
        title: Text('Haul ${_haul.id} - Add Shark'),
        actions: <Widget>[_bulkModeButtonSwitch()],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Select species
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: ModelDropdown<Species>(
                    label: 'Species',
                    selected: _selectedSpecies,
                    items: sortedSpecies.map<DropdownMenuItem<Species>>(
                      (Species species) {
                        return DropdownMenuItem<Species>(
                          value: species,
                          child: Text(species.englishName),
                        );
                      },
                    ).toList(),
                    onChanged: (Species species) {
                      setState(() => _selectedSpecies = species);
                    },
                  ),
                ),

                // Weight
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Text(
                          _bulkMode ? 'Total Weight (kg)' : 'Weight (kg)',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 30),
                        keyboardType: TextInputType.number,
                        controller: _weightController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a weight';
                          }

                          // check if valid float
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Length
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Text(
                          _bulkMode ? 'Avg. Length (cm)' : 'Length (cm)',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 30),
                        keyboardType: TextInputType.number,
                        controller: _lengthController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a length';
                          }

                          // check if valid float
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid length';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Individualsl
                _bulkMode ? _individualsTextInput() : Container(),

                Container(height: 100)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
