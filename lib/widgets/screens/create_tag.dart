import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/tag/rfid.dart';
import 'package:oltrace/widgets/tag_scanner.dart';

class CreateTagScreen extends StatefulWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final Haul _haulArg;

  CreateTagScreen(this._haulArg);

  @override
  State<StatefulWidget> createState() => CreateTagScreenState(_haulArg);
}

class CreateTagScreenState extends State<CreateTagScreen> {
  /// The unique code of the RFID tag
  String _tagCode;

  /// Animal species to be associated with the tag.
  Species _selectedSpecies;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final geolocator = Geolocator();

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _lengthController = TextEditingController();

  final Haul _haul;

  CreateTagScreenState(this._haul);

  @override
  void initState() {
    super.initState();
    // When a tag is held to the device, read the tag
    FlutterNfcReader.onTagDiscovered().listen((NfcData onData) {
      setState(() {
        _tagCode = onData.id;
      });
    });
  }

  _onPressSaveButton(haul, context) async {
    if (_tagCode == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('No RFID has been scanned.'),
        ),
      );
      return;
    }

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

    final tag = await widget._appStore.saveTag(
      Tag(
        tagCode: _tagCode,
        species: _selectedSpecies,
        createdAt: DateTime.now(),
        location: Location.fromPosition(position),
        // kg -> g
        weight: int.parse(_weightController.value.text) * 1000,
        length: int.parse(_lengthController.value.text),
        haulId: haul.id,
      ),
    );

    bool createProductTag = await _showTagSavedDialog(tag);

    setState(() {
      _tagCode = null;
      _weightController.clear();
      _lengthController.clear();
    });

    if (createProductTag) {
      await Navigator.pushNamed(context, '/create_product', arguments: tag);
    }
  }

  Future<bool> _showTagSavedDialog(Tag tag) {
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
                'Carcass Tag for ${tag.species.englishName} (ID ${tag.tagCode}) saved!',
                style: TextStyle(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              Text(
                'Do you want to create a Product Tag from this Carcass Tag?',
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

  @override
  Widget build(BuildContext context) {
    final sortedSpecies = species;
    sortedSpecies.sort((Species a, Species b) => a.englishName.compareTo(b.englishName));

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _floatingActionButton(_haul, context),
      appBar: AppBar(
        title: Text('Haul ${_haul.id} - Create Carcass Tag'),
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
                // Tag code
                TagScanner(onScan: (String tagCode) => setState(() => _tagCode = tagCode)),
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
                          'Weight (kg)',
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
                          'Length (cm)',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
