import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:olrac_widgets/westlake/westlake_text_input.dart';
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
import 'package:oltrace/widgets/datetime_editor.dart';
import 'package:oltrace/widgets/location_editor.dart';
import 'package:oltrace/widgets/svg_icon.dart';

const textFieldTextStyle = TextStyle(fontSize: 20, color: OlracColours.fauxPasBlue);

class LandingFormScreen extends StatefulWidget {
  final Haul haulArg;
  final Landing landingArg;

  const LandingFormScreen({this.haulArg, this.landingArg});

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
  final _geolocator = Geolocator();

  final TextEditingController _weightController;
  final TextEditingController _lengthController;
  final TextEditingController _individualsController;

  final _landingRepo = LandingRepository();
  final Haul haul;

  /// If this is null we are creating.
  final Landing landingArg;

  /// Animal species to be associated with the tag.
  Species _selectedSpecies;

  Location _location;

  DateTime _createdAt;

  /// Is bulk mode enabled?
  /// Bulk mode changes the form to allow entry of no. of individuals
  /// in the event of a bulk bin of animals.
  final bool _bulkMode;

  LandingFormScreenState({this.haul, this.landingArg})
      : _weightController = TextEditingController(
            text: landingArg != null && landingArg.weight != null ? (landingArg.weight / 1000).toString() : null),
        _lengthController = TextEditingController(
            text: landingArg != null && landingArg.length != null ? (landingArg.length / 10000).toString() : null),
        _individualsController =
            TextEditingController(text: landingArg != null ? landingArg?.individuals.toString() : null),
        _selectedSpecies = landingArg?.species,
        _bulkMode = landingArg != null ? landingArg.individuals > 1 : sharedPrefs.getBool('bulkMode') ?? false,
        _location = landingArg?.location,
        _createdAt = landingArg?.createdAt;

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

    final int individuals = int.tryParse(_individualsController.value.text);

    if (individuals == null || individuals < 2) {
      // invalid input
      return null;
    }
    return individuals;
  }

  Future<void> _onPressSaveButton(Haul haul, BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (_selectedSpecies == null) {
      showTextSnackBar(_scaffoldKey, 'Please select a species');
      return;
    }

    final int weightGrams = _parseWeightInput();
    final int lengthMicrometers = _lengthController.value.text == '' ? null : _parseLengthInput();

    final int individuals = _parseIndividualsInput();

    if (isEditMode) {
      final updatedLanding = landingArg.copyWith(
        weight: weightGrams,
        length: lengthMicrometers,
        species: _selectedSpecies,
        individuals: individuals,
        createdAt: _createdAt,
        location: _location,
      );

      await _landingRepo.store(updatedLanding);

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Shark updated.'),
          onVisible: () async {
            await Future.delayed(const Duration(seconds: 1));
            Navigator.pop(context);
          },
        ),
      );
    } else {
      showTextSnackBar(_scaffoldKey, Messages.WAITING_FOR_GPS);
      // TODO get from location provider
      final position = await _geolocator.getCurrentPosition();
      _scaffoldKey.currentState.hideCurrentSnackBar();

      final landing = Landing(
        species: _selectedSpecies,
        createdAt: DateTime.now(),
        location: Location.fromPosition(position),
        // kg -> g
        weight: weightGrams,
        length: lengthMicrometers,
        haulId: haul.id,
        individuals: _bulkMode ? int.tryParse(_individualsController.value.text) : 1,
        isBulk: _bulkMode,
      );

      await _landingRepo.store(landing);

      setState(() {
        _selectedSpecies = null;
        _weightController.clear();
        _lengthController.clear();
        _individualsController.clear();
      });

      Navigator.pop(context);
    }
  }

  String _validateIndividuals(String value) {
    // Optional
    if (value.isEmpty) {
      return null;
    }

    // check if valid float
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number of individuals';
    }
    return null;
  }

  String _validateWeight(String value) {
    if (value.isEmpty) {
      return 'Please enter a weight';
    }

    // check if valid float
    if (double.tryParse(value) == null) {
      return 'Please enter a valid weight';
    }

    if (double.tryParse(value) == 0) {
      return 'The weight may not be 0';
    }
    return null;
  }

  String _validateLength(String value) {
    // Length is optional
    if (value.isEmpty) {
      return null;
    }

    // check if valid float
    if (double.tryParse(value) == null) {
      return 'Please enter a valid length';
    }

    if (double.tryParse(value) == 0) {
      return 'The length may not be 0';
    }
    return null;
  }

  Widget _individualsTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: const Text(
              'Number of Individuals',
              style: textFieldTextStyle,
            ),
          ),
          WestlakeTextInput(
            keyboardType: TextInputType.number,
            controller: _individualsController,
            validator: _validateIndividuals,
          ),
        ],
      ),
    );
  }

  Widget _speciesDropdown() {
    final List<Species> sortedSpecies = List.from(species);
    sortedSpecies.sort((Species a, Species b) => a.englishName.compareTo(b.englishName));

    return Container(
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
                    Expanded(
                      child: Text(species.englishName),
                    ),
                    SvgIcon(
                      assetPath: SvgIcons.path(species.scientificName),
//                      height: 80,
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
    );
  }

  Widget _weightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            _bulkMode ? 'Total Weight (kg)' : 'Weight (kg)',
            style: textFieldTextStyle,
          ),
        ),
        WestlakeTextInput(
          keyboardType: TextInputType.number,
          controller: _weightController,
          validator: _validateWeight,
        ),
      ],
    );
  }

  Widget _lengthInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Text(
            _bulkMode ? 'Avg. Length (cm)' : 'Length (cm)',
            style: textFieldTextStyle,
          ),
        ),
        WestlakeTextInput(
          keyboardType: TextInputType.number,
          controller: _lengthController,
          validator: _validateLength,
        ),
      ],
    );
  }

  Widget _saveStripButton() {
    return StripButton(
      icon: const Icon(Icons.save, color: Colors.white),
      labelText: 'Save',
      color: OlracColours.ninetiesGreen,
      onPressed: () async => await _onPressSaveButton(haul, context),
    );
  }

  Widget _locationEditor() {
    return LocationEditor(
        location: _location, onChanged: (Location l) => setState(() => _location = l), title: 'Location');
  }

  Widget _createdAtEditor() {
    return DateTimeEditor(
        initialDateTime: _createdAt,
        onChanged: (Picker picker, List<int> selectedIndices) {
          setState(() {
            _createdAt = DateTime.parse(picker.adapter.toString());
          });
        },
        title: 'Created');
  }

  @override
  Widget build(BuildContext context) {
    final String titleText = widget.landingArg == null ? _bulkMode ? 'Add Bulk' : 'Add Species' : 'Edit Species';

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Select species
                    _speciesDropdown(),
                    const SizedBox(height: 15),

                    // Weight
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: _weightInput(),
                    ),

                    // Length
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: _lengthInput(),
                    ),

                    // Individuals
                    if (_bulkMode) _individualsTextInput() else Container(),

                    // Location
                    if (isEditMode) _locationEditor(),
                    if (isEditMode) const SizedBox(height: 15),
                    // Date / time
                    if (isEditMode) _createdAtEditor(),
                  ],
                ),
              ),
            ),
          ),
          _saveStripButton(),
        ],
      ),
    );
  }
}
