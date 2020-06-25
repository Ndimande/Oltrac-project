import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/data/countries.dart';
import 'package:oltrace/data/fishery_types.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:uuid/uuid.dart';

const TextStyle _sectionHeadingTextStyle = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
  color: OlracColours.fauxPasBlue,
);

class WelcomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  FisheryType _selectedFisheryType = AppConfig.debugMode ? fisheries.first : null;
  Country _selectedCountry = AppConfig.debugMode ? countries.first : null;
  String _vesselName;
  String _vesselId;
  String _skipperFirstName;
  String _skipperLastName;

  bool isSaving = false;

  final _vesselNameFocusNode = FocusNode();
  final _vesselIdFocusNode = FocusNode();
  final _skipperFirstNameFocusNode = FocusNode();
  final _skipperLastNameFocusNode = FocusNode();

  Widget _countryDropdown() => ModelDropdown(
        label: 'Country',
        labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[600]),
        selected: _selectedCountry,
        onChanged: (Country _country) => setState(() => _selectedCountry = _country),
        items: countries.map<DropdownMenuItem<Country>>((Country country) {
          return DropdownMenuItem<Country>(
            value: country,
            child: Text(country.name),
          );
        }).toList(),
      );

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: const Image(
              image: AssetImage('assets/images/olsps-logo.png'),
              width: 100,
            ),
            alignment: Alignment.topRight,
          ),
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: Text('General', style: _sectionHeadingTextStyle),
          ),
          // Country
          Container(
            padding: const EdgeInsets.all(15),
            child: _countryDropdown(),
          ),

          // Fishery
          Container(
            padding: const EdgeInsets.all(15),
            child: ModelDropdown(
              label: 'Fishery',
              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              selected: _selectedFisheryType,
              onChanged: (FisheryType _fishery) {
                setState(() => _selectedFisheryType = _fishery);
              },
              items: fisheries
                  .map<DropdownMenuItem<FisheryType>>(
                    (FisheryType fishery) => DropdownMenuItem<FisheryType>(
                      value: fishery,
                      child: Text(fishery.safsCode),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Vessel
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Vessel', style: _sectionHeadingTextStyle),
                _buildVesselNameTextFormField(),
                _buildVesselIdTextFormField(),
              ],
            ),
          ),

          // Skipper
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Skipper', style: _sectionHeadingTextStyle),
                _buildSkipperFirstNameTextFormField(),
                _buildSkipperLastNameTextFormField(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVesselNameTextFormField() {
    return _welcomeTextFormField(
      labelText: 'Name',
      focusNode: _vesselNameFocusNode,
      onFieldSubmitted: (value) {
        _vesselNameFocusNode.unfocus();
        FocusScope.of(context).requestFocus(_vesselIdFocusNode);
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a vessel name.';
        }
        _vesselName = value;
        return null;
      },
      onChanged: (String value) => setState(() {}),
    );
  }

  Widget _buildVesselIdTextFormField() {
    return _welcomeTextFormField(
      labelText: 'ID',
      focusNode: _vesselIdFocusNode,
      onFieldSubmitted: (value) {
        _vesselIdFocusNode.unfocus();
        FocusScope.of(context).requestFocus(_skipperFirstNameFocusNode);
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a vessel ID.';
        }
        _vesselId = value;
        return null;
      },
      onChanged: (String value) => setState(() {}),
    );
  }

  Widget _buildSkipperFirstNameTextFormField() {
    return _welcomeTextFormField(
      labelText: 'First name',
      focusNode: _skipperFirstNameFocusNode,
      onFieldSubmitted: (value) {
        _skipperFirstNameFocusNode.unfocus();
        FocusScope.of(context).requestFocus(_skipperLastNameFocusNode);
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a skipper first name.';
        }
        _skipperFirstName = value;
        return null;
      },
      onChanged: (String value) => setState(() {}),
    );
  }

  Widget _buildSkipperLastNameTextFormField() {
    return _welcomeTextFormField(
      labelText: 'Last name',
      focusNode: _skipperLastNameFocusNode,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) async {
        _skipperLastNameFocusNode.unfocus();
        await _onPressSave(context);
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter a skipper last name.';
        }
        _skipperLastName = value;
        return null;
      },
      onChanged: (String value) => setState(() {}),
    );
  }

  Future<void> _onPressSave(BuildContext context) async {
    // todo redo this flow
    // Prevent double submission
    if (isSaving) {
      return;
    }
    setState(() {
      isSaving = true;
    });

    if (!_formKey.currentState.validate()) {
      setState(() {
        isSaving = false;
      });

      return;
    }

    if (_selectedFisheryType == null) {
      setState(() {
        isSaving = false;
      });

      showTextSnackBar(_scaffoldKey, 'Please select a fishery type');
      return;
    }
    if (_selectedCountry == null) {
      setState(() {
        isSaving = false;
      });

      showTextSnackBar(_scaffoldKey, 'Please select a country');
      return;
    }

    final profile = Profile(
      vesselName: _vesselName,
      vesselId: _vesselId,
      skipper: Skipper(
        firstName: _skipperFirstName,
        lastName: _skipperLastName,
      ),
      fisheryType: _selectedFisheryType,
      country: _selectedCountry,
      uuid: Uuid().v4(),
    );

    AppData.profile = profile;
    await JsonRepository().set('profile', profile);

    await Navigator.pushReplacementNamed(context, '/');
  }

  Widget _saveButton() {
    final bool allValid =
        _formKey?.currentState?.validate() == true && _selectedCountry != null && _selectedFisheryType != null;

    return StripButton(
      labelText: 'Save',
      color: allValid ? OlracColours.ninetiesGreen : Colors.grey,
      icon: const Icon(Icons.save, color: Colors.white),
      onPressed: () async => _onPressSave(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: _buildForm(),
            ),
          ),
          _saveButton(),
        ],
      ),
    );
  }
}

Widget _welcomeTextFormField({
  String labelText,
  String helperText,
  FocusNode focusNode,
  TextInputAction textInputAction = TextInputAction.next,
  void Function(String) onFieldSubmitted,
  String Function(String) validator,
  Function(String) onChanged,
}) {
  return Container(
    child: TextFormField(
      initialValue: AppConfig.debugMode ? 'DEV_MODE' : '',
      focusNode: focusNode,
      textCapitalization: TextCapitalization.words,
      autocorrect: false,
      textInputAction: textInputAction,
      style: const TextStyle(fontSize: 30),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        helperText: helperText,
      ),
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onChanged: onChanged,
    ),
  );
}
