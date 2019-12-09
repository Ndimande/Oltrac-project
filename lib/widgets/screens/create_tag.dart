import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/species.dart';
import 'package:oltrace/framework/model_dropdown.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/create_product.dart';
import 'package:oltrace/widgets/screens/tag/rfid.dart';

class CreateTagScreen extends StatefulWidget {
  final AppStore _appStore;

  CreateTagScreen(this._appStore);

  @override
  State<StatefulWidget> createState() => CreateTagScreenState();
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

  CreateTagScreenState();

  @override
  void initState() {
    super.initState();
    // When a tag is held to the device
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

    _scaffoldKey.currentState.showSnackBar(SnackBar(
//      action: SnackBarAction(
//        label: 'Create Product Tag',
//        onPressed: () async {
//          await Navigator.push(
//            context,
//            MaterialPageRoute(
//              builder: (context) => CreateProductScreen(),
//              settings: RouteSettings(
//                arguments: tag,
//              ),
//            ),
//          );
//        },
//      ),
      behavior: SnackBarBehavior.fixed,
      content: Text(
        'Tag ${tag.tagCode} saved',
      ),
    ));

    setState(() {
      _tagCode = null;
      _weightController.clear();
      _lengthController.clear();
    });
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
    final Haul haulArg = ModalRoute.of(context).settings.arguments;
    final sortedSpecies = species;
    sortedSpecies.sort((Species a, Species b) => a.englishName.compareTo(b.englishName));

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _floatingActionButton(haulArg, context),
      appBar: AppBar(
        title: Text('Haul ${haulArg.id} - Create Tag'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RFID(tagCode: _tagCode),
                    RaisedButton(
                      child: Text('Fake RFID scan'),
                      onPressed: () => setState(() => _tagCode = '0xFA7E5C46'),
                    )
                  ],
                ),

                // Select species
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: ModelDropdown<Species>(
                    label: 'Species:',
                    selected: _selectedSpecies,
                    items: sortedSpecies.map<DropdownMenuItem<Species>>(
                      (Species species) {
                        return DropdownMenuItem<Species>(
                          value: species,
                          child: Text(
                            species.englishName,
                            style: TextStyle(color: AppConfig.textColor1),
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
