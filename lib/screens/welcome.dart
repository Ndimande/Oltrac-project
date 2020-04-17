import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/countries.dart';
import 'package:oltrace/data/fishery_types.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:uuid/uuid.dart';

final TextStyle _sectionHeadingTextStyle = TextStyle(
  fontSize: 26,
  fontWeight: FontWeight.bold,
  color: OlracColours.olspsBlue,
);

class WelcomeScreen extends StatefulWidget {
  final AppStore _appStore = StoreProvider().appStore;

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  FisheryType _selectedFisheryType;
  Country _selectedCountry;
  String _vesselName;
  String _vesselId;
  String _skipperFirstName;
  String _skipperLastName;

  bool isSaving = false;

  final _vesselNameFocusNode = FocusNode();
  final _vesselIdFocusNode = FocusNode();
  final _skipperFirstNameFocusNode = FocusNode();
  final _skipperLastNameFocusNode = FocusNode();

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('assets/images/olsps-logo.png'),
              width: 100,
            ),
            alignment: Alignment.topRight,
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'General',
              style: _sectionHeadingTextStyle,
            ),
          ),
          // Country
          Container(
            padding: EdgeInsets.all(15),
            child: ModelDropdown(
              label: 'Country',
              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              selected: _selectedCountry,
              onChanged: (_country) => setState(() => _selectedCountry = _country),
              items: countries.map<DropdownMenuItem<Country>>((Country country) {
                return DropdownMenuItem<Country>(
                  value: country,
                  child: Text(country.name),
                );
              }).toList(),
            ),
          ),

          // todo State / Province

          // Fishery
          Container(
            padding: EdgeInsets.all(15),
            child: ModelDropdown(
              label: 'Fishery',
              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              selected: _selectedFisheryType,
              onChanged: (_fishery) {
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
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Vessel',
                  style: _sectionHeadingTextStyle,
                ),
                _buildVesselNameTextFormField(),
                _buildVesselIdTextFormField(),
              ],
            ),
          ),

          // Skipper
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Skipper',
                  style: _sectionHeadingTextStyle,
                ),
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
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a vessel name.';
        }
        _vesselName = value;
        return null;
      },
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
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a vessel ID.';
        }
        _vesselId = value;
        return null;
      },
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
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a skipper first name.';
        }
        _skipperFirstName = value;
        return null;
      },
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
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a skipper last name.';
        }
        _skipperLastName = value;
        return null;
      },
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

    await widget._appStore.saveProfile(profile);

    showTextSnackBar(_scaffoldKey, 'Profile saved');
    // Give them time to see the SnackBar
    await Future.delayed(Duration(seconds: 1));

    await Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
      ),
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: _buildForm(),
            ),
          ),
          StripButton(
            labelText: 'Save',
            color: Colors.green,
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async => _onPressSave(context),
          ),
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
  Function onFieldSubmitted,
  Function validator,
}) {
  return Container(
    child: TextFormField(
      initialValue: AppConfig.debugMode ? 'DEV_MODE' : '',
      focusNode: focusNode,
      textCapitalization: TextCapitalization.words,
      autocorrect: false,
      textInputAction: textInputAction,
      style: TextStyle(fontSize: 30),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        helperText: helperText,
      ),
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
    ),
  );
}
