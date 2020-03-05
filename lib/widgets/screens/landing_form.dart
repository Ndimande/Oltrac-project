import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/widgets/olrac_icon.dart';
import 'package:oltrace/widgets/strip_button.dart';

const textFieldTextStyle = TextStyle(fontSize: 20, color: olracBlue);

class LandingFormScreen extends StatefulWidget {
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

  final _landingRepo = LandingRepository();
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
        _lengthController = TextEditingController(
            text: landingArg != null ? (landingArg.length / 10000).toString() : null),
        _individualsController = TextEditingController(
            text: landingArg != null ? landingArg?.individuals.toString() : null),
        _selectedSpecies = landingArg?.species,
        _bulkMode = landingArg != null
            ? landingArg.individuals > 1 ? true : false
            : sharedPrefs.getBool('bulkMode') ?? false;

  bool get isEditMode => landingArg != null;

  // Convert Kilograms -> Grams
  int _parseWeightInput() {
    return (double.parse(_weightController.value.text) * 1000).round();
  }

  // Convert centimeters -> micrometers
  int _parseLengthInput() {
    return (double.parse(_lengthController.value.text) * 10 * 1000).round();
  }

  int _parseIndividualsInput() {
    // If bulk mode is disabled, default to 1
    if (_bulkMode != true) {
      return 1;
    }

    int individuals = int.tryParse(_individualsController.value.text);

    if (individuals == null || individuals < 2) {
      // invalid input
      return null;
    }
    return individuals;
  }

  _onPressSaveButton(Haul haul, BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (_selectedSpecies == null) {
      showTextSnackBar(_scaffoldKey, 'Please select a species');
      return;
    }

    final int weightGrams = _parseWeightInput();
    final int lengthMicrometers = _parseLengthInput();

    final int individuals = _parseIndividualsInput();

    if (individuals == null) {
      showTextSnackBar(_scaffoldKey, 'Please enter 2 or higher for individuals');
      return;
    }

    if (isEditMode) {
      final updatedLanding = landingArg.copyWith(
        weight: weightGrams,
        length: lengthMicrometers,
        species: _selectedSpecies,
        individuals: individuals,
      );

      await _landingRepo.store(updatedLanding);

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Shark updated.'),
          onVisible: () async {
            await Future.delayed(Duration(seconds: 1));
            Navigator.pop(context);
          },
        ),
      );
    } else {
      showTextSnackBar(_scaffoldKey, Messages.WAITING_FOR_GPS);
      // TODO get from location provider
      var position = await geolocator.getCurrentPosition();
      _scaffoldKey.currentState.hideCurrentSnackBar();

      final landing = Landing(
        species: _selectedSpecies,
        createdAt: DateTime.now(),
        location: Location.fromPosition(position),
        // kg -> g
        weight: weightGrams,
        length: lengthMicrometers,
        haulId: haul.id,
        individuals: _bulkMode ? int.parse(_individualsController.value.text) : 1,
      );

      await _landingRepo.store(landing);

      bool createAnotherDialogResponse = await _showLandingSavedDialog(landing);

      setState(() {
        _selectedSpecies = null;
        _weightController.clear();
        _lengthController.clear();
        _individualsController.clear();
      });

      if (createAnotherDialogResponse == false) {
        Navigator.pop(context);
      }
    }
  }

  Future<bool> _showLandingSavedDialog(Landing landing) {
    const actionTextStyle = TextStyle(fontSize: 26);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(15),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 60),
            child: FlatButton(
              child: Text('Yes', style: actionTextStyle),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          Container(
            child: FlatButton(
              child: Text('No', style: actionTextStyle),
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
              Icon(Icons.check_circle_outline, size: 50),
              Text(
                '${landing.species.englishName} saved!',
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
      onPressed: () => _changeBulkMode(),
      child: Row(
        children: <Widget>[
          Text('Bulk Mode', style: TextStyle(color: Colors.white)),
          Switch(
            activeColor: Colors.white,
            onChanged: (bool value) => _changeBulkMode(),
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

    final String titleText =
        widget.landingArg == null ? _bulkMode ? 'Add Species' : 'Add Species' : 'Edit Species';

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
                      child: ModelDropdown<Species>(
                        label: 'Species',
                        selected: _selectedSpecies,
                        items: sortedSpecies.map<DropdownMenuItem<Species>>(
                          (Species species) {
                            return DropdownMenuItem<Species>(
                              value: species,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      species.englishName,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    OlracIcon(
                                      assetPath: SvgIcons.path(species.scientificName),
                                      darker: true,
                                    )
                                  ],
                                ),
                              ),
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
