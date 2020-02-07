import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/strings.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/strip_button.dart';

const textFieldTextStyle = TextStyle(fontSize: 20, color: olracBlue);

class LandingFormScreen extends StatefulWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final Haul haulArg;
  final Landing landingArg;

  LandingFormScreen({this.haulArg, this.landingArg});

  @override
  State<StatefulWidget> createState() {
    if (landingArg != null) {
      return LandingFormScreenState(haul: haulArg, landingArg: landingArg);
    }
    return LandingFormScreenState(haul: haulArg);
  }
}

class LandingFormScreenState extends State<LandingFormScreen> {
  static final sharedPrefs = SharedPreferencesProvider().sharedPreferences;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final geolocator = Geolocator();

  final TextEditingController _weightController;
  final TextEditingController _lengthController;
  final TextEditingController _individualsController;

  final Haul haul;

  /// If this is null we are creating.
  final Landing landingArg;

  /// Animal species to be associated with the tag.
  Species _selectedSpecies;

  /// Is bulk mode enabled?
  /// Bulk mode changes the form to allow entry of no. of individuals
  /// in the event of a bulk bin of animals.
  bool _bulkMode;

  LandingFormScreenState({this.haul, this.landingArg})
      : _weightController = TextEditingController(
            text: landingArg != null ? (landingArg.weight / 1000).toString() : null),
        _lengthController =
            TextEditingController(text: landingArg != null ? landingArg.length.toString() : null),
        _individualsController = TextEditingController(
            text: landingArg != null ? landingArg?.individuals.toString() : null),
        _selectedSpecies = landingArg?.species,
        _bulkMode = landingArg != null
            ? landingArg.individuals > 1 ? true : false
            : sharedPrefs.getBool('bulkMode') ?? false;

  bool get isEditMode => landingArg != null;

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

    final int weightGrams = (double.parse(_weightController.value.text) * 1000).round();
    final int length = int.parse(_lengthController.value.text);

    // If bulk mode is disabled, default to 1
    final int individuals = _bulkMode == true ? int.tryParse(_individualsController.value.text) : 1;

    if (isEditMode) {
      final updatedLanding = landingArg.copyWith(
        weight: weightGrams,
        length: length,
        species: _selectedSpecies,
        individuals: individuals,
      );
      await widget._appStore.editLanding(updatedLanding);

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Shark updated.'),
          onVisible: () async {
            await Future.delayed(Duration(seconds: 1));
            Navigator.pop(context);
          },
        ),
      );
      return;
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(Strings.WAITING_FOR_GPS)));
    // TODO get from location provider
    var position = await geolocator.getCurrentPosition();
    _scaffoldKey.currentState.hideCurrentSnackBar();

    final landing = await widget._appStore.saveLanding(
      Landing(
        species: _selectedSpecies,
        createdAt: DateTime.now(),
        location: Location.fromPosition(position),
        // kg -> g
        weight: weightGrams,
        length: length,
        haulId: haul.id,
        individuals: _bulkMode ? int.parse(_individualsController.value.text) : 1,
      ),
    );

    bool createAnotherDialogResponse = await _showLandingSavedDialog(landing);

    setState(() {
      _selectedSpecies = null;
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
              style: textFieldTextStyle,
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

  void _changeBulkMode() {
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
    final List<Species> sortedSpecies = List.from(species);
    sortedSpecies.sort((Species a, Species b) => a.englishName.compareTo(b.englishName));

    final String titleText = widget.landingArg == null ? 'Add Shark' : 'Edit Shark';

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(titleText),
        actions: <Widget>[_bulkModeButtonSwitch()],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
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
                              style: textFieldTextStyle,
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
                              style: textFieldTextStyle,
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

                    // Individuals
                    _bulkMode ? _individualsTextInput() : Container(),
                  ],
                ),
              ),
            ),
          ),
          StripButton(
            centered: true,
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            labelText: 'Save',
            color: Colors.green,
            onPressed: () async => await _onPressSaveButton(haul, context),
          ),
        ],
      ),
    );
  }
}